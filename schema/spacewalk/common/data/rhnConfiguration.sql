INSERT INTO rhnConfiguration (key, description) VALUES ('extauth_default_orgid', 'Organization id, where externally authenticated users will be created.');
INSERT INTO rhnConfiguration (key, description, default_value) VALUES ('extauth_use_orgunit', 'Use Org. Unit IPA setting as organization name to create externally authenticated users in.', 'false');
INSERT INTO rhnConfiguration (key, description, default_value) VALUES ('extauth_keep_temproles', 'Keep temporary user roles granted due to the external authentication setup for subsequent logins using password.', 'false');
