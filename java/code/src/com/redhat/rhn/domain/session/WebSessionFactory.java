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
package com.redhat.rhn.domain.session;

import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.domain.user.User;

import org.apache.log4j.Logger;
import org.hibernate.Query;
import org.hibernate.Session;

/**
 * SessionFactory - the singleton class used to fetch and store
 * com.redhat.rhn.domain.session.Session objects from the
 * database.
 * @version $Rev$
 */
public class WebSessionFactory extends HibernateFactory {

    private static WebSessionFactory singleton = new WebSessionFactory();
    private static Logger log = Logger.getLogger(WebSessionFactory.class);


    private WebSessionFactory() {
        super();
    }

    /**
     * Get the Logger for the derived class so log messages
     * show up on the correct class
     */
    protected Logger getLogger() {
        return log;
    }

    /**
     * Create a new Session from scratch
     * @return the Session created
     */
    public static WebSession createSession() {
        return new WebSessionImpl();
    }

    /**
     * Lookup a Session by their id
     * @param id the id to search for
     * @return the Session found
     */
    public static WebSession lookupById(Long id) {
        Session session = HibernateFactory.getSession();
        return (WebSession)session.get(WebSessionImpl.class, id);
    }

    /**
     * Insert or Update a Session.
     * @param webSession WebSession to be stored in database.
     */
    public static void save(WebSession webSession) {
        singleton.saveObject(webSession);
    }

    /**
     * Remove a Session from the DB
     * @param webSession WebSession to be removed from database.
     * @return the number of items affected.
     */
    public static int remove(WebSession webSession) {
        return singleton.removeObject(webSession);
    }

    /**
     * Removes all the sessions of a user. This action is useful
     * especially when we disable/deactivate a user. We donot want
     * a deactivated user's sessions to be alive..
     * @param user the user whose sessions are to be purged.
     */
    public static void purgeUserSessions(User user) {
        Session session = HibernateFactory.getSession();
        Query query = session.getNamedQuery("WebSession.deleteByUserId");
        query.setParameter("user_id", user.getId());
        query.executeUpdate();
    }
}

