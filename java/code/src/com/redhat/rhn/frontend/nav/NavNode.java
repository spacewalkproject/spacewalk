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

package com.redhat.rhn.frontend.nav;

import com.redhat.rhn.common.localization.LocalizationService;

import org.apache.commons.lang.StringEscapeUtils;
import org.apache.commons.lang.builder.ToStringBuilder;
import org.apache.commons.lang.builder.ToStringStyle;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/**
 * Class representing a navigation tree node (aka tab)
 * @version $Rev$
 */

public class NavNode {
    private String label;
    private String name;
    private String acl;
    private String target;
    private boolean dominant;
    private boolean invisible;
    private boolean overrideSidenav;
    private boolean showChildrenIfActive;
    private boolean first;
    private boolean last;
    private String permFailRedirect;
    private String activeImage;
    private String inactiveImage;
    private String onClick;
    private String dynamicChildren;

    private List children;
    private List urls;
    private List dirs;

    /**
     * Default constructor
     */
    public NavNode() {
        children = new ArrayList();
        urls = new ArrayList();
        dirs = new ArrayList();
    }

    /**
     * Returns an unmodifiableList containing children of the node
     * @return List the children of the node
     */
    public List getNodes() {
        return Collections.unmodifiableList(children);
    }

    /**
     * Adds a child node to the current node
     * @param child The child node
     */
    public void addNode(NavNode child) {
        children.add(child);
    }

    /**
     * Associated a URL with this node
     * @param url The URL (a string, not java.net.URL)
     */
    public void addURL(String url) {
        urls.add(url);
    }

    /**
     * Associated a URL with this node.  This is the primary URL and
     * comes first.  If not called, then the first normal addURL is
     * the primary URL.
     * @param url The URL (a string, not java.net.URL)
     */
    public void addPrimaryURL(String url) {
        urls.add(0, url);
    }

    /**
     * Get URLs associated with this node
     * @return List the associated URLs
     */
    public List getURLs() {
        return Collections.unmodifiableList(urls);
    }

    /**
     * Get Dirs associated with this node
     * @return List the associated dirs
     */
    public List getDirs() {
        return Collections.unmodifiableList(dirs);
    }

    /**
     * Associates a directory with this node
     * @param dir the directory
     */
    public void addDirectory(String dir) {
        dirs.add(dir);
    }

    /**
     *  String version of node
     *  @return String the stringified node
     */
    public String toString() {
        return
            ToStringBuilder.reflectionToString(this,
                                               ToStringStyle.MULTI_LINE_STYLE);
    }

    /* Begin copy/paste constructors */

    /**
     * Gets the current value of label
     * @return String the current value
     */
    public String getLabel() {
        return this.label;
    }

    /**
     * Sets the value of label to new value
     * @param labelIn New value for label
     */
    public void setLabel(String labelIn) {
        this.label = labelIn;
    }

    /**
     * Gets the current value of name
     * @return String the current value
     */
    public String getName() {
        //Return the translated and escaped name
        String unescapedName = LocalizationService.getInstance().getMessage(this.name);
        return StringEscapeUtils.escapeHtml(unescapedName);
    }

    /**
     * Sets the value of name to the localized version of the passed in name.
     * @param nameIn Message key for name
     */
    public void setName(String nameIn) {
        name = nameIn;
    }

    /**
     * Gets the current value of acl
     * @return String the current value
     */
    public String getAcl() {
        return this.acl;
    }

    /**
     * Sets the value of acl to new value
     * @param aclIn New value for acl
     */
    public void setAcl(String aclIn) {
        this.acl = aclIn;
    }

    /**
     * Gets the current value of dominant
     * @return boolean the current value
     */
    public boolean getDominant() {
        return this.dominant;
    }

    /**
     * Sets the value of dominant to new value
     * @param dominantIn New value for dominant
     */
    public void setDominant(boolean dominantIn) {
        this.dominant = dominantIn;
    }

    /**
     * Gets the current value of invisible
     * @return boolean the current value
     */
    public boolean getInvisible() {
        return this.invisible;
    }

    /**
     * Sets the value of invisible to new value
     * @param invisibleIn New value for invisible
     */
    public void setInvisible(boolean invisibleIn) {
        this.invisible = invisibleIn;
    }

