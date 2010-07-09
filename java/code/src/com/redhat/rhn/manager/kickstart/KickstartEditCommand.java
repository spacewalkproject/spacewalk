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
package com.redhat.rhn.manager.kickstart;

import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.ChannelFactory;
import com.redhat.rhn.domain.kickstart.KickstartCommand;
import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.kickstart.KickstartVirtualizationType;
import com.redhat.rhn.domain.kickstart.KickstartableTree;
import com.redhat.rhn.domain.kickstart.RepoInfo;
import com.redhat.rhn.domain.kickstart.builder.KickstartBuilder;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.token.ActivationKey;
import com.redhat.rhn.domain.token.ActivationKeyFactory;
import com.redhat.rhn.domain.token.Token;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.manager.channel.ChannelManager;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;

import java.util.Arrays;
import java.util.Collection;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeSet;

/**
 * KickstartEditCommand - Command class for loading and editing a Kickstart Profile.
 * @version $Rev$
 */
public class KickstartEditCommand extends BaseKickstartCommand {

    /**
     * Logger for this class
     */
    private static Logger logger = Logger
            .getLogger(KickstartEditCommand.class);



    /**
     *
     * @param ksid Kickstart Id
     * @param userIn to set on this Command.
     */
    public KickstartEditCommand(Long ksid, User userIn) {
        super(ksid, userIn);
    }


    /**
     *
     * @param data Kickstart data
     * @param userIn to set on this Command.
     */
    public KickstartEditCommand(KickstartData data, User userIn) {
        super(data, userIn);
    }

    /**
     *
     * @return Kickstart Label
     */
    public String getLabel() {
        String returnString = this.ksdata.getLabel();
        logger.debug("getLabel() - end - return value=" + returnString);
        return returnString;
    }

    /**
     *
     * @param labelIn Kickstart Label to set
     */
    public void setLabel(String labelIn) {
        if (!ksdata.getLabel().equals(labelIn)) {
            KickstartBuilder builder = new KickstartBuilder(getUser());
            builder.validateNewLabel(labelIn);
        }
        logger.debug("setLabel(String labelIn=" + labelIn + ") - start");
        this.ksdata.setLabel(labelIn);
    }

    /**
     *
     * @return Whether the Kickstart is active
     */
    public Boolean getActive() {
        logger.debug("getActive() - start");
        Boolean returnBoolean = this.ksdata.isActive();
        logger.debug("getActive() - end - return value=" + returnBoolean);
        return returnBoolean;
    }

    /**
     *
     * @param activeIn Set active status of Kickstart
     */
    public void setActive(Boolean activeIn) {
        logger.debug("setActive(Boolean activeIn=" + activeIn + ") - start");
        this.ksdata.setActive(activeIn);
    }

    /**
     *
     * @return Get virtualizationtype
     */
    public KickstartVirtualizationType getVirtualizationType() {
        return this.ksdata.getKickstartDefaults().getVirtualizationType();
    }

    /**
     *
     * @param typeIn Set virtualization type
     */
    public void setVirtualizationType(KickstartVirtualizationType typeIn) {

        // If the virtualization type is changing to or from guest, we need to adjust
        // some kickstart options potentially wiping out user changes. (a note will be
        // present in the UI to indicate this side effect)
        String oldType = getVirtualizationType().getLabel();
        String newType = typeIn.getLabel();
        if (!newType.equals(oldType)) {
            if (newType.equals(KickstartVirtualizationType.XEN_PARAVIRT) ||
                    oldType.equals(KickstartVirtualizationType.XEN_PARAVIRT)) {
                // Signal that we'll need to rebuild the partition commands:
                rebuildPartitionCommands = true;
            }
        }

        this.ksdata.getKickstartDefaults().setVirtualizationType(typeIn);
    }

    /**
     *
     * @return Kickstart Comments
     */
    public String getComments() {
        String returnString = this.ksdata.getComments();
        logger.debug("getComments() - end - return value=" + returnString);
        return returnString;
    }

    /**
     * Update the isOrgDefault field for this KickstartData.  If set to
     * true this will update any existing KickstartData records for this Org
     * that have their isOrgDefault set to true.  There can be only *ONE*
     * KickstartData with isOrgDefault set.
     *
     * @param defaultIn to update this profile to
     */
    public void setIsOrgDefault(Boolean defaultIn) {
        this.ksdata.setOrgDefault(defaultIn);
    }
    /**
     *
     * @param commentsIn to set for Kickstart
     */
    public void setComments(String commentsIn) {
        logger.debug("setComments(String commentsIn=" + commentsIn + ") - start");
        this.ksdata.setComments(commentsIn);

    }

    /**
     * Take in the set of required information to
     * determine what kickstartable tree to use for this Kickstart
     * profile.
     *
     * @param channelId id of ChannelFamily selected.
     * @param orgId org id
     * @param treeId kickstart tree id
     * @param url the url of the channel.
     * @return ValidatorError if we couldn't find a KickstartableTree to update to
     */
    public ValidatorError updateKickstartableTree(Long channelId,
                                                    Long orgId,
                                                    Long treeId,
                                                    String url) {



        if (!KickstartFactory.verifyTreeAssignment(channelId, orgId, treeId)) {
            ValidatorError ve = new ValidatorError("kickstart.software.notree");
            return ve;
        }

        KickstartableTree tree = KickstartFactory.findTreeById(treeId, orgId);
        KickstartWizardHelper helper = new KickstartWizardHelper(getUser());


        for (Token token : ksdata.getDefaultRegTokens()) {
            ActivationKey key = ActivationKeyFactory.lookupByToken(token);
            if (key != null && key.getKickstartSession() != null) {
                token.setBaseChannel(tree.getChannel());
            }
        }

        if (tree != null) {

            this.ksdata.getKickstartDefaults().setKstree(tree);
            if (!ksdata.isRawData() && !StringUtils.isBlank(url)) {
                KickstartCommand kcmd = this.ksdata.getCommand("url");
                kcmd.setArguments("--url " + url);

                // Any time we update the kickstartable tree we need to remove any existing
                // yum repo commands and re-add them for the new tree if necessary:
                this.ksdata.removeCommand("repo", false);
                this.ksdata.removeCommand("key", true);
                logger.debug("updateKickstartableTree(Long, String, String, Long)" +
                        " - end - return value=" + null);
            }
            return null;
        }
        else {
            ValidatorError ve = new ValidatorError("kickstart.software.notree");
            logger.debug("updateKickstartableTree(Long, String, " +
                    "String, Long) - end - return value=" + ve);
            return ve;
        }

    }

