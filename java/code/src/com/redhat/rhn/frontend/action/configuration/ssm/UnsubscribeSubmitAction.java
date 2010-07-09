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
package com.redhat.rhn.frontend.action.configuration.ssm;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.common.BaseSetOperateOnSelectedItemsAction;
import com.redhat.rhn.manager.configuration.ConfigurationManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * UnsubscribeSubmitAction, for ssm config management
 * @version $Rev$
 */
public class UnsubscribeSubmitAction extends BaseSetOperateOnSelectedItemsAction {

    /**
     * {@inheritDoc}
     */
    protected DataResult getDataResult(User userIn,
                                       ActionForm formIn,
                                       HttpServletRequest requestIn) {
        return ConfigurationManager.getInstance().ssmChannelList(userIn, null);
    }

    /**
     * {@inheritDoc}
     */
    protected RhnSetDecl getSetDecl() {
        return RhnSetDecl.CONFIG_CHANNELS;
    }

    /**
     * {@inheritDoc}
     */
    protected void processMethodKeys(Map mapIn) {
        mapIn.put("unsubscribe.jsp.unsubscribe", "unsubscribe");
    }

    /**
     * {@inheritDoc}
     */
    protected void processParamMap(ActionForm formIn,
                                   HttpServletRequest requestIn,
                                   Map paramsIn) {
        //no-op
    }

    /**
     * Go to the confirm page.
     * @param mapping struts ActionMapping
     * @param form struts ActionForm
     * @param request HttpServletRequest
     * @param response HttpServletResponse
     * @return ActionForward to the confirm page.
     */
    public ActionForward unsubscribe(ActionMapping mapping, ActionForm form,
            HttpServletRequest request, HttpServletResponse response) {
        RhnSet set = updateSet(request);
        if (set.isEmpty()) {
            return handleEmptySelection(mapping, form, request);
        }
        return mapping.findForward("confirm");
    }

}
