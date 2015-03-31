/**
 * Copyright (c) 2013 SUSE LLC
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

package org.cobbler;

import org.apache.commons.lang.builder.EqualsBuilder;
import org.apache.commons.lang.builder.HashCodeBuilder;

import java.util.LinkedList;
import java.util.List;
import java.util.Map;

/**
 * Encapsulates an Image object in Cobbler.
 */
public class Image extends CobblerObject {

    /** Cobbler field name for the image type. Can be one of the TYPE_ constants */
    public static final String TYPE = "image_type";

    /** Cobbler field name for image file name */
    public static final String FILE = "file";

    // see TYPE
    /** An ISO image */
    public static final String TYPE_ISO = "iso";

    /** A raw executable binary (eg. memtest86+) */
    public static final String TYPE_DIRECT = "direct";

    /** A memory disk */
    public static final String TYPE_MEMDISK = "memdisk";

    /** A virtual image */
    public static final String TYPE_VIRT_IMAGE = "virt-image";

    /**
     * Instantiates a new image.
     * @param clientIn a Cobbler connection
     */
    private Image(CobblerConnection clientIn) {
        super();
        client = clientIn;
    }

    /**
     * Create a new image in Cobbler.
     * @param client a Cobbler connection
     * @param name the image name
     * @param type the image type
     * @param file the image file name
     * @return the newly created image
     */
    public static Image create(CobblerConnection client, String name, String type,
        String file) {
        Image image = new Image(client);
        image.handle = (String) client.invokeTokenMethod("new_image");
        image.modify(NAME, name);
        image.setType(type);
        image.setFile(file);
        image.save();
        image = lookupByName(client, name);
        return image;
    }

    /**
     * Lookup an image by its name.
     * @param client a Cobbler connection
     * @param name the name
     * @return the image
     */
    public static Image lookupByName(CobblerConnection client, String name) {
        return handleLookup(client, lookupDataMapByName(client, name, "get_image"));
    }

    /**
     * Lookup an image by its id.
     * @param client a Cobbler connection
     * @param id the id
     * @return the image
     */
    public static Image lookupById(CobblerConnection client, String id) {
        return handleLookup(client, lookupDataMapById(client, id, "find_image"));
    }

    /**
     * Lists all known images.
     * @param client a Cobbler connection
     * @return the list
     */
    @SuppressWarnings("unchecked")
    public static List<Image> list(CobblerConnection client) {
        List<Image> result = new LinkedList<Image>();

        List<Map<String, Object>> imageMaps = (List<Map<String, Object>>) client
            .invokeMethod("get_images");

        for (Map<String, Object> imageMap : imageMaps) {
            Image distro = new Image(client);
            distro.dataMap = imageMap;
            result.add(distro);
        }
        return result;
    }

    /**
     * Handles lookups.
     * @param client a Cobbler connection
     * @param imageMap the image map
     * @return the image
     */
    private static Image handleLookup(CobblerConnection client,
        Map<String, Object> imageMap) {
        if (imageMap != null) {
            Image image = new Image(client);
            image.dataMap = imageMap;
            return image;
        }
        return null;
    }

    /**
     * Gets the type.
     * @return the type
     */
    public String getType() {
        return (String) dataMap.get(TYPE);
    }

    /**
     * Gets the file.
     * @return the file
     */
    public String getFile() {
        return (String) dataMap.get(FILE);

    }

    /**
     * Sets the type.
     * @param typeIn the new type
     */
    public void setType(String typeIn) {
        modify(TYPE, typeIn);

    }

    /**
     * Sets the file.
     * @param fileIn the new file
     */
    public void setFile(String fileIn) {
        modify(FILE, fileIn);
    }

    /*
     * (non-Javadoc)
     * @see org.cobbler.CobblerObject#invokeModify(java.lang.String,
     * java.lang.Object)
     */
    @Override
    protected void invokeModify(String key, Object value) {
        client.invokeTokenMethod("modify_image", getHandle(), key, value);
    }

    /*
     * (non-Javadoc)
     * @see org.cobbler.CobblerObject#invokeSave()
     */
    @Override
    protected void invokeSave() {
        client.invokeTokenMethod("save_image", getHandle());
    }

    /*
     * (non-Javadoc)
     * @see org.cobbler.CobblerObject#invokeRemove()
     */
    @Override
    protected boolean invokeRemove() {
        return (Boolean) client.invokeTokenMethod("remove_image", getName());
    }

    /*
     * (non-Javadoc)
     * @see org.cobbler.CobblerObject#invokeGetHandle()
     */
    @Override
    protected String invokeGetHandle() {
        return (String) client.invokeTokenMethod("get_image_handle", this.getName());
    }

    /*
     * (non-Javadoc)
     * @see org.cobbler.CobblerObject#reload()
     */
    @Override
    protected void reload() {
        Image newImage = lookupById(client, getId());
        dataMap = newImage.dataMap;
    }

    /*
     * (non-Javadoc)
     * @see org.cobbler.CobblerObject#invokeRename(java.lang.String)
     */
    @Override
    protected void invokeRename(String newName) {
        client.invokeTokenMethod("rename_image", getHandle(), newName);
    }

    /**
     * @see java.lang.Object#equals(java.lang.Object)
     * @param   other   the reference object with which to compare
     * @return  {@code true} if this object is the same as the obj
     *          argument; {@code false} otherwise.
     */
    @Override
    public boolean equals(Object other) {
        if (other == null || other.getClass() != getClass()) {
            return false;
        }
        Image otherImage = (Image) other;

        return new EqualsBuilder().append(getId(), otherImage.getId())
            .append(getName(), otherImage.getName())
            .append(getType(), otherImage.getType())
            .append(getFile(), otherImage.getFile()).isEquals();
    }

    /**
     * @return  a hash code value for this object
     * @see java.lang.Object#hashCode()
     */
    @Override
    public int hashCode() {
        return new HashCodeBuilder().append(getId()).append(getName()).append(getType())
            .append(getFile()).hashCode();
    }
}
