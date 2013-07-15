/**
 * Copyright (c) 2009--2012 Red Hat, Inc.
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
package com.redhat.rhn.frontend.dto;

import java.io.Serializable;

/**
 * SystemSearchResult
 * @version $Rev$
 */
public class SystemSearchPartialResult implements Serializable  {

    private static final long serialVersionUID = -1521482033166547203L;
    private String matchingField;
    private String matchingFieldValue;
    private Long id;

    /**
     * Constructor which takes SystemSearchResult and saves data which
     * does not com from elaborator
     * @param result SystemSearchResult which parts should be stored
     */
    public SystemSearchPartialResult(SystemSearchResult result) {
        this.setMatchingField(result.getMatchingField());
        this.setMatchingFieldValue(result.getMatchingFieldValue());
        this.setId(result.getId());
    }

    /**
     * @return returns the data in the field
     * that was searched on
     */
    public String getMatchingField() {
        return matchingField;
    }

    /**
     * @param matchingFieldIn The matchingField to set.
     */
    public void setMatchingField(String matchingFieldIn) {
        this.matchingField = matchingFieldIn;
    }

    /**
     * Takes care of cases where the DB will be returning numerical
     * instead of varchar vlues
     * @param matchingFieldIn matchingField to set
     */
    public void setMatchingField(Long matchingFieldIn) {
        this.matchingField = matchingFieldIn.toString();
    }

    /**
     * @return returns the data in the field
     * that was searched on
     */
    public String getMatchingFieldValue() {
        return matchingFieldValue;
    }

    /**
     * @param matchingFieldValueIn The matchingFieldValue to set.
     */
    public void setMatchingFieldValue(String matchingFieldValueIn) {
        this.matchingFieldValue = matchingFieldValueIn;
    }

    /**
     * Takes care of cases where the DB will be returning numerical
     * instead of varchar vlues
     * @param matchingFieldValueIn matchingFieldValue to set
     */
    public void setMatchingFieldValue(Long matchingFieldValueIn) {
        this.matchingFieldValue = matchingFieldValueIn.toString();
    }

    /**
     * @return the id
     */
    public Long getId() {
        return id;
    }

    /**
     * @param idIn the ID to set
     */
    public void setId(Long idIn) {
        this.id = idIn;
    }
}
