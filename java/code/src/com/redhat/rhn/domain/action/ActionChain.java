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

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.domain.BaseDomainHelper;
import com.redhat.rhn.domain.user.User;

import org.apache.commons.lang.builder.EqualsBuilder;
import org.apache.commons.lang.builder.HashCodeBuilder;
import org.apache.commons.lang.builder.ToStringBuilder;

import java.util.HashSet;
import java.util.Set;

/**
 * POJO for a rhnActionChain row.
 * @author Silvio Moioli <smoioli@suse.de>
 * @version $Rev$
 */
public class ActionChain extends BaseDomainHelper {

    /** The id. */
    private Long id;

    /** The label. */
    private String label;

    /** The user. */
    private User user;

    /** The entries. */
    private Set<ActionChainEntry> entries;

    /**
     * Default constructor.
     */
    public ActionChain() {
        entries = new HashSet<ActionChainEntry>();
    }

    /**
     * Gets the id.
     * @return the id
     */
    public Long getId() {
        return id;
    }

    /**
     * Sets the id.
     * @param idIn the new id
     */
    public void setId(Long idIn) {
        id = idIn;
    }

    /**
     * Gets the label.
     * @return the label
     */
    public String getLabel() {
        return label;
    }

    /**
     * Sets the label.
     * @param labelIn the new label
     */
    public void setLabel(String labelIn) {
        label = labelIn;
    }

    /**
     * Gets the user.
     * @return the user
     */
    public User getUser() {
        return user;
    }

    /**
     * Sets the user.
     * @param userIn the new user
     */
    public void setUser(User userIn) {
        user = userIn;
    }

    /**
     * Gets the entries.
     *
     * @return the entries
     */
    public Set<ActionChainEntry> getEntries() {
        return entries;
    }

    /**
     * Sets the entries.
     *
     * @param entriesIn the new entries
     */
    public void setEntries(Set<ActionChainEntry> entriesIn) {
        entries = entriesIn;
    }

    /**
     * Gets the creation date in localized form
     * @return the localized date
     */
    public String getLocalizedCreated() {
        return LocalizationService.getInstance().formatShortDate(getCreated());
    }

    /**
     * Gets the creation date in localized form
     * @return the localized date
     */
    public String getLocalizedModified() {
        return LocalizationService.getInstance().formatShortDate(getModified());
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public boolean equals(Object other) {
        if (!(other instanceof ActionChain)) {
            return false;
        }
        ActionChain otherActionChain = (ActionChain) other;
        return new EqualsBuilder()
            .append(getLabel(), otherActionChain.getLabel())
            .isEquals();
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public int hashCode() {
        return new HashCodeBuilder()
            .append(getLabel())
            .toHashCode();
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public String toString() {
        return new ToStringBuilder(this)
        .append("id", getId())
        .append("label", getLabel())
        .toString();
    }
}