    /**
     * Update child channels for this KickstartData.  This clears out previous selections.
     *
     * @param childchannelIds as strings
     */
    public void updateChildChannels(String[] childchannelIds) {

        // Clear out the old selections
        if (getKickstartData().getChildChannels() != null) {
            getKickstartData().getChildChannels().clear();
        }

        if (childchannelIds != null) {
            for (int i = 0; i < childchannelIds.length; i++) {
                Long channelId = Long.valueOf(childchannelIds[i]);
                Channel c = ChannelManager.lookupByIdAndUser(channelId,
                        user);
                getKickstartData().addChildChannel(c);
            }
        }

    }

    /**
     * Get the Set of ChannelArches that are available
     * to this Kickstart.
     * @return Set of ChannelArch objects that are available
     * to this Kickstart.
     */
    public Set getAvailableArches() {
        logger.debug("getAvailableArches() - start");
        List ksc = ChannelFactory.getKickstartableChannels(user.getOrg());
        Set retval = new HashSet();
        Iterator i = ksc.iterator();
        while (i.hasNext()) {
            Channel ca = (Channel) i.next();
            retval.add(ca.getChannelArch());
        }
        logger.debug("getAvailableArches() - end - return value=" + retval);
        return retval;
    }

    /**
     * Get list of available Channels for Kickstarting.
     * @return Collection of Channels.
     */
    public Collection getAvailableChannels() {
        logger.debug("getAvailableChannels() - start");
        Collection returnCollection = ChannelFactory
                .getKickstartableChannels(user.getOrg());
        logger.debug("getAvailableChannels() - end - return value=" + returnCollection);
        return returnCollection;
    }

    /**
     * Returns a list of KickstartableTrees available for a given channel id and org id
     * @param channelId base channel
     * @param org caller's org
     * @return list of KickstartableTree instances
     */
    public List getTrees(Long channelId, Org org) {
        return KickstartManager.getInstance().
            removeInvalid(KickstartFactory.lookupKickstartableTrees(channelId, org));
    }

    /**
     * Get the Set of ChannelFamily objects available to be Kickstarted.
     * @return Set of ChannelFamily objects.
     */
    public Set getAvailableChannelFamilies() {
        logger.debug("getAvailableChannelFamilies() - start");
        Collection channels = getAvailableChannels();
        Set retval = new HashSet();
        Iterator i = channels.iterator();
        while (i.hasNext()) {
            Channel c = (Channel) i.next();
            retval.add(c.getChannelFamily());
        }
        logger.debug("getAvailableChannelFamilies() - end - return value=" + retval);
        return retval;
    }

    /**
     * Get the Set of available u1, u2, u3 .. for the current tree.
     * @return Set of String values.
     */
    public Set getAvailableUpdates() {

        // TODO: Take out this hard coded list!
        String[] updates = {"", "u1", "u2", "u3", "u4", "u5", "u6", "u7", "u8", "u9"};
        Set retval = new TreeSet();
        retval.addAll(Arrays.asList(updates));

        logger.debug("getAvailableUpdates() - end - return value=" + retval);
        return retval;
    }

    /**
     * Get the "U" update release for the current Kickstart.
     * @return String update
     */
    public String getReleaseUpdate() {
        String retval = null;

        // TODO: Actually fetch this off the kickstartableTree
        // Only can parse the label if its an RHN
        // owned channel
        //if (this.ksdata.getTree().getChannel().getOrg() == null) {
        logger.debug("we have an RHN owned channel");
        retval = this.ksdata.getTree().getLabel();
        retval = retval.replaceAll(
                getBaseLabel(this.ksdata.getTree().getChannel()), "");
        logger.debug("retval after replace: " + retval);
        int hyphen = retval.indexOf("-");
        if (hyphen >= 0) {
            retval = retval.substring(hyphen + 1, retval.length());
        }
        //}
        logger.debug("retval: " + retval);
        return retval;
    }

    // private string to concat "ks-" + Channel.label
    private String getBaseLabel(Channel c) {
        return "ks-" + c.getLabel();
    }

    /**
     *  Updates the kickstart data with the repo name array passed in
     * @param reposIn the names of the repos to be associated with this KS data.
     */
    public void updateRepos(String[] reposIn) {
        if (ksdata.isRhel5OrGreater()) {

            Map<String, RepoInfo> repos = RepoInfo.getStandardRepos();
            Set<RepoInfo> selected = new HashSet <RepoInfo>();

            for (int i = 0; i < reposIn.length; i++) {
                selected.add(repos.get(reposIn[i]));
            }
            ksdata.setRepoInfos(selected);
            KickstartWizardHelper ksHelper = new KickstartWizardHelper(user);
            ksHelper.processSkipKey(ksdata);
        }
    }
}
