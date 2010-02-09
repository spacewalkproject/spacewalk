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

import com.redhat.rhn.domain.config.ConfigRevision;
import com.redhat.rhn.frontend.action.configuration.ConfigActionHelper;
import com.redhat.rhn.frontend.action.configuration.ConfigFileForm;
import com.redhat.rhn.frontend.struts.RhnAction;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;

import java.io.IOException;
import java.io.OutputStream;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * FileDownloadAction
 * @version $Rev$
 */
public class FileDownloadAction extends RhnAction {

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping, ActionForm form,
            HttpServletRequest request, HttpServletResponse response) {
        Map params = makeParamMap(request);
        ConfigFileForm cff = (ConfigFileForm) form;

        ConfigRevision cr = ConfigActionHelper.findRevision(request);

        String charSet = response.getCharacterEncoding();
        String mimeType = getMimeType(cr);
        response.setContentType(mimeType + ";charset=" + charSet);
        response.setHeader("Content-Disposition", "attachment; filename=" +
                getDownloadFilename(cr));
        try {
            OutputStream out = response.getOutputStream();
            out.write(cr.getConfigContent().getContents());
            out.flush();
        }
        catch (IOException ioe) {
            ActionMessages msgs = new ActionMessages();
            ActionMessage am = 
                new ActionMessage("filedetails.jsp.error.download", 
                        ioe.getLocalizedMessage(), 
                        cr.getConfigFile().getConfigFileName().getPath());
            msgs.add(ActionMessages.GLOBAL_MESSAGE, am);
            saveMessages(request, msgs);
        }
        cff.updateFromRevision(request, cr);

        return null;
    }

    protected String getMimeType(ConfigRevision cr) {
        if (cr.getConfigContent().isBinary()) {
            return "application/octet-stream";
        }
        else {
            return "text/plain";
        }
    }

    protected String getDownloadFilename(ConfigRevision cr) {
        String path = cr.getConfigFile().getConfigFileName().getPath();
        String file = path.substring(path.lastIndexOf('/') + 1);
        return file;
    }
}
