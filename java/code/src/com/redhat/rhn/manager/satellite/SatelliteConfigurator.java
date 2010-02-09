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
package com.redhat.rhn.manager.satellite;

import com.redhat.rhn.common.validator.ValidatorError;

/**
 * SatelliteConfigurator - interface to describe the storage of configuration to 
 * the local machine.
 * @version $Rev$
 */
public interface SatelliteConfigurator {

    /**
     * Store the configuration to the machine
     * @return ValidatorError[] array if there were problems
     */
    ValidatorError[] storeConfiguration();
}
