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
package com.redhat.rhn.frontend.action.kickstart;

import com.redhat.rhn.common.util.download.DownloadException;
import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.kickstart.BaseKickstartCommand;
import com.redhat.rhn.manager.kickstart.KickstartFileDownloadCommand;
import com.redhat.rhn.manager.kickstart.KickstartManager;
import com.redhat.rhn.manager.kickstart.KickstartUrlHelper;

import org.apache.commons.lang.StringEscapeUtils;
import org.apache.struts.action.DynaActionForm;

import javax.servlet.http.HttpServletRequest;

/**
 * KickstartFileDownloadAction extends RhnAction
 * @version $Rev: 1 $
 */
public class KickstartFileDownloadAction extends BaseKickstartEditAction {

    public static final String FILEDATA = "filedata";
    public static final String KSURL = "ksurl";
    private static final String INVALID_CHANNEL = "invalid_channel";

    /**
     * {@inheritDoc}
     * no form to process. return null.
     */
    protected ValidatorError processFormValues(HttpServletRequest request,
            DynaActionForm form,
            BaseKickstartCommand cmdIn) {
        return null;
    }

    /**
     *
     * {@inheritDoc}
     * no success msg to process...return empty string.
     */
    protected String getSuccessKey() {
        return "";
    }

    /**
     * {@inheritDoc}
     */
    protected void setupFormValues(RequestContext ctx,
            DynaActionForm form, BaseKickstartCommand cmdIn) {
        HttpServletRequest request = ctx.getRequest();
        KickstartFileDownloadCommand cmd = (KickstartFileDownloadCommand) cmdIn;
        KickstartData data = cmd.getKickstartData();
        KickstartHelper helper = new KickstartHelper(request);


        /*
         * To generate the file data, our kickstart channel must have at least
         * a minimum list of packages. Verify that those are there before even
         * trying to render the file. However, the auto-kickstart packages are
         * not needed.
         */
        if (helper.verifyKickstartChannel(
                    cmdIn.getKickstartData(), ctx.getLoggedInUser(), false)) {
            try {
                request.setAttribute(FILEDATA, StringEscapeUtils.escapeHtml(
                        KickstartManager.getInstance().renderKickstart(data)));
            }
            catch (DownloadException de) {
                request.setAttribute(FILEDATA,
                                StringEscapeUtils.escapeHtml(de.getContent()));
            }

            request.setAttribute(KSURL, KickstartUrlHelper.getCobblerProfileUrl(data));
        }
        else {
            request.setAttribute(INVALID_CHANNEL, "true");
        }
    }

    /**
     * {@inheritDoc}
     */
    protected BaseKickstartCommand getCommand(RequestContext ctx) {
        return new KickstartFileDownloadCommand(
                ctx.getRequiredParam(RequestContext.KICKSTART_ID),
                ctx.getCurrentUser(), ctx.getRequest());
    }
}
