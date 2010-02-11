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
package com.redhat.rhn.frontend.xmlrpc.kickstart.keys;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.domain.kickstart.crypto.CryptoKey;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.xmlrpc.BaseHandler;
import com.redhat.rhn.frontend.xmlrpc.NoSuchUserException;
import com.redhat.rhn.manager.kickstart.KickstartLister;
import com.redhat.rhn.manager.kickstart.crypto.CreateCryptoKeyCommand;
import com.redhat.rhn.manager.kickstart.crypto.DeleteCryptoKeyCommand;
import com.redhat.rhn.manager.kickstart.crypto.EditCryptoKeyCommand;

import java.util.List;

/**
 * @xmlrpc.namespace kickstart.keys
 * @xmlrpc.doc Provides methods to manipulate kickstart keys.
 *
 * @author Jason Dobies
 * @version $Revision$
 */
public class CryptoKeysHandler extends BaseHandler {

    /**
     * Lists all keys associated with the org of the user (identified by the session key).
     *
     * @param sessionKey identifies the user that is logged in and performing the call
     * @return a list of maps containing the description and type of key found 
     *
     * @xmlrpc.doc list all keys for the org associated with the user logged into the
     *             given session
     * @xmlrpc.param #session_key()
     * @xmlrpc.returntype
     *      #array()
     *          #struct("key")
     *              #prop("string", "description")
     *              #prop("string", "type")
     *          #struct_end()
     *      #array_end()
     */
    public List listAllKeys(String sessionKey) {
        User loggedInUser = getLoggedInUser(sessionKey);

        if (loggedInUser == null) {
            throw new NoSuchUserException();
        }

        Org org = loggedInUser.getOrg();
        KickstartLister lister = KickstartLister.getInstance();

        DataResult dataResult = lister.cryptoKeysInOrg(org, null);
        return dataResult;
    }

    /**
     * Creates a new key with the given parameters.
     *
     * @param sessionKey   identifies the user that is logged in and performing the call
     * @param description  description of the key
     * @param type         type of key being created
     * @param content      contents of the key itself
     * @return 1 if the creation was successful
     * @throws KickstartKeyAlreadyExistsException if a key with the given description
     *         already exists for the user's org
     *
     * @xmlrpc.doc creates a new key with the given parameters
     * @xmlrpc.param #param("string", "session_key")
     * @xmlrpc.param #param("string", "description")
     * @xmlrpc.param #param_desc("string", "type", "valid values are GPG or SSL")
     * @xmlrpc.param #param("string", "content")
     * @xmlrpc.returntype #return_int_success()
     */
    public int create(String sessionKey, String description, String type, String content) {
        User loggedInUser = getLoggedInUser(sessionKey);

        if (loggedInUser == null) {
            throw new NoSuchUserException();
        }

        Org org = loggedInUser.getOrg();
        CreateCryptoKeyCommand command = new CreateCryptoKeyCommand(org);
        command.setType(type);
        command.setDescription(description);
        command.setContents(content);

        ValidatorError[] errors = command.store();

        if (errors == null) {
            return 1;
        }
        else {
            throw new KickstartKeyAlreadyExistsException();
        }
    }

    /**
     * Deletes the key identified by the given parameters.
     *
     * @param sessionKey   identifies the user that is logged in and performing the call
     * @param description  description of the key
     * @return 1 if the delete was successful
     * @throws KickstartKeyDeleteException if there is an error during the delete
     *
     * @xmlrpc.doc deletes the key identified by the given parameters
     * @xmlrpc.param #param("string", "session_key")
     * @xmlrpc.param #param("string", "description")
     * @xmlrpc.returntype #return_int_success()
     */
    public int delete(String sessionKey, String description) {
        User loggedInUser = getLoggedInUser(sessionKey);

        if (loggedInUser == null) {
            throw new NoSuchUserException();
        }

        DeleteCryptoKeyCommand command =
            new DeleteCryptoKeyCommand(loggedInUser, description);
        ValidatorError[] errors = command.store();

        if (errors == null) {
            return 1;
        }
        else {
            throw new KickstartKeyDeleteException();
        }
    }

    /**
     * Returns all of the data associated with the given key.
     * 
     * @param sessionKey  identifies the user that is logged in and performing the call
     * @param description identifies the key
     * 
     * @return holder object containing the data associated with the key
     * 
     * @xmlrpc.doc returns all of the data associated with the given key
     * @xmlrpc.param #param("string", "session_key")
     * @xmlrpc.param #param("string", "description")
     * @xmlrpc.returntype
     *      #struct("key")
     *          #prop("string", "description")
     *          #prop("string", "type")
     *          #prop("string", "content")
     *      #struct_end()
     */
    public CryptoKey getDetails(String sessionKey, String description) {
        User loggedInUser = getLoggedInUser(sessionKey);

        EditCryptoKeyCommand command = new EditCryptoKeyCommand(loggedInUser, description);

        CryptoKey key = command.getCryptoKey();
        return key;
    }
}
