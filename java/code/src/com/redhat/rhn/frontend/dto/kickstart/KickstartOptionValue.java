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
package com.redhat.rhn.frontend.dto.kickstart;


/**
 * DTO for a com.redhat.rhn.domain.kickstart.KickstartOptionValue
 * @version $Rev: 50942 $
 */
public class KickstartOptionValue implements Comparable<KickstartOptionValue> {

    private String name;    
    private String arg;    
    private Boolean hasArgs;
    private Boolean enabled;
    private Boolean required;
    private String additionalNotesKey; // resource key
    
    /**
     * 
     *default constructor
     */
    public KickstartOptionValue() {
        this.arg = "";
    }
    
    /**
     * 
     * @return If value is allowed optional arguments
     */
    public Boolean getHasArgs() {
        return hasArgs;
    }
    
    /**
     * 
     * @param hasArgsIn to set for advanced option
     */
    public void setHasArgs(Boolean hasArgsIn) {
        this.hasArgs = hasArgsIn;
    }
    
    /**
     * 
     * @return name of ui widget 
     */
    public String getName() {
        return name;
    }
    
    /**
     * 
     * @param nameIn of ui widget to set
     */
    public void setName(String nameIn) {
        this.name = nameIn;
    }
    
    /**
     * Return the value of the option argument with '"' characters 
     * replaced by their HTML escape sequence '&quot;'.
     * @return value of the option arg
     */
    public String getArg() {
        if (arg != null) {
            return arg.replaceAll("\"", "&quot;");
        }
        else {
            return arg;
        }
    }
    
    /**
     * 
     * @param argIn of optional arg to set
     */
    public void setArg(String argIn) {
        this.arg = argIn;
    }
    
    /**
     * 
     * @return if this option is enabled
     */
    public Boolean getEnabled() { 
        return this.enabled;
    }
    
    /**
     * 
     * @param enabledIn to set 
     */
    public void setEnabled(Boolean enabledIn) {
        this.enabled = enabledIn;
    }

    /**
     * 
     * @return if this option is required
     */
    public Boolean getRequired() {
        return required;
    }

    /**
     * 
     * @param requiredIn set if this option is required
     */
    public void setRequired(Boolean requiredIn) {
        this.required = requiredIn;
    }

    
    /**
     * @return Returns the additionalNotesKey.
     */
    public String getAdditionalNotesKey() {
        return additionalNotesKey;
    }

    
    /**
     * @param additionalNotesKeyIn The additionalNotesKey to set.
     */
    public void setAdditionalNotesKey(String additionalNotesKeyIn) {
        this.additionalNotesKey = additionalNotesKeyIn;
    }

    /** {@inheritDoc} */
    public boolean equals(Object o) {
        if (this == o) { return true; }
        if (!(o instanceof KickstartOptionValue)) { return false; }

        KickstartOptionValue that = (KickstartOptionValue) o;

        if (arg != null ? !arg.equals(that.arg) : that.arg != null) { return false; }
        if (enabled != null ? !enabled.equals(that.enabled) : that.enabled != null)
            { return false; }
        if (name != null ? !name.equals(that.name) : that.name != null) { return false; }

        return true;
    }

    /** {@inheritDoc} */
    public int hashCode() {
        int result;
        result = (name != null ? name.hashCode() : 0);
        result = 31 * result + (arg != null ? arg.hashCode() : 0);
        result = 31 * result + (enabled != null ? enabled.hashCode() : 0);
        return result;
    }

    /**
     * 
     * {@inheritDoc}
     */
    public int compareTo(KickstartOptionValue o) {
        return getName().compareTo(o.getName());
    }
}
