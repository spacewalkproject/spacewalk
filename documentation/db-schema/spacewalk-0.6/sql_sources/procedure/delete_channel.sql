-- created by Oraschemadoc Mon Aug 31 10:54:41 2009
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE PROCEDURE "MIM1"."DELETE_CHANNEL" (
	channel_id_in in number
) is
begin
        delete from rhnChannelPackage where channel_id = channel_id_in;
        delete from rhnChannelErrata where channel_id = channel_id_in;
        delete from rhnServerChannel where channel_id = channel_id_in;
        delete from rhnRegTokenChannels where channel_id = channel_id_in;
        delete from rhnDistChannelMap where channel_id = channel_id_in;
        delete from rhnChannelFamilyMembers where channel_id = channel_id_in;
        delete from rhnServerProfilePackage where server_profile_id in (
            select id from rhnServerProfile where base_channel = channel_id_in
        );
        delete from rhnServerProfile where base_channel = channel_id_in;
        delete from rhnChannel where id = channel_id_in;
end;
 
/
