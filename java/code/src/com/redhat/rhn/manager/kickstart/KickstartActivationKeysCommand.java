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

import com.redhat.rhn.domain.token.ActivationKeyFactory;
import com.redhat.rhn.domain.token.Token;
import com.redhat.rhn.domain.token.TokenFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.manager.kickstart.cobbler.CobblerXMLRPCHelper;

import org.cobbler.Profile;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashSet;
import java.util.Set;

/**
 * KickstartActivationKeysCommand
 * @version $Rev$
 */
public class KickstartActivationKeysCommand extends BaseKickstartCommand {

    /**
     *
     * @param ksid Kickstart Id
     * @param userIn Logged in User
     */
    public KickstartActivationKeysCommand(Long ksid, User userIn) {
        super(ksid, userIn);
    }

    /**
     * Removes default regtokens from the kickstart profile.
     * @param ids The ids of the regtokens to remove.
    */
    public void removeTokensByIds(ArrayList<Long> ids) {
        Set<String> keysToRemove = new HashSet<String>();

        for (Long id : ids) {
            Set<Token> tokenSetCopy = new HashSet<Token>();
            tokenSetCopy.addAll(this.getKickstartData().getDefaultRegTokens());
            for (Token token : tokenSetCopy) {
                if (token.getId() == id) {
                    this.getKickstartData().getDefaultRegTokens().remove(token);
                    keysToRemove.add(ActivationKeyFactory.lookupByToken(token).getKey());
                }
            }
        }

        Profile prof = Profile.lookupById(
                CobblerXMLRPCHelper.getConnection(this.getUser()),
                this.getKickstartData().getCobblerId());
        if (prof != null) {
            prof.syncRedHatManagementKeys(keysToRemove, Collections.EMPTY_SET);
        }
        prof.save();
    }

    /**
     * Adds default regtokens from the kickstart profile.
     * @param ids The ids of the regtokens to add.
    */
    public void addTokensByIds(ArrayList<Long> ids) {
        Set<String> keysToAdd = new HashSet<String>();

        for (Long id : ids) {
            Token token = TokenFactory.lookupById(id);
            this.getKickstartData().addDefaultRegToken(token);
        }
        //So we will add them all even if they are already there (in case the
        //  Key was added via the commandline and doesn't actually have them :/
        for (Token token : this.getKickstartData().getDefaultRegTokens()) {
            keysToAdd.add(ActivationKeyFactory.lookupByToken(token).getKey());
        }

        Profile prof = Profile.lookupById(
                CobblerXMLRPCHelper.getConnection(this.getUser()),
                this.getKickstartData().getCobblerId());
        if (prof != null) {
            prof.syncRedHatManagementKeys(Collections.EMPTY_SET, keysToAdd);
        }
        prof.save();
    }

    /**
     * Get the Set of ActivationKeys (Registration Tokens)
     *  associated with this profile.
     * @return Set of ActivationKeys (Registration Tokens)
     */
    public Set getDefaultRegTokens() {
        if (this.ksdata.getDefaultRegTokens() != null) {
            return this.ksdata.getDefaultRegTokens();
        }
        else {
            return Collections.EMPTY_SET;
        }
    }

}
