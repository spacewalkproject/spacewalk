alter table rhnReleaseChannelMap add CONSTRAINT rhn_rcm_cid_fk  FOREIGN KEY (channel_id) REFERENCES rhnChannel (id);
alter table rhnReleaseChannelMap add CONSTRAINT rhn_rcm_caid_fk  FOREIGN KEY (channel_arch_id) REFERENCES rhnChannelArch (id);
