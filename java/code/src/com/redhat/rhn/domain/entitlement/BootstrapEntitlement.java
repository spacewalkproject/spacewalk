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
package com.redhat.rhn.domain.entitlement;

import com.redhat.rhn.manager.entitlement.EntitlementManager;

/**
 * The Class BootstrapEntitlement.
 *
 * @version $Rev$
 */
public class BootstrapEntitlement extends Entitlement {

    /**
     * Constructor.
     */
    public BootstrapEntitlement() {
        super(EntitlementManager.BOOTSTRAP_ENTITLED);
    }

    /**
     * Instantiates a new bootstrap entitlement with a label.
     * @param labelIn the label
     */
    BootstrapEntitlement(String labelIn) {
        super(labelIn);
    }

    /**
     * {@inheritDoc}
     */
    public boolean isPermanent() {
        return false;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public boolean isBase() {
        return false;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public boolean isSatelliteEntitlement() {
        return false;
    }
}
