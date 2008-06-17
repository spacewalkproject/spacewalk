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
package com.redhat.rhn.manager.kickstart;

import com.redhat.rhn.domain.kickstart.KickstartCommandName;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.user.User;

/**
 * SystemDetailsCommand
 * 
 * @version $Rev $
 */
public class SystemDetailsCommand extends BaseKickstartCommand {
    
    /**
     * constructor
     * @param ksidIn kickstart id
     * @param userIn logged in user
     */
    public SystemDetailsCommand(Long ksidIn, User userIn) {
        super(ksidIn, userIn);
    }

    /**
     * Looks up a KickstartCommandName by name
     * @param commandName name of the KickstartCommandName
     * @return found instance, if any
     */
    public KickstartCommandName findCommandName(String commandName) {
        return KickstartFactory.lookupKickstartCommandName(commandName);
    }
}
