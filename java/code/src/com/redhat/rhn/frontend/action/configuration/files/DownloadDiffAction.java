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

import com.redhat.rhn.common.filediff.Diff;
import com.redhat.rhn.domain.config.ConfigFile;
import com.redhat.rhn.domain.config.ConfigRevision;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.configuration.ConfigActionHelper;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.manager.configuration.ConfigurationManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;

import java.io.IOException;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.util.Date;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * DownloadDiffAction
 * @version $Rev$
 */
public class DownloadDiffAction extends RhnAction {
    
    /**
     * {@inheritDoc}
     */
    public ActionForward execute(ActionMapping mapping, ActionForm form,
            HttpServletRequest request, HttpServletResponse response) throws Exception {
        
        RequestContext requestContext = new RequestContext(request);
        
        User user = requestContext.getLoggedInUser();
        Long ocrid = requestContext.getRequiredParam("ocrid");
        
        //Get the objects.
        ConfigFile file = ConfigActionHelper.getFile(request);
        ConfigRevision revision = ConfigActionHelper.getRevision(request, file);
        ConfigRevision other = ConfigurationManager.getInstance()
            .lookupConfigRevision(user, ocrid);
        
        //Get the content that we will diff.
        String[] rev = revision.getConfigContent().getContentsString().split("\n");
        String[] orev = other.getConfigContent().getContentsString().split("\n");
        
        Diff diff = new Diff(rev, orev);
        String charSet = response.getCharacterEncoding();
        String mimeType = "text/plain";
        response.setContentType(mimeType + ";charset=" + charSet);
        response.setHeader("Content-Disposition", "attachment; filename=rhnpatch");
        
        try {
            OutputStream out = response.getOutputStream();
            OutputStreamWriter writer = new OutputStreamWriter(out);
            String path = file.getConfigFileName().getPath();
            String opath = other.getConfigFile().getConfigFileName().getPath();
            Date date = revision.getCreated();
            Date odate = other.getCreated();
            writer.write(diff.patchDiff(path, opath, date, odate));
            writer.flush();
            return null;
        }
        catch (IOException ioe) {
            ActionMessages msgs = new ActionMessages();
            ActionMessage am = 
                new ActionMessage("filedetails.jsp.error.download", 
                        ioe.getLocalizedMessage(), 
                        file.getConfigFileName().getPath());
            msgs.add(ActionMessages.GLOBAL_MESSAGE, am);
            saveMessages(request, msgs);
        }
        
        return getStrutsDelegate().forwardParams(mapping.findForward(
                RhnHelper.DEFAULT_FORWARD), request.getParameterMap());
    }

}
