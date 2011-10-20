INSERT INTO rhnServerNetAddress4
    (interface_id, address, netmask, broadcast, created)
    SELECT id, ip_addr, netmask, broadcast, created
    FROM rhnServerNetInterface;

COMMIT;
