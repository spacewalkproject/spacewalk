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
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.kickstart.KickstartSession;
import com.redhat.rhn.domain.kickstart.KickstartSessionState;
import com.redhat.rhn.domain.kickstart.KickstartVirtualizationType;

/**
 * KickstartSessionUpdateCommand - Command to update a KickstartSession's status
 * @version $Rev$
 */
public class KickstartSessionUpdateCommand {

    private KickstartSession sess;

    /**
     * Constructor
     * @param sessionId of KickstartSession
     */
    public KickstartSessionUpdateCommand(Long sessionId) {
        sess = KickstartFactory.lookupKickstartSessionById(sessionId);
    }

    /**
     * Store the KickstartSession
     * @return ValidatorError if something failed
     */
    public ValidatorError store() {
        KickstartFactory.saveKickstartSession(this.sess);
        return null;
    }

    /**
     * Set the state of the session.
     * @param stateIn to update the KickstartSession to
     */
    public void setSessionState(KickstartSessionState stateIn) {
        this.sess.setState(stateIn);
    }

    /**
     * Set the client IP that is kickstarting.
     * @param clientIpIn to set.
     */
    public void setClientIp(String clientIpIn) {
        this.sess.setClientIp(clientIpIn);
    }

    /**
     * Set the virtualization type of the session.
     * @param typeIn to update the KickstartSession to
     */
    public void setSessionVirtualizationType(KickstartVirtualizationType typeIn) {
        this.sess.setVirtualizationType(typeIn);
    }

    /**
     * Get the KickstartData associated with this command.
     * @return KickstartData object
     */
    public KickstartData getKsdata() {
        return this.sess.getKsdata();
    }

    /**
     * Get the KickstartSession
     * @return KickstartSession associated with this command.
     */
    public KickstartSession getKickstartSession() {
        return this.sess;
    }



}
