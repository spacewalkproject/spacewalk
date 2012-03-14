/**
 * Copyright (c) 2012 Red Hat, Inc.
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
package com.redhat.rhn.domain.audit;

/**
 * XccdfBenchmark - Class representation of the table rhnXccdfBenchmark.
 * @version $Rev$
 */
public class XccdfBenchmark {

    private Long id;
    private String identifier;
    private String version;

    /**
     * Getter for id
     * @return Long to get
    */
    public Long getId() {
        return this.id;
    }

    /**
     * Setter for id
     * @param idIn to set
    */
    public void setId(Long idIn) {
        this.id = idIn;
    }

    /**
     * Getter for identifier
     * @return String to get
    */
    public String getIdentifier() {
        return this.identifier;
    }

    /**
     * Setter for identifier
     * @param identifierIn to set
    */
    public void setIdentifier(String identifierIn) {
        this.identifier = identifierIn;
    }

    /**
     * Getter for version
     * @return String to get
     */
    public String getVersion() {
        return this.version;
    }

    /**
     * Setter for version
     * @param versionIn to set
     */
    public void setVersion(String versionIn) {
        this.version = versionIn;
    }
}
