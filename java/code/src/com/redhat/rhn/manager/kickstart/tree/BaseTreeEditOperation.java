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
package com.redhat.rhn.manager.kickstart.tree;

import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.common.validator.ValidatorException;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.ChannelFactory;
import com.redhat.rhn.domain.channel.ChannelVersion;
import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.kickstart.KickstartInstallType;
import com.redhat.rhn.domain.kickstart.KickstartableTree;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.PackageListItem;
import com.redhat.rhn.manager.BasePersistOperation;
import com.redhat.rhn.manager.channel.ChannelManager;
import com.redhat.rhn.manager.kickstart.cobbler.CobblerCommand;
import com.redhat.rhn.manager.kickstart.cobbler.CobblerXMLRPCHelper;
import com.redhat.rhn.manager.rhnpackage.PackageManager;

import org.cobbler.Distro;
import org.cobbler.XmlRpcException;

import java.io.File;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * BaseTreeEditCommand
 * @version $Rev$
 */
public abstract class BaseTreeEditOperation extends BasePersistOperation {
    private static final String INVALID_INITRD = "kickstart.tree.invalidinitrd";
    private static final String INVALID_KERNEL = "kickstart.tree.invalidkernel";
    protected KickstartableTree tree;
    private static final String EMPTY_STRING = "";
    public static final String KICKSTART_CAPABILITY = "rhn.kickstart.boot_image";
    private String postKernelOptions = "";
    private String kernelOptions = "";

    /**
     * Constructor
     * @param userIn to associate with cmd.
     */
    public BaseTreeEditOperation(User userIn) {
        this.user = userIn;
    }

    /**
     * Constructor for use when looking up by label
     * @param treeLabel to lookup
     * @param userIn who owns the tree
     */
    public BaseTreeEditOperation(String treeLabel, User userIn) {
        this(userIn);
        this.tree = KickstartFactory.
            lookupKickstartTreeByLabel(treeLabel, userIn.getOrg());
    }

    /**
     * {@inheritDoc}
     */
    public ValidatorError store() {
        if (!this.validateLabel()) {
            HibernateFactory.getSession().evict(this.tree);
            return new ValidatorError("kickstart.tree.invalidlabel");
        }

        try {
            validateBasePath();
        }
        catch (ValidatorException ve) {
            return ve.getResult().getErrors().get(0);
        }

        KickstartFactory.saveKickstartableTree(this.tree);
        // Sync to cobbler
        try {
            CobblerCommand command = getCobblerCommand();
            command.store();

            Distro distro = Distro.lookupById(CobblerXMLRPCHelper.getConnection(
                    this.getUser()), tree.getCobblerId());

            Map kOpts = distro.getKernelOptions();
            distro.setKernelOptions(getKernelOptions());
            distro.setKernelPostOptions(getPostKernelOptions());
            distro.save();
        }
        catch (XmlRpcException xe) {
            HibernateFactory.rollbackTransaction();
            if (xe.getCause().getMessage().contains("kernel not found")) {
                return new ValidatorError(INVALID_KERNEL,
                        this.tree.getKernelPath());
            }
            else if (xe.getCause().getMessage().contains("initrd not found")) {
                return new ValidatorError(INVALID_INITRD,
                        this.tree.getInitrdPath());
            }
            else {
                throw new RuntimeException(xe.getCause());
            }
        }
        catch (Exception e) {
            HibernateFactory.rollbackTransaction();
            if (e.getMessage().contains("kernel not found")) {
                return new ValidatorError(INVALID_KERNEL,
                        this.tree.getKernelPath());
            }
            else if (e.getMessage().contains("initrd not found")) {
                return new ValidatorError(INVALID_INITRD,
                        this.tree.getInitrdPath());
            }
            else {
                throw new RuntimeException(e);
            }

        }
        return null;
    }

    /**
     * Validate the label to make sure:
     *
     * "The Distribution Label field should contain only letters, numbers, hyphens,
     * periods, and underscores. It must also be at least 4 characters long."
     *
     * @return boolean if its valid or not
     */
    public boolean validateLabel() {
        String regEx = "^([-_0-9A-Za-z@.]{1,255})$";
        Pattern pattern = Pattern.compile(regEx);
        Matcher matcher = pattern.matcher(this.getTree().getLabel());
        return matcher.matches();
    }

    private void validatePathExists(String path, String key) {
        if (!(new File(path).exists())) {
            ValidatorException.raiseException(key, path);
        }
    }
    /**
     * Ensures that the base path is correctly setup..
     * As in the initrd and kernel structures are setup correctly.
     * @throws ValidatorException if those paths don;t exist
     */
    public void validateBasePath() throws ValidatorException {
        validatePathExists(getTree().getInitrdPath(), INVALID_INITRD);
        validatePathExists(getTree().getKernelPath(), INVALID_KERNEL);
    }

