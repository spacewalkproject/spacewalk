
alter table rhnIndexerWork
add last_modified date default (sysdate) not null;

commit;



