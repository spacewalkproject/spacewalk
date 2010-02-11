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
package com.redhat.rhn.frontend.action.satellite;

import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.manager.satellite.SatelliteConfigurator;

import net.sf.cglib.core.ReflectUtils;

import org.apache.log4j.Logger;

/**
 * BaseConfigAction - contains common methods for Struts Actions needing to
 * config a sat.
 * @version $Rev$
 */
public abstract class BaseConfigAction extends RhnAction {

    /**
     * Logger for this class
     */
    private static Logger logger = Logger.getLogger(BaseConfigAction.class);

    /**
     * Get the command this Action will use.  This method uses the 
     * config value: 
     * 
     * web.com.redhat.rhn.frontend.action.satellite.GeneralConfigAction.command
     * 
     * to determine a dynamic classname to use to instantiate the
     * ConfigureSatelliteCommand. This can be useful if you want to 
     * specify a different class to use for the Command at runtime.
     * 
     * @param currentUser who is requesting this config.
     * @return ConfigureSatelliteCommand instance
     */
    protected SatelliteConfigurator getCommand(User currentUser) {
        if (logger.isDebugEnabled()) {
            logger.debug("getCommand(User currentUser=" + currentUser + ") - start");
        }

        String className = getCommandClassName(); 
            
        try {
            Class c = Class.forName(className);
            Class[] paramTypes = new Class[1];
            paramTypes[0] = User.class;
            Object[] args = new Object[1];
            args[0] = currentUser;
                                       
            SatelliteConfigurator sc = (SatelliteConfigurator) 
                ReflectUtils.newInstance(c, paramTypes, args);

            if (logger.isDebugEnabled()) {
                logger.debug("getCommand(User) - end - return value=" + sc);
            }
            return sc;
        }
        catch (ClassNotFoundException e) {
            logger.error("getCommand(User)", e);

            throw new RuntimeException(e);
        }
    }
    
    /**
     * Subclasses implement this to indicate the name of the class to 
     * use when fetching the Command instance 
     * 
     * @return String classname
     */
    protected abstract String getCommandClassName();

    
}
