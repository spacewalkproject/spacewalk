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
package com.redhat.rhn.domain.action.config;

import com.redhat.rhn.domain.action.ActionChild;
import com.redhat.rhn.domain.config.ConfigFileName;
import com.redhat.rhn.domain.server.Server;


/**
 * ConfigFileNameAssociation -- Represents DB table, rhnActionConfigFileName
 * @version $Rev$
 */
public class ConfigFileNameAssociation extends ActionChild {
    
    private ConfigFileName configFileName;
    private Server server;
    
    /**
     * @return Returns the configFileName.
     */
    public ConfigFileName getConfigFileName() {
        return configFileName;
    }
    
    /**
     * @param configFileNameIn The configFileName to set.
     */
    public void setConfigFileName(ConfigFileName configFileNameIn) {
        configFileName = configFileNameIn;
    }
    
    /**
     * @return Returns the server.
     */
    public Server getServer() {
        return server;
    }
    
    /**
     * @param serverIn The server to set.
     */
    public void setServer(Server serverIn) {
        server = serverIn;
    }
    
}
