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

import javax.servlet.http.HttpServletRequest;

import org.apache.commons.lang.BooleanUtils;
import org.apache.struts.action.DynaActionForm;

import java.util.List;

import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.kickstart.KickstartVirtualizationType;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.xmlrpc.kickstart.InvalidVirtualizationTypeException;
import com.redhat.rhn.manager.kickstart.BaseKickstartCommand;
import com.redhat.rhn.manager.kickstart.KickstartEditCommand;
import com.redhat.rhn.manager.kickstart.KickstartFileDownloadCommand;

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
    public static final String  KS_CFG = "KsCfg";
    
    public static final String VIRTUALIZATION_TYPES = "virtualizationTypes";
    public static final String VIRTUALIZATION_TYPE_LABEL = "virtualizationTypeLabel";
    
    /**
     * {@inheritDoc}
     */
    protected void setupFormValues(RequestContext ctx, 
            DynaActionForm form, BaseKickstartCommand cmdIn) {
        KickstartEditCommand cmd = (KickstartEditCommand) cmdIn;
        form.set(LABEL, cmd.getLabel());
        form.set(COMMENTS, cmd.getComments());
        form.set(ACTIVE, cmd.getActive());
        form.set(ORG_DEFAULT, cmd.getKickstartData().getIsOrgDefault());
        form.set(POST_LOG, cmd.getKickstartData().getPostLog());
        form.set(PRE_LOG, cmd.getKickstartData().getPreLog());
        form.set(KS_CFG, cmd.getKickstartData().getKsCfg());

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
        KickstartEditCommand cmd = (KickstartEditCommand) cmdIn;
        KickstartHelper helper = new KickstartHelper(request);
        ValidatorError retval = null;

        cmd.setComments(form.getString(COMMENTS));
        String label = form.getString(LABEL);
        
        if (!helper.isLabelValid(label)) {
            retval =  new ValidatorError("kickstart.error.invalidlabel", 
                    KickstartHelper.MIN_KS_LABEL_LENGTH);         
        }
        else if (label.trim().length() == 0) {
          retval = new ValidatorError("kickstart.details.nolabel", 
                  KickstartHelper.MIN_KS_LABEL_LENGTH);
        }
        else {
          cmd.setLabel(form.getString(LABEL));
        }
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
        
        String virtTypeLabel = form.getString(VIRTUALIZATION_TYPE_LABEL);
        KickstartVirtualizationType ksVirtType = KickstartFactory.
            lookupKickstartVirtualizationTypeByLabel(virtTypeLabel);
        if (ksVirtType == null) {
            throw new InvalidVirtualizationTypeException(virtTypeLabel);
        }
        cmd.setVirtualizationType(ksVirtType);

        return retval;
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
