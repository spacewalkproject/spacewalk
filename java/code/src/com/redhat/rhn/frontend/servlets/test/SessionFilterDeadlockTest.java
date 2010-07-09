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
package com.redhat.rhn.frontend.servlets.test;

import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.frontend.servlets.SessionFilter;

import com.mockobjects.servlet.MockFilterChain;

import org.apache.log4j.Level;
import org.apache.log4j.Logger;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;

/**
 * AuthFilterTest
 * @version $Rev: 50384 $
 */
public class SessionFilterDeadlockTest extends BaseFilterTst {

    public void testDeadlockFilter() throws Exception {
        // Make sure the chain blows up.
        chain = new MockFilterChain() {
            public void doFilter(ServletRequest req, ServletResponse resp)
            throws IOException, ServletException {
                throw new IOException("Test IOException");
            }
        };
        SessionFilter filter = new SessionFilter();
        HibernateFactory.getSession();
        int caughtCount = 0;

        Logger log = Logger.getLogger(SessionFilter.class);
        Level orig = log.getLevel();
        log.setLevel(Level.OFF);
        for (int i = 0; i < 5; i++) {
            try {
                filter.doFilter(request, response, chain);
            }
            catch (IOException ioe) {
                caughtCount++;
            }
        }
        log.setLevel(orig);
        assertTrue(caughtCount == 5);
        HibernateFactory.getSession();
        assertTrue(HibernateFactory.inTransaction());
    }



}

