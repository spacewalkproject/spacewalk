--
--$Id$
--

--create special command_queue_instances synonyms for monitoring backend code to function as is

create or replace synonym command_queue_instances for rhn_command_queue_instances;
create or replace synonym command_q_instance_recid_seq for rhn_command_q_inst_recid_seq;

--
--$Log$
--Revision 1.1  2004/06/23 15:01:07  kja
--bugzilla 126465 -- fix synonyms for monitoring backend
--
--
