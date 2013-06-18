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
package com.redhat.rhn.frontend.action.kickstart;

import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.kickstart.KickstartableTree;
import com.redhat.rhn.domain.kickstart.RepoInfo;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.frontend.struts.LabelValueEnabledBean;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.channel.ChannelManager;
import com.redhat.rhn.manager.kickstart.BaseKickstartCommand;
import com.redhat.rhn.manager.kickstart.KickstartEditCommand;
import com.redhat.rhn.manager.kickstart.cobbler.CobblerProfileCommand;
import com.redhat.rhn.manager.kickstart.cobbler.CobblerProfileEditCommand;

import org.apache.log4j.Logger;
import org.apache.struts.action.DynaActionForm;
import org.apache.struts.util.LabelValueBean;
import org.cobbler.Distro;

import java.util.Collection;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;

/**
 * KickstartSoftwareEditAction
 * @version $Rev: 1 $
 */
public class KickstartSoftwareEditAction extends BaseKickstartEditAction {

    private static Logger log = Logger.getLogger(KickstartSoftwareEditAction.class);

    public static final String URL = "url";
    public static final String CHANNELS = "channels";
    public static final String CHANNEL = "channel";
    public static final String TREE = "tree";
    public static final String TREES = "trees";
    public static final String AVAIL_CHILD_CHANNELS = "avail_child_channels";
    public static final String CHILD_CHANNELS = "child_channels";
    public static final String STORED_CHILD_CHANNELS = "stored_child_channels";
    public static final String POSSIBLE_REPOS = "possibleRepos";
    public static final String SELECTED_REPOS = "selectedRepos";
    public static final String USE_NEWEST_KSTREE_PARAM = "useNewestTree";
    public static final String USE_NEWEST_RH_KSTREE_PARAM = "useNewestRHTree";
    public static final String RED_HAT_TREES_AVAILABLE = "redHatTreesAvailable";
    public static final String USING_NEWEST = "usingNewest";
    public static final String USING_NEWEST_RH = "usingNewestRH";
    protected String getSuccessKey() {
        return "kickstart.software.success";
    }

