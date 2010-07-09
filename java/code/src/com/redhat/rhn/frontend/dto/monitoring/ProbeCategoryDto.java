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
package com.redhat.rhn.frontend.dto.monitoring;

/**
 * ProbeTypeGroup
 * @version $Rev$
 */
public class ProbeCategoryDto extends CheckProbeDto {
        private String description;
        private Long probeCount;
        private Long serverCount;

        /**
         * @return String that is a description of probes in probe category
         */
        public String getDescription() {
            return this.description;
        }

        /**
         * @return Long that is a count of how many probes are in this category
         */
        public Long getProbeCount() {
            return this.probeCount;
        }

        /**
         * @return Long that is count of how many servers are affected by the probe group
         */
        public Long getServerCount() {
            return this.serverCount;
        }

        /**
         *@param stringIn String that is the description of the probe category
         */
        public void setDescription(String stringIn) {
            this.description = stringIn;
        }

        /**
         * @param longIn Long that is the number of probes in the category
         */
        public void setProbeCount(Long longIn) {
            this.probeCount = longIn;
        }

        /**
         * @param longIn Long that is the number of probes in the category
         */
        public void setServerCount(Long longIn) {
            this.serverCount = longIn;
        }
}
