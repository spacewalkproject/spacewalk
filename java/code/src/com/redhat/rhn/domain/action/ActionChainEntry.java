/**
 * Copyright (c) 2014 SUSE
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
package com.redhat.rhn.domain.action;

import com.redhat.rhn.domain.BaseDomainHelper;
import com.redhat.rhn.domain.server.Server;

import org.apache.commons.lang.builder.EqualsBuilder;
import org.apache.commons.lang.builder.HashCodeBuilder;
import org.apache.commons.lang.builder.ToStringBuilder;

/**
 * POJO for a rhnActionChainEntry row.
 * @author Silvio Moioli <smoioli@suse.de>
 * @version $Rev$
 */
public class ActionChainEntry extends BaseDomainHelper {

    /** The id, which is also the associated Action id. */
    private Long id;

    /** The action. */
    private Action action;

    /** The action chain. */
    private ActionChain actionChain;

    /** The server. */
    private Server server;

    /** The sort order. */
    private Integer sortOrder;

    /**
     * Default constructor.
     */
    public ActionChainEntry() {
    }

    /**
     * Gets the id.
     *
     * @return the id
     */
    public Long getId() {
        return id;
    }

    /**
     * Sets the id.
     *
     * @param idIn the new id
     */
    public void setId(Long idIn) {
        id = idIn;
    }

    /**
    /**
     * Gets the action.
     *
     * @return the action
     */
    public Action getAction() {
        return action;
    }

    /**
     * Sets the action.
     *
     * @param actionIn the new action
     */
    public void setAction(Action actionIn) {
        action = actionIn;
    }

    /**
     * Gets the action id.
     *
     * @return the action id or null
     */
    public Long getActionId() {
        if (getAction() != null) {
            return getAction().getId();
        }
        return null;
    }

    /**
     * Gets the action chain.
     *
     * @return the action chain
     */
    public ActionChain getActionChain() {
        return actionChain;
    }

    /**
     * Sets the action chain.
     *
     * @param actionChainIn the new action chain
     */
    public void setActionChain(ActionChain actionChainIn) {
        actionChain = actionChainIn;
    }

    /**
     * Gets the action chain id.
     * @return the action chain id or null
     */
    public Long getActionChainId() {
        if (getActionChain() != null) {
            return getActionChain().getId();
        }
        return null;
    }

    /**
     * Gets the server.
     *
     * @return the server
     */
    public Server getServer() {
        return server;
    }

    /**
     * Sets the server.
     *
     * @param serverIn the new server
     */
    public void setServer(Server serverIn) {
        server = serverIn;
    }

    /**
     * Gets the server id.
     * @return the server id
     */
    public Long getServerId() {
        if (getServer() != null) {
            return getServer().getId();
        }
        return null;
    }

    /**
     * Gets the sort order.
     *
     * @return the sort order
     */
    public Integer getSortOrder() {
        return sortOrder;
    }

    /**
     * Sets the sort order.
     *
     * @param sortOrderIn the new sort order
     */
    public void setSortOrder(Integer sortOrderIn) {
        sortOrder = sortOrderIn;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public boolean equals(final Object other) {
        if (!(other instanceof ActionChainEntry)) {
            return false;
        }
        ActionChainEntry otherActionChainEntry = (ActionChainEntry) other;

        return new EqualsBuilder()
            .append(getActionId(), otherActionChainEntry.getActionId())
            .append(getActionChainId(), otherActionChainEntry.getActionChainId())
            .append(getServerId(), otherActionChainEntry.getServerId())
            .append(getSortOrder(), otherActionChainEntry.getSortOrder()).isEquals();
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public int hashCode() {
        return new HashCodeBuilder()
            .append(getActionId())
            .append(getActionChainId())
            .append(getServerId())
            .append(getSortOrder())
            .toHashCode();
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public String toString() {
        return new ToStringBuilder(this)
        .append("id", getId())
        .append("sortOrder", getSortOrder())
        .toString();
    }
}
