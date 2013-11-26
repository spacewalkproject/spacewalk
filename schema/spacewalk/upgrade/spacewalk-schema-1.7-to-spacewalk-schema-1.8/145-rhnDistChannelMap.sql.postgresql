-- oracle equivalent source sha1 5d4e5693ab56a45ba202db768693b4ee63450b76

ALTER TABLE rhnDistChannelMap ADD org_id NUMERIC;
ALTER TABLE rhnDistChannelMap ADD CONSTRAINT rhn_dcm_oid_fk FOREIGN KEY (org_id) REFERENCES web_customer (id) ON DELETE CASCADE;
DROP INDEX if exists rhn_dcm_os_release_caid_idx;
ALTER TABLE rhnDistChannelMap DROP CONSTRAINT rhn_dcm_os_release_caid_uq;

delete
 from rhnDistChannelMap
where channel_id in (
      select id
        from rhnChannel
       where parent_channel is not null);

ALTER TABLE rhnDistChannelMap ADD CONSTRAINT rhn_dcm_release_caid_oid_uq UNIQUE (release, channel_arch_id, org_id);

ALTER TABLE rhnDistChannelMap ADD id NUMERIC;
CREATE SEQUENCE rhn_dcm_id_seq;
UPDATE rhnDistChannelMap SET id = nextval('rhn_dcm_id_seq');
ALTER TABLE rhnDistChannelMap ALTER COLUMN id SET NOT NULL;
ALTER TABLE rhnDistChannelMap ADD CONSTRAINT rhn_dcm_id_pk PRIMARY KEY (id);
