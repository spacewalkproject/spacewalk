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
package com.redhat.rhn.domain.common;

import com.redhat.rhn.common.conf.ConfigException;

import java.net.MalformedURLException;
import java.net.URL;
import java.util.Date;

/**
 * TinyUrl - Class representation of the table rhntinyurl.
 * @version $Rev: 1 $
 */
public class TinyUrl {

    private String token;
    private String url;
    private boolean enabled;
    private Date created;
    private Date expires;
    /** 
     * Getter for token 
     * @return String to get
    */
    public String getToken() {
        return this.token;
    }

    /** 
     * Setter for token 
     * @param tokenIn to set
    */
    public void setToken(String tokenIn) {
        this.token = tokenIn;
    }

    /** 
     * Getter for url 
     * @return String to get
    */
    public String getUrl() {
        return this.url;
    }

    /** 
     * Setter for url 
     * @param urlIn to set
    */
    public void setUrl(String urlIn) {
        this.url = urlIn;
    }

    /** 
     * Getter for enabled 
     * @return String to get
    */
    public boolean getEnabled() {
        return this.enabled;
    }

    /** 
     * Setter for enabled 
     * @param enabledIn to set
    */
    public void setEnabled(boolean enabledIn) {
        this.enabled = enabledIn;
    }

    /** 
     * Getter for created 
     * @return Date to get
    */
    public Date getCreated() {
        return this.created;
    }

    /** 
     * Setter for created 
     * @param createdIn to set
    */
    public void setCreated(Date createdIn) {
        this.created = createdIn;
    }

    /** 
     * Getter for expires 
     * @return Date to get
    */
    public Date getExpires() {
        return this.expires;
    }

    /** 
     * Setter for expires 
     * @param expiresIn to set
    */
    public void setExpires(Date expiresIn) {
        this.expires = expiresIn;
    }
    
    /**
     * Translate this TinyUrl's url into a usable URL String
     * @param hostIn to generate the URL to.
     * @return String path:  
     */
    public String computeTinyUrl(String hostIn) {
        URL retval;
        try {
            retval = new URL("http", hostIn, this.computeTinyPath());
        }
        catch (MalformedURLException e) {
            throw new ConfigException("We cant compute the TinyUrl. ", e);
        }
        return retval.toString();
    }
    
    /**
     * Translate this TinyUrl's path into a just the path portion
     * without the http://hostname: /ty/token
     * 
     * @return String path /ty/token   
     */
    public String computeTinyPath() {
        return "/ty/" + this.token;
    }
    
    
}
