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

import java.util.Iterator;

/**
 * KickstartScriptDeleteCommand
 * @version $Rev$
 */
public class KickstartScriptDeleteCommand extends KickstartScriptEditCommand {

    /**
     * Unused constructor.  Throws UnsupportedOperationException
     * @param ksidIn to use
     * @param userIn to use
     */
    public KickstartScriptDeleteCommand(Long ksidIn, User userIn) {
        super(ksidIn, userIn);
        throw new UnsupportedOperationException("Please use the constructor" +
                " that specifies a KickstartScript.id");
    }

    /**
     * Constructor where we specify which KickstartScript to be deleted.
     * @param ksidIn to remove KickstartScript from
     * @param kssidIn of KickstartScript to remove
     * @param userIn User modifying the KickstartData
     */
    public KickstartScriptDeleteCommand(Long ksidIn, Long kssidIn, User userIn) {
        super(ksidIn, kssidIn, userIn);
    }

    /**
     * {@inheritDoc}
     */
    public ValidatorError store() {
        // Remove the script from the collection so it gets deleted.
        Iterator i = ksdata.getScripts().iterator();
        while (i.hasNext()) {
            KickstartScript ksstemp = (KickstartScript) i.next();
        }

        if (!this.ksdata.getScripts().remove(this.script)) {
            throw new RuntimeException("Not removed!");
        }
        return super.store();
    }

}
