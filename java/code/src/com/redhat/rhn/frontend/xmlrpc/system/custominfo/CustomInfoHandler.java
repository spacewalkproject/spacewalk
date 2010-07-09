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
package com.redhat.rhn.frontend.xmlrpc.system.custominfo;

import com.redhat.rhn.FaultException;
import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.org.CustomDataKey;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.domain.server.ServerFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.xmlrpc.BaseHandler;
import com.redhat.rhn.manager.system.SystemManager;

/**
 * CustomInfoHandler
 * @version $Rev$
 * @xmlrpc.namespace system.custominfo
 * @xmlrpc.doc Provides methods to access and modify custom system information.
 */
public class CustomInfoHandler extends BaseHandler {

    /**
     * Create a new custom key
     * @param sessionKey key
     * @param keyLabel string
     * @param keyDescription string
     * @return 1 on success, 0 on failure
     * @throws FaultException A FaultException is thrown if:
     *   - Either the label or description is not provided
     *   - Any error occurs
     *
     * @xmlrpc.doc  Create a new custom key
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "keyLabel", "new key's label")
     * @xmlrpc.param #param_desc("string", "keyDescription", "new key's description")
     * @xmlrpc.returntype #return_int_success()
     */
    public int createKey(String sessionKey, String keyLabel,
                String keyDescription) throws FaultException {

        User loggedInUser = getLoggedInUser(sessionKey);

        if ((keyLabel.length() < 2) || (keyDescription.length() < 2)) {
            throw new FaultException(-1, "labelOrDescriptionTooShort",
                    "Label and description must be at least two characters long");
        }

        if (OrgFactory.lookupKeyByLabelAndOrg(keyLabel, loggedInUser.getOrg()) != null) {
            throw new FaultException(-1, "keyAlreadyExists",
                    "A custom key already exists with the label:" + keyLabel);
        }

        CustomDataKey key = new CustomDataKey();
        key.setLabel(keyLabel);
        key.setDescription(keyDescription);
        key.setCreator(loggedInUser);
        key.setOrg(loggedInUser.getOrg());
        ServerFactory.saveCustomKey(key);
        return 1;
    }

    /**
     * Delete an existing custom key
     * @param sessionKey key
     * @param keyLabel string
     * @return 1 on success, exception thrown otherwise
     * @throws FaultException A FaultException is thrown if:
     *   - Either the label or description is not provided
     *   - Any error occurs
     *
     * @xmlrpc.doc  Delete an existing custom key and all systems' values for the key.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "keyLabel", "new key's label")
     * @xmlrpc.returntype #return_int_success()
     */
    public int deleteKey(String sessionKey, String keyLabel)
        throws FaultException {

        User loggedInUser = getLoggedInUser(sessionKey);

        CustomDataKey key = OrgFactory.lookupKeyByLabelAndOrg(keyLabel,
                loggedInUser.getOrg());

        if (key == null) {
            throw new FaultException(-1, "keyDoesNotExist",
                    "A custom key does not exist with label: " + keyLabel);
        }

        ServerFactory.removeCustomKey(key);
        return 1;
    }

    /**
     * List the custom information keys defined for the user's organization.
     * @param sessionKey the session of the user
     * @return list of inactive systems
     * @throws FaultException A FaultException is thrown on error.
     *
     * @xmlrpc.doc List the custom information keys defined for the user's organization.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.returntype array
     *              $CustomDataKeySerializer
     */
    public Object[] listAllKeys(String sessionKey) throws FaultException {

        User loggedInUser = getLoggedInUser(sessionKey);

        DataResult result = SystemManager.listDataKeys(loggedInUser);
        return result.toArray();
    }
}
