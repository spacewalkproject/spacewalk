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

package com.redhat.rhn.frontend.taglibs.list.helper;

import com.redhat.rhn.frontend.dto.BaseDto;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.struts.Selectable;
import com.redhat.rhn.frontend.taglibs.list.AlphaBarHelper;
import com.redhat.rhn.frontend.taglibs.list.ListTagHelper;
import com.redhat.rhn.frontend.taglibs.list.TagHelper;

import java.util.Collection;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;


/**
 * This class could also be termed as 
 * the base class for a SelectableWebList
 * Basically this guy serves as abstract base class to
 * List Tags that use sets (sessionset or rhnset), i.e.
 * selectable columns
 * <code>
 * JSP side->
 *  <rl:list ....>
 *   ....
 *           <rl:decorator name="SelectableDecorator"/>
 *           <rl:selectablecolumn value="${current.selectionKey}"
 *               selected="${current.selected}"
 *               styleclass="first-column"/>
 *   .....            
 *  </rl:list>
 * Action Side -> 
 *  Java Side ->
 *   public class  ..... extends RhnAction implements Listable {
 *      public ActionForward execute(.....) {
 *          Map params = new HashMap();
 *          params.put("foo_id", request.getParamater("foo_id")); 
 *          ListSessionSetHelper helper = new ListSessionSetHelper
 *                                          (this, request, params);
 *          helper.execute();
 *          if (helper.isDsipatched()) {
 *              //do the submit side of the action
 *              // like remove packages/add systems or whatever
 *              // the dispatch action needs to do
 *              String set = helper.getSet();
 *              for (String item: set) {
 *                  Manager.addFooToDb(Long.valueOf(item));
 *              }
 *              getStrutsDelegate().saveMessage(
 *                   "foo.added",
 *                       new String [] {String.valueOf(set.size())}, request);
 *              return getStrutsDelegate().forwardParam(mapping.findForward("success"), 
 *                                      "foo_id",request.getParamater("foo_id") );
 *          }
 *          return mapping.findForward(RhnHelper.DEFAULT_FORWARD);         
 *      }
 *      
 *      public List getResults(RequestContext context) {
 *          .......
 *          return  fooList;
 *      }
 *   }
 * </code>  
 * @author paji
 * @version $Rev$
 */
abstract class ListSetHelper extends ListHelper {
    private boolean dispatched = false;
    private boolean ignoreEmptySelection = false;
    private boolean willClearSet = true;
    private boolean preSelectAll = false;
    
    private Set initSet = Collections.EMPTY_SET; 
    /**
     * constructor
     * @param inp takes in a ListSubmitable
     * @param request the servlet request
     * @param params the parameter map for this request
     */
    public ListSetHelper(Listable inp, HttpServletRequest request, Map params) {
        super(inp, request, params);
    }

    /**
     * constructor
     * @param inp takes in a ListSubmitable
     * @param request the servlet request
     */
    public ListSetHelper(Listable inp, HttpServletRequest request) {
        this(inp, request, Collections.EMPTY_MAP);
    }

    
    /**
     * Asks the helper to ignore reporting
     * errors if no checkbox was selected
     * and the dispatch action was pressed.  
     */
    public void ignoreEmptySelection() {
        ignoreEmptySelection = true;
    }
    
