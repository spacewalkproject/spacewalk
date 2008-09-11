-- data for rhnTemplateCategory

INSERT INTO rhnTemplateCategory (id, label, description) 
     VALUES (rhn_template_cat_id_seq.nextval, 'org_strings', 'Organization specific strings.');

INSERT INTO rhnTemplateCategory (id, label, description)
     VALUES (rhn_template_cat_id_seq.nextval, 'email_strings', 'Strings appearing in e-mail sent to users.');
