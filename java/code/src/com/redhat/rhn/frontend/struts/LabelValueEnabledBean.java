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

package com.redhat.rhn.frontend.struts;

import org.apache.struts.util.LabelValueBean;

/**
 * An extension of the LabelValueBean that adds in 
 * an extra attribute that can be defined.  Useful for configuring 
 * UI widgets that have display value, actual value and a 'checked' or 
 * 'enabled' attribute.
 * @version $Rev: 1591 $
 */

public class LabelValueEnabledBean extends LabelValueBean {

    private boolean disabled = false;
    
    /**
     * Create a new MultiboxItem
     * @param label to set
     * @param value to set
     * @param disabledIn true if disabled
     */
    public LabelValueEnabledBean(String label, String value, boolean disabledIn) {
        super(label, value);
        disabled = disabledIn;
    }
    
    /**
     * Create a new MultiboxItem
     * @param label to set
     * @param value to set
     */    
    public LabelValueEnabledBean(String label, String value) {
        this(label, value, false);
    }
    /**
     * Get the disabled field.  This can be used from within a JSP
     * to set the disabled flag on the item.
     * @return Returns the disabled.
     */    
    public boolean isDisabled() {
        return disabled;
    }
    
}
