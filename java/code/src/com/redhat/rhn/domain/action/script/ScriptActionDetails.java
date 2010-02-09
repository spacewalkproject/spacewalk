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
package com.redhat.rhn.domain.action.script;

import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.domain.action.ActionChild;

import org.hibernate.Hibernate;

import java.sql.Blob;
import java.util.HashSet;
import java.util.Set;

/**
 * ScriptAction
 * @version $Rev$
 */
public class ScriptActionDetails extends ActionChild {
    
    private Long id;
    private String username;
    private String groupname;
    private byte[] script;
    private Long timeout;
    private Set results;
    
    /**
     * @return Returns the groupname.
     */
    public String getGroupname() {
        return groupname;
    }
    
    /**
     * @param g The groupname to set.
     */
    public void setGroupname(String g) {
        this.groupname = g;
    }
    
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
     * @return Returns the timeout.
     */
    public Long getTimeout() {
        return timeout;
    }
    
    /**
     * @param t The timeout to set.
     */
    public void setTimeout(Long t) {
        this.timeout = t;
    }
    
    /**
     * @return Returns the username.
     */
    public String getUsername() {
        return username;
    }
    
    /**
     * @param u The username to set.
     */
    public void setUsername(String u) {
        this.username = u;
    }
    
    /**
     * @return Returns the result.
     */
    public Set getResults() {
        return results;
    }
    
    /**
     * @param r The result to set.
     */
    public void setResults(Set r) {
        this.results = r;
    }

    /**
     * Add ScriptResult to the results set
     * @param r ScriptResult to add to set
     */
    public void addResult(ScriptResult r) {
        if (this.results == null) { //init results if needed
            this.results = new HashSet();
        }
        r.setParentScriptActionDetails(this);
        this.results.add(r);
    }
    
    /**
     * Get the script
     * @return Returns the script.
     */
    public byte[] getScript() {
        return script;
    }

    /**
     * Set the Script contents
     * @param scriptIn The script to set.
     */
    public void setScript(byte[] scriptIn) {
        this.script = scriptIn;
    }

    /**
     * Let Hibernate get the script blob, used only by Hibernate. 
     * @return Returns the script.
     */
    private Blob getScriptBlob() {
        if (this.script == null) {
            return null;
        }
        else {
            return Hibernate.createBlob(this.script);
        }
    }

    /**
     * Let Hibernate set the Script Blob contents, used only by Hibernate. 
     * @param scriptBlob The script to set.
     */
    private void setScriptBlob(Blob scriptBlob) {
        this.script = HibernateFactory.blobToByteArray(scriptBlob);
    }

    /**
     * Get the String version of the Script contents
     * @return String version of the Script contents
     */
    public String getScriptContents() {
        return HibernateFactory.getByteArrayContents(this.script);
    }

}
