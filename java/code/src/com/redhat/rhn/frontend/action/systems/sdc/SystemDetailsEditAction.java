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
package com.redhat.rhn.frontend.action.systems.sdc;

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.common.validator.ValidatorResult;
import com.redhat.rhn.common.validator.ValidatorWarning;
import com.redhat.rhn.domain.entitlement.Entitlement;
import com.redhat.rhn.domain.entitlement.VirtualizationEntitlement;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.server.Location;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.domain.user.UserServerPreferenceId;
import com.redhat.rhn.frontend.dto.EntitlementDto;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnValidationHelper;
import com.redhat.rhn.manager.action.ActionManager;
import com.redhat.rhn.manager.entitlement.EntitlementManager;
import com.redhat.rhn.manager.system.SystemManager;
import com.redhat.rhn.manager.user.UserManager;

import org.apache.log4j.Logger;
import org.apache.struts.action.ActionErrors;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;
import org.apache.struts.util.LabelValueBean;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * SystemDetailsEditAction
 * @version $Rev$
 */
public class SystemDetailsEditAction extends RhnAction {
    
    private static Logger log = Logger.getLogger(SystemDetailsEditAction.class);
    
    public static final String NAME = "system_name";
    public static final String BASE_ENTITLEMENT_OPTIONS = "base_entitlement_options";
    public static final String BASE_ENTITLEMENT = "base_entitlement";
    public static final String BASE_ENTITLEMENT_PERMANENT = "base_entitlement_permanent";
    public static final String ADDON_ENTITLEMENTS = "addon_entitlements";
    public static final String AUTO_UPDATE = "auto_update";
    public static final String DESCRIPTION = "description";
    public static final String ADDRESS_ONE = "address1";
    public static final String ADDRESS_TWO = "address2";
    public static final String CITY = "city";
    public static final String STATE = "state";
    public static final String COUNTRY = "country";
    public static final String BUILDING = "building";
    public static final String ROOM = "room";
    public static final String RACK = "rack";
    public static final String UNENTITLE = "unentitle";
    

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping, ActionForm form,
            HttpServletRequest request, HttpServletResponse response) {

        RequestContext rctx = new RequestContext(request);
        DynaActionForm daForm = (DynaActionForm) form;
        User user = rctx.getLoggedInUser();
        Server s  = SystemManager.lookupByIdAndUser(
                rctx.getRequiredParam(RequestContext.SID), user);
        String forwardName = "default";
        
        if (isSubmitted(daForm)) {
            ActionErrors errors = RhnValidationHelper.validateDynaActionForm(this, daForm);
            
            if (errors.isEmpty()) {
                if (processSubmission(request, daForm, user, s)) {
                    createSuccessMessage(request,
                            "sdc.details.edit.propertieschanged",
                            s.getName());

                    return getStrutsDelegate().forwardParam(mapping.findForward("success"), 
                            "sid", 
                            s.getId().toString());
                }
                else {
                    forwardName = "error";
                }
            }
            else {
                forwardName = "error";
                getStrutsDelegate().saveMessages(request, errors);
            }
        }
        
        SdcHelper.ssmCheck(request, s.getId(), user);
        
        setupPageAndFormValues(rctx.getRequest(), daForm, user, s);
        return mapping.findForward(forwardName);
    }
    
    /**
     * Proccesses the system details edit form
     * @param request to add messages to.
     * @param daForm DynaActionForm to be processed
     * @param user User submitting the form
     * @param s Server whose details are being update
     * @return true if the submission process didnot produce any errors.
     */
    private boolean processSubmission(HttpServletRequest request,
            DynaActionForm daForm, User user, Server s) {

        boolean success = true;
        
        s.setName(daForm.getString(NAME));
        s.setDescription(daForm.getString(DESCRIPTION));
        
        // Process the base entitlement selection.  Need to 
        // do this first because the below code is effected by the 
        // base entitlement chosen
        String selectedEnt = daForm.getString(BASE_ENTITLEMENT);
        Entitlement base = EntitlementManager.getByName(selectedEnt);
        log.debug("base: " + base);
        if (base != null) {
            s.setBaseEntitlement(base);
        }
        else if (selectedEnt.equals(UNENTITLE)) {
            SystemManager.removeAllServerEntitlements(s.getId());
        }
        
        // setup location information
        if (s.getLocation() == null) {
            Location l = new Location();
            s.setLocation(l);
            l.setServer(s);
        }
        
        s.getLocation().setCountry(daForm.getString(COUNTRY));
        s.getLocation().setAddress1(daForm.getString(ADDRESS_ONE));
        s.getLocation().setAddress2(daForm.getString(ADDRESS_TWO));
        s.getLocation().setState(daForm.getString(STATE));
        s.getLocation().setCity(daForm.getString(CITY));
        s.getLocation().setBuilding(daForm.getString(BUILDING));
        s.getLocation().setRoom(daForm.getString(ROOM));
        s.getLocation().setRack(daForm.getString(RACK));
        
        /* If the server does not have a Base Entitlement
         * the user should not be updating these values
         * no matter what the form they are submitting looks 
         * like
         */
        if (s.getBaseEntitlement() != null) {
            
            if (Boolean.TRUE.equals(daForm.get(AUTO_UPDATE)) &&
                !s.getAutoUpdate().equals("Y")) {
                // only set it if it has changed
                s.setAutoUpdate("Y");
                
                ActionManager.scheduleAllErrataUpdate(user, s, new Date());
                createSuccessMessage(request,
                       "sdc.details.edit.propertieschangedupdate", s.getName());
            }
            else {
                s.setAutoUpdate("N");
            }
            
            boolean flag = Boolean.TRUE.equals(
                    daForm.get(UserServerPreferenceId.INCLUDE_IN_DAILY_SUMMARY));
            UserManager.setUserServerPreferenceValue(user, s, 
                    UserServerPreferenceId.INCLUDE_IN_DAILY_SUMMARY, flag);
            
            flag = Boolean.TRUE.equals(
                    daForm.get(UserServerPreferenceId.RECEIVE_NOTIFICATIONS));
            UserManager.setUserServerPreferenceValue(user, s, 
                    UserServerPreferenceId.RECEIVE_NOTIFICATIONS, flag);

            if (log.isDebugEnabled()) {
                log.debug("looping on addon entitlements");
            }
            
            Set validAddons = user.getOrg().getValidAddOnEntitlementsForOrg();
            success = checkVirtEntitlements(request, daForm, validAddons, s, user);
        } 
 
        return success;
    }
    
    /**
     * Checks the complicated virt logic.
     * @param request the current HTTP request
     * @param daForm the DynaActionForm submitted by the user.
     * @param validAddons list of valid add-on entitlements
     * @return true if validation succeeds, false otherwise.
     */
    private boolean checkVirtEntitlements(HttpServletRequest request, 
            DynaActionForm daForm, Set validAddons, Server s, User user) {

        boolean success = true;
        
        // Tracks whether or not a change has been made that requires a new snapshot
        // to be made
        boolean needsSnapshot = false;
        
        //Check add-on entitlements for V18n
        //Basically make sure both Virt and Virt_platform are not checked
        //if so mention it as an error.
        final Entitlement virt = EntitlementManager.VIRTUALIZATION;
        final Entitlement virtPlatform = EntitlementManager.VIRTUALIZATION_PLATFORM;
        if (validAddons.contains(virtPlatform) && validAddons.contains(virt) && 
                 Boolean.TRUE.equals(daForm.get(virt.getLabel())) &&
                 Boolean.TRUE.equals(daForm.get(virtPlatform.getLabel()))) {
            ValidatorError err = new ValidatorError("system.entitle.alreadyvirt");
            getStrutsDelegate().saveMessages(request, 
                    RhnValidationHelper.validatorErrorToActionErrors(err));
            success = false;
        }
        else if (checkSolarisFailure(validAddons,
                        EntitlementManager.MONITORING, daForm, s)) {
            handleSolarisError(request, EntitlementManager.MONITORING);
            success = false;
        }
        else if (checkSolarisFailure(validAddons,
                EntitlementManager.VIRTUALIZATION, daForm, s)) {
            handleSolarisError(request, EntitlementManager.VIRTUALIZATION);
            success = false;
        }
        else if (checkSolarisFailure(validAddons,
                EntitlementManager.VIRTUALIZATION_PLATFORM, daForm, s)) {
            handleSolarisError(request, EntitlementManager.VIRTUALIZATION_PLATFORM);
            success = false;
        }
        else {
            for (Iterator i = validAddons.iterator(); i.hasNext();) {
                Entitlement e = (Entitlement) i.next();
                log.debug("Entitlement: " + e.getLabel());
                log.debug("form.get: " + daForm.get(e.getLabel()));
                if (Boolean.TRUE.equals(daForm.get(e.getLabel())) &&
                    SystemManager.canEntitleServer(s, e)) {
                    log.debug("Entitling server with: " + e);
                    ValidatorResult vr = SystemManager.entitleServer(s, e);

                    if (vr.getWarnings().size() > 0) {
                        getStrutsDelegate().saveMessages(request,
                                RhnValidationHelper.validatorWarningToActionMessages(
                                    vr.getWarnings().toArray(new ValidatorWarning [] {})));
                    }


                    if (vr.getErrors().size() > 0) {
                        ValidatorError ve = vr.getErrors().get(0);
                        log.debug("Got error: " + ve);
                        getStrutsDelegate().saveMessages(request, 
                                RhnValidationHelper.
                                            validatorErrorToActionErrors(ve));
                        success = false;
                    } 
                    else {
                        needsSnapshot = true;
                        
                        if (log.isDebugEnabled()) {
                            log.debug("entitling worked?: " + s.hasEntitlement(e));
                        }
                        if (e instanceof VirtualizationEntitlement) {
                            log.debug("adding virt msg");
                            createSuccessMessage(request,
                                    "system.entitle.addedvirtualization",
                                    "/rhn/help/reference/en-US/ch-virtualization.jsp");
                        }
                    }
                }
                else if ((daForm.get(e.getLabel()) == null ||
                         daForm.get(e.getLabel()).equals(Boolean.FALSE)) && 
                         s.hasEntitlement(e)) {
                    log.debug("removing entitlement: " + e);
                    SystemManager.removeServerEntitlement(s.getId(), e);
                    
                    needsSnapshot = true;
                }
            }
        }
        
        if (needsSnapshot) {
            String message = 
                LocalizationService.getInstance().getMessage("snapshots.entitlements");
            SystemManager.snapshotServer(s, message);            
        }
        
        return success;
    }

    protected void setupPageAndFormValues(HttpServletRequest request,
            DynaActionForm daForm, User user, Server s) {

        request.setAttribute("system", s);
        request.setAttribute(BASE_ENTITLEMENT_OPTIONS, 
                createBaseEntitlementDropDownList(user, s));
        request.setAttribute("countries", getCountries());
        request.setAttribute(ADDON_ENTITLEMENTS,
                createAddOnEntitlementList(user.getOrg(),
                            s.getValidAddonEntitlementsForServer()));
        
        request.setAttribute("notifications_disabled", 
                user.getEmailNotify() == 0 ? Boolean.TRUE : Boolean.FALSE);
        
        daForm.set(NAME, s.getName());
        
        if (s.getBaseEntitlement() != null) {
            daForm.set(BASE_ENTITLEMENT, s.getBaseEntitlement().getLabel());
            request.setAttribute(BASE_ENTITLEMENT_PERMANENT, 
                                 new Boolean(s.getBaseEntitlement().isPermanent()));
        }
        else {
            daForm.set(BASE_ENTITLEMENT, "none");
        }
        
        Iterator i = s.getAddOnEntitlements().iterator();
        
        while (i.hasNext()) {
            Entitlement e = (Entitlement) i.next();
            if (log.isDebugEnabled()) {
                log.debug("Adding Entitlement to form: " + e.getLabel() +
                        " hrl: " + e.getHumanReadableLabel());
            }
            daForm.set(e.getLabel(), Boolean.TRUE);
        }
        
        daForm.set(UserServerPreferenceId.RECEIVE_NOTIFICATIONS,
                new Boolean(UserManager.lookupUserServerPreferenceValue(
                        user, s, UserServerPreferenceId.RECEIVE_NOTIFICATIONS)));
        
        daForm.set(UserServerPreferenceId.INCLUDE_IN_DAILY_SUMMARY,
                new Boolean(UserManager.lookupUserServerPreferenceValue(
                        user, s, UserServerPreferenceId.INCLUDE_IN_DAILY_SUMMARY)));
        
        daForm.set(AUTO_UPDATE, 
                   s.getAutoUpdate().equals("Y") ? Boolean.TRUE : Boolean.FALSE);
        
        daForm.set(DESCRIPTION, s.getDescription());
        
        if (s.getLocation() != null) {
            daForm.set(ADDRESS_ONE, s.getLocation().getAddress1());
            daForm.set(ADDRESS_TWO, s.getLocation().getAddress2());
            daForm.set(CITY, s.getLocation().getCity());
            daForm.set(STATE, s.getLocation().getState());
            daForm.set(COUNTRY, s.getLocation().getCountry());
            daForm.set(BUILDING, s.getLocation().getBuilding());
            daForm.set(ROOM, s.getLocation().getRoom());
            daForm.set(RACK, s.getLocation().getRack());
        }
    }
    
    private List createAddOnEntitlementList(Org orgIn, 
            Set validAddonEntitlementsForServer) {
        List retval = new LinkedList();
        Iterator i = validAddonEntitlementsForServer.iterator();
        while (i.hasNext()) {
            Entitlement e = (Entitlement) i.next();
            retval.add(new EntitlementDto(e, 
                    EntitlementManager.getAvailableEntitlements(e, orgIn)));
        }
        Collections.sort(retval);
        return retval;
    }

    protected List createBaseEntitlementDropDownList(User user, Server s) {
        LocalizationService ls = LocalizationService.getInstance();
        Entitlement baseEntitlement = s.getBaseEntitlement();
        
        List entitlements = new ArrayList();
        
        if (baseEntitlement == null) {
            entitlements.add(new LabelValueBean(
                    ls.getMessage("sdc.details.edit.none"), "none"));
        }
        
        if (user.hasRole(RoleFactory.ORG_ADMIN)) {
           if (baseEntitlement != null) {
               entitlements.add(new LabelValueBean(
                       ls.getMessage("sdc.details.edit.unentitle"), UNENTITLE));
           }
           
           Iterator i = user.getOrg().getValidBaseEntitlementsForOrg().iterator();
           
           while (i.hasNext()) {
              Entitlement e = (Entitlement) i.next();

              if (log.isDebugEnabled()) {
                  log.debug("Adding Entitlement to list of valid ents: " +
                          e.getLabel());    
              }
              
              entitlements.add(new LabelValueBean(
                      e.getHumanReadableLabel(), e.getLabel()));
           }
        }
        
        return entitlements;
    }
    
    protected List getCountries() {
        LocalizationService ls = LocalizationService.getInstance();
        Map cmap = ls.availableCountries();
        Iterator i = cmap.keySet().iterator();
        List countries = new LinkedList();
        
        countries.add(new LabelValueBean(ls.getMessage("sdc.details.edit.none"), ""));
        while (i.hasNext()) {
            String name = (String) i.next();
            String code = (String) cmap.get(name);
            countries.add(new LabelValueBean(name, code));
        }
        return countries;
    }
    
    private void handleSolarisError(HttpServletRequest request, Entitlement e) {
        log.debug("Solaris Machine can't accept monitoring slotes.");
        
        ValidatorError err = new ValidatorError(
                "system.entitle.no-add.solaris-slots", e.getHumanReadableLabel());
        
        getStrutsDelegate().saveMessages(request, 
                RhnValidationHelper.validatorErrorToActionErrors(err));
    }
    
    private boolean checkSolarisFailure(Set<Entitlement> validAddons, Entitlement e,
            DynaActionForm daForm, Server s) {
        return (s.isSolaris()) ? checkEnt(validAddons, e, daForm) : false;
    }
    
    private boolean checkEnt(Set<Entitlement> validAddons,
            Entitlement e, DynaActionForm daForm) {

        return validAddons.contains(e) &&
                    Boolean.TRUE.equals(daForm.get(e.getLabel()));
    }
}
