-- $Id$
-- EXCLUDE: all
--
-- depsolver that can be shared between web/backend/sql/whatever
--

create or replace package body
rhn_depsolver
as
	rd_server_id number;
	rd_client_version number;

	function get_solver_instance_id
	return number is
	begin
		return rd_solver_instance_id;
	end;

	procedure set_solver_instance_id(
		solver_instance_id_in in number
	) is
	begin
		rd_solver_instance_id := solver_instance_id_in;
	end;

	function init(
		server_id_in in number,
		client_version_in in number
	) return number is
	begin
		select	rhn_solver_instance_id_seq.nextval
		into	rd_solver_instance_id
		from	dual;

		rd_server_id := server_id_in;
		rd_client_version := client_version_in;

		return rd_solver_instance_id;
	end;

	procedure add_dep(
		name_in in varchar2
	) is
	begin
		insert into rhnSolverDeps(solver_instance_id, name)
			values (rd_solver_instance_id, name_in);
	end;

	procedure finalize_results is
		cursor results is
			select	srp.rowid, srp.name, srp.preference, pn.name package_name
			from	rhnPackageName pn,
					rhnSolverResultsPrivate srp
			where	srp.solver_instance_id = rd_solver_instance_id
					and srp.name_id = pn.id
			order by srp.name, srp.preference asc;
		last_name varchar2(256) := null;
		candidate_name varchar2(256) := null;
		candidate rowid;
	begin
		for result in results loop
			if last_name is null then
				last_name := result.name;
			end if;
			if last_name = result.name then
				-- if we don't have an answer yet, compat is ok
				-- otherwise, whatever we've got is better than compat
				if candidate_name is null
						or (substr(result.package_name,0,7) != 'comapt-' and
							substr(candidate_name,0,7) != 'compat-') then
					candidate_name := result.package_name;
					candidate := result.rowid;
				end if;
			end if;
			if last_name != result.name then
				-- mark the candidate as final
				update rhnSolverResultsPrivate
					set final = 'Y'
					where rowid = candidate;

				-- a different dep than the last, reset our state
				-- to reflect that
				last_name := result.name;
				candidate_name := result.package_name;
				candidate := result.rowid;
			end if;
		end loop;
	end finalize_results;

	procedure find_by_files is
	begin
		insert into rhnSolverResultsPrivate (
			solver_instance_id, final, name, name_id, evr_id, preference
		)
		select distinct
			d.solver_instance_id,
			'N',
			d.name name,
			p.name_id,
			p.evr_id,
			3 preference
		from
			rhnServerChannel sc,
			rhnChannelPackage cp,
			rhnPackageFile f,
			rhnPackage p,
			rhnPackageCapability cap,
			rhnSolverDeps d,
			rhnPackageEVR pe
		where
			sc.server_id = rd_server_id
		and sc.channel_id = cp.channel_id
		and cp.package_id = p.id
		and cp.package_id = f.package_id
		and f.capability_id = cap.id
		and d.solver_instance_id = rd_solver_instance_id
		and cap.name = d.name
		and p.evr_id = pe.id
		-- and this package is the latest one from all the channels
		-- this server is subscribed to.
		and pe.evr = (
			select MAX(pe1.evr)
			from
				rhnPackage p1,
				rhnPackageEVR pe1,
				rhnServerChannel sc1,
				rhnChannelPackage cp1
			where
				sc1.server_id = rd_server_id
			and sc1.channel_id = cp1.channel_id
			and cp1.package_id = p1.id
			and p1.name_id = p.name_id
			and p1.evr_id = pe1.id
		);
	end find_by_files;

	procedure find_by_provides is
	begin
		insert into rhnSolverResultsPrivate (
			solver_instance_id, final, name, name_id, evr_id, preference
		)
		select  distinct
			d.solver_instance_id,
			'N',
			d.name name,
			p.name_id,
			p.evr_id,
			2 preference
		from
			rhnServerChannel sc,
			rhnChannelPackage cp,
			rhnPackageProvides pr,
			rhnPackage p,
			rhnSolverDeps d,
			rhnPackageCapability cap,
			rhnPackageEVR pe
		where
			sc.server_id = rd_server_id
		and sc.channel_id = cp.channel_id
		and cp.package_id = p.id
		and cp.package_id = pr.package_id
		and pr.package_id = p.id
		and pr.capability_id = cap.id
		and d.solver_instance_id = rd_solver_instance_id
		and cap.name = d.name
		and p.evr_id = pe.id
		-- and this package is the latest one from all the channels
		-- this server is subscribed to.
		and pe.evr = (
			select MAX(pe1.evr)
			from
				rhnPackage p1,
				rhnPackageEVR pe1,
				rhnServerChannel sc1,
				rhnChannelPackage cp1
			where
				sc1.server_id = rd_server_id
			and sc1.channel_id = cp1.channel_id
			and cp1.package_id = p1.id
			and p1.name_id = p.name_id
			and p1.evr_id = pe1.id
		);			
	end;

	procedure find_by_packages is
	begin
		insert into rhnSolverResultsPrivate (
			solver_instance_id, final, name, name_id, evr_id, preference
		)
		select distinct
			d.solver_instance_id,
			'N',
			d.name name,
			p.name_id,
			p.evr_id,
			1 preference
		from
			rhnPackage p,
			rhnPackageName pn,
			rhnSolverDeps d,
			rhnPackageEvr pe,
			rhnServerChannel sc,
			rhnChannelPackage cp
		where
			p.name_id = pn.id
		and p.evr_id = pe.id
		and p.id = cp.package_id
		and cp.channel_id = sc.channel_id
		and sc.server_id = rd_server_id
		and d.solver_instance_id = rd_solver_instance_id
		and pn.name = d.name
		and pe.evr = (
			select MAX(pe1.evr)
			from
				rhnPackage p1,
				rhnPackageEVR pe1,
				rhnServerChannel sc1,
				rhnChannelPackage cp1
			where
				sc1.server_id = rd_server_id
			and sc1.channel_id = cp1.channel_id
			and cp1.package_id = p1.id
			and p1.name_id = pn.id
			and p1.evr_id = pe1.id
		);
	end;

	procedure solve_dependencies is
	begin
		rhn_depsolver.find_by_packages();
		rhn_depsolver.find_by_provides();
		rhn_depsolver.find_by_files();
	end solve_dependencies;

	procedure cleanup is
	begin
		delete
			from	rhnSolverResultsPrivate
			where	solver_instance_id = rd_solver_instance_id;
		delete
			from	rhnSolverDeps
			where	solver_instance_id = rd_solver_instance_id;
	end cleanup;
end rhn_depsolver;
/
show errors

--
-- $Log$
-- Revision 1.1  2003/10/10 20:37:43  pjones
-- bugzilla: none
--
-- this solves for provides; not a full depsolver yet, but I'm
-- tired of it rattling around on my disk when it should be in CVS,
-- so I'm checking it in ;)
--