    /**
     * @return Returns the tree.
     */
    public KickstartableTree getTree() {
        return tree;
    }

    /**
     * Set the Install type for this Kickstart
     * @param typeIn to set on this KickstartableTree
     */
    public void setInstallType(KickstartInstallType typeIn) {
        this.tree.setInstallType(typeIn);
    }

    /**
     * Set the label on the tree
     * @param labelIn to set
     */
    public void setLabel(String labelIn) {
        this.tree.setLabel(labelIn);
    }

    /**
     * Set the location of the tree
     * @param url to set.
     */
    public void setBasePath(String url) {
        this.tree.setBasePath(url);
    }

    /**
     * Set the Channel for this tree
     * @param channelIn to set
     */
    public void setChannel(Channel channelIn) {
        this.tree.setChannel(channelIn);
    }

    /**
     * Get the list of autokickstart package names.
     * @return List of String package names
     */
    public List getAutoKickstartPackageNames() {
       List retval = PackageManager.
           packageNamesByCapability(user.getOrg(), KICKSTART_CAPABILITY);
       replaceLegacyPackageNames(retval);
       return retval;
    }

    /**
     * Replace legacy package names with empty string for each PackageListItem
     * in the provided list.
     * @param packageListItems List of PackageListItems to be modified in place.
     */
    private void replaceLegacyPackageNames(List packageListItems) {
        // munge the list of auto kickstarts
        for (Iterator itr = packageListItems.iterator(); itr.hasNext();) {
          PackageListItem pli = (PackageListItem)itr.next();
          pli.setName(pli.getName().replaceFirst(
                  KickstartData.LEGACY_KICKSTART_PACKAGE_NAME, EMPTY_STRING));
        }
    }

    /**
     * Get the list of packages that provide the kickstart capability in the
     * given base channel.
     * @param baseChannel Base channel to search for kickstart packages.
     * @return List of kickstart packages for the given channel.
     */
    public List getKickstartPackageNamesForChannel(Channel baseChannel) {

        // Kickstart packages are found in the tools channel associated with a base
        // channel, not the base channel itself:
        Channel toolsChannel = ChannelManager.getToolsChannel(baseChannel, user);
        if (toolsChannel == null) {
            return new LinkedList();
        }

        List ksPackages = PackageManager.packageNamesByCapabilityAndChannel(user.getOrg(),
                KICKSTART_CAPABILITY, toolsChannel);
        replaceLegacyPackageNames(ksPackages);
        return ksPackages;
    }

    /**
     * Get List of KickstartInstallType objects for this channel.
     * @param channel Channel to list the install types for.
     * @return List of KickstartInstallType objects.
     */
    public List getKickstartInstallTypesForChannel(Channel channel) {
        List installTypes = KickstartFactory.lookupKickstartInstallTypes();
        List returnInstallTypes = new LinkedList();

        Set channelVersions = ChannelManager.getChannelVersions(channel);

        // Filter the list of all install types and return only those applicable to this
        // channel:
        Iterator iter = installTypes.iterator();
        while (iter.hasNext()) {
            KickstartInstallType ksType = (KickstartInstallType)iter.next();
            if (channelVersions.contains(
                    ChannelVersion.getChannelVersionForKickstartInstallType(ksType))) {
                returnInstallTypes.add(ksType);
            }
        }

        return returnInstallTypes;
    }

    /**
     * Get List of KickstartInstallType objects.
     * @return List of KickstartInstallType objets
     */
    public List getKickstartableChannels() {
        return ChannelFactory.
            getKickstartableChannels(user.getOrg());
    }

    /**
     * Get the CobblerCommand class associated with this operation.
     * Determines which Command we should execute when calling store()
     *
     * @return CobblerCommand instance.
     */
    protected abstract CobblerCommand getCobblerCommand();


    /**
     * @return Returns the postKernelOptions.
     */
    public String getPostKernelOptions() {
        return postKernelOptions;
    }


    /**
     * @param postKernelOptionsIn The postKernelOptions to set.
     */
    public void setPostKernelOptions(String postKernelOptionsIn) {
        postKernelOptions = postKernelOptionsIn;
    }


    /**
     * @return Returns the kernelOptions.
     */
    public String getKernelOptions() {
        return kernelOptions;
    }


    /**
     * @param kernelOptionsIn The kernelOptions to set.
     */
    public void setKernelOptions(String kernelOptionsIn) {
        kernelOptions = kernelOptionsIn;
    }
}
