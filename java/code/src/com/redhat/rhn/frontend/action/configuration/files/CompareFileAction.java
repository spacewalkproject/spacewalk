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

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.config.ConfigChannel;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.configuration.ConfigActionHelper;
import com.redhat.rhn.frontend.listview.PageControl;
import com.redhat.rhn.frontend.struts.BaseListAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.configuration.ConfigurationManager;

import javax.servlet.http.HttpServletRequest;

/**
 * CompareFileAction
 * @version $Rev$
 */
public class CompareFileAction extends BaseListAction {

    /**
     * {@inheritDoc}
     */
    protected void processRequestAttributes(RequestContext rctxIn) {
        HttpServletRequest request = rctxIn.getRequest();
        ConfigActionHelper.processRequestAttributes(rctxIn);
        request.setAttribute("ochannel", ConfigActionHelper.getChannel(request));
    }

    /**
     * {@inheritDoc}
     */
    protected DataResult getDataResult(RequestContext rctxIn, PageControl pcIn) {
        HttpServletRequest request = rctxIn.getRequest();
        User user = rctxIn.getLoggedInUser();

        ConfigChannel channel = ConfigActionHelper.getChannel(request);
        ConfigurationManager cm = ConfigurationManager.getInstance();
        return cm.listFilesInChannel(user, channel, pcIn);
    }

}