    /***
     * @return true if the dispatch action was called by execute.
     */
    public boolean isDispatched() {
        return dispatched;
    }

    
    /** {@inheritDoc} */
    public void execute() {
        RequestContext context = getContext();
        HttpServletRequest request = context.getRequest();
        String alphaBarPressed = request.getParameter(
                                AlphaBarHelper.makeAlphaKey(
                                  TagHelper.generateUniqueName(getListName())));
        //if its not submitted
        // ==> this is the first visit to this page
        // clear the 'dirty set'
        if (!context.isSubmitted() && alphaBarPressed == null && willClearSet) {
            clear();
            add(getPreSelected());
        }

        if (request.getParameter(RequestContext.DISPATCH) != null) {
            // if its one of the Dispatch actions handle it..            
            update();

            // We can consider the request dispatched (in other words valid) if the
            // user selected something or we explicitly indicated that we allow no
            // selections
            if (size() > 0 || ignoreEmptySelection) {
                dispatched = true;
                return;
            }
            else {
                if (!ignoreEmptySelection) {
                    RhnHelper.handleEmptySelection(request);    
                }
                
            }
        }
        
        List dataSet = getDataSet();
        

        if (!context.isSubmitted() && alphaBarPressed == null && preSelectAll) {
            Set selSet = new HashSet();
            for (BaseDto bdto : (List<BaseDto>) dataSet) {
                selSet.add(bdto.getId());
            }
            add(selSet);
        }


        // if its a list action update the set and the selections
        if (ListTagHelper.getListAction(getListName(), request) != null) {
            execute(dataSet);
        }

        // if I have a previous set selections populate data using it       
        if (size() > 0) {
            syncSelections(dataSet, request);
        }
        ListTagHelper.setSelectedAmount(getListName(),
                                                size(), request);

        ListTagHelper.bindSetDeclTo(getListName(), 
                                getDecl(), request);
    }
    
    private void syncSelections(List dataSet,
                    HttpServletRequest request) {
        if ((dataSet != null) && (!dataSet.isEmpty())) {
            if (dataSet.get(0) instanceof Selectable) {
                syncSelections(dataSet);
            }
            request.setAttribute(
                    makeSelectionsName(getListName()),
                    getSelections());
        }
    }
    
    /**
     * Returns the name of the selections key.
     * @param listName the name of the list 
     * i.e. the value specifidied in <rl:list name=>
     * @return
     */
    public static String makeSelectionsName(String listName) {
        return listName + "Selections";
    }
    
    /**
     * @return the initSet
     */
    protected Set getPreSelected() {
        return initSet;
    }

    
    /**
     * @param set the initial set of items to prepopulate
     */
    public void preSelect(Set set) {
        this.initSet = set;
    }
    
    /**
     * gets the declaration associated to this set
     * @return the appropriate declaration.
     */
    public abstract String getDecl();
    
    /**
     * clear the set
     */
    protected abstract void clear();

    /**
     * Update the set getting data 
     * from List, basically perform
     * the RhnListSetHelper.updateSet 
     */
    protected abstract void update();
    
    /**
     * Perform the execute step of the helpers
     * basicall handles the selectall updateset etc..
     * @param dataSet the input data set
     */
    protected abstract void execute(List dataSet);

    /**
     * sync the selections of rhn or session set to dataset.
     * @param dataSet the result set.
     */
    protected abstract void syncSelections(List dataSet);
    
    /**
     * return the size of the set
     * @return set size
     */
    protected abstract int size();
    
    /**
     * returns the selections map.
     * @return selection map
     */
    protected abstract Map getSelections();
    
    /**
     * Add elements to a set.
     * @param set set to add. 
     */
    protected abstract void add(Set set);
    
    /**
     * Obliterates the set from Session or Database
     */
    protected abstract void destroy();
    
    /**
     * Returns a list of items that were added
     *  to the initial set
     * @return Set of ids of items that were added.
     */
    public abstract Collection getAddedKeys();

    /**
     * Returns a list of items that were removed
     *  from the initial set (basically list of unselected items)
     * @return Set of ids of items that were removed.
     */
    public abstract Collection getRemovedKeys();

    /**
     * @return the willClearSet
     */
    public boolean isWillClearSet() {
        return willClearSet;
    }

    /** 
     * If set to true the associated set will be cleared when setting up the page
     * For something like SystemSetManager we don't want this, so set this to false.
     * @param willClearSet the willClearSet to set
     */
    public void setWillClearSet(boolean willClearSetIn) {
        this.willClearSet = willClearSetIn;
    }


    /**
     * @return Returns the preSelectAll.
     */
    public boolean isPreSelectAll() {
        return preSelectAll;
    }


    /**
     * @param preSelectAllIn The preSelectAll to set.
     */
    public void setPreSelectAll(boolean preSelectAllIn) {
        this.preSelectAll = preSelectAllIn;
    }

}
