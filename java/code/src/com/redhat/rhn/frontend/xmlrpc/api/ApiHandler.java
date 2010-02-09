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
package com.redhat.rhn.frontend.xmlrpc.api;

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.frontend.xmlrpc.BaseHandler;

/**
 * ApiHandler
 * Corresponds to API.pm in old perl code.
 * @version $Rev$
 * @xmlrpc.namespace api
 * @xmlrpc.doc Methods providing information about the API.
 */
public class ApiHandler extends BaseHandler {

    /**
     * Returns the server version.
     * @return Returns the server version.
     *
     * @xmlrpc.doc Returns the server version.
     * @xmlrpc.returntype string
     */
    public String systemVersion() {
        return Config.get().getString("web.version");
    }
    
    /**
     * Returns the api version. Called as: api.get_version
     * @return the api version.
     *
     * @xmlrpc.doc Returns the version of the API. Since Spacewalk 0.4
     * (Satellie 5.3) it is no more related to server version.
     * @xmlrpc.returntype string
     */
    public String getVersion() {
        return Config.get().getString("web.apiversion");
    }
}
