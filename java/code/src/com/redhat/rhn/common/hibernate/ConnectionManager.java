/**
 * Copyright (c) 2009--2012 Red Hat, Inc.
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
import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.common.finder.FinderFactory;

import org.apache.log4j.Logger;
import org.hibernate.HibernateException;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.hibernate.Transaction;
import org.hibernate.cfg.Configuration;
import org.hibernate.metadata.ClassMetadata;
import org.hibernate.resource.transaction.spi.TransactionStatus;

import java.util.Arrays;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Properties;
import java.util.Set;


/**
 * Manages the lifecycle of the Hibernate SessionFactory and associated
 * thread-scoped Hibernate sessions.
 */
class ConnectionManager {

    private static final Logger LOG = Logger.getLogger(ConnectionManager.class);
    private static final String[] PACKAGE_NAMES = {"com.redhat.rhn.domain",
    "com.redhat.rhn.taskomatic"};

    private final List<Configurator> configurators = new LinkedList<Configurator>();
    private SessionFactory sessionFactory;
    private final ThreadLocal<SessionInfo> SESSION_TLS = new ThreadLocal<SessionInfo>() {

        @Override
        public SessionInfo get() {
            SessionInfo result = super.get();
            return result;
        }
    };
    private final Set<String> packageNames = new HashSet<String>(
            Arrays.asList(PACKAGE_NAMES));

    /**
     * enable possibility to load hbm.xml files from different path
     */
    void setAdditionalPackageNames(String[] packageNamesIn) {
        for (String pn : packageNamesIn) {
            packageNames.add(pn);
        }
    }

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

        List<String> hbms = new LinkedList<String>();

        for (Iterator<String> iter = packageNames.iterator(); iter.hasNext();) {
            String pn = iter.next();
            hbms.addAll(FinderFactory.getFinder(pn).find("hbm.xml"));
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
            hibProperties.put("hibernate.connection.username",
                    Config.get()
                    .getString(ConfigDefaults.DB_USER));
            hibProperties.put("hibernate.connection.password",
                    Config.get()
                    .getString(ConfigDefaults.DB_PASSWORD));

            hibProperties.put("hibernate.connection.url",
                    ConfigDefaults.get().getJdbcConnectionString());

            config.addProperties(hibProperties);

            for (Iterator<String> i = hbms.iterator(); i.hasNext();) {
                String hbmFile = i.next();
                if (LOG.isDebugEnabled()) {
                    LOG.debug("Adding resource " + hbmFile);
                }
                config.addResource(hbmFile);
            }
            if (configurators != null) {
                for (Iterator<Configurator> i = configurators.iterator(); i
                        .hasNext();) {
                    Configurator c = i.next();
                    c.addConfig(config);
                }
            }

            // add empty varchar warning interceptor
            EmptyVarcharInterceptor interceptor = new EmptyVarcharInterceptor();
            interceptor.setAutoConvert(true);
            config.setInterceptor(interceptor);

            sessionFactory = config.buildSessionFactory();
        }
        catch (HibernateException e) {
            LOG.error("FATAL ERROR creating HibernateFactory", e);
        }
    }

    private SessionInfo threadSessionInfo() {
        return SESSION_TLS.get();
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
        if (info == null || info.getSession() == null) {
            try {
                if (LOG.isDebugEnabled()) {
                    LOG.debug("YYY Opening Hibernate Session");
                }
                info = new SessionInfo(sessionFactory.openSession());
            }
            catch (HibernateException e) {
                throw new HibernateRuntimeException("couldn't open session", e);
            }
            SESSION_TLS.set(info);
        }

        // Automatically start a transaction
        if (info.getTransaction() == null) {
            info.setTransaction(info.getSession().beginTransaction());
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
            if (txn != null && txn.getStatus().isNotOneOf(
                    TransactionStatus.COMMITTED, TransactionStatus.ROLLED_BACK)) {
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
