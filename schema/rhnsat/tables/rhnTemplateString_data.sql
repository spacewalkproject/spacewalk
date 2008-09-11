-- data for rhnTemplateString

SET SQLBLANKLINES ON
SET SCAN OFF

INSERT INTO rhnTemplateString (id, category_id, label, value, description) 
     VALUES (rhn_template_str_id_seq.nextval,
             (SELECT TC.id 
                FROM rhnTemplateCategory TC
	       WHERE TC.label = 'email_strings'),
	     'email_footer', '-' || '-the Red Hat Network Team', 'Footer for RHN e-mail');

INSERT INTO rhnTemplateString (id, category_id, label, value, description) 
     VALUES (rhn_template_str_id_seq.nextval,
             (SELECT TC.id 
                FROM rhnTemplateCategory TC
	       WHERE TC.label = 'email_strings'),
	     'email_account_info', '
Account Information:
  Your RHN login:         <login />
  Your RHN email address: <email-address />', 'Account info lines for RHN e-mail');

