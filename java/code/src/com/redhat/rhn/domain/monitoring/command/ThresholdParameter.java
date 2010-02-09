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

import java.util.Comparator;

/**
 * A command parameter that represents a threshold triggering
 * a probe. Maps table <tt>rhn_command_param_threshold</tt>; the mapping
 * is in the mapping file for 
 * {@link com.redhat.rhn.domain.monitoring.command.CommandParameter}
 * @version $Rev$
 */
public class ThresholdParameter extends CommandParameter {
    
    private String thresholdType;
    private Metric metric;
    
    /**
     * @return Returns the typeName.
     */
    public ThresholdType getThresholdType() {
        return ThresholdType.findType(thresholdType);
    }

    /**
     * @return Returns the metric.
     */
    public Metric getMetric() {
        return metric;
    }

    /**
     * ByType - compare threshold parameters so that they are ordered
     * by the threshold type
     */
    public static final class ByType implements Comparator {

        /**
         * {@inheritDoc}
         */
        public int compare(Object o1, Object o2) {
            ThresholdParameter t1 = (ThresholdParameter) o1;
            ThresholdParameter t2 = (ThresholdParameter) o2;
            return t1.getThresholdType().compareTo(t2.getThresholdType());
        }

    }

}
