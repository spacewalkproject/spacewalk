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
package com.redhat.rhn.frontend.xmlrpc.activationkey;

import com.redhat.rhn.FaultException;
import com.redhat.rhn.domain.token.ActivationKey;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.manager.token.ActivationKeyManager;

import java.util.LinkedList;
import java.util.List;


/**
 * XmlRpcActivationKeysHelper
 * @version $Rev$
 */
public class XmlRpcActivationKeysHelper {

    private static final XmlRpcActivationKeysHelper HELPER =
                                        new XmlRpcActivationKeysHelper();
    /**
     * Constructor
     */
    private XmlRpcActivationKeysHelper() {
    }


    /**
     *
     * @return an instance of the class.
     */
    public static XmlRpcActivationKeysHelper getInstance() {
        return HELPER;
    }

    /**
     * Helper method to lookup a ActivationKey object from key, and throws a FaultException
     * if the key cannot be found.
     * @param user The user looking up the ActivationKey
     * @param key The key value of the ActivationKey
     * @return Returns the ActivationKey Object corresponding to the key value.
     */
    public ActivationKey lookupKey(User user, String key) {
        ActivationKeyManager manager = ActivationKeyManager.getInstance();
        ActivationKey activationKey = manager.lookupByKey(key, user);
        if (activationKey == null) {
            String msg = "Activation Key [" + key + "] Not Found!";
            throw new FaultException(-212, "ActivationKeyNotFound", msg);
        }
        return activationKey;
    }

    /**
     * Helper method to lookup a bunch of activationkeys
     *  from a list of  key values
     * @param user The user looking up the ActivationKey
     * @param keys  activationkeys  ids we're looking for
     * @return Returns a list of actication keys  corresponding to provided key.
     */
    public List<ActivationKey> lookupKeys(User user, List<String> keys) {

        List<ActivationKey> activationKeys = new LinkedList<ActivationKey>();
        for (String key : keys) {
            activationKeys.add(lookupKey(user, key));
        }
        return activationKeys;
    }
}
