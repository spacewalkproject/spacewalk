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
package com.redhat.rhn.frontend.struts;

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.util.MethodUtil;
import com.redhat.rhn.domain.Identifiable;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.context.Context;
import com.redhat.rhn.frontend.taglibs.ListDisplayTag;
import com.redhat.rhn.frontend.taglibs.RhnListTagFunctions;
import com.redhat.rhn.frontend.taglibs.list.ListFilter;
import com.redhat.rhn.frontend.taglibs.list.ListFilterHelper;
import com.redhat.rhn.frontend.taglibs.list.ListTagHelper;
import com.redhat.rhn.frontend.taglibs.list.ListTagUtil;
import com.redhat.rhn.frontend.taglibs.list.TagHelper;
import com.redhat.rhn.frontend.taglibs.list.decorators.AddToSsmDecorator;
import com.redhat.rhn.manager.rhnset.RhnSetManager;
import com.redhat.rhn.manager.ssm.SsmManager;

import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;

/**
 *
 * AbstractSetHelper
 * @version $Rev$
 */
public class BaseSetHelper {
    protected HttpServletRequest request;

    public static final String KEY = "key";
    public static final String SELECTABLE = "selectable";
    public static final String SELECTED = "selected";

    /**
     * Default struts action one might want to execute
     * when selectAll, unselectAll, udate set actions are clicked
     * on a table with an Set.
     * @param set the set to update
     * @param listName the name of the list to grab the data from
     * @param dataSet the dataset that contains everything in the list
     */
    public void execute(Set set, String listName, List dataSet)  {
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


                String attr = request.getParameter(
                        ListTagUtil.makeFilterAttributeByLabel(uniqueName));
                String header = request.getParameter(
                        ListTagUtil.makeFilterByLabel(uniqueName));


                ListFilter klass = null;
                try {
                    klass = (ListFilter) MethodUtil.getClassFromConfig(filterClass);
                }
                catch (RuntimeException e) {
                    try {
                        klass = (ListFilter) MethodUtil.getClassFromConfig(
                                filterClass, header, attr);
                    }
                    catch (RuntimeException e2) {
                        filterList = dataSet;
                    }
                }
                if (klass != null) {
                    Context threadContext = Context.getCurrentContext();
                    klass.prepare(threadContext.getLocale());
                }
                filterList = ListFilterHelper.filterChildren(dataSet, klass,
                        request.getParameter(
                                ListTagUtil.makeFilterByLabel(uniqueName)),
                                ListTagHelper.getFilterValue(request, uniqueName),
                                ListTagHelper.canSearchByParent(request, uniqueName),
                                ListTagHelper.canSearchByChild(request, uniqueName));
            }
            else {
                filterList = ListFilterHelper.filterChildren(dataSet, null, null, null, 
                        ListTagHelper.canSearchByParent(request, uniqueName),
                        ListTagHelper.canSearchByChild(request, uniqueName));
            }

            selectAll(set, listName, filterList);
        }
        else if (lookupEquals(ListDisplayTag.UNSELECT_ALL_KEY, value)) {
            unselectAll(set, listName, dataSet);
        }
        else if (lookupEquals(ListDisplayTag.ADD_TO_SSM_KEY, value)) {

            // If this isn't done, the servers will be added to the SSM but the table
            // itself will have the selected servers cleared
            updateSet(set, listName);

            String[] selected = ListTagHelper.getSelected(listName, request);
            
            RequestContext context = new RequestContext(request);
            User user = context.getLoggedInUser();

            // If the user requested, first clear the SSM server set
            // Note: if the checkbox is selected, this executes regardless of whether or not
            // any servers were selected in the table
            if (request.getParameter(AddToSsmDecorator.PARAM_CLEAR_SSM) != null) {
                SsmManager.clearSsm(user);
            }

            // If the user has made any selections, add those to the SSM 
            if (selected != null && selected.length > 0) {
                SsmManager.addServersToSsm(user, selected);
            }
        }
    }

    
    protected boolean lookupEquals(String lookupKey, String value) {
        if (value == null) {
            return false;
        }
        LocalizationService ls = LocalizationService.getInstance();
        String lookedup = ls.getMessage(lookupKey);
        return value.equals(lookedup);
    }


    /**
     * Updates the set with the items on the current page of the list
     * @param set the set to update
     * @param listName the name of the list to grab the data from
     */
    public void updateSet(Set set,
            String listName) {
        String[] selected = ListTagHelper.getSelected(listName, request);
        String[] itemsOnPage = ListTagHelper.getAll(listName, request);

        //remove all the items on page
        if (itemsOnPage != null) {
            for (String item :  itemsOnPage) {
                set.remove(item);
            }
        } //if

        //add all the items selected
        if (selected != null) {
            for (String item :  selected) {
                set.add(item);
            }
        } //if

        ListTagHelper.setSelectedAmount(listName, set.size(), request);
        storeSet(set);
    }



    /**
     * Clears set for the user.
     * @param set the set to update
     * @param listName the name of the list to grab the data from
     * @param dataSet the dataSet to deselect
     **/
    public void unselectAll(Set set,
                              String listName, List dataSet) {
        set.clear();
        ListTagHelper.setSelectedAmount(listName, 0, request);

        for (Object obj : dataSet) {
            if (obj instanceof Selectable) {
                Selectable next = (Selectable) obj;
                next.setSelected(false);
            }
            else if (obj instanceof Map) {
                Map next = (Map) obj;
                next.remove(SELECTED);
            }
            else {
                break;
            }
        }
        storeSet(set);
    }


    /**
     * Syncs the selections provided by the rhnset to dataset.
     *  This is useful when you want to pre select check boxes
     * @param set this is an Set that holds the selections
     * @param dataSet the dataset that contains everything in the list.
     *                Note theitems in the dataset are expected to implement
     *                'com.redhat.rhn.frontend.struts.Selectable'.
     *                These are required for use with rhnset.
     */
    public void syncSelections(Set set, List dataSet) {
        for (Object obj : dataSet) {
            if (obj instanceof Selectable) {
                Selectable next = (Selectable) obj;
                if (next.isSelectable()) {
                    if (set.contains(next.getSelectionKey())) {
                        next.setSelected(true);
                    }
                }
            }
            else if (obj instanceof Map) {
                Map next = (Map) obj;
                if (next.containsKey(SELECTABLE) &&
                        set.contains(next.get(KEY))) {
                    next.put(SELECTED, true);
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
    public void selectAll(Set set,
                                String listName,
                                 List dataSet) {
        
        boolean everyThingIsAnElement = ListTagHelper.
                            isParentAnElement(request,
                                    TagHelper.generateUniqueName(listName));
        for (Object obj : dataSet) {
            if (everyThingIsAnElement || !RhnListTagFunctions.isExpandable(obj)) {
                if (obj instanceof Selectable) {
                    Selectable next = (Selectable) obj;
                    if (next.isSelectable()) {
                        set.add(next.getSelectionKey());
                    }
                }
                else if (obj instanceof Map) {
                    Map next = (Map) obj;
                    set.add((String)next.get(SessionSetHelper.KEY));
                }
                else {
                   Identifiable next = (Identifiable) obj;
                   set.add(next.getId().toString());
                }
            }            
        }
        storeSet(set);
        ListTagHelper.setSelectedAmount(listName, set.size(), request);
    }

    protected void storeSet(Set set) {
        if (set instanceof RhnSet) {
            RhnSetManager.store((RhnSet) set);
        }
    }

}
