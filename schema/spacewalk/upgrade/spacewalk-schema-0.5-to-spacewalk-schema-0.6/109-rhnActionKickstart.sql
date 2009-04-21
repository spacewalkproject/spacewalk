-- Adding system record for reprovisioning

ALTER TABLE rhnActionKickstart
 ADD cobbler_system_name varchar2(256);

