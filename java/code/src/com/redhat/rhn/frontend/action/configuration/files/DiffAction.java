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
import com.redhat.rhn.domain.config.ConfigInfo;
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

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * DiffAction - For displaying file diffs.
 * @version $Rev$
 */
public class DiffAction extends RhnAction {

    /**
     * {@inheritDoc}
     */
    public ActionForward execute(ActionMapping mapping, ActionForm form,
            HttpServletRequest request, HttpServletResponse response) throws Exception {

        RequestContext requestContext = new RequestContext(request);

        User user = requestContext.getLoggedInUser();
        Long ocrid = requestContext.getRequiredParam("ocrid");
        String view = request.getParameter("view");
        if (view == null) {
            view = "full";
        }

        //Get the objects.
        ConfigFile file = ConfigActionHelper.getFile(request);
        ConfigRevision revision = ConfigActionHelper.getRevision(request, file);
        ConfigRevision other = ConfigurationManager.getInstance()
            .lookupConfigRevision(user, ocrid);

        //Only do the diff if both files are text files.
        if (!revision.isDirectory() && !revision.getConfigContent().isBinary() &&
                !other.isDirectory() && !other.getConfigContent().isBinary()) {
            request.setAttribute("showdiff", "true");
            request.setAttribute("diff",
                    performFileDiff(revision, other, view.equals("changed")));
        }

        //Set attributes so we can display basic file information.
        ConfigActionHelper.processRequestAttributes(new RequestContext(request));
        request.setAttribute("orevision", other);
        request.setAttribute("ofile", other.getConfigFile());
        request.setAttribute("ochannel", other.getConfigFile().getConfigChannel());
        request.setAttribute("view", view);

        setInfoDiffAttributes(revision, other, request);

        return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
    }

    private String performFileDiff(ConfigRevision revision, ConfigRevision other,
            boolean showChanged) {
        //Get the content that we will diff.
        String[] rev = revision.getConfigContent().getContentsString().split("\n");
        String[] orev = other.getConfigContent().getContentsString().split("\n");

        //Diff the content.
        Diff diff = new Diff(rev, orev);
        return diff.htmlDiff(showChanged);
    }

    private void setInfoDiffAttributes(ConfigRevision revision, ConfigRevision other,
            HttpServletRequest request) {
        ConfigInfo info = revision.getConfigInfo();
        ConfigInfo oinfo = other.getConfigInfo();

        //The following pieces are differences between revisions that are
        //not in the file content.  We only show these if they are different.
        if (!info.getFilemode().equals(oinfo.getFilemode())) {
            request.setAttribute("diffmode", "true");
        }
        if (!info.getUsername().equals(oinfo.getUsername())) {
            request.setAttribute("diffuser", "true");
        }
        if (!info.getGroupname().equals(oinfo.getGroupname())) {
            request.setAttribute("diffgroup", "true");
        }
        if (!revision.getDelimStart().equals(other.getDelimStart()) ||
                !revision.getDelimEnd().equals(other.getDelimEnd())) {
            request.setAttribute("diffdelim", "true");
        }
        if (!revision.getConfigFileType().getLabel()
                .equals(other.getConfigFileType().getLabel()) ||
                revision.getConfigContent().isBinary() !=
                    other.getConfigContent().isBinary()) {
            request.setAttribute("difftype", "true");
        }
    }

}
