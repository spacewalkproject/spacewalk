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

import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.kickstart.KickstartableTree;
import com.redhat.rhn.domain.kickstart.RepoInfo;
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

import java.util.HashMap;
import java.util.Iterator;
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
        KickstartableTree selectedTree;
        List trees = null;
        Long incomingChannelId = (Long) form.get(CHANNEL);
        Long channelId = incomingChannelId;
        if (fieldChanged.equals("channel")) {
            trees = cmd.getTrees(incomingChannelId, ctx.getCurrentUser().getOrg());
            KickstartableTree kstree = null;
            if (trees != null && trees.size() > 0) {
                kstree = (KickstartableTree) 
                    trees.get(trees.size() - 1);
                form.set(TREE, kstree.getId());
            }
            if (kstree == null && (trees != null && trees.size() > 0)) {
                kstree = KickstartFactory.lookupKickstartTreeByIdAndOrg(tree.getId(),
                    ctx.getCurrentUser().getOrg());
            }
            setupUrl(ctx, form, kstree);
            selectedTree = kstree;
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
        }
        ctx.getRequest().setAttribute(TREES, trees);
        if (trees == null || trees.size() == 0) {
            ctx.getRequest().setAttribute("notrees", "true");
        }

        // Setup child channels
        setupChildChannels(ctx, channelId, cmd);
        
        // Setup list of releases and channels
        List channels = new LinkedList();
        Iterator i = cmd.getAvailableChannels().iterator();
        while (i.hasNext()) {
            Channel c = (Channel) i.next();
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
        List childchannels = ChannelManager.userAccessibleChildChannels(
                         ctx.getCurrentUser().getOrg().getId(), channelId);
        if (childchannels == null || childchannels.size() == 0) {
            ctx.getRequest().setAttribute("nochildchannels", "true");
        }
        log.debug("AVAIL_CHILD_CHANNELS: " + childchannels);
        ctx.getRequest().setAttribute(AVAIL_CHILD_CHANNELS, childchannels);

        // Setup the list of selected child channels
        HashMap selectedChannels = new HashMap();
        if (cmd.getKickstartData().getChildChannels() != null) {
            Iterator i = cmd.getKickstartData().getChildChannels().iterator();
            while (i.hasNext()) {
                Channel c = (Channel) i.next();
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
            form.set(URL, kstree.getDefaultDownloadLocation(
                        kshelper.getKickstartHost()));
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
        
        KickstartableTree tree =  KickstartFactory.lookupKickstartTreeByIdAndOrg(
                (Long) form.get(TREE), 
                ctx.getLoggedInUser().getOrg());
        if (tree == null) {
            return new ValidatorError("kickstart.softwaredit.tree.required");
        }
        
        Distro distro = CobblerProfileCommand.getCobblerDistroForVirtType(tree, 
                cmdIn.getKickstartData().getKickstartDefaults().getVirtualizationType(),
                ctx.getLoggedInUser());
        if (distro == null) {
            return new ValidatorError("kickstart.cobbler.profile.invalidtreeforvirt");
        }
        
        KickstartEditCommand cmd = (KickstartEditCommand) cmdIn;
        ValidatorError ve = cmd.updateKickstartableTree(
                (Long) form.get(CHANNEL), cmdIn.getUser().getOrg().getId(), 
                (Long) form.get(TREE),
                (String) form.getString(URL));
        
        if (ve == null) {
            String [] repos = form.getStrings(SELECTED_REPOS);
            cmd.updateRepos(repos);
        }
        
        CobblerProfileEditCommand cpec = new CobblerProfileEditCommand(
                cmdIn.getKickstartData(), ctx.getLoggedInUser());
        cpec.store();

        // Process the selected child channels
        String[] childchannelIds = request.getParameterValues(CHILD_CHANNELS);
        cmd.updateChildChannels(childchannelIds);
        
        if (ve != null) {
            return ve;
        }
        else {
            return null;
        }
    }

    private void setupRepos(RequestContext context, 
            DynaActionForm form, KickstartData ksdata, 
            KickstartableTree tree) {
        
        if (tree != null && !tree.getInstallType().isRhel2() &&
                !tree.getInstallType().isRhel3() &&
                !tree.getInstallType().isRhel4()) {
            List <LabelValueEnabledBean> repos = new LinkedList<LabelValueEnabledBean>();
            for (String name : RepoInfo.getStandardRepos().keySet()) {
                repos.add(lve(name, name, false));
            }
            form.set(POSSIBLE_REPOS, (LabelValueEnabledBean[])
                            repos.toArray(new LabelValueEnabledBean[0]));
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
