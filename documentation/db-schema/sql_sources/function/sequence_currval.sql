-- created by Oraschemadoc Tue Jul 19 17:31:35 2011
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FUNCTION "SPACEWALK"."SEQUENCE_CURRVAL" ( seq_name varchar2 ) return number as
	ret number;
begin
	execute immediate 'select '|| seq_name || '.currval from dual'
		into ret;
	return ret;
end;
 
/
