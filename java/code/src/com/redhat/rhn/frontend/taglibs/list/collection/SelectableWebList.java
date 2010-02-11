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

package com.redhat.rhn.frontend.taglibs.list.collection;

import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.struts.Selectable;
import com.redhat.rhn.frontend.taglibs.list.AlphaBarHelper;
import com.redhat.rhn.frontend.taglibs.list.ListTagHelper;
import com.redhat.rhn.frontend.taglibs.list.TagHelper;

import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;


/**
 * @author paji
 * @version $Rev$
 */
abstract class SelectableWebList extends WebList {

    private boolean ignoreEmptySelection = false;

    /**
     * constructor
     * @param request servlet request
     */
    public SelectableWebList(HttpServletRequest request) {
        super(request);
        setup();
    }
    
    /**
     * Asks the helper to ignore reporting
     * errors if no checkbox was selected
     * and the dispatch action was pressed.  
     */
    public void ignoreEmptySelection() {
        ignoreEmptySelection = true;
    }
    
    /** {@inheritDoc} */
    protected void setup() {
        RequestContext context = getContext();
        HttpServletRequest request = context.getRequest();
        
        String alphaBarPressed = request.getParameter(
                                AlphaBarHelper.makeAlphaKey(
                                  TagHelper.generateUniqueName(getListName())));
        //if its not submitted
        // ==> this is the first visit to this page
        // clear the 'dirty set'
        if (!context.isSubmitted() && alphaBarPressed == null) {
            clear();
        }        
        
        if (request.getParameter(RequestContext.DISPATCH) != null) {
            // if its one of the Dispatch actions handle it..            
            update();
            
            if (size() > 0) {
                return;
            }
            else {
                if (!ignoreEmptySelection) {
                    RhnHelper.handleEmptySelection(request);    
                }
                
            }
        }
        setupDataSet();
        
        List dataSet = getDataSet();
        // if its a list action update the set and the selections
        if (ListTagHelper.getListAction(getListName(), request) != null) {
            execute(dataSet);
        }        

        // if I have a previous set selections populate data using it       
        if (size() > 0) {
            syncSelections();
        }
        ListTagHelper.setSelectedAmount(getListName(),
                                            size(), request);
            ListTagHelper.bindSetDeclTo(getListName(),
                                getDecl(), request);
    }
    
    private void syncSelections() {
        HttpServletRequest request = getContext().getRequest();
        List dataSet = getDataSet();
        
        if (!dataSet.isEmpty()) {
            if (dataSet.get(0) instanceof Selectable) {
                syncSelections(dataSet);
            }
            else {
                request.setAttribute(
                        getListName() + "Selections",
                        getSelections());
            }
        }
    }
    
    protected  String getDecl() {
        return getClass().getName();
    }
    
    /**
     * clear the set
     */
    protected abstract void clear();
    
    /**
     * Obliterate the set
     */
    protected abstract void obliterate();

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
}
