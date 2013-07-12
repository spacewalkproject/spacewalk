INSERT INTO web_contact_all (id, org_id, login)
        VALUES (-1, null, 'SETUP');
INSERT INTO web_contact_all (id, org_id, login)
        VALUES (-2, null, 'CLIENT');
INSERT INTO web_contact_all (id, org_id, login)
    SELECT id, org_id, login FROM web_contact;
