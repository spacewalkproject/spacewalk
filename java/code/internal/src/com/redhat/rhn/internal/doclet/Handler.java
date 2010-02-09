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
package com.redhat.rhn.internal.doclet;

import java.util.ArrayList;
import java.util.List;

/**
 * 
 * Handler
 * @version $Rev$
 */
public class Handler implements Comparable<Handler> {

    
    
    private String name;
    private String desc;
    private String className;
    private List<ApiCall> calls;
    
    /**
     * Constructor
     */
    public Handler() {
        calls = new ArrayList<ApiCall>();
    }
    
    /**
     * gets the handler's class name
     * @return name
     */
    public String getClassName() {
        return className;
    }
    
    /**
     * Gets a list of the handler's api calls
     * @return the calls
     */
    public List<ApiCall> getCalls() {
        return calls;
    }

    /**
     * Sets the list of the handlers apicalls 
     * @param callsIn the calls
     */
    public void setCalls(List<ApiCall> callsIn) {
        this.calls = callsIn;
    }

    /**
     * sets the class name of the handler
     * @param classNameIn the class name
     */
    public void setClassName(String classNameIn) {
        this.className = classNameIn;
    }
    
    /**
     * gets the (non-class) name of the handler
     * @return the name
     */
    public String getName() {
        return name;
    }
    
    /**
     * sets the name of the handler
     * @param nameIn the name
     */
    public void setName(String nameIn) {
        this.name = nameIn;
    }
    
    /**
     * adds an apicall to the list
     * @param callIn the call to add
     */
    public void addApiCall(ApiCall callIn) {
        calls.add(callIn);
    }

    /**
     * gets the description of the handler
     * @return the description
     */
    public String getDesc() {
        return desc;
    }

    /**
     * sets the description of the handler
     * @param descIn the description
     */
    public void setDesc(String descIn) {
        this.desc = descIn;
    }

    /**
     * 
     * {@inheritDoc}
     */
    public int compareTo(Handler o) {
        return this.getName().compareTo(o.getName());
    }
    
    
    
    
}
