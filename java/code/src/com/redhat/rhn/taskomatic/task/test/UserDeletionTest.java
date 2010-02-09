/**
 * Copyright (c) 2009--2010 Red Hat, Inc.
 *
 * This software is licensed to you under the GNU General Public License,
 * version 2 (GPLv2). There is NO WARRANTY for this software, express or
 * implied, including the implied warranties of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
 * along with this software; if not, see
 * http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
 *
 * Red Hat trademarks are not licensed under GPLv2. No permission is
 * granted to use or replicate Red Hat trademarks that are incorporated
 * in this software or its documentation.
 */
package com.redhat.rhn.taskomatic.task.test;


import com.redhat.rhn.testing.RhnBaseTestCase;

public class UserDeletionTest extends RhnBaseTestCase {
    
    public void testUserDeletion() throws Exception {
        /*Long userPK = UserTestUtils.createUser("gfedcba", "mlkjih");
        User user = UserFactory.lookupById(userPK);
        user.setEmail("ksmith@redhat.com");
        TestUtils.saveAndFlush(user);
        Long id = user.getId();
        StringBuffer insert = new StringBuffer();
        insert.append("INSERT INTO rhnUserDeletionQueue (user_id) values ");
        insert.append("(").append(id).append(")");
        Connection cn = HibernateFactory.getSession().connection();
        Statement stmt = null;
        try {
            stmt = cn.createStatement();
            stmt.execute(insert.toString());
        }
        finally {
            if (stmt != null) {
                stmt.close();
            }
        }
        UserDeletion ud = new UserDeletion();
        ud.execute(null, true);*/
    }
}
