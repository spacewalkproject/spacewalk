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
package com.redhat.rhn.frontend.action.kickstart;

import com.redhat.rhn.common.util.StringUtil;
import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.common.validator.ValidatorException;
import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.kickstart.KickstartVirtualizationType;
import com.redhat.rhn.domain.kickstart.builder.KickstartBuilder;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.xmlrpc.kickstart.InvalidVirtualizationTypeException;
import com.redhat.rhn.manager.kickstart.BaseKickstartCommand;
import com.redhat.rhn.manager.kickstart.KickstartEditCommand;
import com.redhat.rhn.manager.kickstart.KickstartFileDownloadCommand;
import com.redhat.rhn.manager.kickstart.cobbler.CobblerXMLRPCHelper;

import org.apache.commons.lang.BooleanUtils;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;
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
    
    private static final String  KERNEL_OPTIONS = "kernel_options";
    private static final String  POST_KERNEL_OPTIONS = "post_kernel_options";
    
    public static final String VIRTUALIZATION_TYPES = "virtualizationTypes";
    public static final String VIRTUALIZATION_TYPE_LABEL = "virtualizationTypeLabel";

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
        form.set(COMMENTS, cmd.getComments());
        form.set(ACTIVE, cmd.getActive());
        form.set(ORG_DEFAULT, cmd.getKickstartData().isOrgDefault());
        form.set(POST_LOG, cmd.getKickstartData().getPostLog());
        form.set(PRE_LOG, cmd.getKickstartData().getPreLog());
        form.set(KS_CFG, cmd.getKickstartData().getKsCfg());

        CobblerXMLRPCHelper helper = new CobblerXMLRPCHelper();
        Profile prof = Profile.lookupById(helper.getConnection(ctx.getLoggedInUser()), 
                cmd.getKickstartData().getCobblerId());
        if (prof != null) {
            form.set(KERNEL_OPTIONS, StringUtil.convertMapToString(
                    prof.getKernelOptions(), " "));
            form.set(POST_KERNEL_OPTIONS, StringUtil.convertMapToString(
                    prof.getKernelPostOptions(), " "));
        }
        
        // Lookup the kickstart virtualization types and pre-select the current one:
        List types = KickstartFactory.lookupVirtualizationTypes();
        form.set(VIRTUALIZATION_TYPES, types);
        form.set(VIRTUALIZATION_TYPE_LABEL, cmd.getVirtualizationType().getLabel());
        
        KickstartFileDownloadCommand dcmd = new KickstartFileDownloadCommand(
                cmd.getKickstartData().getId(), 
                cmd.getUser(), 
                ctx.getRequest());  
        ctx.getRequest().setAttribute(KickstartFileDownloadAction.KSURL, 
                dcmd.getOrgDefaultUrl());
        
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
            
                  
                        
            CobblerXMLRPCHelper helper = new CobblerXMLRPCHelper();
            Profile prof = Profile.lookupById(helper.getConnection(ctx.getLoggedInUser()), 
                    cmd.getKickstartData().getCobblerId());
            if (prof != null) {
                prof.setKernelOptions(StringUtil.convertOptionsToMap(
                        form.getString(KERNEL_OPTIONS), 
                        "kickstart.jsp.error.invalidvariable"));
                prof.setKernelPostOptions(StringUtil.convertOptionsToMap(
                        form.getString(POST_KERNEL_OPTIONS), 
                        "kickstart.jsp.error.invalidoption"));
                prof.save(); 
            }
  
            

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

    
}
