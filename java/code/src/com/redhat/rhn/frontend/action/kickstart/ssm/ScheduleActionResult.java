/**
 * Copyright (c) 2013 SUSE
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
package com.redhat.rhn.frontend.action.kickstart.ssm;

import com.redhat.rhn.common.validator.ValidatorError;

import java.util.List;

/**
 * Encapsulates results of an SSM schedule action.
 * @version $Rev$
 */
public class ScheduleActionResult {

    /** Number of systems correctly scheduled. */
    private int successCount;

    /** The errors. */
    private List<ValidatorError> errors;

    /**
     * Instantiates a new result.
     * @param successCountIn the success count
     * @param errorsIn the errors
     */
    ScheduleActionResult(int successCountIn, List<ValidatorError> errorsIn) {
        successCount = successCountIn;
        errors = errorsIn;
    }

    /**
     * Gets the success count.
     * @return the success count
     */
    public int getSuccessCount() {
        return successCount;
    }

    /**
     * Gets the errors.
     * @return the errors
     */
    public List<ValidatorError> getErrors() {
        return errors;
    }
}
