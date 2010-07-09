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
package com.redhat.rhn.frontend.action.configuration;

import com.redhat.rhn.common.util.StringUtil;
import com.redhat.rhn.common.validator.ValidatorException;
import com.redhat.rhn.common.validator.ValidatorResult;
import com.redhat.rhn.domain.config.ConfigChannel;
import com.redhat.rhn.domain.config.ConfigFile;
import com.redhat.rhn.domain.config.ConfigRevision;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnValidationHelper;
import com.redhat.rhn.manager.configuration.ConfigFileBuilder;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;

import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * BaseAddFilesAction
 * @version $Rev$
 */
public abstract class BaseAddFilesAction extends RhnAction {

    public static final String MAX_SIZE = "maxbytes";

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping, ActionForm form,
            HttpServletRequest request, HttpServletResponse response) {

        Map params = makeParamMap(request);
        ConfigFileForm cff = (ConfigFileForm) form;

        processRequest(request);
        request.setAttribute(MAX_SIZE,
                 StringUtil.displayFileSize(ConfigFile.getMaxFileSize()));

        if (isSubmitted(cff)) {
            ConfigChannel channel = getConfigChannel(request);

            if (passesValidation(request, cff, mapping, channel, params)) {
                return doCreate(request, cff, mapping, channel, params);
            }
        }
        else {
            cff.setDefaults();
        }
        return getStrutsDelegate().forwardParams(
                mapping.findForward("default"), params);
    }

    /**
     * Check for new-file-creation validity. The order of importance is:
     *
     * <ol>
     * <li>IF upload - a file-to-be uploaded was provided</li>
     * <li>Filename and path are valid</li>
     * <li>Filename is unique in this channel</li>
     * <li>Everything Else</li>
     * </ol>
     *
     * @param req incoming request
     * @param cff associated ConfigFileForm
     * @param mapping incoming action-mapping
     * @param channel channel we're creating a file into
     * @param params associated parameters
     * @return true if everything's valid, false (and messages have been stored)
     * else
     */
    protected boolean passesValidation(HttpServletRequest req,
            ConfigFileForm cff, ActionMapping mapping, ConfigChannel channel,
            Map params) {

        RhnValidationHelper.setFailedValidation(req);
        // File-upload errors? Bug out if so
        if (mapping.getPath().indexOf("Upload") >= 0) {
            ValidatorResult result = cff.validateUpload(req);
            // If we have any errors, report and bolt
            if (!result.isEmpty()) {
                getStrutsDelegate().saveMessages(req, result);
                return false;
            }
        }
        return true;
    }

    protected ActionForward doCreate(HttpServletRequest req,
            DynaActionForm form, ActionMapping mapping, ConfigChannel channel,
            Map params) {

        ConfigFileForm cff = (ConfigFileForm) form;

        // Yay! We actually might be able to create this file!
        try {
            RequestContext ctx = new RequestContext(req);
            ConfigRevision cr = ConfigFileBuilder.getInstance().create(
                                            cff.toData(),
                                            ctx.getLoggedInUser(), channel);
            if (cr != null) {

                ConfigActionHelper.setupRequestAttributes(ctx, cr
                        .getConfigFile(), cr);
                params.put("cfid", cr.getConfigFile().getId().toString());
                return getStrutsDelegate().forwardParams(
                        mapping.findForward("success"), params);
            }
        }
        catch (ValidatorException ve) {
            getStrutsDelegate().saveMessages(req, ve.getResult());
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        // If we got here, something went wrong - try again
        return getStrutsDelegate().forwardParams(
                mapping.findForward("default"), params);
    }

    protected abstract ConfigChannel getConfigChannel(HttpServletRequest request);

    protected abstract void processRequest(HttpServletRequest request);

}
