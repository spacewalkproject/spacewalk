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
package com.redhat.rhn.domain.rhnpackage;

import com.redhat.rhn.domain.BaseDomainHelper;
import com.redhat.rhn.domain.common.Checksum;

import org.apache.commons.lang.builder.EqualsBuilder;
import org.apache.commons.lang.builder.HashCodeBuilder;

import java.io.Serializable;
import java.util.Date;

/**
 * PackageArch
 * @version $Rev$
 */
public class PackageFile extends BaseDomainHelper implements Serializable {

    /**
     * Comment for <code>serialVersionUID</code>
     */
    private static final long serialVersionUID = 8009150853428038205L;

    private Package pack;
    private PackageCapability capability;
    private Long device;
    private Long inode;
    private Long fileMode;
    private String username;
    private String groupname;
    private Long rdev;
    private Long fileSize;
    private Date mtime;
    private Checksum checksum;
    private String linkTo;
    private Long flags;
    private Long verifyFlags;
    private String lang;

    /**
     * @return Returns the pack.
     */
    public Package getPack() {
        return pack;
    }

    /**
     * @param packIn The pack to set.
     */
    public void setPack(Package packIn) {
        this.pack = packIn;
    }

    /**
     * @return Returns the capability.
     */
    public PackageCapability getCapability() {
        return capability;
    }

    /**
     * @param capabilityIn The capability to set.
     */
    public void setCapability(PackageCapability capabilityIn) {
        this.capability = capabilityIn;
    }

    /**
     * @return Returns the device.
     */
    public Long getDevice() {
        return device;
    }

    /**
     * @param deviceIn The device to set.
     */
    public void setDevice(Long deviceIn) {
        this.device = deviceIn;
    }

    /**
     * @return Returns the inode.
     */
    public Long getInode() {
        return inode;
    }

    /**
     * @param inodeIn The inode to set.
     */
    public void setInode(Long inodeIn) {
        this.inode = inodeIn;
    }

    /**
     * @return Returns the fileMode.
     */
    public Long getFileMode() {
        return fileMode;
    }

    /**
     * @param fileModeIn The fileMode to set.
     */
    public void setFileMode(Long fileModeIn) {
        this.fileMode = fileModeIn;
    }

    /**
     * @return Returns the username.
     */
    public String getUsername() {
        return username;
    }

    /**
     * @param usernameIn The username to set.
     */
    public void setUsername(String usernameIn) {
        this.username = usernameIn;
    }

    /**
     * @return Returns the groupname.
     */
    public String getGroupname() {
        return groupname;
    }

    /**
     * @param groupnameIn The groupname to set.
     */
    public void setGroupname(String groupnameIn) {
        this.groupname = groupnameIn;
    }

    /**
     * @return Returns the rdev.
     */
    public Long getRdev() {
        return rdev;
    }

    /**
     * @param rdevIn The rdev to set.
     */
    public void setRdev(Long rdevIn) {
        this.rdev = rdevIn;
    }

    /**
     * @return Returns the fileSize.
     */
    public Long getFileSize() {
        return fileSize;
    }

    /**
     * @param fileSizeIn The fileSize to set.
     */
    public void setFileSize(Long fileSizeIn) {
        this.fileSize = fileSizeIn;
    }

    /**
     * @return Returns the mtime.
     */
    public Date getMtime() {
        return mtime;
    }

    /**
     * @param mtimeIn The mtime to set.
     */
    public void setMtime(Date mtimeIn) {
        this.mtime = mtimeIn;
    }


    /**
     * @return Returns the linkTo.
     */
    public String getLinkTo() {
        return linkTo;
    }

    /**
     * @param linkToIn The linkTo to set.
     */
    public void setLinkTo(String linkToIn) {
        this.linkTo = linkToIn;
    }

    /**
     * @return Returns the flags.
     */
    public Long getFlags() {
        return flags;
    }

    /**
     * @param flagsIn The flags to set.
     */
    public void setFlags(Long flagsIn) {
        this.flags = flagsIn;
    }

    /**
     * @return Returns the verifyFlags.
     */
    public Long getVerifyFlags() {
        return verifyFlags;
    }

    /**
     * @param verifyFlagsIn The verifyFlags to set.
     */
    public void setVerifyFlags(Long verifyFlagsIn) {
        this.verifyFlags = verifyFlagsIn;
    }

    /**
     * @return Returns the lang.
     */
    public String getLang() {
        return lang;
    }

    /**
     * @param langIn The lang to set.
     */
    public void setLang(String langIn) {
        this.lang = langIn;
    }

    /**
     *
     * {@inheritDoc}
     */
    @Override
    public boolean equals(Object obj) {
        if (!(obj instanceof PackageFile)) {
            return false;
        }
        PackageFile fileIn = (PackageFile) obj;
        EqualsBuilder equals = new EqualsBuilder();
        equals.append(this.getPack(), fileIn.getPack());
        equals.append(this.getCapability(), fileIn.getCapability());
        return equals.isEquals();
    }

    /**
     *
     * {@inheritDoc}
     */
    @Override
    public int hashCode() {
        HashCodeBuilder hash = new HashCodeBuilder();
        hash.append(this.getPack());
        hash.append(this.getCapability());
        return hash.toHashCode();
    }


    /**
     * @return Returns the checksum.
     */
    public Checksum getChecksum() {
        return checksum;
    }


    /**
     * @param checksumIn The checksum to set.
     */
    public void setChecksum(Checksum checksumIn) {
        this.checksum = checksumIn;
    }

}
