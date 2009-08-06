
update rhnUserGroupType
set name = 'Spacewalk Support Administrator'
where label = 'rhn_support';

update rhnUserGroupType
set name = 'Spacewalk Superuser'
where label = 'rhn_superuser';

