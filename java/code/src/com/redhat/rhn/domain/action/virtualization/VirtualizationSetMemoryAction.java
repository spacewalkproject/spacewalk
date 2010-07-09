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
package com.redhat.rhn.domain.action.virtualization;

import java.util.Map;

/**
 * VirtualizationSetMemoryAction - Class representing TYPE_VIRTUALIZATION_SET_MEMORY.
 * Make sure the 'memory' field is in kilobytes.
 *
 * @version $Rev$
 */
public class VirtualizationSetMemoryAction extends BaseVirtualizationAction {

    public static final String SET_MEMORY_STRING = "setMemory";

    private Integer memory;

    /**
     * Set the memory to be appied to the guest.  This is KILOBYTES
     * @param memoryIn New setting for guest memory.
     */
    public void setMemory(Integer memoryIn) {
        memory = memoryIn;
    }

    /**
     * Guest the guest memory. KILOBYTES
     * @return The guest memory setting.
     */
    public Integer getMemory() {
        return memory;
    }

    /**
     * {@inheritDoc}
     */
    public void extractParameters(Map context) {
        if (context.containsKey(VirtualizationSetMemoryAction.SET_MEMORY_STRING)) {
            setMemory(new Integer((String)context.get(
                    VirtualizationSetMemoryAction.SET_MEMORY_STRING)));
        }
    }

}
