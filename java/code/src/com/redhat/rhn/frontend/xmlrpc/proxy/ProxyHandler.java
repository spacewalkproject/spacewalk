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
package com.redhat.rhn.frontend.xmlrpc.proxy;

import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.ChannelFamily;
import com.redhat.rhn.domain.channel.ChannelFamilyFactory;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.frontend.xmlrpc.BaseHandler;
import com.redhat.rhn.frontend.xmlrpc.InvalidProxyVersionException;
import com.redhat.rhn.frontend.xmlrpc.MethodInvalidParamException;
import com.redhat.rhn.frontend.xmlrpc.ProxyAlreadyRegisteredException;
import com.redhat.rhn.frontend.xmlrpc.ProxyNeedManagementException;
import com.redhat.rhn.frontend.xmlrpc.ProxyNotActivatedException;
import com.redhat.rhn.frontend.xmlrpc.ProxySystemIsSatelliteException;
import com.redhat.rhn.manager.entitlement.EntitlementManager;
import com.redhat.rhn.manager.system.SystemManager;

import org.apache.log4j.Logger;
import java.util.ArrayList;
import java.util.List;

/**
 * ProxyHandler
 * @xmlrpc.namespace proxy
 * @xmlrpc.doc Provides methods to activate/deactivate a proxy
 * server.
 */
public class ProxyHandler extends BaseHandler {
    private static Logger log = Logger.getLogger(ProxyHandler.class);

    /**
     * Test, if the system identified by the given client certificate, is proxy.
     * @param clientcert client certificate of the system.
     * @return 1 if system is proxy, 0 otherwise.
     * @throws MethodInvalidParamException thrown if certificate is invalid.
     *
     * @xmlrpc.doc Test, if the system identified by the given client
     * certificate i.e. systemid file, is proxy.
     * @xmlrpc.param #param_desc("string", "systemid", "systemid file")
     * @xmlrpc.returntype #return_int_success()
     */
    public int isProxy(String clientcert)
        throws MethodInvalidParamException {
        Server server = validateClientCertificate(clientcert);
        return (server.isProxy() ? 1 : 0);
    }

    /**
     * Deactivates the system identified by the given client certificate.
     * @param clientcert client certificate of the system.
     * @return 1 if the deactivation succeeded, 0 otherwise.
     * @throws ProxyNotActivatedException thrown if server is not a proxy.
     * @throws MethodInvalidParamException thrown if certificate is invalid.
     *
     * @xmlrpc.doc Deactivates the proxy identified by the given client
     * certificate i.e. systemid file.
     * @xmlrpc.param #param_desc("string", "systemid", "systemid file")
     * @xmlrpc.returntype #return_int_success()
     */
    public int deactivateProxy(String clientcert)
        throws ProxyNotActivatedException, MethodInvalidParamException {
        Server server = validateClientCertificate(clientcert);
        if (!server.isProxy()) {
            throw new ProxyNotActivatedException();
        }

        SystemManager.deactivateProxy(server);
        return 1;
    }

    /**
     * Activates the proxy identified by the given client certificate.
     * @param clientcert client certificate of the system.
     * @param version Proxy version
     * @return 1 if the deactivation succeeded, 0 otherwise.
     * @throws ProxyAlreadyRegisteredException thrown if system has already been
     * registered.
     * @throws MethodInvalidParamException thrown if certificate is invalid.
     * @throws ProxySystemIsSatelliteException thrown if client certificate is
     * for a satellite
     * @throws InvalidProxyVersionException thrown if version is not supported.
     * @throws ProxyNeedManagementException thrown if system does not have the
     * management entitlement.
     *
     * @xmlrpc.doc Activates the proxy identified by the given client
     * certificate i.e. systemid file.
     * @xmlrpc.param #param_desc("string", "systemid", "systemid file")
     * @xmlrpc.param #param_desc("string", "version", "Version of proxy to be
     * registered.")
     * @xmlrpc.returntype #return_int_success()
     */
    public int activateProxy(String clientcert, String version)
        throws ProxyAlreadyRegisteredException, MethodInvalidParamException,
               ProxySystemIsSatelliteException, InvalidProxyVersionException {

        Server server = validateClientCertificate(clientcert);
        if (server.isProxy()) {
            throw new ProxyAlreadyRegisteredException();
        }

        if (!(server.hasEntitlement(EntitlementManager.MANAGEMENT))) {
            throw new ProxyNeedManagementException();
        }

        // if the server does nto have enterprise_entitled entitlement, add it
        //

        if (!server.hasEntitlement(EntitlementManager.MANAGEMENT)) {
            SystemManager.entitleServer(server, EntitlementManager.MANAGEMENT);
        }
        SystemManager.activateProxy(server, version);
        return 1;
    }

    /**
     * List available version of proxy channel for the system.
     * @param clientcert client certificate of the system.
     * @return 1 if the deactivation succeeded, 0 otherwise.
     * @since 10.5
     *
     * @xmlrpc.doc List available version of proxy channel for system
     * identified by the given client certificate i.e. systemid file.
     * @xmlrpc.param #param_desc("string", "systemid", "systemid file")
     * @xmlrpc.returntype  #array_single ("string", "version")
     */
    public List<String> listAvailableProxyChannels(String clientcert) {

        Server server = validateClientCertificate(clientcert);

        ChannelFamily proxyFamily = ChannelFamilyFactory
            .lookupByLabel(ChannelFamilyFactory
                .PROXY_CHANNEL_FAMILY_LABEL,
                null);

        List<String> returnList = new ArrayList<String>();

        if (proxyFamily == null ||
                proxyFamily.getChannels() == null ||
                proxyFamily.getChannels().isEmpty()) {
            return returnList;
        }

        /* We search for a proxy channel whose parent channel is our server's basechannel.
         * This will be the channel we attempt to subscribe the server to.
         */
        for (Channel proxyChan : proxyFamily.getChannels()) {
            if (proxyChan.getProduct() != null &&
                proxyChan.getParentChannel().equals(server.getBaseChannel())) {
                returnList.add(proxyChan.getProduct().getVersion());
            }
        }
        return returnList;
    }
}
