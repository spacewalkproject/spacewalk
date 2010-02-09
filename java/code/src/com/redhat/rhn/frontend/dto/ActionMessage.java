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
 * ActionMessage
 * @version $Rev$
 */
public class ActionMessage {
    private String type;
    private String status;
    private int count;
    private String advisory;
    private String synopsis;
    
    /** {@inheritDoc} */
    public String toString() {
        return "[type=" + type + ",status=" + status + ",count=" + count +
               ",advisory=" + advisory + ",synopsis=" + synopsis + "]";
    }
    /**
     * @return Returns the advisory.
     */
    public String getAdvisory() {
        return advisory;
    }
    
    /**
     * @param advisoryIn The advisory to set.
     */
    public void setAdvisory(String advisoryIn) {
        advisory = advisoryIn;
    }
    
    /**
     * @return Returns the count.
     */
    public int getCount() {
        return count;
    }
    
    /**
     * @param countIn The count to set.
     */
    public void setCount(int countIn) {
        count = countIn;
    }
    
    /**
     * @return Returns the status.
     */
    public String getStatus() {
        return status;
    }
    
    /**
     * @param statusIn The status to set.
     */
    public void setStatus(String statusIn) {
        status = statusIn;
    }
    
    /**
     * @return Returns the synopsis.
     */
    public String getSynopsis() {
        return synopsis;
    }
    
    /**
     * @param synopsisIn The synopsis to set.
     */
    public void setSynopsis(String synopsisIn) {
        synopsis = synopsisIn;
    }
    
    /**
     * @return Returns the type.
     */
    public String getType() {
        return type;
    }
    
    /**
     * @param typeIn The type to set.
     */
    public void setType(String typeIn) {
        type = typeIn;
    }
}
