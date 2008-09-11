--
-- $Id$
--

create or replace
package rhn_server
is

    -- i.e., "can this box do management stuff?" and yes if provisioning box
    function system_service_level(
    	server_id_in in number,
	service_level_in in varchar2
    ) return number;	    

    function can_change_base_channel(
    	server_id_in in number
    ) return number;
    
    procedure set_custom_value(
    	server_id_in in number,
	user_id_in in number,
	key_label_in varchar2,
     	value_in in varchar2
    );
    
    function bulk_set_custom_value(
    	key_label_in in varchar2,
	value_in in varchar2,
	set_label_in in varchar2,
	set_uid_in in number
    ) return integer;
    
    procedure snapshot_server(
    	server_id_in in number,
	reason_in in varchar2
    );
    
    procedure bulk_snapshot(
    	reason_in in varchar2,
    	set_label_in in varchar2,
	set_uid_in in number
    );
    
    procedure tag_delete(
    	server_id_in in number,
	tag_id_in in number
    );

    procedure tag_snapshot(
    	snapshot_id_in in number,
	org_id_in in number,
    	tagname_in in varchar2
    );
    
    procedure bulk_snapshot_tag(
    	org_id_in in number,
    	tagname_in varchar2,
	set_label_in in varchar2,
	set_uid_in in number
    );

    procedure remove_action(
	server_id_in in number,
	action_id_in in number
    );
    
    function check_user_access(server_id_in in number, user_id_in in number) return number;


    function can_server_consume_virt_slot(server_id_in in number,
                                              group_type_in in
                                              rhnServerGroupType.label%TYPE)
    return number;                                              

    procedure insert_into_servergroup (
	server_id_in in number,
	server_group_id_in in number
    );

    function insert_into_servergroup_maybe (
	server_id_in in number,
	server_group_id_in in number
    ) return number;

	procedure insert_set_into_servergroup (
	server_group_id_in in number,
	user_id_in in number,
	set_label_in in varchar2
	);

    procedure delete_from_servergroup (
	server_id_in in number,
	server_group_id_in in number
    );

	procedure delete_set_from_servergroup (
	server_group_id_in in number,
	user_id_in in number,
	set_label_in in varchar2
	);

	procedure clear_servergroup (
	server_group_id_in in number
	);

	procedure delete_from_org_servergroups (
	server_id_in in number
	);
	
	function get_ip_address (
		server_id_in in number
	) return varchar2;
end rhn_server;
/
SHOW ERRORS
