-- Not on data_tbs
create user nosatdev identified by nosatdev
    default tablespace users
    quota unlimited on users
    temporary tablespace temp_tbs;
grant create session to nosatdev;
grant create table to nosatdev;
grant create view to nosatdev;
grant create type to nosatdev;
grant create sequence to nosatdev;
grant create procedure to nosatdev;
grant create operator to nosatdev;
grant create synonym to nosatdev;
grant create trigger to nosatdev;

-- No tablespace quota
create user nosatdev1 identified by nosatdev1
    default tablespace data_tbs
    temporary tablespace temp_tbs;
grant create session to nosatdev1;
grant create table to nosatdev1;
grant create view to nosatdev1;
grant create type to nosatdev1;
grant create sequence to nosatdev1;
grant create procedure to nosatdev1;
grant create operator to nosatdev1;
grant create synonym to nosatdev1;
grant create trigger to nosatdev1;

-- No permission to create tables
create user nosatdev2 identified by nosatdev2
    default tablespace data_tbs
    quota unlimited on data_tbs
    temporary tablespace temp_tbs;
grant create session to nosatdev1;
grant create view to nosatdev2;
grant create type to nosatdev2;
grant create sequence to nosatdev2;
grant create procedure to nosatdev2;
grant create operator to nosatdev2;
grant create synonym to nosatdev2;
grant create trigger to nosatdev2;

-- No permission to create sequences
create user nosatdev3 identified by nosatdev3
    default tablespace data_tbs
    quota unlimited on data_tbs
    temporary tablespace temp_tbs;
grant create session to nosatdev1;
grant create table to nosatdev1;
grant create view to nosatdev3;
grant create type to nosatdev3;
grant create procedure to nosatdev3;
grant create operator to nosatdev3;
grant create synonym to nosatdev3;
grant create trigger to nosatdev3;

