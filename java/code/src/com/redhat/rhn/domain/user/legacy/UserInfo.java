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

package com.redhat.rhn.domain.user.legacy;

import com.redhat.rhn.domain.user.RhnTimeZone;
import com.redhat.rhn.domain.user.User;

import java.util.Date;

/**
 * UserInfo represents the bean version of the DB table
 * RHNUSERINFO
 * @version $Rev: 61184 $
 */
public class UserInfo extends AbstractUserChild {
    private int pageSize;
    private int emailNotify;
    private boolean usePamAuthentication;
    private String showSystemGroupList;
    private String preferredLocale;
    private Date lastLoggedIn;
    private RhnTimeZone timeZone;
    private User user;

    /**
     * Create a new empty user
     */
    protected UserInfo() {
    }

    protected void setUser(User u) {
        user = u;
    }

    protected User getUser() {
        return user;
    }

    /**
     * Getter for pageSize
     * @return pageSize
     */
    public int getPageSize() {
        return this.pageSize;
    }

    /**
     * Setter for pageSize
     * @param pageSizeIn New value for pageSize
     */
    public void setPageSize(int pageSizeIn) {
        this.pageSize = pageSizeIn;
    }

    /**
     * Getter for usePamAuthentication
     * @return usePamAuthentication
     */
    public boolean getUsePamAuthentication() {
        return this.usePamAuthentication;
    }

    /**
     * Setter for usePamAuthentication
     * @param usePamAuthenticationIn New value for usePamAuthentication
     */
    public void setUsePamAuthentication(boolean usePamAuthenticationIn) {
        this.usePamAuthentication = usePamAuthenticationIn;
    }

    /**
     * Getter for showSystemGroupList
     * @return showSystemGroupList
     */
    public String getShowSystemGroupList() {
        if (showSystemGroupList == null ||
                showSystemGroupList.equals("")) {
            showSystemGroupList = "N";
        }
        return this.showSystemGroupList;
    }

    /**
     * Setter for showSystemGroupList
     * @param showSystemGroupListIn New value for showSystemGroupList
     */
    public void setShowSystemGroupList(String showSystemGroupListIn) {
        this.showSystemGroupList = showSystemGroupListIn;
    }

    /**
     * Getter for lastLoggedIn
     * @return lastLoggedIn
     */
    public Date getLastLoggedIn() {
        return this.lastLoggedIn;
    }

    /**
     * Setter for lastLoggedIn
     * @param lastLoggedInIn New value for lastLoggedIn
     */
    public void setLastLoggedIn(Date lastLoggedInIn) {
        this.lastLoggedIn = lastLoggedInIn;
    }

    /**
     * @return Returns the timeZone.
     */
    public RhnTimeZone getTimeZone() {
        return timeZone;
    }
    /**
     * @param timeZoneIn The timeZone to set.
     */
    public void setTimeZone(RhnTimeZone timeZoneIn) {
        this.timeZone = timeZoneIn;
    }

    /**
     * Returns user's preferred locale
     * @return locale
     */
    public String getPreferredLocale() {
        return this.preferredLocale;
    }

    /**
     * Sets user's preferred locale
     * @param locale user's preferred locale
     */
    public void setPreferredLocale(String locale) {
        this.preferredLocale = locale;
    }

    /**
     * Getter for emailNotify
     * @return emailNotify
     */
    public int getEmailNotify() {
        return this.emailNotify;
    }

    /**
     * Setter for emailNotify
     * @param emailNotifyIn New value for emailNotify
     */
    public void setEmailNotify(int emailNotifyIn) {
        this.emailNotify = emailNotifyIn;
    }
}
