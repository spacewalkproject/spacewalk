-- oracle equivalent source sha1 c0e5c5c9d66bb05c209006ce834cebefc48f732e
--
-- Copyright (c) 2017 Red Hat, Inc.
--
-- This software is licensed to you under the GNU General Public License,
-- version 2 (GPLv2). There is NO WARRANTY for this software, express or
-- implied, including the implied warranties of MERCHANTABILITY or FITNESS
-- FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
-- along with this software; if not, see
-- http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
--
-- Red Hat trademarks are not licensed under GPLv2. No permission is
-- granted to use or replicate Red Hat trademarks that are incorporated
-- in this software or its documentation.
--
-- We have to fix rhnConfigInfo in the presence of dups (and the rhnCOnfigRevisions that
-- might be pointing at them)
-- Clean up table, and then create corrected postgresql indicies to prevent dups
-- in the future
--
-- FOUR CASES:
--  Cfg-file is a FILE - username/groupname/filemode are NOT NULL, symlink_target_filename_id IS NULL, AND:
--    selinux_ctx IS NULL
--    selinux_ctx IS NOT NULL
--  Cfg-file is a LINK - username/groupname/filemode ARE ALL NULL, AND symlink_target_filename_id is NOT NULL, AND:
--    selinux_ctx NULL
--    selinux_ctx IS NOT NULL
--
-- Check all FOUR - if ANY show multiple rows, table is broken :(
--
create or replace function
is_cfginfo_broken() returns boolean
as
$$
declare
    throwaway       numeric;
    bad_data_exists boolean := false;
begin
    -- (1) Count username, groupname, filemode combinations where
    --     selinux_ctx is null
    select 1 into throwaway
    from (
        select username, groupname, filemode, count(id) as num
          from rhnConfigInfo
         where username is not null and groupname is not null and filemode is not null
           and symlink_target_filename_id is null and selinux_ctx is null
         group by username, groupname, filemode
    ) x
    where x.num > 1;

    if found then
        raise info 'DUP FILE INFO found, selinux NULL';
        bad_data_exists := true;
    end if;

    -- (2) Count username, groupname, filemode, selinux_ctx combinations where
    --     selinux is not null
    select 1 into throwaway
    from (
        select username, groupname, filemode, selinux_ctx, count(id) as num
          from rhnConfigInfo
         where username is not null and groupname is not null and filemode is not null
           and symlink_target_filename_id is null and selinux_ctx is not null
         group by username, groupname, filemode, selinux_ctx
    ) x
    where x.num > 1;

    if found then
        raise info 'DUP FILE INFO found, selinux is NOT NULL';
        bad_data_exists := true;
    end if;

    -- (3) Count symlink_target_filename_id combinations
    --     where username, groupname, filemode are null and selinux_ctx is null
    select 1 into throwaway
    from (
        select symlink_target_filename_id, count(id) as num
          from rhnConfigInfo
         where symlink_target_filename_id is not null
           and username is null and groupname is null and filemode is null
           and selinux_ctx is null
         group by symlink_target_filename_id
    ) x
    where x.num > 1;

    if found then
        raise info 'DUP LINK INFO found, selinux IS NULL';
        bad_data_exists := true;
    end if;

    -- (4) Count symlink_target_filename_id combinations
    --     where username, groupname, filemode are null and selinux_ctx IS NOT null
    select 1 into throwaway
    from (
        select symlink_target_filename_id, count(id) as num
          from rhnConfigInfo
         where symlink_target_filename_id is not null
           and username is null and groupname is null and filemode is null
           and selinux_ctx is not null
         group by symlink_target_filename_id
    ) x
    where x.num > 1;

    if found then
        raise info 'DUP LINK INFO found, selinux NOT NULL';
        bad_data_exists := true;
    end if;

    return bad_data_exists;
end
$$
language plpgsql;

--
-- Fix rhnConfigRevision pointers into rhnConfigInfo where there are dups
--  Cfg-file is a FILE - username/groupname/filemode are NOT NULL, AND symlink_target_filename_id NULL, AND:
--    fix_cfgrev_files_SELINUX_NULL     : selinux_ctx NULL
--    fix_cfgrev_files_SELINUX_NOT_NULL : selinux_ctx NOT NULL
--  Cfg-file is a LINK - username/groupname/filemode ARE ALL NULL, AND symlink_target_filename_id is NOT NULL, AND:
--    fix_cfgrev_links_SELINUX_NULL     : selinux_ctx NULL
--    fix_cfgrev_links_SELINUX_NOT_NULL : selinux_ctx NOT NULL
--
-- (The following is Ugly Repetitive Code - but it's one-use-only and gets the job done in the most obvious way possible)
--
create or replace function
fix_cfgrev_files_SELINUX_NULL() returns void
as
$$
declare
    d record;
    first_time      boolean               := true;
    good_cfginfo_id numeric               := -1;
    good_username   character varying(32) := '';
    good_groupname  character varying(32) := '';
    good_filemode   numeric               := -1;
begin
    for d in
        -- Find the cardinality of the IDs of the dups
        -- We will remember the most-used rhnConfigInfo.id, and repoint rhnConfigRevisions at it
        SELECT z.id as dup_cfginfo_id, z.username, z.groupname, z.filemode, count(crev.id) as num_rhnConfigRevision_using
        from (
            -- Find the IDs of the dups
            SELECT ci.id, ci.username, ci.groupname, ci.filemode
              from rhnConfigInfo ci
                   inner join (
			-- Find just the ones that are dups
			SELECT x.username, x.groupname, x.filemode, x.num
			from (
			    -- Count username,groupname,filemode combinations where symlink_target_filename_id and selinux_ctx are null
			    select username, groupname, filemode, count(id) as num
			      from rhnConfigInfo
			     where symlink_target_filename_id is null and selinux_ctx is null
			     group by username, groupname, filemode
			     ) x
			where x.num > 1
		    ) y on y.username = ci.username and y.groupname = ci.groupname and y.filemode = ci.filemode
             where 1=1
               and ci.symlink_target_filename_id is null and ci.selinux_ctx is null
             order by username, groupname, filemode, id
        ) z
        left outer join rhnConfigRevision crev on crev.config_info_id = z.id
        group by z.id, z.username, z.groupname, z.filemode
        order by z.username, z.groupname, z.filemode, count(crev.id) desc, z.id
    loop
        -- First time in, or when we move to a new kind-of dup, remember that one
        if first_time or (d.username <> good_username or d.groupname <> good_groupname or d.filemode <> good_filemode)
        then
            first_time := false;
            -- Remember the 'good values' so we can tell when we've moved to a new set in the dataresult
            good_cfginfo_id := d.dup_cfginfo_id;
            good_username   := d.username;
            good_groupname  := d.groupname;
            good_filemode   := d.filemode;
        -- we have seen this one before - repoint users at 'good' and remove this one
        else
            if d.num_rhnconfigrevision_using > 0
            then
                raise info '...REPOINTING RECORDS, rhnConfigInfo = %',d.dup_cfginfo_id;
                UPDATE rhnConfigRevision
                   set config_info_id = good_cfginfo_id
                 where config_info_id = d.dup_cfginfo_id;
            end if;
            DELETE from rhnConfigInfo ci
             where 1=1
               and ci.username = good_username
               and ci.groupname = good_groupname
               and ci.filemode = good_filemode
               and ci.selinux_ctx is null
               and ci.id <> good_cfginfo_id;
        end if;
    end loop;
end
$$
language plpgsql;

create or replace function
fix_cfgrev_files_SELINUX_NOT_NULL() returns void
as
$$
declare
    d record;
    first_time       boolean               := true;
    good_cfginfo_id  numeric               := -1;
    good_username    character varying(32) := '';
    good_groupname   character varying(32) := '';
    good_selinux_ctx character varying(64) := '';
    good_filemode    numeric               := -1;
begin
    for d in
        -- Find the cardinality of the IDs of the dups
        -- We will remember the most-used rhnConfigInfo.id, and repoint rhnConfigRevisions at it
        SELECT z.id as dup_cfginfo_id, z.username, z.groupname, z.filemode, z.selinux_ctx, count(crev.id) as num_rhnConfigRevision_using
        from (
            -- Find the IDs of the dups
            SELECT ci.id, ci.username, ci.groupname, ci.filemode, ci.selinux_ctx
              from rhnConfigInfo ci
                   inner join (
			-- Find just the ones that are dups
			SELECT x.username, x.groupname, x.filemode, x.selinux_ctx, x.num
			from (
			    -- Count username,groupname,filemode combinations where symlink_target_filename_id and selinux_ctx are null
			    select username, groupname, filemode, selinux_ctx, count(id) as num
			      from rhnConfigInfo
			     where symlink_target_filename_id is null and selinux_ctx is not null
			     group by username, groupname, filemode, selinux_ctx
			     ) x
			where x.num > 1
		    ) y on y.username = ci.username and y.groupname = ci.groupname and y.filemode = ci.filemode and y.selinux_ctx = ci.selinux_ctx
             where 1=1
               and ci.symlink_target_filename_id is null and ci.selinux_ctx is not null
             order by username, groupname, filemode, selinux_ctx, id
        ) z
        left outer join rhnConfigRevision crev on crev.config_info_id = z.id
        group by z.id, z.username, z.groupname, z.filemode, z.selinux_ctx
        order by z.username, z.groupname, z.filemode, z.selinux_ctx, count(crev.id) desc, z.id
    loop
        -- First time in, or when we move to a new kind-of dup, remember that one
        if first_time or (d.username <> good_username or d.groupname <> good_groupname or d.filemode <> good_filemode)
        then
            first_time := false;
            -- Remember the 'good values' so we can tell when we've moved to a new set in the dataresult
            good_cfginfo_id  := d.dup_cfginfo_id;
            good_username    := d.username;
            good_groupname   := d.groupname;
            good_filemode    := d.filemode;
            good_selinux_ctx := d.selinux_ctx;
        -- we have seen this one before - repoint users at 'good' and remove this one
        else
            if d.num_rhnconfigrevision_using > 0
            then
                raise info '...REPOINTING RECORDS, rhnConfigInfo = %',d.dup_cfginfo_id;
                UPDATE rhnConfigRevision
                   set config_info_id = good_cfginfo_id
                 where config_info_id = d.dup_cfginfo_id;
            end if;
            DELETE from rhnConfigInfo ci
             where 1=1
               and ci.username = good_username
               and ci.groupname = good_groupname
               and ci.filemode = good_filemode
               and ci.selinux_ctx = good_selinux_ctx
               and ci.id <> good_cfginfo_id;
        end if;
    end loop;
end
$$
language plpgsql;

create or replace function
fix_cfgrev_links_SELINUX_NOT_NULL() returns void
as
$$
declare
    d record;
    first_time                      boolean               := true;
    good_cfginfo_id                 numeric               := -1;
    good_symlink_target_filename_id numeric               := -1;
    good_selinux_ctx                character varying(64) := null;
begin
    for d in
        -- Find the cardinality of the IDs of the dups
        -- We will remember the most-used rhnConfigInfo.id, and repoint rhnConfigRevisions at it
        SELECT z.id as dup_cfginfo_id, z.symlink_target_filename_id, z.selinux_ctx, count(crev.id) as num_rhnConfigRevision_using
        from (
            -- Find the IDs of the dups
            SELECT ci.id, ci.symlink_target_filename_id, ci.selinux_ctx
              from rhnConfigInfo ci
                   inner join (
			-- Find just the ones that are dups
			SELECT x.symlink_target_filename_id, x.selinux_ctx, x.num
			from (
			    -- Count where symlink_target_filename_id is not null and selinux_ctx is not null
			    select symlink_target_filename_id, selinux_ctx, count(id) as num
			      from rhnConfigInfo
			     where username is null
                               and groupname is null
                               and filemode is null
                               and symlink_target_filename_id is not null
                               and selinux_ctx is not null
			     group by symlink_target_filename_id, selinux_ctx
			     ) x
			where x.num > 1
		    ) y on y.symlink_target_filename_id = ci.symlink_target_filename_id and y.selinux_ctx = ci.selinux_ctx
             where 1=1
               and ci.symlink_target_filename_id is not null and ci.selinux_ctx is not null
             order by symlink_target_filename_id, selinux_ctx, id
        ) z
        left outer join rhnConfigRevision crev on crev.config_info_id = z.id
        group by z.id, z.symlink_target_filename_id, z.selinux_ctx
        order by z.symlink_target_filename_id, z.selinux_ctx, count(crev.id) desc, z.id
    loop
        -- First time in, or when we move to a new kind-of dup, remember that one
        if first_time or (d.symlink_target_filename_id <> good_symlink_target_filename_id or d.selinux_ctx <> good_selinux_ctx)
        then
            first_time := false;
            -- Remember the 'good values' so we can tell when we've moved to a new set in the dataresult
            good_cfginfo_id                 := d.dup_cfginfo_id;
            good_symlink_target_filename_id := d.symlink_target_filename_id;
            good_selinux_ctx                := d.selinux_ctx;
        -- we have seen this one before - repoint users at 'good' and remove this one
        else
            if d.num_rhnconfigrevision_using > 0
            then
                raise info '...REPOINTING RECORDS, rhnConfigInfo = %',d.dup_cfginfo_id;
                UPDATE rhnConfigRevision
                   set config_info_id = good_cfginfo_id
                 where config_info_id = d.dup_cfginfo_id;
            end if;
            DELETE from rhnConfigInfo ci
             where 1=1
               and ci.symlink_target_filename_id = good_symlink_target_filename_id
               and ci.selinux_ctx                = good_selinux_ctx
               and ci.id <> good_cfginfo_id;
        end if;
    end loop;
end
$$
language plpgsql;

create or replace function
fix_cfgrev_links_SELINUX_NULL() returns void
as
$$
declare
    d record;
    first_time      boolean                 := true;
    good_cfginfo_id numeric                 := -1;
    good_symlink_target_filename_id numeric := -1;
begin
    raise info 'ENTERING fix_cfgrev_links_SELINUX_NULL';
    for d in
        -- Find the cardinality of the IDs of the dups
        -- We will remember the most-used rhnConfigInfo.id, and repoint rhnConfigRevisions at it
        SELECT z.id as dup_cfginfo_id, z.symlink_target_filename_id, count(crev.id) as num_rhnConfigRevision_using
        from (
            -- Find the IDs of the dups
            SELECT ci.id, ci.symlink_target_filename_id
              from rhnConfigInfo ci
                   inner join (
			-- Find just the ones that are dups
			SELECT x.symlink_target_filename_id, x.num
			from (
			    -- Count where symlink_target_filename_id is not null and selinux_ctx is null
			    select symlink_target_filename_id, count(id) as num
			      from rhnConfigInfo
			     where username is null
                               and groupname is null
                               and filemode is null
                               and symlink_target_filename_id is not null
                               and selinux_ctx is null
			     group by symlink_target_filename_id
			     ) x
			where x.num > 1
		    ) y on y.symlink_target_filename_id = ci.symlink_target_filename_id
             where 1=1
               and ci.symlink_target_filename_id is not null and ci.selinux_ctx is null
             order by symlink_target_filename_id, id
        ) z
        left outer join rhnConfigRevision crev on crev.config_info_id = z.id
        group by z.id, z.symlink_target_filename_id
        order by z.symlink_target_filename_id, count(crev.id) desc, z.id
    loop
        -- First time in, or when we move to a new kind-of dup, remember that one
        if first_time or (d.symlink_target_filename_id <> good_symlink_target_filename_id)
        then
            raise info '...NEW GOOD rhnConfigInfo = %',d.dup_cfginfo_id;
            first_time := false;
            -- Remember the 'good values' so we can tell when we've moved to a new set in the dataresult
            good_cfginfo_id                 := d.dup_cfginfo_id;
            good_symlink_target_filename_id := d.symlink_target_filename_id;
        -- we have seen this one before - repoint users at 'good' and remove this one
        else
            if d.num_rhnconfigrevision_using > 0
            then
                raise info '...REPOINTING RECORDS, rhnConfigInfo = %',d.dup_cfginfo_id;
                UPDATE rhnConfigRevision
                   set config_info_id = good_cfginfo_id
                 where config_info_id = d.dup_cfginfo_id;
            end if;
            DELETE from rhnConfigInfo ci
             where 1=1
               and ci.symlink_target_filename_id = good_symlink_target_filename_id
               and ci.selinux_ctx                is null
               and ci.id <> good_cfginfo_id;
        end if;
    end loop;
    raise info 'EXITING fix_cfgrev_links_SELINUX_NULL';
end
$$
language plpgsql;

create or replace function
fix_cfgrev_files() returns void
as
$$
declare
 throwaway character varying(32);
 is_broken boolean := false;
begin
  select is_cfginfo_broken() into is_broken;
  if is_broken then
    select fix_cfgrev_files_SELINUX_NOT_NULL() into throwaway;
    select fix_cfgrev_files_SELINUX_NULL() into throwaway;
    select fix_cfgrev_links_SELINUX_NOT_NULL() into throwaway;
    select fix_cfgrev_links_SELINUX_NULL() into throwaway;
  end if;
end
$$
language plpgsql;

-- FOUR CASES:
-- u|g|f-not  link-null selinux-null
-- u|g|f-not  link-null selinux-not
-- u|g|f null link-not  selinux-not
-- u|g|f null link-not  selinux-null

-- Fix potential dups
select fix_cfgrev_files();

-- Drop no-longer-necessary functions
drop function if exists fix_cfgrev_files();
drop function if exists is_cfginfo_broken();
drop function if exists fix_cfgrev_files_SELINUX_NOT_NULL();
drop function if exists fix_cfgrev_files_SELINUX_NULL();
drop function if exists fix_cfgrev_links_SELINUX_NOT_NULL();
drop function if exists fix_cfgrev_links_SELINUX_NULL();

-- Make adding new indices idempotent
drop index if exists rhn_confinfo_ugf_uq;
drop index if exists rhn_confinfo_ugf_se_uq;
drop index if exists rhn_confinfo_s_uq;
drop index if exists rhn_confinfo_s_se_uq;

-- Create correct multiple indices to handle null-column cases
create unique index rhn_confinfo_ugf_uq
    on rhnConfigInfo (username, groupname, filemode)
where username is not null and groupname is not null and filemode is not null
  and selinux_ctx is null and symlink_target_filename_id is null;

create unique index rhn_confinfo_ugf_se_uq
    on rhnConfigInfo (username, groupname, filemode, selinux_ctx)
where username is not null and groupname is not null and filemode is not null
  and selinux_ctx is not null and symlink_target_filename_id is null;

create unique index rhn_confinfo_s_uq
    on rhnConfigInfo (symlink_target_filename_id)
where username is null and groupname is null and filemode is null
  and selinux_ctx is null and symlink_target_filename_id is not null;

create unique index rhn_confinfo_s_se_uq
    on rhnConfigInfo (symlink_target_filename_id, selinux_ctx)
where username is null and groupname is null and filemode is null
  and selinux_ctx is not null and symlink_target_filename_id is not null;
