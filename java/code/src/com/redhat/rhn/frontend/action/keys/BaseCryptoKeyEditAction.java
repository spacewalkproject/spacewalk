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
package com.redhat.rhn.frontend.action.keys;

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.security.PermissionException;
import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnValidationHelper;
import com.redhat.rhn.frontend.struts.StrutsDelegate;
import com.redhat.rhn.manager.acl.AclManager;
import com.redhat.rhn.manager.kickstart.crypto.BaseCryptoKeyCommand;

import org.apache.commons.lang.StringUtils;
import org.apache.struts.action.ActionErrors;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;

import java.util.LinkedList;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * BaseCryptoKeyEditAction - abstract base class for cryptokeys
 *  
 * @version $Rev: 1 $
 */
public abstract class BaseCryptoKeyEditAction extends RhnAction {

    public static final String KEY = "cryptoKey";
    public static final String DESCRIPTION = "description";
    public static final String CONTENTS = "contents";
    public static final String TYPE = "type";
    public static final String TYPES = "types";
    
    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
                                  ActionForm formIn,
                                  HttpServletRequest request,
                                  HttpServletResponse response) {

        if (!AclManager.hasAcl("user_role(org_admin) or user_role(config_admin)",
            request, null)) {
            //Throw an exception with a nice error message so the user
            //knows what went wrong.
            LocalizationService ls = LocalizationService.getInstance();
            PermissionException pex =
                new PermissionException(
                    "Only Org Admins or Configuration Admins can modify crypto keys");
            pex.setLocalizedTitle(ls.getMessage("permission.jsp.summary.acl.header"));
            pex.setLocalizedSummary(ls.getMessage("permission.jsp.summary.acl.reason5"));
            throw pex;
        }

        DynaActionForm form = (DynaActionForm) formIn;
        RequestContext ctx = new RequestContext(request);
        BaseCryptoKeyCommand cmd = getCommand(ctx);
        
        StrutsDelegate strutsDelegate = getStrutsDelegate(); 
        
        request.setAttribute(KEY, cmd.getCryptoKey());
        List types = new LinkedList();
        types.add(lvl10n("crypto.key.gpg", 
                KickstartFactory.KEY_TYPE_GPG.getLabel()));
        types.add(lvl10n("crypto.key.ssl",
                KickstartFactory.KEY_TYPE_SSL.getLabel()));
        request.setAttribute(TYPES, types);
        ActionForward retval = mapping.findForward("default");
        if (isSubmitted(form)) {
            ActionErrors errors = RhnValidationHelper.validateDynaActionForm(
                    this, form);
            String contents = strutsDelegate.getFormFileString(form, CONTENTS);
            if (isContentsRequired() && StringUtils.isEmpty(contents)) {
                strutsDelegate.addError("crypto.key.nokey", errors);
            }
            if (!errors.isEmpty()) {
                strutsDelegate.saveMessages(request, errors);
            } 
            else {
                cmd.setDescription(form.getString(DESCRIPTION));
                cmd.setContents(contents);
                cmd.setType(form.getString(TYPE));
                ValidatorError[] verrors = cmd.store();
                if (verrors != null) {
                    ActionErrors storeErrors = 
                        RhnValidationHelper.validatorErrorToActionErrors(verrors);
                    strutsDelegate.saveMessages(request, storeErrors);
                } 
                else {
                    createSuccessMessage(request, getSuccessKey(), null);
                    retval = mapping.findForward("success");
                }
            }
        } 
        else {
            if (cmd.getCryptoKey() != null) {
                form.set(DESCRIPTION, cmd.getCryptoKey().getDescription());
            }
            form.set(TYPE, cmd.getType());
        }
        return retval;
    }

    protected abstract BaseCryptoKeyCommand getCommand(RequestContext ctx);
    
    /**
     * 'Overrideable' method for subclasses that require a 
     * different success message.  
     * @return String "crypto.key.success" that can be overridden 
     */
    protected String getSuccessKey() {
        return "crypto.key.success";
    }

    /**
     * 'Overrideable' method for subclasses that require 
     * the contents field of cryptoKey to be set and non-empty  
     * @return boolean "true" that can be overridden 
     */
    protected boolean isContentsRequired() {
        return true;
    }
}
