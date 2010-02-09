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
package com.redhat.rhn.frontend.action.configuration.files;

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.common.util.StringUtil;
import com.redhat.rhn.common.validator.ValidatorException;
import com.redhat.rhn.domain.config.ConfigRevision;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.configuration.ConfigActionHelper;
import com.redhat.rhn.frontend.action.configuration.ConfigFileForm;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnValidationHelper;
import com.redhat.rhn.manager.configuration.ConfigFileBuilder;
import com.redhat.rhn.manager.configuration.ConfigurationManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * 
 * FileDetailsAction
 * @version $Rev$
 */
public class FileDetailsAction extends RhnAction {
    
    // REQUEST elements
    public static final String REV_SIZE          = "revbytes";
    public static final String REV_TOTAL_SIZE    = "totalbytes";
    public static final String REV_CREATED       = "created";
    public static final String REV_MODIFIED      = "modified";
    public static final String MAX_SIZE          = "maxbytes";
    public static final String MAX_EDIT_SIZE     = "maxEditBytes";
    public static final String LAST_USER         = "lastUser";
    public static final String LAST_USER_ID      = "lastUserId";
    public static final String TOOLARGE          = "toolarge";
    
    public static final String VALIDATION_XSD =
        "/com/redhat/rhn/frontend/action/configuration/validation/configFileForm.xsd";

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping, ActionForm form,
            HttpServletRequest request, HttpServletResponse response) {
        
        RequestContext context = new RequestContext(request);
        ConfigFileForm cff = (ConfigFileForm)form;
        
        ConfigRevision cr = ConfigActionHelper.findRevision(request);
        cff.set(ConfigFileForm.REV_FILETYPE,
                        cr.getConfigFileType().getLabel());
        cff.set(ConfigFileForm.REV_PATH, cr.getConfigFile().getConfigFileName().getPath());
        Map params = makeParamMap(request);
       
        if (cr != null) {
            if (isSubmitted(cff)) {
                
                // Shameful code ahead
                //
                // If this is a DIRECTORY, we've carefully arranged for the user to 
                // only ever fill in uid/gid/mode, because that's all that makes
                // sense.  Unfortunately, the DB schema REQUIRES macro start and
                // end.  That means that updating a directory currently throws
                // struts-validation errors "Start/End Macro Required" - and if you 
                // relax that constraint, then the DB throws a nasty SQLException on update.
                //
                // The right fix involves schema-changes, which is NOT an option.  So,
                // here, we check for isDir - and if you are, we give you the default
                // macro-tags, willy-nilly.
                //
                // Ew.
                if (cr.isDirectory() || cr.getConfigContent().isBinary()) {
                    cff.set(ConfigFileForm.REV_MACROSTART, "{@");
                    cff.set(ConfigFileForm.REV_MACROEND, "@}");
                }
                
                ConfigFileBuilder builder = ConfigFileBuilder.getInstance();
                try {
                    cr = builder.update(cff.toRevisedData(cr), 
                            context.getLoggedInUser(), cr.getConfigFile());
                    params.put("crid", cr.getId().toString());
                }
                catch (ValidatorException ve) {
                    getStrutsDelegate().saveMessages(request, ve.getResult());
                    RhnValidationHelper.setFailedValidation(request);
                    cff.updateFromRevision(request, cr);
                    return getStrutsDelegate().forwardParams(
                            mapping.findForward("error"), params);                    
                }
            }
            cff.updateFromRevision(request, cr);
            setupRequestParams(context, cr);
            request.setAttribute("form", cff);
        }
        return getStrutsDelegate().forwardParams(mapping.findForward("default"), params);
    }

    protected void setupRequestParams(RequestContext ctx, ConfigRevision cr) {
        
        HttpServletRequest request = ctx.getRequest();
        ConfigActionHelper.setupRequestAttributes(ctx, cr.getConfigFile(), cr);
        
        int totalBytes = 0;
        
        if (!cr.isDirectory()) {
            totalBytes = ConfigurationManager.getInstance().
            getFileStorage(ctx.getLoggedInUser(), cr.getConfigFile());
        }
        
        request.setAttribute(MAX_SIZE, 
                StringUtil.displayFileSize(
                        Config.get().getInt(ConfigDefaults.CONFIG_REVISION_MAX_SIZE,
                                ConfigDefaults.DEFAULT_CONFIG_REVISION_MAX_SIZE)));
        request.setAttribute(MAX_EDIT_SIZE,
                StringUtil.displayFileSize(ConfigFileForm.MAX_EDITABLE_SIZE));
        
        request.setAttribute(REV_TOTAL_SIZE, StringUtil.displayFileSize(totalBytes));
        request.setAttribute(REV_SIZE, 
                StringUtil.displayFileSize(
                        cr.getConfigContent().getFileSize().longValue()));
        request.setAttribute(REV_CREATED, 
                StringUtil.categorizeTime(cr.getConfigFile().getCreated().getTime(),
                        StringUtil.WEEKS_UNITS));
        request.setAttribute(REV_MODIFIED, 
                StringUtil.categorizeTime(cr.getConfigContent().
                                                    getModified().getTime(),
                        StringUtil.WEEKS_UNITS));
        
        User lastUser = cr.getChangedBy();
        if (lastUser != null) {
            request.setAttribute(LAST_USER, lastUser.getLogin());
            request.setAttribute(LAST_USER_ID, lastUser.getId());
        }
    }
}