    /**
     * Gets the current value of overrideSidenav
     * @return boolean the current value
     */
    public boolean getOverrideSidenav() {
        return this.overrideSidenav;
    }

    /**
     * Sets the value of overrideSidenav to new value
     * @param overrideSidenavIn New value for overrideSidenav
     */
    public void setOverrideSidenav(boolean overrideSidenavIn) {
        this.overrideSidenav = overrideSidenavIn;
    }

    /**
     * Gets the current value of showChildrenIfActive
     * @return boolean the current value
     */
    public boolean getShowChildrenIfActive() {
        return this.showChildrenIfActive;
    }

    /**
     * Sets the value of showChildrenIfActive to new value
     * @param showChildrenIfActiveIn New value for showChildrenIfActive
     */
    public void setShowChildrenIfActive(boolean showChildrenIfActiveIn) {
        this.showChildrenIfActive = showChildrenIfActiveIn;
    }

    /**
     * Gets the current value of permFailRedirect
     * @return String the current value
     */
    public String getPermFailRedirect() {
        return this.permFailRedirect;
    }

    /**
     * Sets the value of permFailRedirect to new value
     * @param permFailRedirectIn New value for permFailRedirect
     */
    public void setPermFailRedirect(String permFailRedirectIn) {
        this.permFailRedirect = permFailRedirectIn;
    }

    /**
     * Gets the current value of activeImage
     * @return String the current value
     */
    public String getActiveImage() {
        return this.activeImage;
    }

    /**
     * Sets the value of activeImage to new value
     * @param activeImageIn New value for activeImage
     */
    public void setActiveImage(String activeImageIn) {
        this.activeImage = activeImageIn;
    }

    /**
     * Gets the current value of inactiveImage
     * @return String the current value
     */
    public String getInactiveImage() {
        return this.inactiveImage;
    }

    /**
     * Sets the value of inactiveImage to new value
     * @param inactiveImageIn New value for inactiveImage
     */
    public void setInactiveImage(String inactiveImageIn) {
        this.inactiveImage = inactiveImageIn;
    }

    /**
     * Gets the current value of onClick
     * @return String the current value
     */
    public String getOnClick() {
        return this.onClick;
    }

    /**
     * Sets the value of onClick to new value
     * @param onClickIn New value for onClick
     */
    public void setOnClick(String onClickIn) {
        this.onClick = onClickIn;
    }

    /**
     * Gets the current value of dynamicChildren
     * @return String the current value
     */
    public String getDynamicChildren() {
        return this.dynamicChildren;
    }

    /**
     * Sets the value of dynamicChildren to new value
     * @param dynamicChildrenIn New value for dynamicChildren
     */
    public void setDynamicChildren(String dynamicChildrenIn) {
        this.dynamicChildren = dynamicChildrenIn;
    }

    /**
     * get the "best" most "proper" URL for this node
     * @return "best" most "proper" URL for this node
     */
    public String getPrimaryURL() {
        if (urls != null && urls.size() > 0) {
            return (String)urls.get(0);
        }
        throw new IndexOutOfBoundsException("attempt to ask for primary URL of " +
                                            this.getName() +
                                            " node with no URLs associated");
    }

    /**
     * Marks the Node as the first in a list.
     * @param flag true if this Node is the first in a particular level of
     * the tree.
     */
    public void setFirst(boolean flag) {
        first = flag;
        last = false;
    }

    /**
     * Returns true if this Node is the first in a particular level of
     * the tree.
     * @return true if this Node is the first in a particular level of
     * the tree.
     */
    public boolean isFirst() {
        return first;
    }

    /**
     * Marks the Node as the last in a list.
     * @param flag true if this Node is the last in a particular level of
     * the tree.
     */
    public void setLast(boolean flag) {
        last = flag;
        first = false;
    }
    /**
     * Returns true if this Node is the last in a particular level of
     * the tree.
     * @return true if this Node is the last in a particular level of
     * the tree.
     */
    public boolean isLast() {
        return last;
    }

    /**
     * Sets the target of the url.
     * @param tgt link target
     */
    public void setTarget(String tgt) {
        target = tgt;
    }

    /**
     * returns the target for the url
     * @return the target for the url
     */
    public String getTarget() {
        return target;
    }
}

