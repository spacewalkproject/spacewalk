/**
 * Copyright (c) 2009 Red Hat, Inc.
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
package com.redhat.rhn.common.hibernate;

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.common.finder.FinderFactory;

import org.apache.log4j.Logger;
import org.hibernate.HibernateException;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.hibernate.Transaction;
import org.hibernate.cfg.Configuration;
import org.hibernate.cfg.Environment;
import org.hibernate.metadata.ClassMetadata;

import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Properties;


/**
 * Manages the lifecycle of the Hibernate SessionFactory and associated
 * thread-scoped Hibernate sessions
 * @version $Rev$
 */
class ConnectionManager {
    
    private static final Logger LOG = Logger.getLogger(ConnectionManager.class);
    private static final String[] PACKAGE_NAMES = {"com.redhat.rhn.domain"};
    
    private List configurators = new LinkedList();
    private SessionFactory sessionFactory;
    private ThreadLocal SESSION_TLS = new ThreadLocal() {

        public Object get() {
            Object result = super.get();
            return result;
        }
    };

    

    /**
     * Register a class with HibernateFactory, to give the registered class a
     * chance to modify the Hibernate configuration before creating the
     * SessionFactory.
     * @param c Configurator to override Hibernate configuration.
     */
    public void addConfigurator(Configurator c) {
        // Yes, this is a race condition, but it will only ever happen at
        // startup, when we really shouldn't have multiple threads running,
        // so it isn't a real race condition.
        configurators.add(c);
    }
    
    public boolean isTransactionPending() {
        boolean retval = false;
        SessionInfo info = threadSessionInfo();
        if (info != null) {
            retval = info.getTransaction() != null;
        }
        return retval;
    }
    
    public ClassMetadata getMetadata(Object target) {
        ClassMetadata retval = null;
        if (target != null) {
            if (target instanceof Class) {
                retval = sessionFactory.getClassMetadata((Class) target);
            }
            else {
                retval = sessionFactory.getClassMetadata(target.getClass());
            }
        }
        return retval;
    }
    
    /**
     * Close the sessionFactory
     */
    public synchronized void close() {
        try {
            sessionFactory.close();
        }
        catch (HibernateException e) {
            LOG.debug("Could not close the SessionFactory", e);
        }
        finally {
            sessionFactory = null;
        }
    }
    
    public boolean isClosed() {
        return sessionFactory == null;
    }
    
    public boolean isInitialized() {
        return sessionFactory != null;
    }
    
    public synchronized void initialize() {
        if (isInitialized()) {
            return;
        }
        createSessionFactory();
    }

    /**
     * Create a SessionFactory, loading the hbm.xml files from the specified
     * location.
     * @param packageNames Package name to be searched.
     */
    private void createSessionFactory() {
        if (sessionFactory != null && !sessionFactory.isClosed()) {
            return;
        }

        List hbms = new LinkedList();
    
        for (int i = 0; i < PACKAGE_NAMES.length; i++) {
            hbms.addAll(FinderFactory.getFinder(PACKAGE_NAMES[i]).find(
                    "hbm.xml"));
            if (LOG.isDebugEnabled()) {
                LOG.debug("Found: " + hbms);
            }
        }
    
        try {
            Configuration config = new Configuration();
            /*
             * Let's ask the RHN Config for all properties that begin with
             * hibernate.*
             */
            LOG.info("Adding hibernate properties to hibernate Configuration");
            Properties hibProperties = Config.get().getNamespaceProperties(
                    "hibernate");
            config.addProperties(hibProperties);
            // Force the use of our txn factory
            if (config.getProperty(Environment.TRANSACTION_STRATEGY) != null) {
                throw new IllegalArgumentException("The property " +
                        Environment.TRANSACTION_STRATEGY +
                        " can not be set in a configuration file;" +
                        " it is set to a fixed value by the code");
            }
    
            for (Iterator i = hbms.iterator(); i.hasNext();) {
                String hbmFile = (String) i.next();
                if (LOG.isDebugEnabled()) {
                    LOG.debug("Adding resource " + hbmFile);
                }
                config.addResource(hbmFile);
            }
            if (configurators != null) {
                for (Iterator i = configurators.iterator(); i.hasNext();) {
                    Configurator c = (Configurator) i.next();
                    c.addConfig(config);
                }
            }
            sessionFactory = config.buildSessionFactory();
        }
        catch (HibernateException e) {
            LOG.error("FATAL ERROR creating HibernateFactory", e);
        }
    }

    private SessionInfo threadSessionInfo() {
        return (SessionInfo) SESSION_TLS.get();
    }

    /**
     * Commit the transaction for the current session. This method or
     * {@link #rollbackTransaction}can only be called once per session.
     *
     * @throws HibernateException if the commit fails
     */
    public void commitTransaction() throws HibernateException {
        SessionInfo info = threadSessionInfo();
        if (info == null) {
            return;
        }
        if (info.getSession() == null) {
            // Session was never started
            return;
        }
        Transaction txn = info.getTransaction();
        if (txn != null) {
            txn.commit();
            info.setTransaction(null);
        }
    }

    /**
     * Roll the transaction for the current session back. This method or
     * {@link #commitTransaction}can only be called once per session.
     *
     * @throws HibernateException if the commit fails
     */
    public void rollbackTransaction() throws HibernateException {
        SessionInfo info = threadSessionInfo();
        if (info == null) {
            return;
        }
        if (info.getSession() == null) {
            return;
        }
        Transaction txn = info.getTransaction();
        if (txn != null) {
            txn.rollback();
            info.setTransaction(null);
        }
    }

    /**
     * Returns the Hibernate session stored in ThreadLocal storage. If not
     * present, creates a new one and stores it in ThreadLocal; creating the
     * session also begins a transaction implicitly.
     *
     * @return Session Session asked for
     */
    public Session getSession() {
        if (!isInitialized()) {
            initialize();
        }
        return getInternalSession();
    }
    
    private Session getInternalSession() {
        SessionInfo info = threadSessionInfo();
        if (info == null ||
                (info != null && info.getSession() == null)) {
            try {
                if (LOG.isDebugEnabled()) {
                    LOG.debug("YYY Opening Hibernate Session");
                }
                info = new SessionInfo(sessionFactory.openSession());
                // Automatically start a transaction
                info.setTransaction(info.getSession().beginTransaction());
            }
            catch (HibernateException e) {
                throw new HibernateRuntimeException("couldn't open session", e);
            }
            SESSION_TLS.set(info);
        }
    
        return info.getSession();
        
    }

    /**
     * Closes the Hibernate Session stored in ThreadLocal storage.
     */
    public void closeSession() {
        SessionInfo info = threadSessionInfo();
        if (info == null) {
            return;
        }
        Session session = info.getSession();
        try {
            Transaction txn = info.getTransaction();
            if (txn != null) {
                try {
                    txn.commit();
                }
                catch (HibernateException e) {
                    txn.rollback();
                }
            }
        }
        catch (HibernateException e) {
            LOG.error(e);
        }
        finally {        
            if (session != null) {
                try {
                    if (session.isOpen()) {
                        if (LOG.isDebugEnabled()) {
                            LOG.debug("YYY Closing Hibernate Session");
                        }
                        session.close();
                    }
                }
                catch (HibernateException e) {
                    throw new HibernateRuntimeException("couldn't close session");
                }
                finally {
                    SESSION_TLS.set(null);
                }
            }
            else {
                SESSION_TLS.set(null);
            }
        }
    }    
}
