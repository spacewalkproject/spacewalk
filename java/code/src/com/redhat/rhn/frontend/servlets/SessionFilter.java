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
package com.redhat.rhn.frontend.servlets;

import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.common.hibernate.HibernateRuntimeException;

import org.apache.log4j.Logger;
import org.hibernate.HibernateException;

import java.io.IOException;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;

/**
 * SessionFilter is a simple servlet filter to handle cleaning up the Hibernate
 * Session after each request.
 * @version $Rev$
 */
public class SessionFilter implements Filter {

    
private static final String ROLLBACK_MSG = "Error during transaction. Rolling back";
    private static final Logger LOG = Logger.getLogger(SessionFilter.class);

    /** {@inheritDoc} */
    public void init(FilterConfig config) throws ServletException {
        // no-op
    }

    /** {@inheritDoc} */
    public void doFilter(ServletRequest request, ServletResponse response,
            FilterChain chain) throws IOException, ServletException {
        boolean committed = false;
        try {
            logHere("Calling doFilter");
            // pass up stack
            chain.doFilter(request, response);
            HibernateFactory.commitTransaction();
            logHere("Transaction committed");
            committed = true;
        }
        catch (IOException e) {
            LOG.error(ROLLBACK_MSG, e);
            throw e;
        }
        catch (ServletException e) {
            LOG.error(ROLLBACK_MSG, e);
            throw e;
        }
        catch (HibernateException e) {
            LOG.error(ROLLBACK_MSG, e);
            throw new HibernateRuntimeException(ROLLBACK_MSG, e);
        }
        catch (RuntimeException e) {
            LOG.error(ROLLBACK_MSG, e);
            throw e;
        }
        catch (AssertionError e) {
            LOG.error(ROLLBACK_MSG, e);
            throw e;
        }
        finally {
            try {
                if (!committed) {
                    try {
                        logHere("Rolling back transaction");
                        HibernateFactory.rollbackTransaction();
                    }
                    catch (HibernateException e) {
                        final String msg = "Additional error during rollback";
                        LOG.warn(msg, e);
                    }
                }
            } 
            finally {
                // cleanup the session
                HibernateFactory.closeSession();
            }
        }

    }

    private void logHere(final String msg) {
        if (LOG.isDebugEnabled()) {
            LOG.debug(msg);
        }
    }

    /** {@inheritDoc} */
    public void destroy() {
        // no-op
    }
}
