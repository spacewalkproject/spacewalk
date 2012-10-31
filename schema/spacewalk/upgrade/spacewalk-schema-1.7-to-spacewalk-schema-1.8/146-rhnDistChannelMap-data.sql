UPDATE rhnDistChannelMap dcm SET org_id = (SELECT c.org_id FROM rhnChannel c where c.id = dcm.channel_id);
