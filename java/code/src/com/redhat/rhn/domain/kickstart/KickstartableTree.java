/**
 * Copyright (c) 2008 Red Hat, Inc.
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

import com.redhat.rhn.domain.BaseDomainHelper;
import com.redhat.rhn.domain.channel.Channel;

import java.util.Date;

/**
 * KickstartableTree
 * @version $Rev$
 */
public class KickstartableTree extends BaseDomainHelper {

    private String basePath;
    private String bootImage;
    private Channel channel;
    private Long id;
    private KickstartInstallType installType;
    private String label;
    private Date lastModified;
    private Long orgId;
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
     * @return Returns the bootImage.
     */
    public String getBootImage() {
        return bootImage;
    }
    
    /**
     * @param b The bootImage to set.
     */
    public void setBootImage(String b) {
        this.bootImage = b;
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
        return orgId;
    }
    
    /**
     * @param o The orgId to set.
     */
    public void setOrgId(Long o) {
        this.orgId = o;
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
     * Check to see if this tree is 'owned' by RHN and hosted
     * by this Spacewalk.
     * @return boolean if this tree is owned or not by RHN
     */
    public boolean isRhnTree() {
        return (this.orgId == null || 
                this.orgId.equals(new Long(0)));
    }
    
    /**
     * Get the default download location for this KickstartableTree.
     * 
     * eg: http://rlx-3-10.rhndev.redhat.com/rhn/kickstart/ks-rhel-i386-as-4
     * 
     * @param host used to Kickstart from
     * @return String url
     */
    public String getDefaultDownloadLocation(String host) {
        if (this.getBasePath() != null) {
            String defaultLocation = this.getBasePath();
            defaultLocation = defaultLocation.toLowerCase();
            if (basePathIsUrl()) {
                return this.getBasePath();
            }
            else {
                StringBuffer buf = new StringBuffer();
                if (host != null && host.length() > 0) {
                    buf.append("http://").append(host);
                }
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
    
}
