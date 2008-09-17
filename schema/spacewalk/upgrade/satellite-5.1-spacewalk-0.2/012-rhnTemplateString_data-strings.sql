
update rhnTemplateString
set description = 'Footer for Spacewalk e-mail'
where label = 'email_footer';

update rhnTemplateString
set value = '
Account Information:
  Your Spacewalk login:         <login />
  Your Spacewalk email address: <email-address />', 
description = 'Account info lines for Spacewalk e-mail'
where label = 'email_account_info';

