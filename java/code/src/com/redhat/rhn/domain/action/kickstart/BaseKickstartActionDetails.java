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
package com.redhat.rhn.domain.action.kickstart;

import com.redhat.rhn.domain.action.ActionChild;
import com.redhat.rhn.domain.common.FileList;

import java.util.HashSet;
import java.util.Set;

/**
 * 
 * BaseKickstartActionDetails
 * @version $Rev$
 */
public abstract class BaseKickstartActionDetails extends ActionChild {
    
    private String cobblerSystemName;
    private String appendString;
    private String kickstartHost;
    private Set fileLists;
    private Long id;
    
    /**
     * This is the PK for this object.  Its not the 
     * actual ID to a KickstartData object
     * @return Returns the id.
     */
    protected Long getId() {
        return id;
    }
    
    /**
     * This is the PK for this object.  Its not the 
     * actual ID to a KickstartData object.  Making 
     * this protected because nobody should really touch this.
     * @param i The id to set.
     */
    protected void setId(Long i) {
        this.id = i;
    }
    
    
    /**
     * @return Returns the appendString.
     */
    public String getAppendString() {
        return appendString;
    }
    
    /**
     * @param a The appendString to set.
     */
    public void setAppendString(String a) {
        this.appendString = a;
    }
    
    
    /**
     * @return the kickstartHost
     */
    public String getKickstartHost() {
        return kickstartHost;
    }

    
    /**
     * @param kickstartHostIn the kickstartHost to set
     */
    public void setKickstartHost(String kickstartHostIn) {
        this.kickstartHost = kickstartHostIn;
    }

    
    /**
     * @return Returns the cobblerSystemName.
     */
    public String getCobblerSystemName() {
        return cobblerSystemName;
    }

    
    /**
     * @param cobblerSystemNameIn The cobblerSystemName to set.
     */
    public void setCobblerSystemName(String cobblerSystemNameIn) {
        this.cobblerSystemName = cobblerSystemNameIn;
    }
    
    /**
     * Adds a FileList object to fileLists.
     * @param f FileList to add
     */
    public void addFileList(FileList f) {
        if (fileLists == null) {
            fileLists = new HashSet();
        }
        fileLists.add(f);
    }
    
    /**
     * @return Returns the fileLists.
     */
    public Set getFileLists() {
        return fileLists;
    }
    
    /**
     * @param f The fileLists to set.
     */
    public void setFileLists(Set f) {
        this.fileLists = f;
    }
}
