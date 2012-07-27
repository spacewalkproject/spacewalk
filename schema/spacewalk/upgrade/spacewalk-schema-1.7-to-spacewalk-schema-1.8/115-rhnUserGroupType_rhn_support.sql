DELETE FROM rhnUserGroupMembers WHERE user_group_id IN (SELECT g.id from rhnUserGroup g JOIN rhnUserGroupType gt ON g.group_type = gt.id WHERE gt.label = 'rhn_support');

DELETE FROM rhnUserGroup WHERE group_type IN (SELECT id FROM rhnUserGroupType WHERE label = 'rhn_support');

DELETE FROM rhnUserGroupType WHERE label = 'rhn_support';
