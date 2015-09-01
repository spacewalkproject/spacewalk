/**
 * Copyright (c) 2015 Red Hat, Inc.
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
package com.redhat.rhn.domain.common;

import org.apache.commons.lang.builder.EqualsBuilder;
import org.apache.commons.lang.builder.HashCodeBuilder;

import com.redhat.rhn.domain.BaseDomainHelper;

/**
 * ResetPassword
 * @version $Rev$
 */
public class ResetPassword extends BaseDomainHelper {

    private Long id;
    private String token;
    private Long userId;
    private boolean isValid = true;

    public ResetPassword() {
        super();
    }

    public ResetPassword(Long inUserId, String inToken) {
        super();
        userId = inUserId;
        token = inToken;
    }
    /**
     * @return the id
     */
    public Long getId() {
        return id;
    }


    /**
     * @param id the id to set
     */
    public void setId(Long id) {
        this.id = id;
    }


    /**
     * @return the token
     */
    public String getToken() {
        return token;
    }


    /**
     * @param token the token to set
     */
    public void setToken(String token) {
        this.token = token;
    }


    /**
     * @return the userId
     */
    public Long getUserId() {
        return userId;
    }


    /**
     * @param userId the user-id to set
     */
    public void setUserId(Long userId) {
        this.userId = userId;
    }


    /**
     * @return the isValid
     */
    public boolean getIsValid() {
        return isValid;
    }

    /**
     * @return  isValid
     */
    public boolean isValid() {
        return getIsValid();
    }


    /**
     * @param isValid the isValid to set
     */
    public void setIsValid(boolean isValid) {
        this.isValid = isValid;
    }

    /* (non-Javadoc)
     * @see java.lang.Object#hashCode()
     */
    @Override
    public int hashCode() {
        return new HashCodeBuilder().append(this.getId())
                        .append(this.getUserId())
                        .append(this.getToken())
                        .toHashCode();
    }


    /* (non-Javadoc)
     * @see java.lang.Object#equals(java.lang.Object)
     */
    @Override
    public boolean equals(Object obj) {
        if (this == obj)
            return true;
        if (obj == null)
            return false;
        if (getClass() != obj.getClass())
            return false;
        ResetPassword other = (ResetPassword) obj;
        return new EqualsBuilder().append(this.getId(), other.getId())
                                  .append(this.getUserId(), other.getUserId())
                                  .append(this.getToken(), other.getToken())
                                  .isEquals();
    }


    /* (non-Javadoc)
     * @see java.lang.Object#toString()
     */
    @Override
    public String toString() {
        return new StringBuilder("ResetPassword [id=")
                                .append(getId().toString())
                                .append(", token=")
                                .append(getToken())
                                .append(", userId=")
                                .append(userId)
                                .append(", isValid=")
                                .append(isValid())
                                .append("]")
                                .toString();

    }
}
