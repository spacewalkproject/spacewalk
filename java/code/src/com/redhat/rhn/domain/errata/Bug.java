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
package com.redhat.rhn.domain.errata;


/**
 * Bug
 * @version $Rev$
 */
public interface Bug  {
    
    /**
     * @return Returns the id.
     */
    Long getId();
    
    /**
     * @param i The id to set.
     */
    void setId(Long i);
    
    /**
     * @return Returns the summary.
     */
    String getSummary();
    
    /**
     * @param s The summary to set.
     */
    void setSummary(String s);
    
    /**
     * @return Returns the errata.
     */
    Errata getErrata();
    
    /**
     * @param errataIn the errata to set.
     */
    void setErrata(Errata errataIn);
}
