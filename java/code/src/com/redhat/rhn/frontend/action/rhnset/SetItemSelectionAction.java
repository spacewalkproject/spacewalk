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
package com.redhat.rhn.frontend.action.rhnset;

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.SessionSetHelper;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.io.IOException;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * This action is for the Javascript found in check_all.js
 *
 * The idea is that when a checkbox is clicked, a request is made that
 * updates the set controlled by the page, and returns an xml chunk
 * that is then used by the javascript code to update the totals on
 * the page.  Currently works only for the system list {@link RhnSetDecl#SYSTEMS}.
 * 
 * @version $Rev$
 */
public class SetItemSelectionAction extends RhnAction {    

    public static final String JSON_HEADER = "X-JSON";
    public static final String IDS = "ids";
    public static final String CHECKED = "checked";
    public static final String SET_LABEL = "set_label";
    
    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping, ActionForm formIn,
            HttpServletRequest req, HttpServletResponse resp) throws Exception {
        Integer size = updateSetFromRequest(req);
        if (size == null) {
            return null;
        }
        String setLabel = req.getParameter(SET_LABEL);        
        writeResponse(resp, size, setLabel);

        return null;
    }

    // Update the proper set based upon request parameters
    private Integer updateSetFromRequest(HttpServletRequest req) throws Exception {
        String setLabel = req.getParameter(SET_LABEL);
        String[] which = req.getParameterValues(IDS);
        String checked = req.getParameter(CHECKED);
        boolean isOn = checked.equals("on"); 
        
        if (which == null) {
            return null;
        }

        if (SessionSetHelper.exists(req, setLabel)) {
            Set<String> set  = SessionSetHelper.lookupAndBind(req, setLabel);

            if (isOn) {
                for (String id : which) {
                    set.add(id);    
                }
            }
            else {
                for (String id : which) {
                    set.remove(id);    
                }
            }
            return set.size();
        }
        else {
            RhnSetDecl decl = RhnSetDecl.find(setLabel);
            if (decl != null) {
                RhnSet set = decl.get(new RequestContext(req).getLoggedInUser());
                if (isOn) {
                    set.addElements(which);
                }
                else {
                    set.removeElements(which);
                }
                RhnSetManager.store(set);
                return set.size();    
            }
        }
        return null;
    }    
    
    
    // Write an responseText with the current count from the set
    private void writeResponse(HttpServletResponse resp, int setSize, String setLabel)
        throws IOException {
        StringBuffer responseText = new StringBuffer();
        LocalizationService ls = LocalizationService.getInstance(); 
        if (RhnSetDecl.SYSTEMS.getLabel().equals(setLabel)) {
            String headerMessage;
            if (setSize == 0) {
                headerMessage = ls.getMessage("header.jsp.noSystemsSelected");
            }
            else if (setSize == 1) {
                headerMessage = ls.getMessage("header.jsp.singleSystemSelected");
            }
            else {
                headerMessage = ls.getMessage("header.jsp.systemsSelected", 
                                                      Integer.toString(setSize));
            }
            responseText.append("\"header\":\"").append(headerMessage).append("\"");
            
        }

        if (responseText.length() > 0) {
            responseText.append(",");
        }
        
        String  paginationMessage = ls.getMessage("message.numselected",
                                                Integer.toString(setSize));
        responseText.append("\"pagination\":\"").
                        append(paginationMessage).
                        append("\"");
        
        resp.setContentType("application/json");
        resp.addHeader("X-JSON", 
                        "({" + responseText.toString() + "})");
    }

}
