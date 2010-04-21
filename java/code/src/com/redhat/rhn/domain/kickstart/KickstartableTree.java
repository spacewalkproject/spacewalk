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
package com.redhat.rhn.domain.kickstart;

import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.common.util.StringUtil;
import com.redhat.rhn.domain.BaseDomainHelper;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.manager.kickstart.cobbler.CobblerCommand;
import com.redhat.rhn.manager.kickstart.cobbler.CobblerXMLRPCHelper;

import org.apache.commons.lang.StringUtils;
import org.cobbler.CobblerConnection;
import org.cobbler.Distro;

import java.io.File;
import java.util.Date;

/**
 * KickstartableTree
 * @version $Rev$
 */
public class KickstartableTree extends BaseDomainHelper {

    private String basePath;
    private Channel channel;
    private Long id;
    private KickstartInstallType installType;
    private String label;
    private Date lastModified;
    private String cobblerId;
    private String cobblerXenId;

    private Org org;
    private KickstartTreeType treeType;
    
    /**
     * @return Returns the basePath.
     */
    public String getBasePath() {
        return basePath;
    }
    
    /**
     * @param b The basePath to set.
     */
    public void setBasePath(String b) {
        this.basePath = b;
    }

    /**
     * @return Returns the channel.
     */
    public Channel getChannel() {
        return channel;
    }
    
    /**
     * @param c The channel to set.
     */
    public void setChannel(Channel c) {
        this.channel = c;
    }
    
    /**
     * @return Returns the id.
     */
    public Long getId() {
        return id;
    }
    
    /**
     * @param i The id to set.
     */
    public void setId(Long i) {
        this.id = i;
    }
    
    /**
     * @return Returns the installType.
     */
    public KickstartInstallType getInstallType() {
        return installType;
    }
    
    /**
     * @param i The installType to set.
     */
    public void setInstallType(KickstartInstallType i) {
        this.installType = i;
    }
    
    /**
     * @return Returns the label.
     */
    public String getLabel() {
        return label;
    }
    
    /**
     * @param l The label to set.
     */
    public void setLabel(String l) {
        this.label = l;
    }
    
    /**
     * @return Returns the lastModified.
     */
    public Date getLastModified() {
        return lastModified;
    }
    
    /**
     * @param l The lastModified to set.
     */
    public void setLastModified(Date l) {
        this.lastModified = l;
    }
    
    /**
     * @return Returns the orgId.
     */
    public Long getOrgId() {
        if (isRhnTree()) {
            return null;
        }
        return getOrg().getId();
    }

    /**
     * @return Returns the org.
     */    
    public Org getOrg() {
        return org;
    }
    
    /**
     * @param o The org to set.
     */
    public void setOrg(Org o) {
        this.org = o;
    }
    
    /**
     * @return Returns the treeType.
     */
    public KickstartTreeType getTreeType() {
        return treeType;
    }
    
    /**
     * @param t The treeType to set.
     */
    public void setTreeType(KickstartTreeType t) {
        this.treeType = t;
    }
    
    /**
     * Check to see if this tree is 'owned' by RHN.
     * @return boolean if this tree is owned or not by RHN
     */
    public boolean isRhnTree() {
        return this.org == null;  
    }
    
    /**
     * Get the default download location for this KickstartableTree.
     * 
     * eg: /rhn/kickstart/ks-rhel-i386-as-4
     *
     * NOTE: the default path does not include a host.
     *  We append the host if it starts with a '/'
     * 
     * @param host used to Kickstart from
     * @return String url
     */
    public String getDefaultDownloadLocation(String host) {
        if (this.getBasePath() != null) {

            String defaultLocation = "ks/dist/";

            if (this.getOrg() != null) {
                defaultLocation += "org/" + this.getOrgId() + "/";
            }

            defaultLocation += this.getLabel();

            if (basePathIsUrl()) {
                return this.getBasePath();
            }
            else {
                StringBuilder buf = new StringBuilder();
                if (!defaultLocation.startsWith("/")) {
                    buf.append("/");
                }
                buf.append(defaultLocation);
                return buf.toString();                                    
            }
        }
        else {
            return "";
        }

    }
    
    /**
     * Check if the tree's base path is a fully qualified URL or just a relative path.
     * 
     * @return True if base path is a URL.
     */
    public boolean basePathIsUrl() {
        String defaultLocation = this.getBasePath().toLowerCase();
        return (defaultLocation.startsWith("http://") || 
                defaultLocation.startsWith("ftp://"));
    }
    

    /**
     * @return the cobblerDistroName
     */
    public String getCobblerDistroName() {
        return CobblerCommand.makeCobblerName(getLabel(), getOrg());
    }
    
