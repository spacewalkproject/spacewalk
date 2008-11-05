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

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.db.datasource.Elaborator;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.struts.Selectable;

import org.apache.log4j.Logger;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


/**
 * @author paji
 * @version $Rev$
 */
abstract class ListSetHelper {
    
    private static Logger log = Logger.getLogger(ListSetHelper.class);
    private ListSubmitable listable;
    private boolean obliterateOnCompletion = true;
    private boolean dispatched = false;
    private boolean ignoreEmptySelection = false;
    private boolean willClearSet = true;

    /**
     * constructor
     * @param inp takes in a ListSubmitable
     */
    public ListSetHelper(ListSubmitable inp) {
        listable = inp;
    }

    /**
     * Asks the LisySetHelper to
     *  not obliterate the set 
     *  when done with the handleDispatch operation.
     *  This implies that the action using
     *  this helper is responsible for the 
     *  cleanup of the the session set. 
     *  (useful in list/confirm pages where a set
     *  needs to be preserved in multiple pages)
     */
    public void preserveSetOnCompletion() {
        obliterateOnCompletion = false;
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
    public ActionForward execute(ActionMapping mapping,
                                 ActionForm formIn,
                                 HttpServletRequest request,
                                 HttpServletResponse response) {
        
        RequestContext context = new RequestContext(request);
        ListSetAdapter adapter = getAdapter(request, listable);
        String alphaBarPressed = request.getParameter(
                                AlphaBarHelper.makeAlphaKey(
                                  TagHelper.generateUniqueName(listable.getListName())));
        //if its not submitted
        // ==> this is the first visit to this page
        // clear the 'dirty set'
        if (!context.isSubmitted() && alphaBarPressed == null && willClearSet) {
            adapter.clear();
        }        
        
        if (request.getParameter(RequestContext.DISPATCH) != null) {
            // if its one of the Dispatch actions handle it..            
            adapter.update();
            
            if (adapter.size() > 0) {
                
                ActionForward forward = listable.
                                handleDispatch(mapping, formIn, request, response);
                if (obliterateOnCompletion) {
                    adapter.obliterate();
                }
                dispatched = true;
                return forward;
            }
            else {
                if (!ignoreEmptySelection) {
                    RhnHelper.handleEmptySelection(request);    
                }
                
            }
        }
        List dataSet = listable.getResult(context);
        
        // if its a list action update the set and the selections
        if (ListTagHelper.getListAction(listable.getListName(), request) != null) {
            adapter.execute(dataSet);
        }        

        // if I have a previous set selections populate data using it       
        if (adapter.size() > 0) {
            syncSelections(adapter, dataSet, request);
        }
        ListTagHelper.setSelectedAmount(listable.getListName(),
                                            adapter.size(), request);
        
        request.setAttribute(ListTagHelper.PARENT_URL, 
                                    listable.getParentUrl(context));  
        
        request.setAttribute(listable.getDataSetName(), dataSet);
        ListTagHelper.bindSetDeclTo(listable.getListName(), 
                                listable.getDecl(context), request);
        if (dataSet instanceof DataResult) {
            DataResult data = (DataResult) dataSet;
            Elaborator elab = data.getElaborator();
            if (elab != null) {
                TagHelper.bindElaboratorTo(listable.getListName(), 
                        elab, request);       
            }
        }

        return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
    }
    
    private void syncSelections(ListSetAdapter adapter, 
                    List dataSet,
                    HttpServletRequest request) {
        if ((dataSet != null) && (!dataSet.isEmpty())) {
            if (dataSet.get(0) instanceof Selectable) {
                adapter.syncSelections(dataSet);
            }
            else {
                request.setAttribute(
                        listable.getListName() + "Selections",
                        adapter.getSelections());
            }
        }
    }
    
    protected abstract ListSetAdapter getAdapter(HttpServletRequest req,
                                    ListSubmitable ls);

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
}
