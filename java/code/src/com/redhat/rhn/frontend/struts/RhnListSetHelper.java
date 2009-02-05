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
package com.redhat.rhn.frontend.struts;

import java.util.Iterator;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.domain.Identifiable;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.rhnset.RhnSetElement;
import com.redhat.rhn.frontend.context.Context;
import com.redhat.rhn.frontend.taglibs.ListDisplayTag;
import com.redhat.rhn.frontend.taglibs.list.ListFilter;
import com.redhat.rhn.frontend.taglibs.list.ListFilterHelper;
import com.redhat.rhn.frontend.taglibs.list.ListTagHelper;
import com.redhat.rhn.frontend.taglibs.list.ListTagUtil;
import com.redhat.rhn.frontend.taglibs.list.TagHelper;
import com.redhat.rhn.manager.rhnset.RhnSetManager;


/**
 * RhnListSetHelper
 * @version $Rev$
 */
public class RhnListSetHelper {
    private HttpServletRequest request;
    /**
     * Constructor
     * 
     * @param requestIn to associate
     */
    public  RhnListSetHelper(HttpServletRequest requestIn) {
        this.request = requestIn;
    }
    
        
    /**
     * Updates the set with the items on the current page of the list
     * @param set the set to update
     * @param listName the name of the list to grab the data from
     */
    public void updateSet(RhnSet set, 
                                String listName) {
        String[] selected = ListTagHelper.getSelected(listName, request);
        String[] itemsOnPage = ListTagHelper.getAll(listName, request);
        
        //remove all the items on page
        if (itemsOnPage != null) {
            set.removeElements(itemsOnPage);
        } //if

        //add all the items selected
        if (selected != null) {
            set.addElements(selected);
        } //if
        
        ListTagHelper.setSelectedAmount(listName, set.size(), request);
        // Save the new RhnSet
        RhnSetManager.store(set);
    }

    /**
     * Syncs the selections provided by the rhnset to dataset.
     *  This is useful when you want to pre select check boxes 
     * @param set this is an RhnSet that holds the selections  
     * @param dataSet the dataset that contains everything in the list.
     *                Note theitems in the dataset are expected to implement
     *                'com.redhat.rhn.frontend.struts.Selectable'. 
     *                These are required for use with rhnset.
     */
    public void syncSelections(RhnSet set, List dataSet) {
        for (Object obj : dataSet) {
            if (obj instanceof Selectable) {
                Selectable next = (Selectable) obj;
                if (next.isSelectable()) {
                    RhnSetElement elem = new RhnSetElement(set.getUserId(), 
                                                                set.getLabel(),
                                                                next.getSelectionKey());
                    if (set.contains(elem)) {
                        next.setSelected(true);
                    }
                }
            }
            else if (obj instanceof Map) {
                Map next = (Map) obj;
                RhnSetElement key = new RhnSetElement(set.getUserId(), 
                                    set.getLabel(),
                                (String)next.get(SessionSetHelper.KEY));
                if (next.containsKey(SessionSetHelper.SELECTABLE) &&
                                                    set.contains(key)) {
                    next.put(SessionSetHelper.SELECTED, true);
                }
            }
        }        
    }

        
    /**
     * Puts all systems visible to the user into the set. 
     * @param set the set to update
     * @param listName the name of the list to grab the data from.                
     * @param dataSet the dataset that contains everything in the list.
     *                Note theitems in the dataset are expected to implement
     *                'com.redhat.rhn.frontend.struts.Selectable'. 
     *                These are required for use with rhnset.  
     */
    public void selectAll(RhnSet set, 
                                    String listName, 
                                    List dataSet) {
        set.clear();
        for (Object obj : dataSet) {
            if (obj instanceof Selectable) {
                Selectable next = (Selectable) obj;
                if (next.isSelectable()) {
                    set.addElement(next.getSelectionKey());                    
                }
            }
            else if (obj instanceof Map) {
                Map next = (Map) obj;
                set.addElement((String)next.get(SessionSetHelper.KEY));
            }
            else {
               Identifiable next = (Identifiable) obj;
               set.addElement(next.getId()); 
            }
        }
        RhnSetManager.store(set);
        ListTagHelper.setSelectedAmount(listName, set.size(), request);        
    }

    /**
     * Clears set for the user.
     * @param set the set to update
     * @param listName the name of the list to grab the data from
     * @param dataSet the dataSet to deselect 
     **/
    public void unselectAll(RhnSet set, 
                              String listName, List dataSet) {
        set.clear();
        RhnSetManager.store(set);
        ListTagHelper.setSelectedAmount(listName, 0, request);
        for (Iterator<Selectable> it = dataSet.iterator(); it.hasNext();) {
            it.next().setSelected(false);
        }
    }
    
    /**
     * Default struts action one might want to execute
     * when selectAll, unselectAll, udate set actions are clicked 
     * on a table with an Rhn Set. 
     * @param set the set to update
     * @param listName the name of the list to grab the data from 
     * @param dataSet the dataset that contains everything in the list
     */
    public void execute(RhnSet set, 
                                String listName, 
                                List dataSet)  {
        
        
        String value = ListTagHelper.getListAction(listName, request);                

        if (ListTagHelper.PAGE_ACTION.equals(value)) {
            updateSet(set, listName);
        }
        else if (lookupEquals(ListDisplayTag.UPDATE_LIST_KEY, value)) {
            int sizeBefore = set.size();
            updateSet(set, listName);
            if (sizeBefore == 0 && set.isEmpty()) {
                RhnHelper.handleEmptySelection(request);
            }
        } 
        else if (lookupEquals(ListDisplayTag.SELECT_ALL_KEY, value)) {
            List filterList = null;
            
            String uniqueName = TagHelper.generateUniqueName(listName);
            String filterClass = (String) request.getParameter(
                    ListTagUtil.makeFilterClassLabel(uniqueName));
            if (filterClass != null) {

                ClassLoader cl = Thread.currentThread().getContextClassLoader();
                try {
                    ListFilter klass =  
                        (ListFilter)  cl.loadClass(filterClass).newInstance();
                    klass.prepare(Context.getCurrentContext().getLocale());
                    
                    filterList = ListFilterHelper.filter(dataSet, klass, 
                            request.getParameter(
                                    ListTagUtil.makeFilterByLabel(uniqueName)),
                                    ListTagHelper.getFilterValue(request, uniqueName));
                }
                catch (ClassNotFoundException e) {
                    filterList = dataSet;
                }
                catch (IllegalAccessException e2) {
                    filterList = dataSet;
                }
                catch (InstantiationException e3) {
                    filterList = dataSet;
                }

            }
            else {
                filterList = dataSet;
            }

            selectAll(set, listName, filterList);
        }
        else if (lookupEquals(ListDisplayTag.UNSELECT_ALL_KEY, value)) {
            unselectAll(set, listName, dataSet);
        }        
    }
    
    private boolean lookupEquals(String lookupKey, String value) {
        LocalizationService ls = LocalizationService.getInstance();
        String lookedup = ls.getMessage(lookupKey);
        return value.equals(lookedup);
    }
}
