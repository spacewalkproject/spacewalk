/**
 * Copyright (c) 2009 Red Hat, Inc.
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

import com.redhat.rhn.domain.token.Token;
import com.redhat.rhn.domain.token.TokenFactory;
import com.redhat.rhn.domain.user.User;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Iterator;
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
    public void removeTokensByIds(ArrayList ids) {
        Iterator toRemoveIter = ids.iterator();

        while (toRemoveIter.hasNext()) {
            Long id = (Long) toRemoveIter.next();

            Iterator tokensIter = this.getKickstartData().getDefaultRegTokens().iterator();

            while (tokensIter.hasNext()) {
                Token token = (Token) tokensIter.next();

                if (token.getId() == id) {
                    tokensIter.remove();
                }
            }
        }
    }

    /** 
     * Adds default regtokens from the kickstart profile.
     * @param ids The ids of the regtokens to add.
    */
    public void addTokensByIds(ArrayList ids) {
        Iterator toAddIter = ids.iterator();

        while (toAddIter.hasNext()) {
            Long id = (Long) toAddIter.next();
            
            this.getKickstartData().addDefaultRegToken(TokenFactory.lookupById(id));
        }
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
