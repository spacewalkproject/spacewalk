/**
 * Copyright (c) 2008 Red Hat, Inc.
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
package com.redhat.rhn.frontend.xmlrpc.system;

import com.redhat.rhn.domain.action.Action;
import com.redhat.rhn.domain.action.server.ServerAction;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.frontend.xmlrpc.serializer.util.MapBuilder;

import java.util.Iterator;
import java.util.Map;


/**
 * ActionMapper - converts a com.redhat.rhn.domain.action.Action class into a Map
 * 
 * @version $Rev$
 */
public class ActionMapper {
    
    private MapBuilder actionsBuilder = new MapBuilder();
    private MapBuilder serverActionsBuilder = new MapBuilder();
    
    /**
     * Constructor
     */
    public ActionMapper() {
        actionsBuilder.exclude("callbacks");
        actionsBuilder.exclude("class");
        actionsBuilder.exclude("org");
        actionsBuilder.exclude("serverActions");
        actionsBuilder.exclude("hibernateLazyInitializer");
        actionsBuilder.exclude("ageString");
        actionsBuilder.exclude("formatter");
        
        serverActionsBuilder.include("pickupTime");
        serverActionsBuilder.include("completionTime");
        serverActionsBuilder.include("resultMsg");
    }
    
    /**
     * Convert an Action to a Map
     * 
     * @param convert this Action to a Map
     * @param server the server object needed to get the exact server action.. 
     * @return Map with all useful attributes from an Action converted to a string entries
     * in a map.
     */
    public Map actionToMap(Action convert, Server server) {
        Map mapped =  actionsBuilder.mapify(convert);
        ServerAction sa = null; 
        for (Iterator itr = convert.getServerActions().iterator(); itr.hasNext();) {
            ServerAction temp = (ServerAction) itr.next();
            if (server.getId().equals(temp.getServer().getId())) {
                sa = temp;
                break;
            }
        }

        if (sa != null) {
            Map actions = serverActionsBuilder.mapify(sa);
            mapped.putAll(actions);
        }
        return mapped;
    }
}
