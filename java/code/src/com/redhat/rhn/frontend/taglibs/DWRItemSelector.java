/**
 * Copyright (c) 2010--2012 Red Hat, Inc.
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
package com.redhat.rhn.frontend.taglibs;

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.SessionSetHelper;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;

import org.directwebremoting.WebContext;
import org.directwebremoting.WebContextFactory;

import java.util.Set;

import javax.servlet.http.HttpServletRequest;


/**
 * DWRItemSelector
 * @version $Rev$
 */
public class DWRItemSelector {
    public static final String JSON_HEADER = "X-JSON";
    public static final String IDS = "ids";
    public static final String CHECKED = "checked";
    public static final String SET_LABEL = "set_label";

    /**
     * Dwr Item selector updates the RHNset
     * when its passed the setLabel, and ids to update
     * @param setLabel the set label
     * @param ids the ids to update
     * @param on true if the items were to be added
     * @return the selected
     * @throws Exception on exceptions
     */
    public String select(String setLabel, String[] ids, boolean on) throws Exception {
        WebContext ctx = WebContextFactory.get();
        HttpServletRequest req = ctx.getHttpServletRequest();
        Integer size = updateSetFromRequest(req, setLabel, ids, on);
        if (size == null) {
            return "";
        }
        return getResponse(size, setLabel);
    }

    // Update the proper set based upon request parameters
    private Integer updateSetFromRequest(HttpServletRequest req,
            String setLabel, String[] which, boolean isOn) throws Exception {
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
        return null;
    }


    // Write an responseText with the current count from the set
    private String getResponse(int setSize, String setLabel) {
        StringBuffer responseText = new StringBuffer();
        LocalizationService ls = LocalizationService.getInstance();
        Boolean systemsRelated = RhnSetDecl.SYSTEMS.getLabel().equals(setLabel);
        if (systemsRelated) {
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

        String paginationMessage = "";
        if (!systemsRelated) {
            paginationMessage = ls.getMessage("message.numselected",
                    Integer.toString(setSize));
        }
        responseText.append("\"pagination\":\"").
                        append(paginationMessage).
                        append("\"");
        return  "({" + responseText.toString() + "})";
    }
}
