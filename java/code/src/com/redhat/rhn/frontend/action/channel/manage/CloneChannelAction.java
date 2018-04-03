/**
 * Copyright (c) 2015 Red Hat, Inc.
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

package com.redhat.rhn.frontend.action.channel.manage;

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.ChannelFactory;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.ChannelTreeNode;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.manager.channel.ChannelManager;

import org.apache.struts.action.ActionErrors;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeSet;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


/**
 * EditChannelAction
 * @version $Rev: 1 $
 */
public class CloneChannelAction extends RhnAction {
    public static final String CURRENT = "current";
    public static final String ORIGINAL = "original";
    public static final String SELECT = "select";

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
                                 ActionForm formIn,
                                 HttpServletRequest request,
                                 HttpServletResponse response) {

        ActionErrors errors = new ActionErrors();
        DynaActionForm form = (DynaActionForm)formIn;
        Map<String, Object> params = makeParamMap(request);
        RequestContext ctx = new RequestContext(request);
        User user = ctx.getCurrentUser();
        Org org = user.getOrg();

        if (isSubmitted(form)) {
            Channel original = ChannelManager.lookupByIdAndUser((Long) form
                    .get("original_id"), user);
            if (original != null) {
                setupEditDefaults(ctx, original, form, form
                        .getString(EditChannelAction.CLONE_TYPE));
                return getStrutsDelegate().forwardParams(mapping.findForward("success"),
                        params);
            }
        }

        // create the channel tree for the drop down box.
        // only subscribable channels should be shown.
        Set<Long> subscribableCids = ChannelManager.subscribableChannelIdsForUser(user);

        List<Map<String, String>> channels = new ArrayList<Map<String, String>>();
        Map<String, Long> nameToId = new HashMap<String, Long>();
        Map<Long, TreeSet<String>> parentToChildren = new HashMap<Long, TreeSet<String>>();
        TreeSet<String> parents = new TreeSet<String>();

        List<ChannelTreeNode> channelTree = ChannelManager.allChannelTree(user, null);
        // add all parents
        for (ChannelTreeNode channel : channelTree) {
            if (!subscribableCids.contains(channel.getId()) || !channel.isParent()) {
                continue;
            }
            nameToId.put(channel.getName(), channel.getId());
            parents.add(channel.getName());
            parentToChildren.put(channel.getId(), new TreeSet<String>());
        }

        // add all children
        for (ChannelTreeNode channel : channelTree) {
            if (!subscribableCids.contains(channel.getId()) || channel.isParent() ||
                    !subscribableCids.contains(channel.getParentId())) {
                continue;
            }
            nameToId.put(channel.getName(), channel.getId());
            parentToChildren.get(channel.getParentId()).add(channel.getName());
        }

        // construct channel tree (string TreeSets are alphabetically ordered)
        for (String parentName : parents) {
            Long parentId = nameToId.get(parentName);
            addOption(channels, parentName, parentId.toString());
            for (String childName : parentToChildren.get(parentId)) {
                // indent a few spaces for child channels
                addOption(channels, "&nbsp;&nbsp;&nbsp;" + childName, nameToId.get(
                        childName).toString());
            }
        }

        ctx.getRequest().setAttribute("channels", channels);
        // set default radio button
        form.set(EditChannelAction.CLONE_TYPE, CURRENT);

        return getStrutsDelegate().forwardParams(
                mapping.findForward(RhnHelper.DEFAULT_FORWARD), request.getParameterMap());
    }

    /**
     * Utility function to create options for the dropdown.
     * @param options list containing all options.
     * @param key resource bundle key used as the display value.
     * @param value value to be submitted with form.
     */
    private void addOption(List<Map<String, String>> options, String key, String value) {
        Map<String, String> selection = new HashMap<String, String>();
        selection.put("label", key);
        selection.put("value", value);
        options.add(selection);
    }

    private void setupEditDefaults(RequestContext ctx, Channel original,
            DynaActionForm form, String cloneType) {
        EditChannelAction.prepDropdowns(ctx, original);
        HttpServletRequest req = ctx.getRequest();

        String channelName = LocalizationService.getInstance().getMessage(
                "frontend.actions.channels.manager.create");
        req.setAttribute(EditChannelAction.CHANNEL_NAME, channelName);
        form.set(EditChannelAction.ORG_SHARING, "private");
        form.set(EditChannelAction.SUBSCRIPTIONS, "all");

        req.setAttribute(EditChannelAction.CLONE_TYPE, cloneType);
        req.setAttribute(EditChannelAction.ORIGINAL_NAME, original.getName());
        req.setAttribute(EditChannelAction.ORIGINAL_ID, original.getId());
        req.setAttribute("submitted", false);

        // can't really localize this...
        String name = "Clone of " + original.getName();
        String label = "clone-" + original.getLabel();
        int i = 2;
        // okay to use in the webui here; label should unique, org notwithstanding
        while (ChannelFactory.lookupByLabel(label) != null) {
            name = "Clone " + i + " of " + original.getName();
            label = "clone-" + i + "-" + original.getLabel();
            i++;
        }

        form.set(EditChannelAction.NAME, name);
        form.set(EditChannelAction.LABEL, label);

        EditChannelAction.setupFormHelper(req, form, original);
    }

}
