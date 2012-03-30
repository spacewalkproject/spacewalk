/**
 * Copyright (c) 2012 Novell
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
package com.redhat.rhn.domain.image;

import com.redhat.rhn.frontend.dto.BaseDto;

/**
 * Images for deployment to virtual host systems. Currently such image objects
 * are not being persisted, but they rather exist in memory only.
 */
public class Image extends BaseDto implements Comparable<Image> {

    private Long id;
    private String name;
    private String version;
    private String arch;
    private String imageSize;
    private String imageType;
    private String downloadUrl;
    private String editUrl;
    private boolean selectable = true;

    /**
     * Return the ID.
     * @return id
     */
    public Long getId() {
        return this.id;
    }

    /**
     * Set the ID.
     * @param inId id
     */
    public void setId(Long inId) {
        this.id = inId;
    }

    /**
     * Return the name.
     * @return name
     */
    public String getName() {
        return this.name;
    }

    /**
     * Set the name.
     * @param nameIn name
     */
    public void setName(String nameIn) {
        this.name = nameIn;
    }

    /**
     * Return the version.
     * @return version
     */
    public String getVersion() {
        return this.version;
    }

    /**
     * Set the version.
     * @param versionIn version
     */
    public void setVersion(String versionIn) {
        this.version = versionIn;
    }

    /**
     * Return the architecture.
     * @return architecture
     */
    public String getArch() {
        return this.arch;
    }

    /**
     * Set the architecture.
     * @param archIn architecture
     */
    public void setArch(String archIn) {
        this.arch = archIn;
    }

    /**
     * Get the image size.
     * @return image size
     */
    public String getImageSize() {
        return this.imageSize;
    }

    /**
     * Set the image size.
     * @param imageSizeIn image size
     */
    public void setImageSize(String imageSizeIn) {
        this.imageSize = imageSizeIn;
    }

    /**
     * Return the image type.
     * @return image type
     */
    public String getImageType() {
        return this.imageType;
    }

    /**
     * Set the image type.
     * @param imageTypeIn image type
     */
    public void setImageType(String imageTypeIn) {
        this.imageType = imageTypeIn;
    }

    /**
     * Return the download URL.
     * @return download URL
     */
    public String getDownloadUrl() {
        return this.downloadUrl;
    }

    /**
     * Set the download URL.
     * @param downloadUrlIn download URL
     */
    public void setDownloadUrl(String downloadUrlIn) {
        this.downloadUrl = downloadUrlIn;
    }

    /**
     * Return the edit URL.
     * @return edit URL
     */
    public String getEditUrl() {
        return this.editUrl;
    }

    /**
     * Set the edit URL.
     * @param editUrlIn edit URL
     */
    public void setEditUrl(String editUrlIn) {
        this.editUrl = editUrlIn;
    }

    /**
     * Control if this image is selectable.
     * @param value true to make it selectable, otherwise false.
     */
    public void setSelectable(boolean value) {
        this.selectable = value;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public boolean isSelectable() {
        return selectable;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public String getSelectionKey() {
        return String.valueOf(getId());
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj == null) {
            return false;
        }
        if (!(obj instanceof Image)) {
            return false;
        }
        Image other = (Image) obj;
        if (id == null) {
            if (other.id != null) {
                return false;
            }
        }
        else if (!id.equals(other.id)) {
            return false;
        }
        return true;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + ((id == null) ? 0 : id.hashCode());
        return result;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public int compareTo(Image image) {
        int ret = 0;
        if (!this.name.equals(image.getName())) {
            ret = this.name.compareTo(image.name);
        }
        else if (!this.version.equals(image.getVersion())) {
            ret = this.version.compareTo(image.version);
        }
        else if (!this.arch.equals(image.getArch())) {
            ret = this.arch.compareTo(image.getArch());
        }
        else if (!this.imageType.equals(image.getImageType())) {
            ret = this.imageType.compareTo(image.getImageType());
        }
        return ret;
    }
}
