
delete from rhn_contact_groups
where not exists (
	select 1
	from rhn_contact_group_members
	where rhn_contact_groups.recid = contact_group_id
	);

