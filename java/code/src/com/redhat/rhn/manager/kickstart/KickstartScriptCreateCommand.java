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
import com.redhat.rhn.domain.kickstart.KickstartScript;
import com.redhat.rhn.domain.user.User;

/**
 * KickstartScriptCreateCommand - Command for creating a new KickstartScript object
 * associated with specified KickstartData.
 * @version $Rev$
 */
public class KickstartScriptCreateCommand extends BaseKickstartScriptCommand {

    /**
     *
     * @param ksidIn kicksart id to associate this script with
     * @param userIn User who is doing the creating
     */
    public KickstartScriptCreateCommand(Long ksidIn, User userIn) {
        super(ksidIn, userIn);
        this.script = new KickstartScript();
    }

    /**
     * {@inheritDoc}
     */
    public ValidatorError store() {
        // Its important that we add the script only before
        // we save otherwise we will get scripts showing up
        // when the user only had to click on the page.
        this.ksdata.addScript(this.script);
        return super.store();
    }


}
