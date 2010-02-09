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
package com.redhat.rhn.common.hibernate.test;

import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.domain.session.WebSession;
import com.redhat.rhn.domain.session.WebSessionFactory;
import com.redhat.rhn.testing.RhnBaseTestCase;

import org.hibernate.HibernateException;
import org.hibernate.Session;
import org.hibernate.TransactionException;

/**
 * UnnestedTransactionFactoryTest
 * @version $Rev$
 */
public class NestedTransactionFactoryTest extends RhnBaseTestCase {

    private static final long EXP_TIME = 60 * 60 * 1000;

    
    public void aTestNesting() throws HibernateException {
        //System.out.println("XXX BEGIN testNesting");
        Session session = HibernateFactory.getSession();
        try {
            //System.out.println("XXX beginTransaction1");
            session.beginTransaction();
            //System.out.println("XXX END testNesting, fail");
            fail("Created nested transaction, which is verboten");
        } 
        catch (TransactionException e) {
            // Expected
            //System.out.println("XXX expected transaction");
        }
        //System.out.println("XXX END testNesting");
    }

    public void testRollback() throws HibernateException {
        WebSession s = createWebSession();
        HibernateFactory.rollbackTransaction();
        HibernateFactory.closeSession();
        
        assertNotExists(s);
    }

    public void testCommit() throws HibernateException {
        WebSession s = createWebSession();
        HibernateFactory.commitTransaction();
        
        assertExists(s);
    }

    public void testSeqRollbackCommit() throws HibernateException {
        WebSession s1 = createWebSession();
        HibernateFactory.rollbackTransaction();
        HibernateFactory.closeSession();
        
        WebSession s2 = createWebSession();
        HibernateFactory.commitTransaction();
        
        assertNotExists(s1);
        assertExists(s2);
    }

    public void testSeqCommitRollback() throws HibernateException {
        WebSession s1 = createWebSession();
        HibernateFactory.commitTransaction();
        HibernateFactory.closeSession();
        
        WebSession s2 = createWebSession();
        HibernateFactory.rollbackTransaction();
        HibernateFactory.closeSession();
        
        assertExists(s1);
        assertNotExists(s2);
    }

    private void assertNotExists(WebSession s) {
        WebSession sl = WebSessionFactory.lookupById(s.getId());
        assertNull(sl);
    }

    private void assertExists(WebSession s) {
        WebSession sl = WebSessionFactory.lookupById(s.getId());
        assertNotNull(sl);
        assertEquals(s.getId(), sl.getId());
        assertNull(sl.getWebUserId());
        assertEquals(s.getExpires(), sl.getExpires());
    }

    private WebSession createWebSession() {
        WebSession s = WebSessionFactory.createSession();
        s.setExpires(System.currentTimeMillis() + EXP_TIME);
        WebSessionFactory.save(s);
        return s;
    }

}
