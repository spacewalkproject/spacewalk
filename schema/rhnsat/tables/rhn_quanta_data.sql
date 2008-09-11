--
--$Id$
--
-- 
--

--data for rhn_quanta

insert into rhn_quanta(quantum_id,basic_unit_id,description,last_update_user,
last_update_date) 
    values ( 'none','-','No physical quantity',
    'system',sysdate);
insert into rhn_quanta(quantum_id,basic_unit_id,description,last_update_user,
last_update_date) 
    values ( 'time','secs','Measure of time',
    'system',sysdate);
insert into rhn_quanta(quantum_id,basic_unit_id,description,last_update_user,
last_update_date) 
    values ( 'data','bytes','Measure of information',
    'system',sysdate);
insert into rhn_quanta(quantum_id,basic_unit_id,description,last_update_user,
last_update_date) 
    values ( 'datarate','Bps','Measure of information flow',
    'system',sysdate);
insert into rhn_quanta(quantum_id,basic_unit_id,description,last_update_user,
last_update_date) 
    values ( 'frequency','hertz','Measure of freqency',
    'system',sysdate);
insert into rhn_quanta(quantum_id,basic_unit_id,description,last_update_user,
last_update_date) 
    values ( 'temp','kelvins','Measure of temperature',
    'system',sysdate);
insert into rhn_quanta(quantum_id,basic_unit_id,description,last_update_user,
last_update_date) 
    values ( 'length','metres','Measure of length',
    'system',sysdate);
insert into rhn_quanta(quantum_id,basic_unit_id,description,last_update_user,
last_update_date) 
    values ( 'mass','kilograms','Measure of mass',
    'system',sysdate);
insert into rhn_quanta(quantum_id,basic_unit_id,description,last_update_user,
last_update_date) 
    values ( 'current','amperes','Measure of electric current',
    'system',sysdate);
insert into rhn_quanta(quantum_id,basic_unit_id,description,last_update_user,
last_update_date) 
    values ( 'force','newtons','Measure of force/weight',
    'system',sysdate);
insert into rhn_quanta(quantum_id,basic_unit_id,description,last_update_user,
last_update_date) 
    values ( 'power','watts','Measure of power',
    'system',sysdate);
insert into rhn_quanta(quantum_id,basic_unit_id,description,last_update_user,
last_update_date) 
    values ( 'charge','coulombs','Measure of charge',
    'system',sysdate);
insert into rhn_quanta(quantum_id,basic_unit_id,description,last_update_user,
last_update_date) 
    values ( 'voltage','volts','Measure of electric potential difference',
    'system',sysdate);
commit;

--$Log$
--Revision 1.4  2004/06/17 20:48:59  kja
--bugzilla 124970 -- _data is in for 350.
--
--Revision 1.3  2004/05/29 21:51:49  pjones
--bugzilla: none -- _data is not for 340, so says kja.
--
--Revision 1.2  2004/05/04 20:03:38  kja
--Added commits.
--
--Revision 1.1  2004/04/22 17:49:49  kja
--Added data for the reference tables.
--