    /**
     * @return the cobblerDistroName
     */
    public String getCobblerXenDistroName() {
        String sep = ConfigDefaults.get().getCobblerNameSeparator();
        return CobblerCommand.makeCobblerName(getLabel() + sep + "xen", getOrg());
    }    


    /**
     * Basically returns the actual basepath
     * we need this method because the
     * database stores rhn/.... as basepath for redhat channels
     * and actual path for non redhat channels... 
     * @return the actual basepath.
     */
    public  String getAbsolutePath() {
        if (isRhnTree()) {
            //redhat channel append the mount point to 
            //base path...
            return ConfigDefaults.get().getKickstartMountPoint() + getBasePath();
        }
        //its a base channel return the 
        return getBasePath();
    }
    
    /**
     * Returns the kernel path 
     * includes the mount point 
     * its an absolute path.
     * @return the kernel path
     */
    public String getKernelPath() {
        String arch = this.getChannel().getChannelArch().getLabel();
        if (arch.equals("channel-s390") || arch.endsWith("channel-s390x")) {
            return StringUtil.addPath(getAbsolutePath(), "/images/kernel.img");
        }
        else if (arch.equals("channel-ppc")) {
            return StringUtil.addPath(getAbsolutePath(), "/ppc/ppc64/vmlinuz");
        }
        else {
            return StringUtil.addPath(getAbsolutePath(), "/images/pxeboot/vmlinuz");
        }
    }

    /**
     * Returns the Initrd path 
     * includes the mount point 
     * its an absolute path.
     * @return the Initrd path
     */
    public String getInitrdPath() {
        String arch = this.getChannel().getChannelArch().getLabel();
        if (arch.equals("channel-s390") || arch.endsWith("channel-s390x")) {
            return StringUtil.addPath(getAbsolutePath(), "/images/initrd.img");
        }
        else if (arch.equals("channel-ppc")) {
            return StringUtil.addPath(getAbsolutePath(), "/ppc/ppc64/ramdisk.image.gz");
        }
        else {
            return StringUtil.addPath(getAbsolutePath(), "/images/pxeboot/initrd.img");
        }
    }

    /**
     * Returns the kernel path for the xen kernel 
     * includes the mount point 
     * its an absolute path.
     * @return the kernel path
     */
    public String getKernelXenPath() {
        return StringUtil.addPath(getAbsolutePath(), "/images/xen/vmlinuz");
    }
    
    /**
     * Returns the Initrd path for the xen kernel
     * includes the mount point 
     * its an absolute path.
     * @return the Initrd path
     */
    public String getInitrdXenPath() {
        return StringUtil.addPath(getAbsolutePath(), "/images/xen/initrd.img");
    }    
    
    /**
     * @return Returns the cobblerId.
     */
    public String getCobblerId() {
        return cobblerId;
    }

    
    /**
     * @param cobblerIdIn The cobblerId to set.
     */
    public void setCobblerId(String cobblerIdIn) {
        this.cobblerId = cobblerIdIn;
    }

    
    /**
     * Gets the cobblerXenId, which is the cobbler id corresponding to the 
     *      cobbler distro that is pointing to Xen PV boot images instead of regular
     *      boot images (yes this sucks) 
     * @return Returns the cobblerXenId.
     */
    public String getCobblerXenId() {
        return cobblerXenId;
    }

    
    /**
     * @param cobblerXenIdIn The cobblerXenId to set.
     */
    public void setCobblerXenId(String cobblerXenIdIn) {
        this.cobblerXenId = cobblerXenIdIn;
    }
    
    /**
     * Check to see if the selected tree support xen paravirt
     * @return true if it can, false otherwise
     */
    public boolean doesParaVirt() {
        File kernel = new File(this.getKernelXenPath());
        return kernel.exists();
    }
    
    /**
     * Returns the cobbler object associated to 
     * to this tree.
     * @param user the user object needed for connection,
     *              enter null if you want to use the 
     *              automated connection as provided by
     *              taskomatic.
     * @return the Distro associated to this tree
     */
    public Distro getCobblerObject(User user) {
        if (StringUtils.isBlank(getCobblerId())) {
            return null;
        }
        CobblerConnection con;
        if (user == null) {
            con = CobblerXMLRPCHelper.getAutomatedConnection();
        }
        else {
            con = CobblerXMLRPCHelper.getConnection(user);
        }
        return Distro.lookupById(con, getCobblerId());
    }
    
    private boolean pathExists(String path) {
        return new File(path).exists();
    }
    
    /**
     * Returns true if both the kernel path and initrd paths exist
     * and cobbler id is not null for this distribution.
     * @return true if this is a valid distro.
     */
    public boolean isValid() {
        return !StringUtils.isBlank(getCobblerId()) && 
                    pathExists(getInitrdPath()) && pathExists(getKernelPath()); 
    }
}
