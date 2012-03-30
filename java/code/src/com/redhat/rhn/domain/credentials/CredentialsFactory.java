/**
 * Copyright (c) 2012 Novell
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

package com.redhat.rhn.domain.credentials;

import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import org.apache.log4j.Logger;

import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.domain.user.User;

/**
 * CredentialsFactory
 */
public class CredentialsFactory extends HibernateFactory {

    private static CredentialsFactory singleton = new CredentialsFactory();
    private static Logger log = Logger.getLogger(CredentialsFactory.class);

    private CredentialsFactory() {
        super();
    }

    /**
     * Create new empty {@link Credentials}.
     * @return new empty credentials
     */
    public static Credentials createCredentials() {
        Credentials creds = new Credentials();
        return creds;
    }

    /**
     * Store {@link Credentials} to the database.
     * @param creds credentials
     */
    public static void storeCredentials(Credentials creds) {
        creds.setModified(new Date());
        singleton.saveObject(creds);
    }

    /**
     * Delete {@link Credentials} from the database.
     * @param creds credentials
     */
    public static void removeCredentials(Credentials creds) {
        singleton.removeObject(creds);
    }

    /**
     * Load {@link Credentials} for a given {@link User} and type label.
     * @param user user
     * @param typeLabel type label
     * @return credentials or null
     */
    public static Credentials lookupByUserAndType(User user, String typeLabel) {
        if (user == null || typeLabel == null) {
            return null;
        }
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("user", user);
        params.put("label", typeLabel);
        return (Credentials) singleton.lookupObjectByNamedQuery(
                "Credentials.findByUserAndTypeLabel", params);
    }

    /**
     * Find a {@link CredentialsType} by a given label.
     * @param label label
     * @return CredentialsType instance for given label
     */
    public static CredentialsType findCredentialsTypeByLabel(String label) {
        if (label == null) {
            return null;
        }
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("label", label);
        return (CredentialsType) singleton.lookupObjectByNamedQuery(
                "CredentialsType.findByLabel", params);
    }

    /**
     * Helper method for creating new SUSE Studio {@link Credentials} for a
     * given user.
     * @param user user to associate with these credentials
     * @return new credentials for SUSE Studio
     */
    public static Credentials createStudioCredentials(User user) {
        Credentials creds = createCredentials();
        creds.setUser(user);
        creds.setType(CredentialsFactory
                .findCredentialsTypeByLabel(Credentials.TYPE_SUSESTUDIO));
        return creds;
    }

    /**
     * Helper method for looking up SUSE Studio credentials.
     * @param user user
     * @return credentials or null
     */
    public static Credentials lookupStudioCredentials(User user) {
        return lookupByUserAndType(user, Credentials.TYPE_SUSESTUDIO);
    }

    @Override
    protected Logger getLogger() {
        return log;
    }
}
