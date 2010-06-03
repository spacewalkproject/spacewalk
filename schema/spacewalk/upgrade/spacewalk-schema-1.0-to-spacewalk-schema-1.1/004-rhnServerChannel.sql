
alter TABLE rhnServerChannel add is_fve  char default 'N' 
   CONSTRAINT rhn_server_channel_is_fve_nn NOT NULL
   CONSTRAINT rhn_server_channel_is_fve_ck CHECK (IS_FVE IN ('Y', 'N'));
