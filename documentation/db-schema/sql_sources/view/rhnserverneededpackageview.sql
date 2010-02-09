-- created by Oraschemadoc Fri Jan 22 13:40:44 2010
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FORCE VIEW "SPACEWALK"."RHNSERVERNEEDEDPACKAGEVIEW" ("ORG_ID", "SERVER_ID", "ERRATA_ID", "PACKAGE_ID", "PACKAGE_NAME_ID") AS
  SELECT   S.org_id,
         S.id,
	  (SELECT EP.errata_id
	     FROM rhnErrataPackage EP,
	          rhnChannelErrata CE,
		  rhnServerChannel SC
	    WHERE SC.server_id = S.id
	      AND SC.channel_id = CE.channel_id
	      AND CE.errata_id = EP.errata_id
	      AND EP.package_id = P.id
	      AND ROWNUM = 1),
	 P.id,
	 P.name_id
FROM
	 rhnPackage P,
	 rhnServerPackageArchCompat SPAC,
	 rhnPackageEVR P_EVR,
	 rhnPackageEVR SP_EVR,
	 rhnServerPackage SP,
	 rhnChannelPackage CP,
	 rhnServerChannel SC,
         rhnServer S
WHERE
    	 SC.server_id = S.id
  AND  	 SC.channel_id = CP.channel_id
  AND    CP.package_id = P.id
  AND    p.package_arch_id = spac.package_arch_id
  AND    spac.server_arch_id = s.server_arch_id
  AND    SP_EVR.id = SP.evr_id
  AND    P_EVR.id = P.evr_id
  AND    SP.server_id = S.id
  AND    SP.name_id = P.name_id
  AND    SP.evr_id != P.evr_id
  AND    SP_EVR.evr < P_EVR.evr
  AND    SP_EVR.evr = (SELECT MAX(PE.evr) FROM rhnServerPackage SP2, rhnPackageEvr PE WHERE PE.id = SP2.evr_id AND SP2.server_id = SP.server_id AND SP2.name_id = SP.name_id)
 
/
