-- Copyright (c) 2012 Red Hat, Inc.
--
-- This software is licensed to you under the GNU General Public License,
-- version 2 (GPLv2). There is NO WARRANTY for this software, express or
-- implied, including the implied warranties of MERCHANTABILITY or FITNESS
-- FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
-- along with this software; if not, see
-- http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
-- 
-- Red Hat trademarks are not licensed under GPLv2. No permission is
-- granted to use or replicate Red Hat trademarks that are incorporated
-- in this software or its documentation. 

create or replace function insert_transaction_package(
    o_id in number,
    n_id in number,
    e_id in number,
    p_arch_id in number)
return number
is
    pragma autonomous_transaction;
    tp_id   number;
begin
    insert into rhnTransactionPackage (id, operation, name_id, evr_id, package_arch_id)
    values (rhn_transpack_id_seq.nextval, o_id, n_id, e_id, p_arch_id) returning id into tp_id;
    commit;
    return tp_id;
end;
/
show errors
