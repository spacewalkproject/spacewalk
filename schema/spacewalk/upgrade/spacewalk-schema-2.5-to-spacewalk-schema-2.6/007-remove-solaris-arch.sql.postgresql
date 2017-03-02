-- oracle equivalent source sha1 6dedab3f67b9add9308dfbb6471c74e06b4577da

create or replace
function delete_server_tmp (
  arch_in varchar
)
returns void as
$$
declare
  rec record;
begin
  for rec in select server.id as id
      from rhnServer server
      where server_arch_id = LOOKUP_SERVER_ARCH(arch_in) loop
    perform logging.clear_log_id();
    perform delete_server(rec.id);
  end loop;
end;
$$ language plpgsql;

select delete_server_tmp('sparc-sun4m-solaris');
select delete_server_tmp('sparc-sun4u-solaris');
select delete_server_tmp('sparc-sun4v-solaris');
select delete_server_tmp('i386-i86pc-solaris');

drop function delete_server_tmp(varchar);

create or replace
function delete_channel_tmp (
  arch_in varchar
)
returns void as
$$
declare
  rec record;
begin
  for rec in select channel.id as id
      from rhnChannel channel
      where channel_arch_id = LOOKUP_CHANNEL_ARCH(arch_in) loop
    perform delete_channel(rec.id);
  end loop;
end;
$$ language plpgsql;

create or replace
function delete_channel_tmp_child (
  arch_in varchar
)
returns void as
$$
declare
  rec record;
begin
  for rec in select channel.id as id
      from rhnChannel channel
      where channel.parent_channel in
        (select id from rhnChannel c2
          where c2.channel_arch_id = LOOKUP_CHANNEL_ARCH(arch_in))
    loop
    perform delete_channel(rec.id);
  end loop;
end;
$$ language plpgsql;

select delete_channel_tmp_child('channel-sparc-sun-solaris');
select delete_channel_tmp_child('channel-i386-sun-solaris');
select delete_channel_tmp('channel-sparc-sun-solaris');
select delete_channel_tmp('channel-i386-sun-solaris');

drop function delete_channel_tmp(varchar);
drop function delete_channel_tmp_child(varchar);

delete from rhnChannelPackageArchCompat where channel_arch_id = LOOKUP_CHANNEL_ARCH('channel-sparc-sun-solaris');
delete from rhnChannelPackageArchCompat where channel_arch_id = LOOKUP_CHANNEL_ARCH('channel-i386-sun-solaris');

delete from rhnServerChannelArchCompat where channel_arch_id = LOOKUP_CHANNEL_ARCH('channel-sparc-sun-solaris');
delete from rhnServerChannelArchCompat where channel_arch_id = LOOKUP_CHANNEL_ARCH('channel-i386-sun-solaris');

delete from rhnChildChannelArchCompat where parent_arch_id = LOOKUP_CHANNEL_ARCH('channel-sparc-sun-solaris');
delete from rhnChildChannelArchCompat where parent_arch_id = LOOKUP_CHANNEL_ARCH('channel-i386-sun-solaris');
delete from rhnChildChannelArchCompat where child_arch_id = LOOKUP_CHANNEL_ARCH('channel-sparc-sun-solaris');
delete from rhnChildChannelArchCompat where child_arch_id = LOOKUP_CHANNEL_ARCH('channel-i386-sun-solaris');

delete from rhnChannelArch where label = 'channel-sparc-sun-solaris';
delete from rhnChannelArch where label = 'channel-i386-sun-solaris';

delete from rhnPackageUpgradeArchCompat where package_arch_id = LOOKUP_PACKAGE_ARCH('sparc-solaris');
delete from rhnPackageUpgradeArchCompat where package_arch_id = LOOKUP_PACKAGE_ARCH('sparc.sun4u-solaris');
delete from rhnPackageUpgradeArchCompat where package_arch_id = LOOKUP_PACKAGE_ARCH('sparc.sun4v-solaris');
delete from rhnPackageUpgradeArchCompat where package_arch_id = LOOKUP_PACKAGE_ARCH('i386-solaris');
delete from rhnPackageUpgradeArchCompat where package_arch_id = LOOKUP_PACKAGE_ARCH('sparc-solaris-patch');
delete from rhnPackageUpgradeArchCompat where package_arch_id = LOOKUP_PACKAGE_ARCH('i386-solaris-patch');
delete from rhnPackageUpgradeArchCompat where package_arch_id = LOOKUP_PACKAGE_ARCH('sparc-solaris-patch-cluster');
delete from rhnPackageUpgradeArchCompat where package_arch_id = LOOKUP_PACKAGE_ARCH('i386-solaris-patch-cluster');
delete from rhnPackageUpgradeArchCompat where package_arch_id = LOOKUP_PACKAGE_ARCH('noarch-solaris');
delete from rhnPackageUpgradeArchCompat where package_arch_id = LOOKUP_PACKAGE_ARCH('noarch-solaris-patch');
delete from rhnPackageUpgradeArchCompat where package_arch_id = LOOKUP_PACKAGE_ARCH('noarch-solaris-patch-cluster');

