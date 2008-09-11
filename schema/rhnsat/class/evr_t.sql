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

