
alter table rhnKickstartPackage
add position number;

update rhnKickstartPackage
set position = 0;

commit;

alter table rhnKickstartPackage
modify position not null;

