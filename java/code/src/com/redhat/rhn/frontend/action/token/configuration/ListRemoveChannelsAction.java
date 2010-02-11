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

package com.redhat.rhn.frontend.action.token.configuration;

import com.redhat.rhn.domain.config.ConfigChannel;
import com.redhat.rhn.domain.config.ConfigChannelListProcessor;
import com.redhat.rhn.domain.config.ConfigurationFactory;
import com.redhat.rhn.domain.token.ActivationKey;
import com.redhat.rhn.frontend.action.token.BaseListAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.StrutsDelegate;
import com.redhat.rhn.frontend.taglibs.list.helper.ListSessionSetHelper;
import com.redhat.rhn.manager.configuration.ConfigurationManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


/**
 * @author paji
 * ConfigurationChannelsAction
 * @version $Rev$
 */
public class ListRemoveChannelsAction extends BaseListAction {

    /** {@inheritDoc} */
    @Override
    public ActionForward handleDispatch(ListSessionSetHelper helper,
            ActionMapping mapping,
            ActionForm formIn, HttpServletRequest request,
            HttpServletResponse response) {
        RequestContext context = new RequestContext(request);
        ActivationKey key = context.lookupAndBindActivationKey();
        ConfigChannelListProcessor proc = new ConfigChannelListProcessor();
        Set <String> set = helper.getSet();
        
        for (String id : set) {
            Long ccid = Long.valueOf(id);
            ConfigChannel cc = ConfigurationFactory.lookupConfigChannelById(ccid);
            proc.remove(key.getConfigChannelsFor(context.getLoggedInUser()), cc);
        }
        getStrutsDelegate().saveMessage(
                    "config_channels_to_unsubscribe.unsubscribe.success",
                        new String [] {String.valueOf(set.size())}, request);
        
        
        Map params = new HashMap();
        params.put(RequestContext.TOKEN_ID, key.getToken().getId().toString());
        StrutsDelegate strutsDelegate = getStrutsDelegate();
        return strutsDelegate.forwardParams
                        (mapping.findForward("success"), params);
    }


    /** {@inheritDoc} */
    public List getResult(RequestContext context) {
        ConfigurationManager cm = ConfigurationManager.getInstance();
        return cm.listGlobalChannelsForActivationKey(
                    context.lookupAndBindActivationKey(), 
                    context.getLoggedInUser());
    }
}
