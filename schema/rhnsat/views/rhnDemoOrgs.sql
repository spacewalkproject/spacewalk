--
-- $Id$
--

create or replace view rhnDemoOrgs
as
(
    select org_id 
    from demo_log
    where server_id = 0
)
/

show errors;

-- another way to do this:
--        select 1
--        from
--            rh_product rp,
--            web_cp_service_line wcpsl,
--            web_customer_product wcp
--        where
--            wcp.customer_id = org_id
--       and wcp.active_flag = 'Y'
--        and wcpsl.active_flag = 'Y'
--        and wcpsl.oracle_customer_product_id = wcp.oracle_customer_product_id
--        and wcp.rh_product_id = rp.product_id
--        and wcpsl.rh_product_id = rp.product_id
--        and rp.item_code = 'MCT0127US'
--        and wcp.created_by = 'RHN'
--        and wcpsl.created_by = 'RHN'
