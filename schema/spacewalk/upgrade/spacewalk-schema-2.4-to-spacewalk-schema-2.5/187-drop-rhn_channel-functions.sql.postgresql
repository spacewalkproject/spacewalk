-- oracle equivalent source sha1 b04dab2ff31049a8744e5ce1531ccd8b00152bbc

update pg_settings set setting = 'rhn_channel,' || setting where name = 'search_path';

drop function if exists available_chan_subscriptions(channel_id_in numeric, org_id_in numeric);
drop function if exists available_family_subscriptions(channel_family_id_in numeric, org_id_in numeric);
drop function if exists available_fve_chan_subs(channel_id_in numeric, org_id_in numeric);
drop function if exists available_fve_family_subs(channel_family_id_in numeric, org_id_in numeric);
drop function if exists can_convert_to_fve(server_id_in numeric, channel_family_id_val numeric);
drop function if exists can_server_consume_fve(server_id_in numeric);
drop function if exists can_server_consume_virt_channl(server_id_in numeric, family_id_in numeric);
drop function if exists cfam_curr_fve_members(channel_family_id_in numeric, org_id_in numeric);
drop function if exists channel_family_current_members(channel_family_id_in numeric, org_id_in numeric);
drop function if exists clear_subscriptions(server_id_in numeric, deleting_server numeric, update_family_countsyn numeric);
drop function if exists convert_to_fve(server_id_in numeric, channel_family_id_val numeric);
drop function if exists delete_server_channels(server_id_in numeric);
drop function if exists obtain_read_lock(channel_family_id_in numeric, org_id_in numeric);
drop function if exists subscribe_server(server_id_in numeric, channel_id_in numeric, immediate_in numeric, user_id_in numeric, recalcfamily_in numeric);
drop function if exists subscribe_server(server_id_in numeric, channel_id_in numeric, immediate_in numeric, user_id_in numeric);
drop function if exists unsubscribe_server(server_id_in numeric, channel_id_in numeric, immediate_in numeric, unsubscribe_children_in numeric, deleting_server numeric, update_family_countsyn numeric);
drop function if exists update_family_counts(channel_family_id_in numeric, org_id_in numeric);
drop function if exists update_group_family_counts(group_label_in character varying, org_id_in numeric);

update pg_settings set setting = overlay( setting placing '' from 1 for (length('rhn_channel')+1) ) where name = 'search_path';
