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
package com.redhat.rhn.manager.kickstart.cobbler;

import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.user.User;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.cobbler.Profile;

/**
 * KickstartCobblerCommand - class to contain logic to communicate with cobbler
 * @version $Rev$
 */
public class CobblerProfileEditCommand extends CobblerProfileCommand {
    private static Logger log = Logger.getLogger(CobblerProfileEditCommand.class);
    
    /**
     * Constructor
     * @param ksDataIn to sync 
     * @param userIn - user wanting to sync with cobbler
     */
    public CobblerProfileEditCommand(KickstartData ksDataIn,
            User userIn) {
        super(ksDataIn, userIn);
    }

    /**
     * {@inheritDoc}
     */
    public ValidatorError store() {
        if (StringUtils.isBlank(ksData.getCobblerId())) {
            return new CobblerProfileCreateCommand(ksData, user).store();
        }
        
        String cobName = makeCobblerName(ksData);
        
        Profile prof = Profile.lookupById(CobblerXMLRPCHelper.getConnection(user), 
                ksData.getCobblerId());
      
        if (prof != null) {
            if (!cobName.equals(prof.getName())) {
                prof.setName(makeCobblerName(ksData));
            }
            updateCobblerFields(prof);
        }

        return null;
    }
}
