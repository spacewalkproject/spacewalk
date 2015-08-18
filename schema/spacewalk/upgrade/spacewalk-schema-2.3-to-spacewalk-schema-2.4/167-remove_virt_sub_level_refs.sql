DELETE FROM rhnException
WHERE label = 'invalid_virt_sub_level';

DELETE FROM rhnSGTypeVirtSubLevel
WHERE
    server_group_type_id = lookup_sg_type('virtualization_host') AND
    virt_sub_level_id = lookup_virt_sub_level('virtualization_free');

DELETE FROM rhnVirtSubLevel
WHERE label = 'virtualization_free';

DROP TABLE rhnChannelFamilyVirtSubLevel;
DROP TABLE rhnSGTypeVirtSubLevel;
DROP TABLE rhnVirtSubLevel;
DROP SEQUENCE rhn_virt_sl_seq;
