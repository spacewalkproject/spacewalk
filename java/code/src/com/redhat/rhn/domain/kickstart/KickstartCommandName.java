/**
 * Copyright (c) 2009 Red Hat, Inc.
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
package com.redhat.rhn.domain.kickstart;


/**
 * KickstartCommandName
 * @version $Rev$
 * This is a read only table so method access will be private
 */
public class KickstartCommandName {

    private Long id;
    private Long order;
    private String name;
    private Boolean args;
    private Boolean required;
    
    /**
     * @return Returns the id.
     */
    public Long getId() {
        return id;
    }
    
    /**
     * @param i The id to set.
     */
    private void setId(Long i) {
        this.id = i;
    }
    
    /**
     * @return Returns the name.
     */
    public String getName() {
        return name;
    }
    
    /**
     * @param n The name to set.
     */
    private void setName(String n) {
        this.name = n;
    }
    
    /**
     * 
     * @param orderIn The order num to set
     */
    private void setOrder(Long orderIn) {
        this.order = orderIn;
    }
    
    /**
     * 
     * @return Returns the display Order 
     */
    public Long getOrder() {
        return this.order;
    }
    
    /**
     * 
     * @param argsIn Sets whether Command option takes in args
     */
    private void setArgs(Boolean argsIn) {
        this.args = argsIn;
    }
    
    /**
     * 
     * @return if this command can have args
     */
    public Boolean getArgs() {
        return this.args;
    }
    
    /**
     * 
     * @return if this command is required
     */
    public Boolean getRequired() {
        return this.required;
    }

    /**
     * 
     * @param requiredIn sets if this command is required
     */
    public void setRequired(Boolean requiredIn) {
        this.required = requiredIn;
    }
}
