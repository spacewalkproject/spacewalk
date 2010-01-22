-- created by Oraschemadoc Fri Jan 22 13:41:03 2010
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FUNCTION "MIM_H1"."LOOKUP_FIRST_MATCHING_CF" (
	server_id_in in number,
	path_in in varchar2
) return number is
	retval number := -1;
begin
	begin
		select	a.cfid
		into	retval
		from	(
			select	b.cfid,
				rownum rn
			from (
				-- We don't need to test latest any more,
				-- because we're not looking for a revision at
				-- all, just the file with the right path
				select	cf.id cfid
				from	rhnConfigFile		cf,
					rhnConfigFileName	cfn,
					rhnConfigChannel	cc,
					rhnServerConfigChannel	scc
				where	scc.server_id = server_id_in
					and scc.config_channel_id = cc.id
					and cc.id = cf.config_channel_id
					and cf.state_id != lookup_cf_state('dead')
					and cfn.path = path_in
					and cf.config_file_name_id = cfn.id
				order by scc.position asc
				) b
			) a
		where a.rn = 1;
	exception
		when no_data_found then
			null;
	end;
	return retval;
end lookup_first_matching_cf;
 
/
