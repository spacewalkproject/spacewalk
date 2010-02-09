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
package com.redhat.rhn.manager.kickstart;

import com.redhat.rhn.domain.kickstart.KickstartScript;
import com.redhat.rhn.domain.user.User;

import java.util.Iterator;

/**
 * KickstartScriptEditCommand
 * @version $Rev$
 */
public class KickstartScriptEditCommand extends BaseKickstartScriptCommand {

    /**
     * Throws IllegalArgumentException.  Must use:
     * 
     * KickstartScriptEditCommand(Long ksidIn, Long scriptId, User userIn)
     * 
     * @param ksidIn id of Kickstart
     * @param userIn user wanting to edit
     */
    public KickstartScriptEditCommand(Long ksidIn, User userIn) {
        super(ksidIn, userIn);
        throw new IllegalArgumentException(
                "Need to construct this Command with a KickstartScript id");
    }
    
    /**
     * Constructor that initalizes the KickstartScript associated with the 
     * KickstartData we get from the ksidIn
     * @param ksidIn id of the KickstartData object
     * @param scriptId id of the KickstartScript object associated with this KickstartData
     * @param userIn User who wants to edit
     */
    public KickstartScriptEditCommand(Long ksidIn, Long scriptId, User userIn) {
        super(ksidIn, userIn);
        Iterator i = this.ksdata.getScripts().iterator();
        
        while (i.hasNext()) { 
            KickstartScript s = (KickstartScript) i.next();
            if (s.getId().equals(scriptId)) {
                this.script = s;
            }
        }
        if (this.script == null) {
            throw new IllegalArgumentException("KickstartScript with ID: " + 
                    scriptId + " not found to be associated with this KicsktartData");
        }
        
    }

}
