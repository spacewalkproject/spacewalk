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
package com.redhat.rhn.frontend.action.rhnpackage.ssm;

import java.util.List;
import java.util.Set;
import java.util.ArrayList;
import java.util.Map;
import java.util.Date;
import java.util.Iterator;
import java.util.HashMap;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.DynaActionForm;
import org.apache.struts.action.ActionMessages;
import org.apache.struts.action.ActionMessage;
import org.apache.commons.lang.StringUtils;
import com.redhat.rhn.frontend.taglibs.list.helper.Listable;
import com.redhat.rhn.frontend.taglibs.list.helper.ListHelper;
import com.redhat.rhn.frontend.taglibs.list.TagHelper;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.struts.SessionSetHelper;
import com.redhat.rhn.frontend.struts.StrutsDelegate;
import com.redhat.rhn.frontend.dto.PackageListItem;
import com.redhat.rhn.common.util.DatePicker;
import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.rhnset.SetCleanup;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.rhnpackage.PackageEvr;
import com.redhat.rhn.manager.rhnset.RhnSetManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.system.SystemManager;
import com.redhat.rhn.manager.action.ActionManager;

/**
 * @version $Revision$
 */
public class SchedulePackageUpgradeAction extends RhnAction implements Listable {

    private static final String DATA_SET = "pageList";

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping actionMapping,
                                 ActionForm actionForm,
                                 HttpServletRequest request,
                                 HttpServletResponse response) throws Exception {
        
        RequestContext requestContext = new RequestContext(request);
        
        ListHelper helper = new ListHelper(this, request);
        helper.setDataSetName(DATA_SET);
        helper.execute();

        if (request.getParameter("dispatch") != null) {
            if (requestContext.wasDispatched("installconfirm.jsp.confirm")) {
                return executePackageAction(actionMapping, actionForm, request, response);
            }
        }

        // Prepopulate the date picker 
        DynaActionForm dynaForm = (DynaActionForm) actionForm;
        DatePicker picker = getStrutsDelegate().prepopulateDatePicker(request, dynaForm,
            "date", DatePicker.YEAR_RANGE_POSITIVE);

        request.setAttribute("date", picker);

        return actionMapping.findForward(RhnHelper.DEFAULT_FORWARD);
    }
    
    /** {@inheritDoc} */
    public List getResult(RequestContext context) {

        HttpServletRequest request = context.getRequest();
        User user = context.getLoggedInUser();

        // Stuff packages into an RhnSet to be used in the query
        String packagesDecl = (String) request.getAttribute("packagesDecl");
        if (packagesDecl != null) {
            Set<String> data = SessionSetHelper.lookupAndBind(request, packagesDecl);

            // bz465892 - As the selected packages are parsed, remove duplicates
            // keeping the highest EVR
            Map<Long, PackageListItem> packageNameIdsToItems =
                new HashMap<Long, PackageListItem>(data.size());
            
            for (String idCombo : data) {
                PackageListItem item = PackageListItem.parse(idCombo);
                
                PackageListItem existing = packageNameIdsToItems.get(item.getIdOne()); 
                if (existing != null) {
                    String[] existingParts = splitEvr(existing.getNvre());
                    String[] itemParts = splitEvr(item.getNvre());
                    
                    PackageEvr existingEvr = new PackageEvr();
                    existingEvr.setEpoch(existingParts[0]);
                    existingEvr.setVersion(existingParts[1]);
                    existingEvr.setRelease(existingParts[2]);
                    
                    PackageEvr itemEvr = new PackageEvr();
                    itemEvr.setEpoch(itemParts[0]);
                    itemEvr.setVersion(itemParts[1]);
                    itemEvr.setRelease(itemParts[2]);

                    if (existingEvr.compareTo(itemEvr) < 0) {
                        packageNameIdsToItems.put(item.getIdOne(), item);
                    }
                }
                else {
                    packageNameIdsToItems.put(item.getIdOne(), item);
                }
            }

            RhnSet packageSet = RhnSetManager.createSet(user.getId(),
                RhnSetDecl.SSM_UPGRADE_PACKAGES_LIST.getLabel(), SetCleanup.NOOP);
            
            for (PackageListItem item : packageNameIdsToItems.values()) {
                packageSet.addElement(item.getIdOne(), item.getIdTwo(), item.getIdThree());
            }
            
            RhnSetManager.store(packageSet);
        }        
        
        DataResult results = SystemManager.ssmSystemPackagesToUpgrade(user,
            RhnSetDecl.SSM_UPGRADE_PACKAGES_LIST.getLabel());
        
        TagHelper.bindElaboratorTo("groupList", results.getElaborator(), request);
        
        return results;
    }
    
    private String[] splitEvr(String evr) {
        String[] values = StringUtils.split(evr, "-");
        for (int i = 0; i < values.length; i++) {
            if ("null".equals(values[i])) {
                values[i] = null;
            }
        }
        return values;
    }
    
    private ActionForward executePackageAction(ActionMapping mapping,
                                               ActionForm formIn,
                                               HttpServletRequest request,
                                               HttpServletResponse response) {

        RequestContext context = new RequestContext(request);
        StrutsDelegate strutsDelegate = getStrutsDelegate();
        User user = context.getLoggedInUser();

        // Load the date selected by the user
        Date earliest = getStrutsDelegate().readDatePicker((DynaActionForm) formIn,
            "date", DatePicker.YEAR_RANGE_POSITIVE);
                
        // Parse through all of the results
        DataResult result = (DataResult) getResult(context); 
        result.elaborate();

        // Loop over each server that will have packages upgraded
        for (Iterator it = result.iterator(); it.hasNext();) {
        
            // Add action for each package found in the elaborator
            Map data = (Map) it.next();
            
            // Load the server
            Long sid = (Long)data.get("id");              
            Server server = SystemManager.lookupByIdAndUser(sid, user);

            // Get the packages out of the elaborator
            List elabList = (List) data.get("elaborator0");

            List<PackageListItem> items = new ArrayList<PackageListItem>(elabList.size());
            for (Iterator elabIt = elabList.iterator(); elabIt.hasNext();) {
                Map elabData = (Map) elabIt.next();
                String idCombo = (String) elabData.get("id_combo");
                PackageListItem item = PackageListItem.parse(idCombo);
                items.add(item);
            }
            
            // Convert to list of maps
            List<Map<String, Long>> packageListData = PackageListItem.toKeyMaps(items);
            
            // Create the action
            ActionManager.schedulePackageUpgrade(user, server, packageListData, earliest);
        }
        
        // Remove the packages from session and the DB
        SessionSetHelper.obliterate(request, request.getParameter("packagesDecl"));
        
        RhnSetManager.deleteByLabel(user.getId(),
            RhnSetDecl.SSM_UPGRADE_PACKAGES_LIST.getLabel());

        ActionMessages msgs = new ActionMessages();

        msgs.add(ActionMessages.GLOBAL_MESSAGE,
            new ActionMessage("ssm.package.upgrade.message.packageupgrade"));
        strutsDelegate.saveMessages(request, msgs);

        return mapping.findForward("confirm");

    
    }    
}
