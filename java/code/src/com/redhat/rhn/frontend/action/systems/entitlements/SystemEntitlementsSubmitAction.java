/**
 * Copyright (c) 2009--2014 Red Hat, Inc.
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
package com.redhat.rhn.frontend.action.systems.entitlements;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.common.validator.ValidatorResult;
import com.redhat.rhn.domain.entitlement.Entitlement;
import com.redhat.rhn.domain.entitlement.VirtualizationEntitlement;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.rhnset.RhnSetElement;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.common.BaseSetOperateOnSelectedItemsAction;
import com.redhat.rhn.frontend.dto.SystemOverview;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.struts.StrutsDelegate;
import com.redhat.rhn.manager.entitlement.EntitlementManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;
import com.redhat.rhn.manager.system.SystemManager;

import org.apache.log4j.Logger;
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
 * Class representing the submit action of the System Entitlements page
 */
public class SystemEntitlementsSubmitAction extends
                BaseSetOperateOnSelectedItemsAction {

    private static Logger log = Logger.getLogger(SystemEntitlementsSubmitAction.class);

    public static final String KEY_MANAGEMENT_ENTITLED =
        "systementitlements.jsp.set_to_manage_entitled";
    public static final String KEY_UNENTITLED =
        "systementitlements.jsp.set_to_unentitled";
    public static final String KEY_ADD_ENTITLED =
        "systementitlements.jsp.add_entitlement";
    public static final String KEY_REMOVE_ENTITLED =
        "systementitlements.jsp.remove_entitlement";

    /**
     * {@inheritDoc}
     */
    protected RhnSetDecl getSetDecl() {
        return RhnSetDecl.SYSTEM_ENTITLEMENTS;
    }

    protected DataResult<SystemOverview> getDataResult(User user,
            ActionForm formIn,
            HttpServletRequest request) {
        return SystemManager.getSystemEntitlements(user, null);
    }

    /**
     * {@inheritDoc}
     */
    protected void processMethodKeys(Map<String, String> map) {
        map.put(KEY_MANAGEMENT_ENTITLED, "processManagementEntitled");
        map.put(KEY_UNENTITLED, "processUnentitle");
        map.put(KEY_ADD_ENTITLED, "processAdd");
        map.put(KEY_REMOVE_ENTITLED, "processRemove");
    }

    protected void processParamMap(ActionForm formIn,
            HttpServletRequest request,
            Map<String, Object> params) {
    }

    //This method does not deal with add-on entitlements
    //prereq: ent is not an add-on entitlement
    //TODO: check this prereq.
    private Boolean entitle(Long sid,
            Entitlement ent,
            User userIn,
            HttpServletRequest req) {
        //Only entitle if the system doesn't already have the entitlement
        if (!SystemManager.hasEntitlement(sid, ent)) {
            //Remove the current ones
            //This is ok because of the prereq for this method.
            SystemManager.removeAllServerEntitlements(sid);
            if (SystemManager.canEntitleServer(sid, ent)) {
                SystemManager.entitleServer(userIn.getOrg(), sid, ent);
            }
            else {
                //entitlement is invalid
                return false;
            }
        }
        //They have been successfully entitled, or they already were.
        return true;
    }

    /**
     *
     * @param mapping ActionMapping
     * @param formIn ActionForm
     * @param request ServletRequest
     * @param response ServletResponse
     * @return The ActionForward to go to next.
     */
    public ActionForward processManagementEntitled(ActionMapping mapping,
            ActionForm formIn, HttpServletRequest request,
            HttpServletResponse response) {
        return operateOnSelectedSet(mapping, formIn, request, response,
        "setToManagementEntitled");

    }

    /**
     * This method is called when the &quot;Set To Management Entitled&quot;
     * button is clicked in the System Entitlements page.
     * Basically sets the entitlements of the selected systems to
     * Management.
     * @param form Action form object.
     * @param req The servlet request object
     * @param elementIn The checked element in the set
     * @param userIn logged in user
     * @return true of the server was entitled.
     */
    public Boolean setToManagementEntitled(ActionForm form,
            HttpServletRequest req,
            RhnSetElement elementIn,
            User userIn) {
        return entitle(elementIn.getElement(), EntitlementManager.MANAGEMENT, userIn, req);
    }

    /**
     *
     * @param mapping ActionMapping
     * @param formIn ActionForm
     * @param request ServletRequest
     * @param response ServletResponse
     * @return The ActionForward to go to next.
     */
    public ActionForward processUnentitle(ActionMapping mapping,
            ActionForm formIn, HttpServletRequest request,
            HttpServletResponse response) {
        return operateOnSelectedSet(mapping, formIn, request, response,
        "unentitle");

    }


    /**
     * This method is called when the &quot;Unentitle&quot;
     * button is clicked in the System Entitlements page.
     * Basically removes all the entitlements
     * related to the selected systems.
     * @param form Action form object.
     * @param req The servlet request object
     * @param elementIn The checked element in the set
     * @param userIn logged in user
     * @return true of the server was unentitled.
     */
    public Boolean unentitle(ActionForm form,
            HttpServletRequest req,
            RhnSetElement elementIn,
            User userIn) {
        SystemManager.removeAllServerEntitlements(elementIn.getElement());
        return Boolean.TRUE;
    }

    private Entitlement findAddOnEntitlement(ActionForm formIn) {
        DynaActionForm form = (DynaActionForm) formIn;
        String entType = form
        .getString(SystemEntitlementsSetupAction.ADDON_ENTITLEMENT);

        if (EntitlementManager.VIRTUALIZATION_ENTITLED.equals(entType)) {
            return EntitlementManager.VIRTUALIZATION;
        }

        return null;
    }

    /**
     *
     * @param mapping ActionMapping
     * @param formIn ActionForm
     * @param request ServletRequest
     * @param response ServletResponse
     * @return The ActionForward to go to next.
     */
    public ActionForward processAdd(ActionMapping mapping, ActionForm formIn,
            HttpServletRequest request, HttpServletResponse response) {
        return operateAddOnEntitlements(mapping, formIn, request, response, true);
    }

    /**
     *
     * @param mapping ActionMapping
     * @param formIn ActionForm
     * @param request ServletRequest
     * @param response ServletResponse
     * @return The ActionForward to go to next.
     */
    public ActionForward processRemove(ActionMapping mapping,
            ActionForm formIn, HttpServletRequest request,
            HttpServletResponse response) {
        return operateAddOnEntitlements(mapping, formIn, request, response, false);
    }


    /**
     * Execute some operation on the set of selected items.  Forwards
     * to the "default"
     * NOTE:  Must define StringResource for failure and success messages:
     * getSetName() + ".success" for providing a parameterized
     * message to the UI that would say "2 ServerProbe Suite(s) deleted."
     *
     * @param mapping ActionMapping
     * @param formIn ActionForm
     * @param request ServletRequest
     * @param response ServletResponse
     * @param add Add/remove entitlement..
     * @return The ActionForward to go to next.
     */
    public ActionForward operateAddOnEntitlements(ActionMapping mapping,
            ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response,
            boolean add) {
        log.debug("operateAddOnEntitlements");

        RhnSet set = updateSet(request);

        //if they chose no probe suites, return to the same page with a message
        if (set.isEmpty()) {
            return handleEmptySelection(mapping, formIn, request);
        }

        Map<String, Object> params = makeParamMap(formIn, request);
        RequestContext rctx = new RequestContext(request);
        User user = rctx.getCurrentUser();

        int successCount = 0;
        int failureDueToNonManagementCount = 0;
        int failureDueToVirtErrorCount = 0;
        int failureDueToSolarisCount = 0;
        int unknownFailureCount = 0;
        boolean isVirtEntitlement = false;

        StrutsDelegate strutsDelegate = getStrutsDelegate();

        Entitlement ent = findAddOnEntitlement(formIn);

        isVirtEntitlement = (ent instanceof VirtualizationEntitlement);

        // TODO: Why are we performing an 'i.remove()' in this loop?
        //Go through the set of systems to which we should add the entitlement
        for (Iterator<RhnSetElement> i = set.getElements().iterator(); i.hasNext();) {
            RhnSetElement element = i.next();
            Long sid = element.getElement();

            //We are adding the add on entitlement
            if (add) {
                //if the system already has the entitlement, do nothing
                //  if so, neither success nor failure count will be updated.
                if (!SystemManager.hasEntitlement(sid, ent)) {
                    if (SystemManager.canEntitleServer(sid, ent)) {
                            log.debug("we can entitle.  Lets entitle to : " + ent);
                            ValidatorResult vr =
                                SystemManager.entitleServer(user.getOrg(), sid, ent);
                            log.debug("entitleServer.VE: " + vr.getMessage());
                            if (vr.getErrors().size() > 0) {
                                ValidatorError ve = vr.getErrors().get(0);
                                if (isVirtEntitlement) {
                                    failureDueToVirtErrorCount++;
                                    i.remove();
                                }
                                else {
                                    unknownFailureCount++;
                                    i.remove();
                                }
                            }
                            else {
                                successCount++;
                                i.remove();
                            }
                        }
                        else {
                            log.debug("canEntitleServer returned false.");
                            //invalid entitlement
                            failureDueToNonManagementCount++;
                        }
                } //if has entitlement
            } //if add
            //We are removing the add on entitlement
            else {
                if (SystemManager.hasEntitlement(sid, ent)) {
                    log.debug("removing entitlement");
                    SystemManager.removeServerEntitlement(sid, ent);
                    successCount++;
                }
                i.remove();

            } //else

        } //for
        RhnSetManager.store(set);

        ActionMessages msg = new ActionMessages();

        String prefix = getSetDecl().getLabel() + ".provisioning";
        log.debug("prefix: " + prefix);
        if (ent.equals(EntitlementManager.VIRTUALIZATION)) {
            prefix = getSetDecl().getLabel() + "." + ent.getLabel();
        }
        if (!add) {
            log.debug("adding remove success message");
            //Create the remove success message.
            Object [] args = new Object[] {String.valueOf(successCount)};
            ActionMessage m = new ActionMessage(prefix + ".removed.success", args);
            msg.add(ActionMessages.GLOBAL_MESSAGE, m);
        }
        else {
            if (log.isDebugEnabled()) {
                log.debug("successCount: " + successCount +
                        " failureDueToNonManagementCount: " +
                        failureDueToNonManagementCount);
            }
            //Create the 'added entitlements' success message
            if (successCount > 0 &&
                    failureDueToNonManagementCount == 0 &&
                    failureDueToVirtErrorCount == 0 &&
                    unknownFailureCount == 0 &&
                    failureDueToSolarisCount == 0) {
                log.debug("adding success msg");
                Object [] args = new Object[] {String.valueOf(successCount)};
                ActionMessage m = new ActionMessage(prefix + ".success", args);
                msg.add(ActionMessages.GLOBAL_MESSAGE, m);

                if (isVirtEntitlement) {
                    log.debug("adding virt note");
                    Object[] noteargs = new Object[3];
                    // TODO: Replace this with real package/channel names
                    noteargs[0] = "rh-virtualization";
                    noteargs[1] = "rhn-tools";
                    noteargs[2] = "rhn-virtualization-host";
                    ActionMessage note = new
                        ActionMessage("system_entitlements.virtualization.success_note",
                                noteargs);
                    msg.add(ActionMessages.GLOBAL_MESSAGE, note);
                }
            }

            //Create the 'invalid entitlement' failure message
            if (failureDueToNonManagementCount > 0) {
                Object [] args = new Object[] {String.valueOf(
                        failureDueToNonManagementCount),
                        String.valueOf(successCount)};
                ActionMessage m = new ActionMessage(prefix + ".noManagement", args);
                msg.add(ActionMessages.GLOBAL_MESSAGE, m);
            }

            if (failureDueToSolarisCount > 0) {
                ActionMessage m = new ActionMessage(prefix + ".noSolarisSupport",
                                                        failureDueToSolarisCount);
                msg.add(ActionMessages.GLOBAL_MESSAGE, m);
            }

            if (failureDueToVirtErrorCount > 0) {
                ActionMessage m = new ActionMessage(
                        "system_entitlements.virtualization.setup_error",
                        String.valueOf(failureDueToVirtErrorCount));
                msg.add(ActionMessages.GLOBAL_MESSAGE, m);
            }

            if (unknownFailureCount > 0) {
                ActionMessage m = new ActionMessage(
                        "system_entitlements.unknown.error",
                        String.valueOf(unknownFailureCount));
                msg.add(ActionMessages.GLOBAL_MESSAGE, m);
            }
        }

        strutsDelegate.saveMessages(request, msg);
        return strutsDelegate.forwardParams(mapping.findForward(
                RhnHelper.DEFAULT_FORWARD), params);
    }

    /**
     *
     * {@inheritDoc}
     */
    protected void processMessage(ActionMessages msg,
            String methodName,
            long successCount,
            long failureCount) {

        Object[] args = new Object [] {String.valueOf(successCount),
                String.valueOf(failureCount)
        };

        if (failureCount > 0) {
            addToMessage(msg, methodName, false, args);
        }
        else  if (successCount > 0) {
            addToMessage(msg, methodName, true, args);
        }
    }

    /**
     *
     * @return  empty selection message
     */
    protected ActionMessage getEmptySelectionMessage() {
        return new ActionMessage("system_entitlements.emptyselectionerror");
    }
}
