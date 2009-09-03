

ALTER TABLE web_user_personal_info
 ADD (  password  VARCHAR2(38),
        old_password VARCHAR2(38),
        login     VARCHAR2(64),
        login_uc           VARCHAR2(64));



update web_user_personal_info pinfo
  set (password, old_password, login, login_uc)  = ( select password, old_password, login, login_uc 
        from web_contact WC where pinfo.web_user_id = WC.id);

alter table web_user_personal_info 
   modify ( password  VARCHAR2(38) NOT NULL,
            login     VARCHAR2(64) NOT NULL,
            login_uc           VARCHAR2(64) NOT NULL  CONSTRAINT web_personal_login_uc_unq UNIQUE);

 alter table web_contact drop column password;
 alter table web_contact drop column login;
 alter table web_contact drop column login_uc;
 alter table web_contact drop column old_password;


create or replace trigger
web_contact_mod_trig
before insert or update on web_contact
for each row
begin
        :new.modified := sysdate;
end
/

create or replace trigger
web_user_pi_timestamp
BEFORE INSERT OR UPDATE ON web_user_personal_info
FOR EACH ROW
BEGIN
  :new.modified := sysdate;
  :new.login_uc := UPPER(:new.login);
  IF :new.password <> :old.password THEN
         :new.old_password := :old.password;
  END IF;
END;
/

CREATE SEQUENCE web_user_personal_id_seq;

alter table web_user_personal_info add id number;
update web_user_personal_info set id = web_user_personal_id_seq.nextval;
alter table web_user_personal_info modify id number not null CONSTRAINT web_user_personal_pk PRIMARY KEY;



 alter table web_contact add  personal_info_id number; 
 update web_contact wc set personal_info_id = ( select pinfo.id from web_user_personal_info pinfo where pinfo.web_user_id = wc.id);
 alter table web_contact modify personal_info_id number NOT NULL CONSTRAINT web_contact_personal_id_fk
                               REFERENCES web_user_personal_info (id);
 alter table web_user_personal_info drop column web_user_id;

 alter table web_user_personal_info add default_org number;
 update web_user_personal_info pinfo set default_org = ( select org_id from web_contact wc where wc.personal_info_id = pinfo.id);
 alter table web_user_personal_info modify default_org number NOT NULL CONSTRAINT web_user_per_info_def_org_fk REFERENCES web_customer (id);



create or replace view rhnUsersInOrgOverview as
select    
        u.org_id                                        as org_id,
        u.id                                            as user_id,
        pi.login                                         as user_login,
        pi.first_names                                  as user_first_name,
        pi.last_name                                    as user_last_name,
        u.modified                                      as user_modified,
        (       select  count(server_id)
                from    rhnUserServerPerms sp
                where   sp.user_id = u.id)
                                                        as server_count,
        (       select  count(server_group_id)
                from    rhnUserManagedServerGroups umsg
                where   umsg.user_id = u.id and exists (
                        select  1
                        from    rhnVisibleServerGroup sg
                        where   sg.id = umsg.server_group_id))
                                                        as server_group_count,
        (       select  coalesce(utcv.names, '(normal user)')
                from    rhnUserTypeCommaView utcv
                where   utcv.user_id = u.id)
                                                        as role_names
from    web_user_personal_info pi, 
        web_contact u 
where
        u.personal_info_id = pi.id;




create or replace view
rhnWebContactDisabled
as
select
   wcon.id,
   wcon.org_id,
   pi.login,
   pi.login_uc,
   pi.password,
   pi.old_password,
   wcon.oracle_contact_id,
   wcon.created,
   wcon.modified,
   wcon.ignore_flag
from
   rhnWebContactChangeLog   wccl,
   rhnWebContactChangeState wccs,
   web_contact              wcon,
   web_user_personal_info   pi
where wccl.change_state_id = wccs.id
   and wccs.label = 'disabled'
   and wccl.web_contact_id = wcon.id
   and wcon.personal_info_id = pi.id
   and wccl.date_completed =
              (select max(wccl_exists.date_completed)
                 from rhnWebContactChangeLog   wccl_exists
                where wccl.web_contact_id = wccl_exists.web_contact_id);


create or replace view
rhnWebContactEnabled
as
select
   wcon.id,
   wcon.org_id,
   pinfo.login,
   pinfo.login_uc,
   pinfo.password,
   pinfo.old_password,
   wcon.oracle_contact_id,
   wcon.created,
   wcon.modified,
   wcon.ignore_flag
from
   web_contact wcon inner join 
   web_user_personal_info PINFO on PINFO.id = wcon.personal_info_id
minus
select
   wcd.id,
   wcd.org_id,
   wcd.login,
   wcd.login_uc,
   wcd.password,
   wcd.old_password,
   wcd.oracle_contact_id,
   wcd.created,
   wcd.modified,
   wcd.ignore_flag
from
   rhnWebContactDisabled wcd;



CREATE OR REPLACE VIEW
rhnActionOverview
(
        org_id,
        action_id,
        type_id,
        type_name,
        name,
        scheduler,
        scheduler_login,
        earliest_action,
        total_count,
        successful_count,
        failed_count,
        in_progress_count,
        archived
)
AS
SELECT    A.org_id,
          A.id,
          AT.id,
          AT.name,
          A.name,
          A.scheduler,
          pinfo.login,
          A.earliest_action,
          (SELECT COUNT(*) FROM rhnServerAction WHERE action_id = A.id),
          (SELECT COUNT(*) FROM rhnServerAction WHERE action_id = A.id AND status = 2), -- XXX: don''t hard code status here :)
          (SELECT COUNT(*) FROM rhnServerAction WHERE action_id = A.id AND status = 3),
          (SELECT COUNT(*) FROM rhnServerAction WHERE action_id = A.id AND status NOT IN (2, 3)),
          A.archived
FROM
          rhnActionType AT,
          rhnAction A
                left outer join
          web_contact U
                on A.scheduler = U.id inner join
          web_user_personal_info pinfo on pinfo.id = U.personal_info_id
WHERE A.action_type = AT.id
ORDER BY  A.earliest_action;

