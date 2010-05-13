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

import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.user.User;

import org.cobbler.Profile;

/**
 * KickstartCloneCommand - class to clone a KickstartData object and its children
 * @version $Rev$
 */
public class KickstartCloneCommand extends BaseKickstartCommand {

    private KickstartData clonedKickstart;
    private String newLabel; 
    
    
    /**
     * Construct a KickstartCloneCommand
     * @param ksidIn id of KickstartData that wants to be cloned
     * @param userIn user doing the cloning
     * @param newLabelIn to gived to cloned ks.
     */
    public KickstartCloneCommand(Long ksidIn, User userIn, String newLabelIn) {
        super(ksidIn, userIn);
        this.newLabel = newLabelIn;
    }

    /**
     * Execute the clone or copy of the KickstartData associated with this command.
     * 
     * Call getClonedKickstart() to get the new object created.
     * 
     * @return ValidatorError if there was a problem
     */
    public ValidatorError store() {
        if (clonedKickstart != null) {
            throw new UnsupportedOperationException(
                    "Can't call store twice on this Command");
        }
        // we keep the name and the label the same.
        clonedKickstart = this.ksdata.deepCopy(user, newLabel);
        KickstartWizardHelper helperCmd = new KickstartWizardHelper(user);
        helperCmd.store(clonedKickstart);
        
        Profile original = ksdata.getCobblerObject(user);
        Profile cloned = clonedKickstart.getCobblerObject(user);
        cloned.setKsMeta(original.getKsMeta());
        
        cloned.setVirtRam(((Integer) original.getVirtRam()));
        cloned.setVirtCpus(original.getVirtCpus());
        cloned.setVirtFileSize(((Integer) original.getVirtFileSize()));
        cloned.setVirtBridge(original.getVirtBridge());
        cloned.setVirtPath(original.getVirtBridge());
        cloned.save();
        
        return null;
    }

    
    /**
     * @return the clonedKickstart
     */
    public KickstartData getClonedKickstart() {
        return clonedKickstart;
    }

    
    /**
     * @return the newLabel
     */
    public String getNewLabel() {
        return newLabel;
    }

    
}
