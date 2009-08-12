-- Change columns to numeric 12 to match the columns of their foreign keys.
alter table rhn_contact_group_members modify(contact_group_id NUMBER(12));
alter table rhn_contact_group_members modify(member_contact_method_id NUMBER(12));
alter table rhn_contact_group_members modify(member_contact_group_id NUMBER(12));
alter table rhn_ll_netsaint modify(netsaint_id NUMBER(12));
alter table rhn_probe_param_value modify(probe_id NUMBER(12));
alter table rhn_probe_param_value modify(command_id NUMBER(12));