    /**
     * {@inheritDoc}
     */
    protected void setupFormValues(RequestContext ctx, DynaActionForm form,
            BaseKickstartCommand cmdIn) {
        String fieldChanged = form.getString("fieldChanged");
        KickstartEditCommand cmd = (KickstartEditCommand) cmdIn;
        KickstartableTree tree = cmd.getKickstartData().getKickstartDefaults().getKstree();
        KickstartTreeUpdateType updateType = cmd.getKickstartData()
                .getRealUpdateType();
        KickstartableTree selectedTree;
        List<KickstartableTree> trees = null;
        Long incomingChannelId = (Long) form.get(CHANNEL);
        Long channelId = incomingChannelId;
        if (fieldChanged.equals("channel")) {
            trees = cmd.getTrees(incomingChannelId, ctx.getCurrentUser().getOrg());
            KickstartableTree kstree = null;
            if (trees != null && trees.size() > 0) {
                kstree = trees.get(trees.size() - 1);
                form.set(TREE, kstree.getId());
            }
            if (kstree == null && (trees != null && trees.size() > 0)) {
                kstree = KickstartFactory.lookupKickstartTreeByIdAndOrg(tree.getId(),
                        ctx.getCurrentUser().getOrg());
            }
            setupUrl(ctx, form, kstree);
            selectedTree = kstree;
            updateType = KickstartTreeUpdateType.NONE;
        }
        else {
            if (form.get(CHANNEL) != null) {
                channelId = (Long) form.get(CHANNEL);
            }
            else {
                channelId = tree.getChannel().getId();
            }
            trees = cmd.getTrees(channelId,
                    ctx.getCurrentUser().getOrg());
            KickstartableTree kstree = null;
            if (trees != null && trees.size() > 0) {
                kstree = KickstartFactory.lookupKickstartTreeByIdAndOrg(tree.getId(),
                        ctx.getCurrentUser().getOrg());
            }
            setupUrl(ctx, form, kstree);
            selectedTree = kstree;
        }
        if (fieldChanged.equals("kstree")) {
            KickstartableTree kstree =
                    KickstartFactory.lookupKickstartTreeByIdAndOrg((Long) form.get(TREE),
                            ctx.getCurrentUser().getOrg());
            setupUrl(ctx, form, kstree);
            selectedTree = kstree;
            updateType = KickstartTreeUpdateType.NONE;
        }
        if (updateType.equals(KickstartTreeUpdateType.ALL)) {
            ctx.getRequest().setAttribute(USING_NEWEST, "true");
        }
        else if (updateType.equals(KickstartTreeUpdateType.RED_HAT)) {
            ctx.getRequest().setAttribute(USING_NEWEST_RH, "true");
        }
        for (KickstartableTree tr : trees) {
            if (tr.getOrg() == null) {
                ctx.getRequest().setAttribute(RED_HAT_TREES_AVAILABLE, "true");
                break;
            }
        }
        ctx.getRequest().setAttribute(TREES, trees);
        if (trees == null || trees.size() == 0) {
            ctx.getRequest().setAttribute("notrees", "true");
        }

        // Setup child channels
        setupChildChannels(ctx, channelId, cmd);

        // Setup list of releases and channels
        List<LabelValueBean> channels = new LinkedList<LabelValueBean>();
        Collection<Channel> channelList = cmd.getAvailableChannels();
        for (Channel c : channelList) {
            log.debug("channel : " + c);
            LabelValueBean lb = lv(c.getName(), c.getId().toString());
            if (!channels.contains(lb)) {
                channels.add(lb);
            }
        }
        log.debug("setting channel attrib: " + channels);
        ctx.getRequest().setAttribute(CHANNELS, channels);

        if (form.get(CHANNEL) == null) {
            form.set(CHANNEL, tree.getChannel().getId());
        }
        if (form.get(TREE) == null) {
            form.set(TREE, tree.getId());
        }

        if (form.getString(URL) == null) {
            ctx.getRequest().setAttribute("nourl", "true");
        }
        setupRepos(ctx, form, cmd.getKickstartData(), selectedTree);
    }

    private void setupChildChannels(RequestContext ctx, Long channelId,
            KickstartEditCommand cmd) {
        log.debug("ChannelId: " + channelId);
        // Get all available child channels for this user
        List<Channel> childchannels = ChannelManager
                .userAccessibleChildChannels(
                        ctx.getCurrentUser().getOrg().getId(), channelId);
        if (childchannels == null || childchannels.size() == 0) {
            ctx.getRequest().setAttribute("nochildchannels", "true");
        }
        // Remove the Proxy channels from the child channel list
        for (int i = 0; i < childchannels.size(); i++) {
            if (childchannels.get(i).isProxy()) {
                childchannels.remove(i);
            }
        }
        log.debug("AVAIL_CHILD_CHANNELS: " + childchannels);
        ctx.getRequest().setAttribute(AVAIL_CHILD_CHANNELS, childchannels);

        // Setup the list of selected child channels
        HashMap<Long, Long> selectedChannels = new HashMap<Long, Long>();
        if (cmd.getKickstartData().getChildChannels() != null) {
            Set<Channel> channelSet = cmd.getKickstartData().getChildChannels();
            for (Channel c : channelSet) {
                selectedChannels.put(c.getId(), c.getId());
            }
        }

        ctx.getRequest().setAttribute("stored_child_channels", selectedChannels);
        log.debug("scc: " + selectedChannels);

    }
    /**
     * Sets the computed file url for the File Location field..
     * @param ctx the request context
     * @param form the dyna form
     * @param kstree the kickstart tree
     */
    private void setupUrl(RequestContext ctx, DynaActionForm form,
            KickstartableTree kstree) {
        if (kstree != null) {
            KickstartHelper kshelper = new KickstartHelper(ctx.getRequest());
            form.set(URL, kstree.getDefaultDownloadLocation(kshelper
                    .getKickstartHost()));
        }
        else {
            form.set(URL, "");
        }
    }



