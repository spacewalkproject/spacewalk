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
package com.redhat.rhn.domain.monitoring.command;

import java.util.Set;

/**
 * CommandClass - Class representation of the table rhn_command_class.
 * @version $Rev: 1 $
 */
public class CommandClass {
    
    private String className;
    private Set metrics;
    
    /** 
     * Getter for className 
     * @return String to get
    */
    public String getClassName() {
        return this.className;
    }

    /** 
     * Setter for className 
     * @param classNameIn to set
    */
    public void setClassName(String classNameIn) {
        this.className = classNameIn;
    }

    /**
     * @return Returns the metrics.
     */
    public Set getMetrics() {
        return metrics;
    }
    /**
     * @param metricsIn The metrics to set.
     */
    public void setMetrics(Set metricsIn) {
        this.metrics = metricsIn;
    }
}
