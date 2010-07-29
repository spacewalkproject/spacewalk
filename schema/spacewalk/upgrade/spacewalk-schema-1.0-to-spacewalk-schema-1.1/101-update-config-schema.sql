--
-- Copyright (c) 2008 Red Hat, Inc.
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

alter table rhnConfigInfo add SYMLINK_TARGET_FILENAME_ID NUMBER
                CONSTRAINT rhn_confinfo_symlink_fk
                    REFERENCES rhnConfigFileName (id);
alter table rhnConfigInfo modify username  NULL;
alter table rhnConfigInfo modify groupname  NULL;
alter table rhnConfigInfo modify filemode  NULL;
drop index rhn_confinfo_ugf_uq;
CREATE UNIQUE INDEX rhn_confinfo_ugf_uq
    ON rhnConfigInfo (username, groupname, filemode, selinux_ctx, symlink_target_filename_id);


alter table rhnConfigContent     add delim_start    VARCHAR2(16);
alter table rhnConfigContent     add delim_end      VARCHAR2(16);

DECLARE
     CURSOR config_content_delimeters is
       select CONFIG_CONTENT_ID, DELIM_START, DELIM_END 
        from rhnConfigRevision;
BEGIN
  FOR content IN config_content_delimeters
  LOOP
      update rhnConfigContent set DELIM_START = content.DELIM_START
        where id = content.CONFIG_CONTENT_ID;
        
      update rhnConfigContent set DELIM_END = content.DELIM_END
        where id = content.CONFIG_CONTENT_ID;        

  END LOOP;
  commit;
END;


alter table rhnConfigContent modify delim_start   not null;
alter table rhnConfigContent modify delim_end     not null;

alter table rhnConfigRevision modify config_content_id  NULL;
alter table rhnConfigRevision drop column delim_start;
alter table rhnConfigRevision drop column delim_end;

update rhnConfigRevision set CONFIG_CONTENT_ID = null 
    where CONFIG_CONTENT_ID in
    (select cr.CONFIG_CONTENT_ID 
        from rhnConfigRevision cr 
                inner join rhnConfigFileType cft on cft.id = cr.config_file_type_id and cft.label ='directory');

delete from rhnConfigContent where id not in 
    (select CONFIG_CONTENT_ID from rhnConfigRevision cr where CONFIG_CONTENT_ID is not null);

