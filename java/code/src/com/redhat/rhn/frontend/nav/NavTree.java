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

import org.apache.commons.lang.builder.ToStringBuilder;
import org.apache.commons.lang.builder.ToStringStyle;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/**
 * Class representing a navigation tree
 * @version $Rev$
 */

public class NavTree {
    private String label;
    private int titleDepth;
    private boolean invisible;
    private String formvar;
    private List nodes;
    private String aclMixins;
    private AclGuard guard;

    /** default constructor
     */
    public NavTree() {
        titleDepth = 0;
        invisible = false;

        nodes = new ArrayList();
    }

    /**
       Adds a node to the tree
       @param n node added to tree
    */
    public void addNode(NavNode n) {
        nodes.add(n);
    }
    /**
     * Gets the top-level nodes associated with the tree
     * @return List of the nodes
     */
    public List getNodes() {
        return Collections.unmodifiableList(nodes);
    }

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
     * Gets the current value of titleDepth
     * @return int the current value
     */
    public int getTitleDepth() {
        return this.titleDepth;
    }

    /**
     * Sets the value of titleDepth to new value
     * @param titleDepthIn New value for titleDepth
     */
    public void setTitleDepth(int titleDepthIn) {
        this.titleDepth = titleDepthIn;
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
     * Gets the current value of formvar 
     * @return String the current value
     */
    public String getFormvar() {
        return this.formvar;
    }

    /**
     * Sets the value of formvar to new value
     * @param formVarIn New value for label
     */
    public void setFormvar(String formVarIn) {
        this.formvar = formVarIn;
    }

    /**
     * Gets the current value of aclMixins
     * @return String the current value
     */
    public String getAclMixins() {
        return this.aclMixins;
    }

    /**
     * Sets the value of aclMixins to new value
     * @param aclMixinsIn New value for aclMixins
     */
    public void setAclMixins(String aclMixinsIn) {
        this.aclMixins = aclMixinsIn;
    }

    /**
     *  String version of tree
     *  @return String the stringified tree
     */
    public String toString() {
        return
            ToStringBuilder.reflectionToString(this,
                                               ToStringStyle.MULTI_LINE_STYLE);
    }
    /**
     * @return Returns the guard.
     */
    public AclGuard getGuard() {
        return guard;
    }
    /**
     * NavMenuTag sets this instance because the request is used for context
     * @param guardIn The guard to set.
     */
    public void setGuard(AclGuard guardIn) {
        this.guard = guardIn;
    }
}