delete from rhnPackageUpgradeArchCompat where package_upgrade_arch_id = LOOKUP_PACKAGE_ARCH('sparc-solaris');
delete from rhnPackageUpgradeArchCompat where package_upgrade_arch_id = LOOKUP_PACKAGE_ARCH('sparc.sun4u-solaris');
delete from rhnPackageUpgradeArchCompat where package_upgrade_arch_id = LOOKUP_PACKAGE_ARCH('sparc.sun4v-solaris');
delete from rhnPackageUpgradeArchCompat where package_upgrade_arch_id = LOOKUP_PACKAGE_ARCH('i386-solaris');
delete from rhnPackageUpgradeArchCompat where package_upgrade_arch_id = LOOKUP_PACKAGE_ARCH('sparc-solaris-patch');
delete from rhnPackageUpgradeArchCompat where package_upgrade_arch_id = LOOKUP_PACKAGE_ARCH('i386-solaris-patch');
delete from rhnPackageUpgradeArchCompat where package_upgrade_arch_id = LOOKUP_PACKAGE_ARCH('sparc-solaris-patch-cluster');
delete from rhnPackageUpgradeArchCompat where package_upgrade_arch_id = LOOKUP_PACKAGE_ARCH('i386-solaris-patch-cluster');
delete from rhnPackageUpgradeArchCompat where package_upgrade_arch_id = LOOKUP_PACKAGE_ARCH('noarch-solaris');
delete from rhnPackageUpgradeArchCompat where package_upgrade_arch_id = LOOKUP_PACKAGE_ARCH('noarch-solaris-patch');
delete from rhnPackageUpgradeArchCompat where package_upgrade_arch_id = LOOKUP_PACKAGE_ARCH('noarch-solaris-patch-cluster');

delete from rhnServerPackageArchCompat where package_arch_id = LOOKUP_PACKAGE_ARCH('sparc-solaris');
delete from rhnServerPackageArchCompat where package_arch_id = LOOKUP_PACKAGE_ARCH('sparc.sun4u-solaris');
delete from rhnServerPackageArchCompat where package_arch_id = LOOKUP_PACKAGE_ARCH('sparc.sun4v-solaris');
delete from rhnServerPackageArchCompat where package_arch_id = LOOKUP_PACKAGE_ARCH('i386-solaris');
delete from rhnServerPackageArchCompat where package_arch_id = LOOKUP_PACKAGE_ARCH('sparc-solaris-patch');
delete from rhnServerPackageArchCompat where package_arch_id = LOOKUP_PACKAGE_ARCH('i386-solaris-patch');
delete from rhnServerPackageArchCompat where package_arch_id = LOOKUP_PACKAGE_ARCH('sparc-solaris-patch-cluster');
delete from rhnServerPackageArchCompat where package_arch_id = LOOKUP_PACKAGE_ARCH('i386-solaris-patch-cluster');
delete from rhnServerPackageArchCompat where package_arch_id = LOOKUP_PACKAGE_ARCH('noarch-solaris');
delete from rhnServerPackageArchCompat where package_arch_id = LOOKUP_PACKAGE_ARCH('noarch-solaris-patch');
delete from rhnServerPackageArchCompat where package_arch_id = LOOKUP_PACKAGE_ARCH('noarch-solaris-patch-cluster');

delete from rhnPackage where package_arch_id = (select id from rhnPackageArch where label = 'sparc-solaris');
delete from rhnPackage where package_arch_id = (select id from rhnPackageArch where label = 'sparc.sun4u-solaris');
delete from rhnPackage where package_arch_id = (select id from rhnPackageArch where label = 'sparc.sun4v-solaris');
delete from rhnPackage where package_arch_id = (select id from rhnPackageArch where label = 'i386-solaris');
delete from rhnPackage where package_arch_id = (select id from rhnPackageArch where label = 'sparc-solaris-patch');
delete from rhnPackage where package_arch_id = (select id from rhnPackageArch where label = 'i386-solaris-patch');
delete from rhnPackage where package_arch_id = (select id from rhnPackageArch where label = 'sparc-solaris-patch-cluster');
delete from rhnPackage where package_arch_id = (select id from rhnPackageArch where label = 'i386-solaris-patch-cluster');
delete from rhnPackage where package_arch_id = (select id from rhnPackageArch where label = 'noarch-solaris');
delete from rhnPackage where package_arch_id = (select id from rhnPackageArch where label = 'noarch-solaris-patch');
delete from rhnPackage where package_arch_id = (select id from rhnPackageArch where label = 'noarch-solaris-patch-cluster');

