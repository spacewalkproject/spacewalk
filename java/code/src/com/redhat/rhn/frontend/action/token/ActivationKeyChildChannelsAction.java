/**
 * Copyright (c) 2009--2012 Red Hat, Inc.
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
package com.redhat.rhn.frontend.action.token;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.SelectMode;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.ChannelFactory;
import com.redhat.rhn.domain.token.ActivationKey;
import com.redhat.rhn.domain.token.ActivationKeyFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.manager.token.ActivationKeyManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;
import org.apache.struts.action.DynaActionForm;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


/**
 * ActivationKeyDetailsAction
 * @version $Rev$
 */
public class ActivationKeyChildChannelsAction extends RhnAction {
    private static final String CHANNELS = "channels";
    /**
     *
     * {@inheritDoc}
     */
    public ActionForward execute(ActionMapping mapping,
                                 ActionForm formIn,
                                 HttpServletRequest request,
                                 HttpServletResponse response) throws Exception {
        RequestContext context = new RequestContext(request);
        DynaActionForm form = (DynaActionForm) formIn;

        ActivationKey key = context.lookupAndBindActivationKey();
        Map params = new HashMap();
        String fwd = "default";

        request.setAttribute("description", key.getNote());

        if (context.isSubmitted()) {
            params.put(RequestContext.TOKEN_ID, key.getId().toString());
            update(form, context);
            fwd = "success";
        }
        else {
            populateForm(form, key, context);
        }

        return getStrutsDelegate().forwardParams(
            mapping.findForward(fwd), params);

    }

    private ActivationKey update(DynaActionForm form, RequestContext context) {
        User user = context.getLoggedInUser();
        ActivationKeyManager manager = ActivationKeyManager.getInstance();
        ActivationKey key = context.lookupAndBindActivationKey();

        Channel base = key.getBaseChannel();
        key.clearChannels();
        if (base != null) {
            key.addChannel(base);
        }

        for (String id : (String[])form.get("childChannels")) {
            key.addChannel(ChannelFactory.lookupById(Long.parseLong(id.trim())));
        }

        ActivationKeyFactory.save(key);
        ActionMessages msg = new ActionMessages();
        addToMessage(msg, "activation-key.java.modified", key.getNote());

        getStrutsDelegate().saveMessages(context.getRequest(), msg);
        return key;
    }

    private void populateForm(DynaActionForm form, ActivationKey key,
                                                RequestContext context) {
        context.getRequest().setAttribute(CHANNELS, key.getChannels());

        User user = context.getLoggedInUser();
        DataResult<HashMap> channelList = getPossibleChannels(user, key.getId());
        ArrayList finalList = new ArrayList();

        if (key.getBaseChannel() != null) {
            for (HashMap c : channelList) {
                Long id = (Long)c.get("id");
                if (ChannelFactory.lookupById(id).getParentChannel().getId() ==
                        key.getBaseChannel().getId()) {
                    finalList.add(c);
                }
            }
            context.getRequest().setAttribute("baseChannel",
                    key.getBaseChannel().getName());
        }
        else {
            finalList = channelList;
        }
        context.getRequest().setAttribute(CHANNELS, finalList);
        form.set(CHANNELS, finalList);
    }

    private void addToMessage(ActionMessages msgs, String key, Object... args) {
        ActionMessage temp =  new ActionMessage(key, args);
        msgs.add(ActionMessages.GLOBAL_MESSAGE, temp);
    }

    private static DataResult getPossibleChannels(User user, Long tokenId) {
        SelectMode m = ModeFactory.getMode("Channel_queries",
                                           "activation_key_child_channels");
        Map params = new HashMap();
        params.put("user_id", user.getId());
        params.put("token_id", tokenId);
        DataResult list = m.execute(params);
        list.elaborate();
        return list;
    }

}
