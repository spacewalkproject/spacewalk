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
package com.redhat.rhn.frontend.action.systems.entitlements;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.common.validator.ValidatorResult;
import com.redhat.rhn.domain.entitlement.Entitlement;
import com.redhat.rhn.domain.entitlement.VirtualizationEntitlement;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.rhnset.RhnSetElement;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerGroup;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.common.BaseSetOperateOnSelectedItemsAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.StrutsDelegate;
import com.redhat.rhn.manager.entitlement.EntitlementManager;
import com.redhat.rhn.manager.monitoring.ScoutConfigPushCommand;
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
 * Class representing the submit action of the Systeme Eintitlements page
 * SystemEntitlementsSubmitAction
 * @version $Rev$
 */
public class SystemEntitlementsSubmitAction extends
                BaseSetOperateOnSelectedItemsAction {

    private static Logger log = Logger.getLogger(SystemEntitlementsSubmitAction.class);

    public static final String KEY_UPDATE_ENTITLED =
        "systementitlements.jsp.set_to_update_entitled";
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

    protected DataResult getDataResult(User user,
            ActionForm formIn,
            HttpServletRequest request) {
        return SystemManager.getSystemEntitlements(user, null);
    }

    /**
     * {@inheritDoc}
     */
    protected void processMethodKeys(Map map) {
        map.put(KEY_UPDATE_ENTITLED, "processUpdateEntitled");
        map.put(KEY_MANAGEMENT_ENTITLED, "processManagementEntitled");
        map.put(KEY_UNENTITLED, "processUnentitle");
        map.put(KEY_ADD_ENTITLED, "processAdd");
        map.put(KEY_REMOVE_ENTITLED, "processRemove");
    }

    protected void processParamMap(ActionForm formIn,
            HttpServletRequest request,
            Map params) {
    }

    /**
     *
     * @param mapping ActionMapping
     * @param formIn ActionForm
     * @param request ServletRequest
     * @param response ServletResponse
     * @return The ActionForward to go to next.
     */
    public ActionForward processUpdateEntitled(ActionMapping mapping,
            ActionForm formIn, HttpServletRequest request,
            HttpServletResponse response) {
        return operateOnSelectedSet(mapping, formIn, request, response,
        "setToUpdateEntitled");

    }

    /**
     * This method is called when the &quot;Set To Update Entitled&quot;
     * button is clicked in the System Entitlements page.
     * Basically sets the entitlements of the selected systems to
     * Update.
     * @param form Action form object.
     * @param req The servlet request object
     * @param elementIn The checked element in the set
     * @param userIn logged in user
     * @return true of the server was entitled.
     */
    public Boolean setToUpdateEntitled(ActionForm form,
            HttpServletRequest req,
            RhnSetElement elementIn, User userIn) {
        return entitle(elementIn.getElement(), EntitlementManager.UPDATE, userIn, req);
    }

    //This method does not deal with add-on entitlements
    //prereq: ent is not an add-on entitlement
    //TODO: check this prereq.
    private Boolean entitle(Long sid,
            Entitlement ent,
            User userIn,
            HttpServletRequest req) {
        final String availableSlotsLabel = "Available_Slots";
        //Only entitle if the system doesn't already have the entitlement
        if (!SystemManager.hasEntitlement(sid, ent)) {

            if (req.getAttribute(availableSlotsLabel) == null) {
                //The slots were not in the request, find them and put them there.
                Long slots = EntitlementManager.getAvailableEntitlements(ent,
                        userIn.getOrg());
                req.setAttribute(availableSlotsLabel, slots);
            }
            //We need one slot to put our system in.
            Long availableSlots =
                ((Long) req.getAttribute(availableSlotsLabel));

            if (availableSlots != null && availableSlots.longValue() > 0) {
                //Remove the current ones
                //This is ok because of the prereq for this method.
                SystemManager.removeAllServerEntitlements(sid);
                if (SystemManager.canEntitleServer(sid, ent)) {
                    SystemManager.entitleServer(userIn.getOrg(), sid, ent);
                    if (availableSlots.longValue() != ServerGroup.UNLIMITED) {
                        //Now we need to update our request attribute.
                        req.setAttribute(availableSlotsLabel,
                                new Long(availableSlots.longValue() - 1));
                    }
                }
                else {
                    //entitlement is invalid
                    return Boolean.FALSE;
                }
            }
            else {
                //not enough slots to put server
                return Boolean.FALSE;
            }
        }
        //They have been successfully entitled, or they already were.
        return Boolean.TRUE;
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

        if (EntitlementManager.MONITORING_ENTITLED.equals(entType)) {
            return EntitlementManager.MONITORING;
        }
        else if (EntitlementManager.PROVISIONING_ENTITLED.equals(entType)) {
            return EntitlementManager.PROVISIONING;
        }
        else if (EntitlementManager.VIRTUALIZATION_ENTITLED.equals(entType)) {
            return EntitlementManager.VIRTUALIZATION;
        }
        else if (EntitlementManager.VIRTUALIZATION_PLATFORM_ENTITLED.equals(entType)) {
            return EntitlementManager.VIRTUALIZATION_PLATFORM;
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

        Map params = makeParamMap(formIn, request);
        RequestContext rctx = new RequestContext(request);
        User user = rctx.getLoggedInUser();

        int successCount = 0;
        int failureDueToSlotsCount = 0;
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
        for (Iterator i = set.getElements().iterator(); i.hasNext();) {
            RhnSetElement element = (RhnSetElement) i.next();
            Long sid = element.getElement();

            //We are adding the add on entitlement
            if (add) {
                //if the system already has the entitlement, do nothing
                //  if so, neither success nor failure count will be updated.
                if (!SystemManager.hasEntitlement(sid, ent)) {
                        if (checkSolarisFailure(sid, ent, user)) {
                            failureDueToSolarisCount++;
                        }
                        else if (SystemManager.canEntitleServer(sid, ent)) {
                            log.debug("we can entitle.  Lets entitle to : " + ent);
                            ValidatorResult vr =
                                SystemManager.entitleServer(user.getOrg(), sid, ent);
                            log.debug("entitleServer.VE: " + vr.getMessage());
                            if (vr.getErrors().size() > 0) {
                                ValidatorError ve = vr.getErrors().get(0);
                                if (ve.getKey().equals(SystemManager.NO_SLOT_KEY)) {
                                    failureDueToSlotsCount++;
                                    i.remove();
                                }
                                else if (isVirtEntitlement) {
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
        if (ent.equals(EntitlementManager.MONITORING)) {
            // Need to push the scout configs as well.
            ScoutConfigPushCommand cmd = new ScoutConfigPushCommand(user);
            cmd.store();
            prefix = getSetDecl().getLabel() + ".monitoring";
        }
        else if (ent.equals(EntitlementManager.VIRTUALIZATION) ||
                ent.equals(EntitlementManager.VIRTUALIZATION_PLATFORM)) {
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
                        " failureDueToSlotsCount:" + failureDueToSlotsCount +
                        " failureDueToNonManagementCount: " +
                        failureDueToNonManagementCount);
            }
            //Create the 'added entitlements' success message
            if (successCount > 0 &&
                    failureDueToSlotsCount == 0 &&
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

            //Create the 'not enough slots' failure message
            if (failureDueToSlotsCount > 0) {
                Object [] args = new Object[] {String.valueOf(successCount),
                        String.valueOf(failureDueToSlotsCount)};
                ActionMessage m = new ActionMessage(prefix + ".notEnoughSlots", args);
                msg.add(ActionMessages.GLOBAL_MESSAGE, m);
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
        return strutsDelegate.forwardParams(mapping.findForward("default"), params);
    }

    private boolean checkSolarisFailure(Long sid, Entitlement ent, User user) {
        Server server = SystemManager.lookupByIdAndUser(sid, user);
        if (server.isSolaris()) {
            return EntitlementManager.MONITORING.equals(ent) ||
                      EntitlementManager.VIRTUALIZATION.equals(ent) ||
                      EntitlementManager.VIRTUALIZATION_PLATFORM.equals(ent);
        }
        return false;
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

    /**
     * Used for debug purposes to print out all the error mesages....
     * @param msgs
     * @return
     */
    private ActionMessages dumpMessages(ActionMessages msgs) {
        Object [] args = new Object[]{String.valueOf(1), String.valueOf(0)};
        addToMessage(msgs, "system_entitlements.setToManagementEntitled.success", args);
        addToMessage(msgs, "system_entitlements.setToManagementEntitled.failure", args);
        addToMessage(msgs, "system_entitlements.setToUpdateEntitled.success", args);
        addToMessage(msgs, "system_entitlements.setToUpdateEntitled.failure", args);
        addToMessage(msgs, "system_entitlements.unentitle.success", args);
        addToMessage(msgs, "system_entitlements.unentitle.failure", args);
        addToMessage(msgs, "system_entitlements.provisioning.success", args);
        addToMessage(msgs, "system_entitlements.provisioning.notEnoughSlots", args);
        addToMessage(msgs, "system_entitlements.provisioning.noManagement", args);
        addToMessage(msgs, "system_entitlements.monitoring.success", args);
        addToMessage(msgs, "system_entitlements.monitoring.notEnoughSlots", args);
        addToMessage(msgs, "system_entitlements.monitoring.noManagement", args);

        return msgs;
    }

    private void addToMessage(ActionMessages msgs, String key, Object[] args) {
        ActionMessage temp =  new ActionMessage(key, args);
        msgs.add(ActionMessages.GLOBAL_MESSAGE, temp);
    }



}
