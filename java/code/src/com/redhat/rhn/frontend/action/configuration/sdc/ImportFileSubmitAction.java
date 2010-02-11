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
package com.redhat.rhn.frontend.action.configuration.sdc;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.validator.ValidatorResult;
import com.redhat.rhn.domain.config.ConfigFileName;
import com.redhat.rhn.domain.config.ConfigurationFactory;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.rhnset.RhnSetElement;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.common.RhnSetAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.manager.configuration.ConfigurationManager;
import com.redhat.rhn.manager.configuration.ConfigurationValidation;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;

import org.apache.struts.action.ActionErrors;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;
import org.apache.struts.action.DynaActionForm;

import java.util.Iterator;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


/**
 * ImportFileSubmitAction,  sdc add config file action
 * @version $Rev$
 */
public class ImportFileSubmitAction extends RhnSetAction {

    /**
     * {@inheritDoc}
     */
    protected DataResult getDataResult(User user, ActionForm form,
            HttpServletRequest request) {
        RequestContext rctx = new RequestContext(request);
        return ConfigurationManager.getInstance().listFileNamesForSystem(user,
                rctx.lookupServer(), null);
    }

    /**
     * {@inheritDoc}
     */
    protected RhnSetDecl getSetDecl() {
        return RhnSetDecl.CONFIG_FILE_NAMES;
    }

    /**
     * {@inheritDoc}
     */
    protected void processMethodKeys(Map map) {
        map.put("sdcimportfile.jsp.button", "importFile");
    }

    /**
     * {@inheritDoc}
     */
    protected void processParamMap(ActionForm formIn, HttpServletRequest requestIn,
            Map paramsIn) {
        //keep sid around
        paramsIn.put("sid", requestIn.getParameter("sid"));
    }
    
    /**
     * Validate all the written paths.  Add all of the chosen paths
     * to an RhnSet and forward to the confirm page.
     * @param mapping struts ActionMapping
     * @param formIn struts ActionForm
     * @param request HttpServletRequest
     * @param response HttpServletResponse
     * @return an ActionForward to the confirm page. To the same page
     *         if errors are found.
     */
    public ActionForward importFile(ActionMapping mapping,
                                    ActionForm formIn,
                                    HttpServletRequest request,
                                    HttpServletResponse response) {
        Map params = makeParamMap(formIn, request);
        
        //read the file names from the textbox and add them to the import set
        //return to the same page if there are any validation errors.
        if (readTextBox(formIn, request)) {
            return getStrutsDelegate().forwardParams(
                    mapping.findForward(RhnHelper.DEFAULT_FORWARD), params);
        }
        
        //read the selected file names from the form and add them to the import
        //set.  Find out how many we have selected
        int totalFiles = importSelected(request);
        
        //go to the confirm page.
        if (totalFiles > 0) {
            return getStrutsDelegate().forwardParams(
                    mapping.findForward("success"), params);
        }
        else {
            ActionErrors errors = new ActionErrors();
            errors.add(ActionMessages.GLOBAL_MESSAGE,
                    new ActionMessage("sdcimportfile.jsp.noSelected"));
            addErrors(request, errors);
            return getStrutsDelegate().forwardParams(
                    mapping.findForward(RhnHelper.DEFAULT_FORWARD), params);
        }
    }
    
    /**
     * Read line by line from the text box, update the RhnSet
     * @param formIn The ActionForm we are reading from
     * @param request HttpServletRequest
     * @return whether there were errors.
     */
    private boolean readTextBox(ActionForm formIn, HttpServletRequest request) {
        User user = new RequestContext(request).getLoggedInUser();
        
        DynaActionForm form = (DynaActionForm) formIn;
        String[] names = form.getString("contents").split("\n");
        
        RhnSet importSet = RhnSetDecl.CONFIG_IMPORT_FILE_NAMES.create(user);
        ValidatorResult result = new ValidatorResult();
        
        //Look at every path, validate and either add that path to the
        //import set or add error messages for that path to the request.
        for (int i = 0; i < names.length; i++) {
            String name = names[i].trim(); //trim takes care of \r chars too.
            if (name.equals("")) {
                continue; //skip blank lines... would cause error.
            }
            
            ValidatorResult problems = ConfigurationValidation.validatePath(name);
            
            //add to the import set
            if (problems.isEmpty()) {
                ConfigFileName path =
                    ConfigurationFactory.lookupOrInsertConfigFileName(name);
                importSet.addElement(path.getId());
            }
            //add to the errors
            else {
                result.append(problems);
            }
        }
        
        //Some of the paths had validation errors, go back to the same
        //page with a message.  The set we have been building is also moot.
        if (!result.isEmpty()) {
            importSet.clear();
            getStrutsDelegate().saveMessages(request, result);
            return true;
        }
        //No errors, save the set and go to the list.
        RhnSetManager.store(importSet);
        return false;
    }
    
    private int importSelected(HttpServletRequest request) {
        User user = new RequestContext(request).getLoggedInUser();
        //note that the set could already be populated by the text box
        RhnSet importSet = RhnSetDecl.CONFIG_IMPORT_FILE_NAMES.get(user);
        RhnSet selectedSet = updateSet(request);
        
        //All we are doing is copying the values of the selected set into
        //the import set.
        
        /*
         * To accomplish this task, I would like to just do the following line
         * importSet.getElements().addAll(selectedSet.getElements());
         * 
         * However, this does not work, because RhnSetElement contains member
         * variables for the user and set label, even though the element is
         * actually just the two longs. The user and label should be for the
         * RhnSet, but not for every element of the set.
         */
        Iterator i = selectedSet.getElements().iterator();
        while (i.hasNext()) {
            importSet.addElement(((RhnSetElement)i.next()).getElement());
        }
        
        //data cleanup
        RhnSetManager.store(importSet);
        RhnSetManager.remove(selectedSet);
        
        return importSet.size();
    }

}
