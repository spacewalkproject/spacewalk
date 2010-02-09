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
package com.redhat.rhn.domain.common;


/**
 * CommonConstants
 * @version $Rev$
 */
public class CommonConstants {

    private CommonConstants() {
    }
    
    /**
     * Get constant for virtualization_platform (limited)
     * @return VirtSubscriptionLevel for virt-limited
     */
    public static final VirtSubscriptionLevel getVirtSubscriptionLevelFree() {
        return CommonFactory.
            lookupVirtSubscriptionLevel("virtualization_free");
    }
    
    /**
     * Get constant for virtualization_platform_free
     * @return VirtSubscriptionLevel for platform
     */
    public static final VirtSubscriptionLevel getVirtSubscriptionLevelPlatformFree() {
        return CommonFactory.
            lookupVirtSubscriptionLevel("virtualization_platform_free");
    }
    
}
