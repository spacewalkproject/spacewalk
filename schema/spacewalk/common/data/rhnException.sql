--
-- Copyright (c) 2008--2013 Red Hat, Inc.
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
--
--
--
-- data for rhnException

insert into rhnException values (-20002, 'testing_error', 'An error used for testing and testing only');

insert into rhnException values (-20100, 'channel_no_parent_subscription', 'A server must be subscribed to the parent channel to subscribe to the child channel');
insert into rhnException values (-20101, 'channel_must_subscribe_to_parent', 'A server must be subscribed to all parents of all children');
insert into rhnException values (-20102, 'channel_server_one_base', 'A server can be subscribed to at most one base channel');

insert into rhnException values (-20200, 'usergroup_max_members', 'User group membership cannot exceed maximum membership');

insert into rhnException values (-20230, 'ugm_different_orgs', 'User and usergroup must be in same group to make a user a member');
insert into rhnException values (-20231, 'sgm_different_orgs', 'Server and servergroup must be in same group to make a server a member');
insert into rhnException values (-20232, 'no_org_admin_group', 'Organization has no org_admin usergroup');
insert into rhnException values (-20233, 'sg_delete_typed', 'Special server groups (non-null group_type) cannot be deleted');
insert into rhnException values (-20234, 'ug_delete_typed', 'Special user groups (non-null group_type) cannot be deleted');

insert into rhnException values (-20236, 'channel_subscribe_no_family', 'Attempt to subscribe to a channel with no family');

insert into rhnException values (-20237, 'invalid_enterprise_flag','Enterprise flag must be Y or N');

insert into rhnException values (-20238, 'channel_unsubscribe_no_family','Attempt to unsubscribe from a channel with no family');
insert into rhnException values (-20239, 'arch_not_found','Architecture could not be found');

insert into rhnException values (-20240, 'channel_consent_no_license','No license agreement exists for that channel');
insert into rhnException values (-20241, 'channel_subscrib_no_consent','Channel requires consent to license for subscription');

insert into rhnException values (-20242, 'channel_arch_not_found','Channel architecture could not be found');
insert into rhnException values (-20243, 'package_arch_not_found','Package architecture could not be found');
insert into rhnException values (-20244, 'server_arch_not_found','Server architecture could not be found');
insert into rhnException values (-20245, 'cpu_arch_not_found','CPU architecture could not be found');

insert into rhnException values (-20246, 'channel_unsubscribe_child_exists','Unsubscribe failed because server is subscribed to child channels');

insert into rhnException values (-20247, 'null_email_address','A user must have either a pending or a validated email address');

insert into rhnException values (-20248, 'invalid_item_code','The specified item does not exist');
insert into rhnException values (-20249, 'invalid_server_group','The specified server group does not exist');

insert into rhnException values (-20251, 'invalid_state','The specified state does not exist');
insert into rhnException values (-20253, 'invalid_state_transition','The specified transition is not allowed');
insert into rhnException values (-20254, 'ep_error','Entitlement Proxy error');
insert into rhnException values (-20255, 'cannot_delete_user','The specified user may not be deleted.');
insert into rhnException values (-20256, 'no_channel_product','No products were found to entitle this channel');
insert into rhnException values (-20257, 'no_server_multiple_swmgr_entitlements','Server is already entitled');
insert into rhnException values (-20258, 'erratafile_type_not_found','No such errata file type exists');
insert into rhnException values (-20259, 'invalid_quantity','Number fields may not be null');
insert into rhnException values (-20260, 'invalid_operation','The operation specified is not supported');
insert into rhnException values (-20261, 'sgm_insert_diff_orgs','Server does not belong to same org as server_group');
insert into rhnException values (-20262, 'invalid_transaction_operation', 'Invalid transaction operation');
insert into rhnException values (-20263, 'no_subscribe_permissions','Insufficient permissions for subscription');
insert into rhnException values (-20264, 'invalid_user_group','The specified user group does not exist');
insert into rhnException values (-20265, 'invalid_snapshot_invalid_reason','The specified reason for snapshot invalidation does not exist');
insert into rhnException values (-20266, 'action_is_child','The specified action is in a chain, but is not the first action in the chain');
insert into rhnException values (-20267, 'not_enough_quota','Insufficient available quota for the specified action');
insert into rhnException values (-20268, 'server_not_in_group','The specified server is not a member of the specified group');
insert into rhnException values (-20269, 'servergroup_use_upgrade', 'The specified server group is full, upgrades are available');
insert into rhnException values (-20270, 'invalid_upgrade', 'The specified server cannot be upgraded from management to provisioning');
insert into rhnException values (-20271, 'arch_type_not_found','Architecture type could not be found');
insert into rhnException values (-20272, 'mismatching_entitlement', 'The server architecture does not match the specified entitlement level');
insert into rhnException values (-20273, 'usgp_different_orgs', 'User and servergroup must be in same org in order to add this permission');
insert into rhnException values (-20274, 'usgp_already_allowed', 'The specified user already has permissions for this server group');
insert into rhnException values (-20275, 'usgp_not_allowed', 'The specified user does not have permissions for this server group');
insert into rhnException values (-20276, 'product_not_registered', 'The specified item is not registered to this customer');
insert into rhnException values (-20277, 'product_no_service', 'This product grants no services');
insert into rhnException values (-20278, 'webreg_duplicate', 'Registration number is already registered');
insert into rhnException values (-20279, 'webreg_not_active', 'Registration number is not active');
insert into rhnException values (-20280, 'webreg_sync_error', 'Error synchronizing, xxrh_oai_wrapper.sync_registration_uber');
insert into rhnException values (-20281, 'webreg_not_found', 'Registration number does not exist');
insert into rhnException values (-20282, 'webreg_unkown_error', 'Unknown error during web registration');
insert into rhnException values (-20283, 'invalid_feature', 'The specified feature does not exist');
insert into rhnException values (-20284, 'invalid_base_entitlement', 'The base entitlement is not valid for adding on other entitlements'); 
insert into rhnException values (-20285, 'invalid_addon_entitlement', 'The addon entitlement is not valid for adding onto other entitlements'); 
insert into rhnException values (-20286, 'no_available_server_group', 'The server can be entitled to that entitlement, but no valid server group was found');
insert into rhnException values (-20287, 'invalid_entitlement', 'The server can not be entitled to the specified level'); 
insert into rhnException values (-20288, 'invalid_server_group_member', 'The specified entitlement can not be removed from the specified server because the server does not have that entitlement level');

insert into rhnException
values (-20291,
        'cannot_delete_base_org',
        'You cannot delete the base org.');
insert into rhnException values (-20292, 'package_provider_not_found', 'The specified package provider could not be found.');

insert into rhnException values (-20293, 'package_key_type_not_found', 'The specified package key type could not be found.');

commit;

