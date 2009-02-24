/**
 * Copyright (c) 2009 Red Hat, Inc.
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
package com.redhat.rhn.frontend.action.kickstart.cobbler;

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.security.PermissionException;
import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnValidationHelper;
import com.redhat.rhn.manager.acl.AclManager;
import com.redhat.rhn.manager.kickstart.cobbler.BaseCobblerSnippetCommand;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;
import org.apache.struts.action.DynaActionForm;

import java.io.File;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * BaseCobblerSnippetEditAction - abstract base class for Cobbler Snippets
 *  
 * @version $Rev: 1 $
 */
public abstract class BaseCobblerSnippetEditAction extends RhnAction {

    public static final String SNIPPET = "cobblerSnippet";
    public static final String NAME = "name";
    public static final String CONTENTS = "contents";
    
    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
                                  ActionForm formIn,
                                  HttpServletRequest request,
                                  HttpServletResponse response) {

        ActionMessages messages = new ActionMessages();

        if (!AclManager.hasAcl("user_role(org_admin)",
            request, null)) {
            //Throw an exception with a nice error message so the user
            //knows what went wrong.
            LocalizationService ls = LocalizationService.getInstance();
            PermissionException pex =
                new PermissionException(
                    "Only Org Admins can modify Cobbler snippets");
            pex.setLocalizedTitle(ls.getMessage("permission.jsp.summary.acl.header"));
            pex.setLocalizedSummary(ls.getMessage("permission.jsp.summary.acl.reason5"));
            throw pex;
        }

        DynaActionForm form = (DynaActionForm) formIn;
        RequestContext ctx = new RequestContext(request);
        BaseCobblerSnippetCommand cmd = getCommand(ctx);

        String snipName = request.getParameter("name");
        String snipContents = new String();

        if (snipName != null) {
            cmd.setName(snipName);
            snipContents = cmd.getContents();
            cmd.setContents(snipContents);
            request.setAttribute(CONTENTS, snipContents);
        }

        request.setAttribute(SNIPPET, cmd.getCobblerSnippet());

        ActionForward retval = mapping.findForward("default");
        if (isSubmitted(form)) {
            String dirName = new String(BaseCobblerSnippetCommand.SNIPDIR);
            String[] result = snipName.split("/");

            for (int i = 0; i < (result.length - 1); i++) {
                dirName = dirName.concat(result[i]).concat("/");
                    File dir = new File(dirName);
                    dir.mkdir();
                }
 
                // only [a-zA-Z_0-9/] and '-' are valid filename characters
            Pattern p = Pattern.compile("^[\\w/\\.\\-_]*[\\w\\.\\-_]$");
            Matcher m = p.matcher(snipName);

            if (m.matches()) {
                cmd.setName(snipName);
                cmd.setContents(form.getString(CONTENTS));
                cmd.store();

                ValidatorError ve = cmd.store();
                if (ve != null) {
                    ValidatorError[] verr = {ve};
                    getStrutsDelegate().saveMessages(request,
                            RhnValidationHelper.validatorErrorToActionErrors(verr));
                    retval = mapping.findForward("default");
                } 
                else {
                    createSuccessMessage(request, getSuccessSnippet(), null);
                    retval = mapping.findForward("success");
                }
                
            }
            else {
                ActionMessage msg = new ActionMessage
                        ("cobbler.snippet.invalidfilename.message");
                messages.add("cobbler.snippet.invalidfilename.message", msg);
            }
        }
        else {
            if (cmd.getCobblerSnippet() != null) {
                form.set(NAME, cmd.getCobblerSnippet().getName());
            }
        }
        saveMessages(request, messages);
        return retval;
    }

    protected abstract BaseCobblerSnippetCommand getCommand(RequestContext ctx);
    
    /**
     * 'Overrideable' method for subclasses that require 
     * the contents field of cobblerSnippet to be set and non-empty  
     * @return boolean "true" that can be overridden 
     */
    protected boolean isContentsRequired() {
        return true;
    }

    /**
     * 'Overrideable' method for subclasses that require a
     * different success message.
     * @return String "cobblersnippet.update.success" that can be overridden
     */
    protected String getSuccessSnippet() {
        return "cobblersnippet.update.success";
    }

    /**
     * Erase the snippet from disk
     *
     * @param name name of the Cobbler Snippet
     * @return string error message or null if successful
     */
    public String deleteSnippet(String name) {
        File f = new File(name);
        boolean success = f.delete();
        if (!success) {
            return "cobbler.snippet.couldnotdelete.message";
        }
        return null;
    }


}
