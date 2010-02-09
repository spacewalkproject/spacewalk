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
package com.redhat.rhn.domain.user;

import org.apache.commons.lang.builder.CompareToBuilder;
import org.apache.commons.lang.builder.EqualsBuilder;
import org.apache.commons.lang.builder.HashCodeBuilder;
import org.apache.commons.lang.builder.ToStringBuilder;

import java.util.Date;

/**
 * StateChange
 * @version $Rev$
 */
public class StateChange implements Comparable<StateChange> {

    private Long id;
    private Date date = new Date();
    private User user;
    private User changedBy;
    private State state;
    
    
    /**
     * @return Returns the date.
     */
    public Date getDate() {
        return date;
    }
    
    /**
     * @param d The date to set.
     */
    public void setDate(Date d) {
        this.date = d;
    }
    
    /**
     * @return Returns the changedBy.
     */
    public User getChangedBy() {
        return changedBy;
    }
    
    /**
     * @param d The changedBy to set.
     */
    public void setChangedBy(User d) {
        this.changedBy = d;
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
     * @return Returns the state.
     */
    public State getState() {
        return state;
    }
    
    /**
     * @param s The state to set.
     */
    public void setState(State s) {
        this.state = s;
    }
    
    /**
     * @return Returns the user.
     */
    public User getUser() {
        return user;
    }
    
    /**
     * @param u The user to set.
     */
    public void setUser(User u) {
        this.user = u;
    }
    
    /**
     * {@inheritDoc}
     */
    @Override
    public boolean equals(Object o) {
        if (!(o instanceof StateChange)) {
            return false;
        }
        StateChange that = (StateChange) o;
        EqualsBuilder builder = new EqualsBuilder();

        builder.append(this.getId(), that.getId());
        builder.append(this.getDate(), that.getDate());
        builder.append(this.getState(), that.getState());
        builder.append(this.getChangedBy(), that.getChangedBy());
        
        builder.append(this.getUser(), that.getUser());

        return builder.isEquals();
    }
    /**
     * {@inheritDoc}
     */
    @Override
    public int hashCode() {
        HashCodeBuilder builder = new HashCodeBuilder();
        builder.append(this.getId());
        builder.append(this.getDate());
        builder.append(this.getState());
        builder.append(this.getUser());
        builder.append(this.getChangedBy());
        return builder.toHashCode();

    }
    
    /**
     * {@inheritDoc}
     */
    public int compareTo(StateChange rhs) {
        CompareToBuilder builder = new CompareToBuilder();
        builder.append(getDate(), rhs.getDate());
        builder.append(getId(), rhs.getId());
        builder.append(this.getState(), rhs.getState());
        builder.append(this.getUser(), rhs.getUser());
        builder.append(this.getChangedBy(), rhs.getChangedBy());
        return builder.toComparison();
    }
    
    /**
     * {@inheritDoc}
     */
    @Override
    public String toString() {
        return ToStringBuilder.reflectionToString(this);
    }
}
