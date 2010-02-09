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
package com.redhat.rhn.manager.system;

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.kickstart.KickstartSession;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.manager.PersistOperation;

/**
 * DeleteSystemFromActionOperation - deletes a system from an action
 * @version $Rev$
 */
public class CancelKickstartSessionOperation 
    extends BaseSystemOperation implements PersistOperation {

    /**
     * Construct the Operation
     * @param userIn who is performing this operation
     * @param sid id of System to lookup
     */
    public CancelKickstartSessionOperation(User userIn, Long sid) {
        super(sid);
        this.user = userIn;
    }
    
    /**
     * {@inheritDoc}
     */
    public ValidatorError store() {
        
        KickstartSession ksession = 
            KickstartFactory.lookupKickstartSessionByServer(server.getId());
        String failedMessage = LocalizationService.getInstance().
        getMessage("kickstart.session.user_canceled", this.user.getLogin()); 
        ksession.markFailed(failedMessage);
        KickstartFactory.saveKickstartSession(ksession);
        
        return null;
    }

}
