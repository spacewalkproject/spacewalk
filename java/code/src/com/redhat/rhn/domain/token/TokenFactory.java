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
package com.redhat.rhn.domain.token;

import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.common.hibernate.LookupException;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.server.Server;

import org.apache.log4j.Logger;
import org.hibernate.HibernateException;
import org.hibernate.Session;

/**
 * TokenFactory
 * @version $Rev$
 */
public class TokenFactory extends HibernateFactory {

    private static TokenFactory singleton = new TokenFactory();
    private static Logger log = Logger.getLogger(TokenFactory.class);

    /**
     * Lookup an token by id
     * You probably want ActivationKeyFactory.lookupById() instead.
     * The Token does not include the actual hex string used for
     * registration, or the relationship to the kickstart session(s).
     * WARNING - This method should be used very carefully, because
     *  it doesn't filter out based on org
     * @param id the id to search for
     * @return the ActivationKey found
     */
    public static Token lookupById(Long id) {
        if (id == null) {
            return null;
        }

        Session session = null;
        try {
            session = HibernateFactory.getSession();
            return (Token) session.getNamedQuery("Token.findById")
                .setParameter("id", id)
                //Retrieve from cache if there
                .setCacheable(true)
                .uniqueResult();
        }
        catch (HibernateException e) {
            log.error("Hibernate exception: " + e.toString());
            throw e;
        }
    }



    /**
     * Lookup an token by id
     * You probably want ActivationKeyFactory.lookupById() instead.
     * The Token does not include the actual hex string used for
     * registration, or the relationship to the kickstart session(s).
     * @param id the id to search for
     * @param org the org to whom the token belongs to
     * @return the ActivationKey found
     */
    public static Token lookup(Long id, Org org) {
        if (id == null || org == null) {
            LocalizationService ls = LocalizationService.getInstance();
            String msg = "Null value provided id=[%s] , org = [%s]";
            LookupException e = new LookupException(String.format(msg, id, org));
            e.setLocalizedTitle(ls.getMessage("lookup.jsp.title.token"));
            e.setLocalizedReason1(ls.getMessage("lookup.jsp.reason1.token"));
            e.setLocalizedReason2(ls.getMessage("lookup.jsp.reason2.token"));
            throw e;
        }
        Token t;
        Session session = null;
        try {
            session = HibernateFactory.getSession();
            t = (Token) session.getNamedQuery("Token.findByIdAndOrg")
                .setParameter("id", id).setParameter("org", org)
                //Retrieve from cache if there
                .setCacheable(true)
                .uniqueResult();
        }
        catch (HibernateException e) {
            log.error("Hibernate exception: " + e.toString());
            throw e;
        }
        if (t == null) {
            LocalizationService ls = LocalizationService.getInstance();
            LookupException e = new LookupException("Could not find " +
                                                    "token with id =  " + id);
            e.setLocalizedTitle(ls.getMessage("lookup.jsp.title.token"));
            e.setLocalizedReason1(ls.getMessage("lookup.jsp.reason1.token"));
            e.setLocalizedReason2(ls.getMessage("lookup.jsp.reason2.token"));
            throw e;
        }
        return t;

    }
    /**
     * Lookup a Token for the given Server
     * @param server to lookup the Token for
     * @return Token if found.  Null if not
     */
    public static Token lookupByServer(Server server) {
        if (server == null) {
            return null;
        }

        Session session = null;
        try {
            session = HibernateFactory.getSession();
            return (Token) session.getNamedQuery("Token.findByServerAndOrg")
                .setEntity("server", server)
                .setEntity("org", server.getOrg())
                //Retrieve from cache if there
                .setCacheable(true)
                .uniqueResult();
        }
        catch (HibernateException e) {
            log.error("Hibernate exception: " + e.toString());
            throw e;
        }
    }


    /**
     * Saves a token to the database
     * @param tokenIn The Token to save.
     */
    public static void save(Token tokenIn) {
        singleton.saveObject(tokenIn);
    }

    /**
     * {@inheritDoc}
     */
    protected Logger getLogger() {
        return log;
    }

    /**
     * Delete a regtoken
     * @param token to delete
     */
    public static void removeToken(Token token) {
        singleton.removeObject(token);

    }

}
