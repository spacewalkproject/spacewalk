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

package com.redhat.rhn.frontend.taglibs.list;

import com.redhat.rhn.frontend.struts.RequestContext;

import org.apache.struts.action.ActionMapping;

import java.util.List;

/**
 * 
 * @author paji
 * Listable
 * @version  $Rev$
 */
public interface Listable {
    /**
     * The dataresult associated to a set
     * @param context the request context 
     * @param mapping the action mapping
     * @return a List of Selectable or Identifiable objects
     */
    List getResult(RequestContext context, ActionMapping mapping);
    
    /**
     * gets the list name
     * @return listname
     */
    String getListName();
    
    /**
     * gets the DataSet Name
     * @return dataSetName
     */
    String getDataSetName();
    
    /** 
     * returns the parent Url
     * @param context the request context
     * @return parent url
     */
    String getParentUrl(RequestContext context);

}
