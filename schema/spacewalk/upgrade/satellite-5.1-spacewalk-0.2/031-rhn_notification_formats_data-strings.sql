
update rhn_notification_formats
set body_format = replace(body_format, 'RHN', 'Spacewalk')
where description in ( 'New Default (2.15)', 'New Default (2.18)' )
	and customer_id is null;

