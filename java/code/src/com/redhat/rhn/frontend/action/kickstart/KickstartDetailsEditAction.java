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
package com.redhat.rhn.frontend.action.kickstart;


import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.common.validator.ValidatorException;
import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.kickstart.KickstartVirtualizationType;
import com.redhat.rhn.domain.kickstart.builder.KickstartBuilder;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnValidationHelper;
import com.redhat.rhn.frontend.struts.StrutsDelegate;
import com.redhat.rhn.frontend.xmlrpc.kickstart.InvalidVirtualizationTypeException;
import com.redhat.rhn.manager.kickstart.BaseKickstartCommand;
import com.redhat.rhn.manager.kickstart.KickstartEditCommand;
import com.redhat.rhn.manager.kickstart.KickstartFileDownloadCommand;
import com.redhat.rhn.manager.kickstart.KickstartManager;
import com.redhat.rhn.manager.kickstart.KickstartWizardHelper;
import com.redhat.rhn.manager.kickstart.cobbler.CobblerProfileCommand;
import com.redhat.rhn.manager.kickstart.cobbler.CobblerProfileEditCommand;
import com.redhat.rhn.manager.kickstart.cobbler.CobblerXMLRPCHelper;

import org.apache.commons.lang.BooleanUtils;
import org.apache.commons.lang.StringUtils;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;
import org.cobbler.Distro;
import org.cobbler.Profile;

import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * KickstartDetailsEdit extends RhnAction
 * @version $Rev: 1 $
 */
public class KickstartDetailsEditAction extends BaseKickstartEditAction {
    
    public static final String LABEL = "label";
    public static final String ACTIVE = "active";
    public static final String COMMENTS = "comments";
    public static final String ORG_DEFAULT = "org_default";
    public static final String  POST_LOG = "post_log";
    public static final String  PRE_LOG = "pre_log";
    public static final String  KS_CFG = "ksCfg";
    public static final String  KERNEL_OPTIONS = "kernel_options";
    public static final String  POST_KERNEL_OPTIONS = "post_kernel_options";

    
    public static final String VIRTUALIZATION_TYPES = "virtualizationTypes";
    public static final String VIRTUALIZATION_TYPE_LABEL = "virtualizationTypeLabel";
    
    public static final String IS_VIRT = "is_virt";
    public static final String VIRT_CPU = "virt_cpus";
    public static final String VIRT_DISK_SIZE = "virt_disk_size";
    public static final String VIRT_MEMORY = "virt_mem_mb";
    public static final String VIRT_BRIDGE = "virt_bridge";
    public static final String VIRT_PATH = "virt_disk_path";
    
