/**
 * Copyright (c) 2009--2013 Red Hat, Inc.
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

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.messaging.MessageQueue;
import com.redhat.rhn.common.util.DatePicker;
import com.redhat.rhn.domain.action.ActionChain;
import com.redhat.rhn.domain.rhnpackage.PackageEvr;
import com.redhat.rhn.domain.rhnpackage.PackageEvrFactory;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.rhnset.SetCleanup;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.PackageListItem;
import com.redhat.rhn.frontend.events.SsmUpgradePackagesEvent;
import com.redhat.rhn.frontend.struts.ActionChainHelper;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.struts.SessionSetHelper;
import com.redhat.rhn.frontend.struts.StrutsDelegate;
import com.redhat.rhn.frontend.taglibs.list.TagHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.ListHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.Listable;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;
import com.redhat.rhn.manager.system.SystemManager;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;
import org.apache.struts.action.DynaActionForm;

import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * @version $Revision$
 */
public class SchedulePackageUpgradeAction extends RhnAction implements Listable {

    private static Logger log = Logger.getLogger(SchedulePackageUpgradeAction.class);

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping actionMapping,
                                 ActionForm actionForm,
                                 HttpServletRequest request,
                                 HttpServletResponse response) throws Exception {

        RequestContext requestContext = new RequestContext(request);
        DynaActionForm f = (DynaActionForm) actionForm;

        ListHelper helper = new ListHelper(this, request);
        helper.setDataSetName(RequestContext.PAGE_LIST);
        helper.execute();

        Map params = new HashMap();
        params.put(RequestContext.MODE,
                requestContext.getRequiredParamAsString(RequestContext.MODE));

        if (request.getParameter("dispatch") != null) {
            String packagesDecl = request.getParameter("packagesDecl");
            if (requestContext.wasDispatched("installconfirm.jsp.confirm")) {
                return executePackageAction(actionMapping, actionForm, request, response);
            }
        }

        // Pre-populate the date picker
        DynaActionForm dynaForm = (DynaActionForm) actionForm;
        DatePicker picker = getStrutsDelegate().prepopulateDatePicker(request, dynaForm,
            "date", DatePicker.YEAR_RANGE_POSITIVE);
        request.setAttribute("date", picker);

        // Pre-populate the Action Chain selector
        ActionChainHelper.prepopulateActionChains(request);

        return actionMapping.findForward(RhnHelper.DEFAULT_FORWARD);
    }

    /** {@inheritDoc} */
    public List getResult(RequestContext context) {

        HttpServletRequest request = context.getRequest();
        User user = context.getCurrentUser();

        // Stuff packages into an RhnSet to be used in the query
        String packagesDecl = (String) request.getAttribute("packagesDecl");
        if (packagesDecl != null) {
            Set<String> data = SessionSetHelper.lookupAndBind(request, packagesDecl);

            // bz465892 - As the selected packages are parsed, remove duplicates
            // keeping the highest EVR
            Map<String, PackageListItem> packageNameIdsToItems =
                new HashMap<String, PackageListItem>(data.size());

            for (String idCombo : data) {
                PackageListItem item = PackageListItem.parse(idCombo);

                PackageListItem existing =
                    packageNameIdsToItems.get(item.getIdOne() + "|" + item.getIdThree());
                if (existing != null) {
                    String[] existingParts = splitEvr(existing.getNvre());
                    String[] itemParts = splitEvr(item.getNvre());

                    PackageEvr existingEvr = PackageEvrFactory
                            .lookupOrCreatePackageEvr(existingParts[0],
                                    existingParts[1], existingParts[2]);

                    PackageEvr itemEvr = PackageEvrFactory
                            .lookupOrCreatePackageEvr(itemParts[0],
                                    itemParts[1], itemParts[2]);

                    if (existingEvr.compareTo(itemEvr) < 0) {
                        packageNameIdsToItems.put(item.getIdOne() + "|" +
                                item.getIdThree(), item);
                    }
                }
                else {
                    packageNameIdsToItems.put(item.getIdOne() + "|" +
                            item.getIdThree(), item);
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
        User user = context.getCurrentUser();

        // Load the date selected by the user
        DynaActionForm form = (DynaActionForm) formIn;
        Date earliest = getStrutsDelegate().readDatePicker(form, "date",
            DatePicker.YEAR_RANGE_POSITIVE);

        // Load the Action Chain, if any
        ActionChain actionChain = ActionChainHelper.readActionChain(form, user);

        log.debug("Getting package upgrade data.");
        List<Map> result =  getResult(context);
        ((DataResult) result).elaborate();


        Map<Long, List<Map<String, Long>>> sysPackageSet =
            new HashMap<Long, List<Map<String, Long>>>();
        for (Map sys : result) {
            Long sysId = (Long) sys.get("id");
            List<Map<String, Long>> pkgSet = new ArrayList<Map<String, Long>>();
            sysPackageSet.put(sysId, pkgSet);
            for (Map pkg : (List<Map>) sys.get("elaborator0")) {
                Map<String, Long> newPkg = new HashMap();
                newPkg.put("name_id", (Long) pkg.get("name_id"));
                newPkg.put("evr_id", (Long) pkg.get("evr_id"));
                newPkg.put("arch_id", (Long) pkg.get("arch_id"));
                pkgSet.add(newPkg);
            }

        }


        log.debug("Publishing schedule package upgrade event to message queue.");
        SsmUpgradePackagesEvent event = new SsmUpgradePackagesEvent(user.getId(), earliest,
            actionChain, sysPackageSet);
        MessageQueue.publish(event);

        // Remove the packages from session and the DB
        SessionSetHelper.obliterate(request, request.getParameter("packagesDecl"));

        log.debug("Deleting set.");
        RhnSetManager.deleteByLabel(user.getId(),
            RhnSetDecl.SSM_UPGRADE_PACKAGES_LIST.getLabel());

        ActionMessages msgs = new ActionMessages();

        msgs.add(ActionMessages.GLOBAL_MESSAGE,
            new ActionMessage("ssm.package.upgrade.message.packageupgrade"));
        strutsDelegate.saveMessages(request, msgs);

        return mapping.findForward("confirm");


    }
}
