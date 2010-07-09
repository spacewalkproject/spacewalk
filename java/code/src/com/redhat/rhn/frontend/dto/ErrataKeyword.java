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
package com.redhat.rhn.frontend.dto;


/**
 * ErrataKeyword
 * @version $Rev$
 */
public class ErrataKeyword {

    private Long errataId;
    private String keyword;
    /**
     * @return Returns the errataId.
     */
    public Long getErrataId() {
        return errataId;
    }
    /**
     * @param errataIdIn The errataId to set.
     */
    public void setErrataId(Long errataIdIn) {
        this.errataId = errataIdIn;
    }
    /**
     * @return Returns the keyword.
     */
    public String getKeyword() {
        return keyword;
    }
    /**
     * @param keywordIn The keyword to set.
     */
    public void setKeyword(String keywordIn) {
        this.keyword = keywordIn;
    }

    /**
     * {@inheritDoc}
     */
    public String toString() {
        return getKeyword();
    }
}

