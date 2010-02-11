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
package com.redhat.rhn.frontend.action.satellite;

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnValidationHelper;
import com.redhat.rhn.frontend.struts.StrutsDelegate;
import com.redhat.rhn.manager.satellite.ConfigureCertificateCommand;

import org.apache.commons.lang.StringUtils;
import org.apache.struts.action.ActionErrors;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * CertificateConfigAction - Struts action to process the uploaded Sat Cert. 
 *  
 * @version $Rev: 1 $
 */
public class CertificateConfigAction extends BaseConfigAction {

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
                                 ActionForm formIn,
                                 HttpServletRequest request,
                                 HttpServletResponse response) {
        
        DynaActionForm form = (DynaActionForm) formIn;
        RequestContext requestContext = new RequestContext(request);
        
        StrutsDelegate strutsDelegate = getStrutsDelegate();
        
        if (isSubmitted(form)) {
            ConfigureCertificateCommand cmd = (ConfigureCertificateCommand) 
                getCommand(requestContext.getCurrentUser());
            String certString = strutsDelegate.getFormFileString(form, 
                                                CertificateConfigForm.CERT_FILE);
            // If we didn't get it from the File, we need to 
            // get it from the pasted in form val.
            if (StringUtils.isEmpty(certString)) {
                certString = form.getString(CertificateConfigForm.CERT_TEXT);
            }

            if (StringUtils.isEmpty(certString)) {
                addMessage(request, "certificate.config.error.nocert");
            } 
            else {
                cmd.setCertificateText(certString);

                String ignoreMismatch = request.getParameter("ignoreMismatch");
                cmd.setIgnoreVersionMismatch(ignoreMismatch != null);

                ValidatorError[] verrors = cmd.storeConfiguration();
                if (verrors != null) {
                    ActionErrors errors = 
                        RhnValidationHelper.validatorErrorToActionErrors(verrors);
                    strutsDelegate.saveMessages(request, errors);
                } 
                else {
                    addMessage(request, "certificate.config.success");
                }
            }
        }
        return mapping.findForward("default");
    }

    /**
     * {@inheritDoc}
     */
    protected String getCommandClassName() {
        return Config.get().getString("web.com.redhat.rhn.frontend." +
           "action.satellite.CertificateConfigAction.command", 
           "com.redhat.rhn.manager.satellite.ConfigureCertificateCommand");
    }

}