    public static final String INVALID = "invalid";

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
                                  ActionForm formIn,
                                  HttpServletRequest request,
                                  HttpServletResponse response) {
        RequestContext context = new RequestContext(request);
        KickstartData data = context.lookupAndBindKickstartData();
                
        if (data.isRawData()) {
            return getStrutsDelegate().forwardParam(
                    mapping.findForward("raw_mode"), RequestContext.KICKSTART_ID, 
                                                            data.getId().toString());
            
        }
        return super.execute(mapping, formIn, request, response);
        
    }
    /**
     * {@inheritDoc}
     */
    protected void setupFormValues(RequestContext ctx, 
            DynaActionForm form, BaseKickstartCommand cmdIn) {
        KickstartEditCommand cmd = (KickstartEditCommand) cmdIn;
        form.set(LABEL, cmd.getLabel());
        if (!cmdIn.getKickstartData().isValid()) {
            ctx.getRequest().setAttribute(INVALID, Boolean.TRUE);
            return;
        }
        
        form.set(COMMENTS, cmd.getComments());
        form.set(ACTIVE, cmd.getActive());
        form.set(ORG_DEFAULT, cmd.getKickstartData().isOrgDefault());
        form.set(POST_LOG, cmd.getKickstartData().getPostLog());
        form.set(PRE_LOG, cmd.getKickstartData().getPreLog());
        form.set(KS_CFG, cmd.getKickstartData().getKsCfg());


        setupCobblerFormValues(ctx, form, cmd.getKickstartData());
        
        KickstartWizardHelper wizardHelper = new 
                            KickstartWizardHelper(ctx.getLoggedInUser()); 
        // Lookup the kickstart virtualization types and pre-select the current one:
        List types = wizardHelper.getVirtualizationTypes();
        form.set(VIRTUALIZATION_TYPES, types);
        form.set(VIRTUALIZATION_TYPE_LABEL, cmd.getVirtualizationType().getLabel());
        
        KickstartFileDownloadCommand dcmd = new KickstartFileDownloadCommand(
                cmd.getKickstartData().getId(), 
                cmd.getUser(), 
                ctx.getRequest());  
        ctx.getRequest().setAttribute(KickstartFileDownloadAction.KSURL, 
                dcmd.getOrgDefaultUrl());
        checkKickstartFile(ctx, getStrutsDelegate());
    }
    

    /**
     * Setup cobbler form values These include, kernel options and virt options
     * @param ctx the RequestContext
     * @param form The form
     * @param data the kickstart data
     */
    public static void setupCobblerFormValues(RequestContext ctx,
            DynaActionForm form, KickstartData data) {
        CobblerXMLRPCHelper helper = new CobblerXMLRPCHelper();
        Profile prof = Profile.lookupById(helper.getConnection(ctx.getLoggedInUser()), 
                data.getCobblerId());
        if (prof != null) {
            form.set(KERNEL_OPTIONS, prof.getKernelOptionsString());
            form.set(POST_KERNEL_OPTIONS, prof.getKernelPostOptionsString());
        }
        KickstartVirtualizationType type = data.getKickstartDefaults().
                                                    getVirtualizationType();
        //Should we show virt options?
        if (!type.equals(KickstartVirtualizationType.paraHost()) &&
                !type.equals(KickstartVirtualizationType.none())) {
           if (prof == null) {
               form.set(VIRT_BRIDGE, data.getDefaultVirtBridge());
               form.set(VIRT_CPU, ConfigDefaults.get().getDefaultVirtCpus());
               form.set(VIRT_DISK_SIZE, ConfigDefaults.get().getDefaultVirtDiskSize());
               form.set(VIRT_MEMORY, ConfigDefaults.get().getDefaultVirtMemorySize());
           }
           else {
               setFormValueOrDefault(form, VIRT_BRIDGE, prof.getVirtBridge(), 
                       data.getDefaultVirtBridge());
               setFormValueOrDefault(form, VIRT_CPU, prof.getVirtCpus(),
                       ConfigDefaults.get().getDefaultVirtCpus());
               setFormValueOrDefault(form, VIRT_DISK_SIZE, prof.getVirtFileSize(),
                       ConfigDefaults.get().getDefaultVirtDiskSize());
               setFormValueOrDefault(form, VIRT_MEMORY, prof.getVirtRam(),
                       ConfigDefaults.get().getDefaultVirtMemorySize());  
           }
           ctx.getRequest().setAttribute(IS_VIRT, Boolean.TRUE);    
        }
    }
    
    
    private static void setFormValueOrDefault(DynaActionForm form, String key, 
                                            Object value, Object defaultValue) {
        if (value == null || StringUtils.isBlank(value.toString()) || value.equals(0)) {
            form.set(key, defaultValue);
        }
        else {
            form.set(key, value);
        }
    }
    
        

    /**
     * {@inheritDoc}
     */
    protected ValidatorError processFormValues(HttpServletRequest request, 
            DynaActionForm form, 
            BaseKickstartCommand cmdIn) {
        
        ValidatorError error = null;
        KickstartEditCommand cmd = (KickstartEditCommand) cmdIn;
        RequestContext ctx = new RequestContext(request);
        KickstartBuilder builder = new KickstartBuilder(ctx.getLoggedInUser());
        cmd.setComments(form.getString(COMMENTS));
        try {
            

            KickstartVirtualizationType vType = 
                KickstartFactory.lookupKickstartVirtualizationTypeByLabel(
                    form.getString(VIRTUALIZATION_TYPE_LABEL));
            
            Distro distro = CobblerProfileCommand.getCobblerDistroForVirtType(
                    cmdIn.getKickstartData().getTree(), vType, ctx.getLoggedInUser());
            if (distro == null) {
                ValidatorException.raiseException("kickstart.cobbler.profile.invalidvirt"); 
            }
            
            
            if (!cmdIn.getKickstartData().getLabel().equals(form.getString(LABEL))) {
                builder.validateNewLabel(form.getString(LABEL));
            }
            
            
            cmd.setLabel(form.getString(LABEL));
            cmd.setActive(new 
                    Boolean(BooleanUtils.toBoolean((Boolean) form.get(ACTIVE))));
            cmd.setIsOrgDefault(new 
                    Boolean(BooleanUtils.toBoolean((Boolean) form.get(ORG_DEFAULT))));
            cmd.getKickstartData().setPostLog(
                    BooleanUtils.toBoolean((Boolean) form.get(POST_LOG)));
            cmd.getKickstartData().setPreLog(
                    BooleanUtils.toBoolean((Boolean) form.get(PRE_LOG)));
            cmd.getKickstartData().setKsCfg(
                    BooleanUtils.toBoolean((Boolean) form.get(KS_CFG)));
            
            processCobblerFormValues(cmd.getKickstartData(), form, ctx.getLoggedInUser());
            
            String virtTypeLabel = form.getString(VIRTUALIZATION_TYPE_LABEL);
            KickstartVirtualizationType ksVirtType = KickstartFactory.
                lookupKickstartVirtualizationTypeByLabel(virtTypeLabel);
            if (ksVirtType == null) {
                throw new InvalidVirtualizationTypeException(virtTypeLabel);
            }
            cmd.setVirtualizationType(ksVirtType);
            

            
            return null;
        }
        catch (ValidatorException ve) {
            return ve.getResult().getErrors().get(0);
        }
    }

    protected String getSuccessKey() {
        return "kickstart.details.success";
    }

    /**
     * {@inheritDoc}
     */
    protected BaseKickstartCommand getCommand(RequestContext ctx) {
        return new KickstartEditCommand(ctx.getRequiredParam(RequestContext.KICKSTART_ID),
                ctx.getCurrentUser());
    }    
    
   
    /**
     * Should i save virt options?
     * @param data the kickstart data
     * @param form the form
     * @return true if you should save the kickstart options
     */
    private static boolean canSaveVirtOptions(KickstartData data, DynaActionForm form) {
        //if the form was not part of the values submitted, don't save values
        if (form.get(VIRT_DISK_SIZE) == null) {
            return false;
        }
        //or if it was there, but we switched to none-type, don't save it either
        String virtType = (String) form.get(VIRTUALIZATION_TYPE_LABEL);
        return virtType != null && !virtType.equals(
                KickstartFactory.VIRT_TYPE_PV_HOST.getLabel());
    }
    
    
    /**
     * Proccess Cobbler form values, pulling in the form 
     *      and pushing the values to cobbler
     * @param ksdata the kickstart data
     * @param form the form
     * @param user the user
     */
    public static void processCobblerFormValues(KickstartData ksdata, 
                                            DynaActionForm form, User user) {
        CobblerProfileEditCommand cmd = new CobblerProfileEditCommand(ksdata, user);

        cmd.setKernelOptions(StringUtils.defaultString(form.getString(KERNEL_OPTIONS)));
        cmd.setPostKernelOptions(StringUtils.defaultString(
                            form.getString(POST_KERNEL_OPTIONS)));
        cmd.store();

        CobblerXMLRPCHelper helper = new CobblerXMLRPCHelper();
        Profile prof = Profile.lookupById(helper.getConnection(user), 
                ksdata.getCobblerId());
        if (prof == null) {
            return;
        }
        
        if (KickstartDetailsEditAction.canSaveVirtOptions(ksdata, form)) {
            prof.setVirtRam((Integer) form.get(VIRT_MEMORY));
            prof.setVirtCpus((Integer) form.get(VIRT_CPU));
            prof.setVirtFileSize((Integer) form.get(VIRT_DISK_SIZE));
            prof.setVirtBridge(form.getString(VIRT_BRIDGE));
        }
        prof.save();
    }

    /**
     * Method used to check if when/after a kickstart file was generated
     * if there is any glitch (like parser error) in the template that got created
     * @param context the request context
     * @param strutsDelegate the strutsdelegate associated to the action.
     */
    public static void checkKickstartFile(RequestContext context,
                                                StrutsDelegate strutsDelegate) {
        try {
            KickstartManager.getInstance().validateKickstartFile(
                    context.lookupAndBindKickstartData());
        }
        catch (ValidatorException ve) {
            RhnValidationHelper.setFailedValidation(context.getRequest());
            strutsDelegate.saveMessages(context.getRequest(), ve.getResult());          
        }
    }
}
