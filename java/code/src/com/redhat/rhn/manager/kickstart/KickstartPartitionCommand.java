/**
 * Copyright (c) 2009--2012 Red Hat, Inc.
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
import com.redhat.rhn.domain.user.User;

/**
 * KickstartPrePostCommand - for editing the pre and post steps
 * in a kickstart.
 * @version $Rev$
 */
public class KickstartPartitionCommand extends BaseKickstartCommand {
    /**
     * Constructor
     * @param ksidIn id of the Kickstart to lookup
     * @param userIn userIn who owns the Kickstart
     */
    public KickstartPartitionCommand(Long ksidIn, User userIn) {
        super(ksidIn, userIn);
    }

    /**
     *
     * @param partitionsIn String from dynaform
     * @return ValidatorError if validation error exists
     */
    public ValidatorError setPartitionData(String partitionsIn) {
        ksdata.setPartitionData(partitionsIn);
        return null;
    }
}
