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
 * VirtualizationSetVcpusAction - Class representing TYPE_VIRTUALIZATION_SET_VCPUS
 * @version $Rev$
 */
public class VirtualizationSetVcpusAction extends BaseVirtualizationAction {

    public static final String SET_CPU_STRING = "setVcpu";
    
    private Integer vcpu;

    /**
     * Set the vcpus to be appied to the guest.
     * @param vcpuIn New setting for guest vcpus.
     */
    public void setVcpu(Integer vcpuIn) {
        vcpu = vcpuIn;
    }

    /**
     * Guest the guest vcpus.
     * @return The guest vcpu setting.
     */
    public Integer getVcpu() {
        return vcpu;
    }

    /**
     * {@inheritDoc}
     */
    public void extractParameters(Map context) {
        if (context.containsKey(VirtualizationSetVcpusAction.SET_CPU_STRING)) {
            setVcpu(new Integer((String)context.get(
                    VirtualizationSetVcpusAction.SET_CPU_STRING)));
        }
    }

}

