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

import com.redhat.rhn.frontend.struts.Selectable;

/**
 * 
 * PatchSetOverview
 * @version $Rev$
 */
public class PatchSetOverview implements Selectable {

    
    
    private Long id;
    private String name;
    private String nvre;
    private String summary;
    private String arch;
    private String nvrea;
    private String setDate;
    private boolean selected;
    
    /**
     * @return Returns the arch.
     */
    public String getArch() {
        return arch;
    }
    
    /**
     * @param archIn The arch to set.
     */
    public void setArch(String archIn) {
        this.arch = archIn;
    }
    
    /**
     * @return Returns the id.
     */
    public Long getId() {
        return id;
    }
    
    /**
     * @param idIn The id to set.
     */
    public void setId(Long idIn) {
        this.id = idIn;
    }
    
    /**
     * @return Returns the name.
     */
    public String getName() {
        return name;
    }
    
    /**
     * @param nameIn The name to set.
     */
    public void setName(String nameIn) {
        this.name = nameIn;
    }
    
    /**
     * @return Returns the nvre.
     */
    public String getNvre() {
        return nvre;
    }
    
    /**
     * @param nvreIn The nvre to set.
     */
    public void setNvre(String nvreIn) {
        this.nvre = nvreIn;
    }
    
    /**
     * @return Returns the nvrea.
     */
    public String getNvrea() {
        return nvrea;
    }
    
    /**
     * @param nvreaIn The nvrea to set.
     */
    public void setNvrea(String nvreaIn) {
        this.nvrea = nvreaIn;
    }
    
    /**
     * @return Returns the setDate.
     */
    public String getSetDate() {
        return setDate;
    }
    
    /**
     * @param setDateIn The setDate to set.
     */
    public void setSetDate(String setDateIn) {
        this.setDate = setDateIn;
    }
    
    /**
     * @return Returns the summary.
     */
    public String getSummary() {
        return summary;
    }
    
    /**
     * @param summaryIn The summary to set.
     */
    public void setSummary(String summaryIn) {
        this.summary = summaryIn;
    }
    
    /**
     * 
     * {@inheritDoc}
     */
    public String getSelectionKey() {
        return this.getId().toString();
    }
    
    /**
     * 
     * {@inheritDoc}
     */
    public boolean isSelectable() {
       return true;
    }
    
    /**
     * 
     * {@inheritDoc}
     */
    public boolean isSelected() {
        return selected;
    }
    
    /**
     * 
     * {@inheritDoc}
     */
    public void setSelected(boolean selectedIn) {
        this.selected = selectedIn;
        
    }
    
    
    

}