delete from rhnPackageNEVRA where package_arch_id = (select id from rhnPackageArch where label = 'sparc-solaris');
delete from rhnPackageNEVRA where package_arch_id = (select id from rhnPackageArch where label = 'sparc.sun4u-solaris');
delete from rhnPackageNEVRA where package_arch_id = (select id from rhnPackageArch where label = 'sparc.sun4v-solaris');
delete from rhnPackageNEVRA where package_arch_id = (select id from rhnPackageArch where label = 'i386-solaris');
delete from rhnPackageNEVRA where package_arch_id = (select id from rhnPackageArch where label = 'sparc-solaris-patch');
delete from rhnPackageNEVRA where package_arch_id = (select id from rhnPackageArch where label = 'i386-solaris-patch');
delete from rhnPackageNEVRA where package_arch_id = (select id from rhnPackageArch where label = 'sparc-solaris-patch-cluster');
delete from rhnPackageNEVRA where package_arch_id = (select id from rhnPackageArch where label = 'i386-solaris-patch-cluster');
delete from rhnPackageNEVRA where package_arch_id = (select id from rhnPackageArch where label = 'noarch-solaris');
delete from rhnPackageNEVRA where package_arch_id = (select id from rhnPackageArch where label = 'noarch-solaris-patch');
delete from rhnPackageNEVRA where package_arch_id = (select id from rhnPackageArch where label = 'noarch-solaris-patch-cluster');

delete from rhnPackageArch where label = 'sparc-solaris';
delete from rhnPackageArch where label = 'sparc.sun4u-solaris';
delete from rhnPackageArch where label = 'sparc.sun4v-solaris';
delete from rhnPackageArch where label = 'i386-solaris';
delete from rhnPackageArch where label = 'sparc-solaris-patch';
delete from rhnPackageArch where label = 'i386-solaris-patch';
delete from rhnPackageArch where label = 'sparc-solaris-patch-cluster';
delete from rhnPackageArch where label = 'i386-solaris-patch-cluster';
delete from rhnPackageArch where label = 'noarch-solaris';
delete from rhnPackageArch where label = 'noarch-solaris-patch';
delete from rhnPackageArch where label = 'noarch-solaris-patch-cluster';

delete from rhnPackageArch where arch_type_id = (select id from rhnArchType where label = 'solaris-patch');
delete from rhnPackageArch where arch_type_id = (select id from rhnArchType where label = 'solaris-patch-cluster');
delete from rhnPackageArch where arch_type_id = (select id from rhnArchType where label = 'sysv-solaris');

delete from rhnServerServerGroupArchCompat where server_arch_id = LOOKUP_SERVER_ARCH('sparc-sun4m-solaris');
delete from rhnServerServerGroupArchCompat where server_arch_id = LOOKUP_SERVER_ARCH('sparc-sun4u-solaris');
delete from rhnServerServerGroupArchCompat where server_arch_id = LOOKUP_SERVER_ARCH('sparc-sun4v-solaris');
delete from rhnServerServerGroupArchCompat where server_arch_id = LOOKUP_SERVER_ARCH('i386-i86pc-solaris');

delete from rhnServerArch where label = 'sparc-sun4m-solaris';
delete from rhnServerArch where label = 'sparc-sun4u-solaris';
delete from rhnServerArch where label = 'sparc-sun4v-solaris';
delete from rhnServerArch where label = 'i386-i86pc-solaris';

delete from rhnArchTypeActions where arch_type_id = (select id from rhnArchType where label = 'solaris-patch');
delete from rhnArchTypeActions where arch_type_id = (select id from rhnArchType where label = 'solaris-patch-cluster');
delete from rhnArchTypeActions where arch_type_id = (select id from rhnArchType where label = 'sysv-solaris');

delete from rhnArchType where label = 'solaris-patch';
delete from rhnArchType where label = 'solaris-patch-cluster';
delete from rhnArchType where label = 'sysv-solaris';