    /**
     * {@inheritDoc}
     */
    protected ValidatorError processFormValues(HttpServletRequest request,
            DynaActionForm form,
            BaseKickstartCommand cmdIn) {

        KickstartData ksdata = cmdIn.getKickstartData();
        RequestContext ctx = new RequestContext(request);
        KickstartTreeUpdateType updateType = null;
        KickstartableTree tree = null;
        Long channelId = (Long) form.get(CHANNEL);
        String url = form.getString(URL);
        Org org = ctx.getLoggedInUser().getOrg();

        if (form.get(USE_NEWEST_KSTREE_PARAM) != null) {
            updateType = KickstartTreeUpdateType.ALL;
            tree = KickstartFactory.getNewestTree(updateType, channelId, org);
        }
        else if (form.get(USE_NEWEST_RH_KSTREE_PARAM) != null) {
            updateType = KickstartTreeUpdateType.RED_HAT;
            tree = KickstartFactory.getNewestTree(updateType, channelId, org);
        }
        else {
            updateType = KickstartTreeUpdateType.NONE;
            tree = KickstartFactory.lookupKickstartTreeByIdAndOrg(
                    (Long) form.get(TREE), org);
        }

        if (tree == null) {
            return new ValidatorError("kickstart.softwaredit.tree.required");
        }

        Distro distro = CobblerProfileCommand.getCobblerDistroForVirtType(tree,
                ksdata.getKickstartDefaults().getVirtualizationType(),
                ctx.getLoggedInUser());
        if (distro == null) {
            return new ValidatorError("kickstart.cobbler.profile.invalidtreeforvirt");
        }

        KickstartEditCommand cmd = (KickstartEditCommand) cmdIn;
        ValidatorError ve = cmd.updateKickstartableTree(channelId, org.getId(),
                tree.getId(), url);

        if (ve == null) {
            String [] repos = form.getStrings(SELECTED_REPOS);
            cmd.updateRepos(repos);
        }

        ksdata.setRealUpdateType(updateType);

        CobblerProfileEditCommand cpec = new CobblerProfileEditCommand(ksdata,
                ctx.getLoggedInUser());
        cpec.store();

        // Process the selected child channels
        String[] childchannelIds = request.getParameterValues(CHILD_CHANNELS);
        cmd.updateChildChannels(childchannelIds);

        if (ve != null) {
            return ve;
        }
        return null;
    }

    private void setupRepos(RequestContext context,
            DynaActionForm form, KickstartData ksdata,
            KickstartableTree tree) {

        if (tree != null && !tree.getInstallType().isRhel2() &&
                !tree.getInstallType().isRhel3() &&
                !tree.getInstallType().isRhel4()) {
            List <LabelValueEnabledBean> repos = new LinkedList<LabelValueEnabledBean>();
            for (RepoInfo repo : RepoInfo.getStandardRepos(tree)) {
                repos.add(lve(repo.getName(), repo.getName(), !repo.isAvailable()));
            }
            form.set(POSSIBLE_REPOS, repos.toArray(new LabelValueEnabledBean[0]));
            Set<RepoInfo> selected = ksdata.getRepoInfos();
            String [] items = new String[selected.size()];
            int i = 0;
            for (RepoInfo repo : selected) {
                items[i] = repo.getName();
                i++;
            }
            form.set(SELECTED_REPOS, items);
        }
    }

    /**
     * {@inheritDoc}
     */
    protected BaseKickstartCommand getCommand(RequestContext ctx) {
        return new KickstartEditCommand(ctx.getRequiredParam(RequestContext.KICKSTART_ID),
                ctx.getCurrentUser());
    }

}
