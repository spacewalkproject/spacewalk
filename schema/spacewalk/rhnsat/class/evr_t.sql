--
-- Copyright (c) 2008 Red Hat, Inc.
--
-- This software is licensed to you under the GNU General Public License,
-- version 2 (GPLv2). There is NO WARRANTY for this software, express or
-- implied, including the implied warranties of MERCHANTABILITY or FITNESS
-- FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
-- along with this software; if not, see
-- http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
-- 
-- Red Hat trademarks are not licensed under GPLv2. No permission is
-- granted to use or replicate Red Hat trademarks that are incorporated
-- in this software or its documentation. 
--
create or replace type evr_t AS OBJECT (
        epoch           varchar2(16),
        version         varchar2(512),
        release         varchar2(512),

        ORDER MEMBER FUNCTION compare (other_in IN evr_t)
          RETURN INTEGER,
        MEMBER FUNCTION as_vre RETURN VARCHAR2,
        MEMBER FUNCTION as_vre_simple RETURN VARCHAR2
);
/
show errors

create or replace type body evr_t
as
order member function compare (other_in IN evr_t)
  return integer
is
begin
        return rpm.vercmp(SELF.epoch, SELF.version, SELF.release,
                          other_in.epoch, other_in.version, other_in.release);
end;

member function as_vre
  return varchar2
is
begin
        return self.version || '-' || SELF.release || ':' || SELF.epoch;
end;

member function as_vre_simple
  return VARCHAR2
is
    vre_out VARCHAR2(256);
begin
    vre_out := self.version || '-' || self.release;
    
    if self.epoch is not null
    then
        vre_out := vre_out || ':' || self.epoch;
    end if;
    
    return vre_out;
end;

end;
/
show errors

create or replace function evr_t_as_vre( a evr_t )
  return varchar2
is
begin
        return a.version || '-' || a.release || ':' || a.epoch;
end;

create or replace function evr_t_as_vre_simple( a evr_t )
  return VARCHAR2
is
    vre_out VARCHAR2(256);
begin
    vre_out := a.version || '-' || a.release;
    
    if a.epoch is not null
    then
        vre_out := vre_out || ':' || a.epoch;
    end if;
    
    return vre_out;
end;


