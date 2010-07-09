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
package com.redhat.rhn.frontend.xmlrpc.packages.provider;

import com.redhat.rhn.domain.rhnpackage.PackageFactory;
import com.redhat.rhn.domain.rhnpackage.PackageKey;
import com.redhat.rhn.domain.rhnpackage.PackageKeyType;
import com.redhat.rhn.domain.rhnpackage.PackageProvider;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.xmlrpc.BaseHandler;
import com.redhat.rhn.frontend.xmlrpc.InvalidPackageKeyTypeException;
import com.redhat.rhn.frontend.xmlrpc.InvalidPackageProviderException;
import com.redhat.rhn.frontend.xmlrpc.PermissionCheckFailureException;

import org.apache.commons.lang.StringEscapeUtils;
import org.apache.log4j.Logger;

import java.util.List;
import java.util.Set;

/**
 * PackagesProvider
 * @version $Rev$
 * @xmlrpc.namespace packages.provider
 * @xmlrpc.doc Methods to retrieve information about Package Providers associated with
 *      packages.
 */
public class PackagesProviderHandler extends BaseHandler {

    private static Logger logger = Logger.getLogger(PackagesProviderHandler.class);


    /**
     * list the package providers
     * @param sessionKey  the session key
     * @return List of package providers
     *
     * @xmlrpc.doc List all Package Providers.
     * User executing the request must be a Satellite administrator.
     * @xmlrpc.param #session_key()
     * @xmlrpc.returntype
     *  #array()
     *      $PackageProviderSerializer
     *  #array_end()
     */
    public List<PackageProvider> list(String sessionKey) {
        User user = getLoggedInUser(sessionKey);
        isSatelliteAdmin(user);
        List<PackageProvider> list = PackageFactory.listPackageProviders();
        return list;
    }



    /**
     * List the keys associated with a package provider
     * @param sessionKey the session key
     * @param providerName the provider name
     * @return set of package keys
     *
     * @xmlrpc.doc List all security keys associated with a package provider.
     * User executing the request must be a Satellite administrator.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "providerName", "The provider name")
     * @xmlrpc.returntype
     *  #array()
     *      $PackageKeySerializer
     *  #array_end()
     */
    public Set<PackageKey> listKeys(String sessionKey, String providerName) {
        User user = getLoggedInUser(sessionKey);
        isSatelliteAdmin(user);
        PackageProvider prov = PackageFactory.lookupPackageProvider(providerName);
        if (prov == null) {
            throw new InvalidPackageProviderException(providerName);
        }
        return prov.getKeys();

    }

    /**
     * Associate a package key with provider.  Provider is created if it doesn't exist.
     *  Key is created if it doesn't exist.
     * @param sessionKey the session key
     * @param providerName the provider name
     * @param key the key string
     * @param typeStr the type string (currently only 'gpg' is supported)
     * @return 1 on success
     *
     * @xmlrpc.doc Associate a package security key and with the package provider.
     *      If the provider or key doesn't exist, it is created. User executing the
     *      request must be a Satellite administrator.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "providerName", "The provider name")
     * @xmlrpc.param #param_desc("string", "key", "The actual key")
     * @xmlrpc.param #param_desc("string", "type", "The type of the key. Currently,
     * only 'gpg' is supported")
     * @xmlrpc.returntype
     *      #return_int_success()
     */
    public int associateKey(String sessionKey, String providerName, String key,
            String typeStr) {
        User user = getLoggedInUser(sessionKey);
        isSatelliteAdmin(user);
        PackageProvider prov = PackageFactory.lookupPackageProvider(providerName);
        if (prov == null) {
            prov = new PackageProvider();
            prov.setName(providerName);
        }

        //package key type might be invalid
        PackageKeyType type = PackageFactory.lookupKeyTypeByLabel(typeStr);
        if (type == null) {
            throw new InvalidPackageKeyTypeException(typeStr);
        }


        PackageKey pKey = PackageFactory.lookupPackageKey(key);
        if (pKey == null) {
            pKey = new PackageKey();
            pKey.setKey(StringEscapeUtils.escapeHtml(key));
            pKey.setType(type);
        }

        pKey.setProvider(prov);
        prov.addKey(pKey);

        PackageFactory.save(prov);

        return 1;
    }



    private void isSatelliteAdmin(User user) {
        if (!user.hasRole(RoleFactory.SAT_ADMIN)) {
            throw new PermissionCheckFailureException(RoleFactory.SAT_ADMIN);
        }
    }

}
