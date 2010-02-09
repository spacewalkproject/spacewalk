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
package com.redhat.rhn.domain.kickstart;

import org.apache.commons.lang.StringUtils;

import java.util.Date;

/**
 * KickstartCommandName
 * @version $Rev$
 */
public class KickstartCommand implements Comparable {

    private Long id;
    private String arguments;
    private Date created;
    private Date modified;
    private KickstartCommandName commandName;
    private KickstartData kickstartData;
    private Integer customPosition;
    
    /**
     * @return Returns the id.
     */
    public Long getId() {
        return id;
    }
    
    /**
     * @param i The id to set.
     */
    public void setId(Long i) {
        this.id = i;
    }
    
    /**
     * @return Returns the name.
     */
    public String getArguments() {
        return arguments;
    }
    
    /**
     * @param argsIn The arguments to set.
     */
    public void setArguments(String argsIn) {
        this.arguments = argsIn;
    }

    /**
     * @return Returns the created.
     */
    public Date getCreated() {
        return created;
    }
    /**
     * @param createdIn The created to set.
     */
    public void setCreated(Date createdIn) {
        this.created = createdIn;
    }

    /**
     * @return Returns the modified.
     */
    public Date getModified() {
        return modified;
    }
    /**
     * @param modifiedIn The modified to set.
     */
    public void setModified(Date modifiedIn) {
        this.modified = modifiedIn;
    }

    /**
     * @return Returns the ksdata.
     */
    public KickstartData getKickstartData() {
        return kickstartData;
    }

    /**
     * @param ksdataIn The KickstartData to set.
     */
    public void setKickstartData(KickstartData ksdataIn) {
        this.kickstartData = ksdataIn;
    }

    /**
     * @return Returns the kickstart command name.
     */
    public KickstartCommandName getCommandName() {
        return commandName;
    }

    /**
     * @param commandNameIn The KickstartData to set.
     */
    public void setCommandName(KickstartCommandName commandNameIn) {
        this.commandName = commandNameIn;
    }
    
    /**
     * 
     * @param kc KickstartCommand to compare
     * @return how does it stack up!
     */    
    public int compareTo(Object kc) {
        if (kc == this) {
            return 0;
        }
        KickstartCommand k = (KickstartCommand)kc;
        int order = getCommandName().getOrder().compareTo(k.getCommandName().getOrder());
        
        if (order == 0) {
            String ourArgs = StringUtils.defaultString(getArguments(), "");
            String theirArgs = StringUtils.defaultString(k.getArguments(), "");
            order = ourArgs.compareTo(theirArgs);
        }
        
        return order;
    }

    /**
     * Clone or 'deepCopy' this KickstartCommand into a new one
     * @param ksDataIn who owns this new instance
     * @return KickstartCommand object that is new.
     */
    public KickstartCommand deepCopy(KickstartData ksDataIn) {
        KickstartCommand cloned = new KickstartCommand();
        cloned.setArguments(this.getArguments());
        cloned.setCommandName(this.getCommandName());
        cloned.setKickstartData(ksDataIn);
        Date now = new Date();
        cloned.setCreated(now);
        cloned.setModified(now);
        return cloned;
    }

    
    /**
     * {@inheritDoc}
     */
    public String toString() {
            return this.getClass().getName() + " name: " + 
                this.getCommandName().getName() + " arguments " + getArguments();
     }

    /**
     * gets the custom command position
     * @return the position of the custom option
     */
    public Integer getCustomPosition() {
        return customPosition;
    }

    /**
     * sets the custom command position.  This is ignored by KickstartCommandComparator 
     *          if id is not null
     * @param customPositionIn the position to set the custom option for
     */
    public void setCustomPosition(Integer customPositionIn) {
        this.customPosition = customPositionIn;
    }
}
