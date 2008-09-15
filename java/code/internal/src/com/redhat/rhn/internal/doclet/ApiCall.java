/**
 * Copyright (c) 2008 Red Hat, Inc.
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
package com.redhat.rhn.internal.doclet;

import java.util.ArrayList;
import java.util.List;

/**
 * 
 * ApiCall
 * @version $Rev$
 */
public class ApiCall implements Comparable<ApiCall> {

    private String name;
    private String doc;
    private List<String> params;
    private String returnDoc;
    private boolean deprecated;
    private String deprecatedVersion;
    
    /**
     * Gets the deprecated version
     * @return the deprecated version
     */
    public String getDeprecatedVersion() {
        return deprecatedVersion;
    }



    /**
     * sets the deprecated version
     * @param deprecatedVersionIn  the version
     */
    public void setDeprecatedVersion(String deprecatedVersionIn) {
        this.deprecatedVersion = deprecatedVersionIn;
    }


    /**
     * constructor
     *
     */
    public ApiCall() {
        params = new ArrayList<String>();
        deprecated = false;
    }
    
    
    /**
     * is the call deprecated
     * @return true of it's deprecated
     */
    public boolean isDeprecated() {
        return deprecated;
    }

    /**
     * Sets if the call is deprecated 
     * @param deprecatedIn is it deprecated?
     */
    public void setDeprecated(boolean deprecatedIn) {
        this.deprecated = deprecatedIn;
    }

    /**
     * gets the call's name (namespace)
     * @return the name
     */
    public String getName() {
        return name;
    }
    
    /**
     * Sets the call's name
     * @param nameIn the name
     */
    public void setName(String nameIn) {
        this.name = nameIn;
    }
    
    /**
     * gets the call's params
     * @return an array of the calls params
     */
    public List<String> getParams() {
        return params;
    }
    
    /**
     * sets the call's params
     * @param paramsIn the aprams to set
     */
    public void setParams(List<String> paramsIn) {
        this.params = paramsIn;
    }
    
    /**
     * adds a param to teh call's list
     * @param param the param
     */
    public void addParam(String param) {
        this.params.add(param);
    }
    
    /**
     * gets the return documentatino of the call 
     * @return the return docs
     */
    public String getReturnDoc() {
        return returnDoc;
    }
    
    /**
     * Sets the return documentation 
     * @param returnDocIn the return doc
     */
    public void setReturnDoc(String returnDocIn) {
        this.returnDoc = returnDocIn;
    }

    /**
     * gets a description of the api call
     * @return a description 
     */
    public String getDoc() {
        return doc;
    }

    /**
     * sets the description
     * @param docIn the description
     */
    public void setDoc(String docIn) {
        this.doc = docIn;
    }


    /**
     * 
     * {@inheritDoc}
     */
    public int compareTo(ApiCall o) {
        return this.getName().compareTo(o.getName());
    }
    
    
    
}
