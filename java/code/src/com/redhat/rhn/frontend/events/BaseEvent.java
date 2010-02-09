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
package com.redhat.rhn.frontend.events;

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.domain.user.User;

import java.util.Locale;

import javax.servlet.http.HttpServletRequest;

/**
 * BaseEvent - basic superclass that holds common event members.
 * 
 * @version $Rev$
 */
public abstract class BaseEvent {

    private HttpServletRequest request;
    private User user;

    /**
     * Set the request for this event.
     * @param reqIn Request where error has occurred.
     */
    public void setRequest(HttpServletRequest reqIn) {
        this.request = reqIn;
    }

    /**
     * Set the User for this event
     * @param userIn User for this event
     */
    public void setUser(User userIn) {
        this.user = userIn;
    }

    
    /**
     * @return Returns the request.
     */
    public HttpServletRequest getRequest() {
        return request;
    }

    
    /**
     * @return Returns the user.
     */
    public User getUser() {
        return user;
    }
    
    /**
     * 
     * @return return the Users locale or default if not set 
     */
    public Locale getUserLocale() {
        //TODO: when we support translated emails, remove this stub
        //String loc = (getUser() == null) ? null : getUser().getPreferredLocale();
        //return (loc == null) ? LocalizationService.DEFAULT_LOCALE : new Locale(loc);
        return LocalizationService.DEFAULT_LOCALE;
    }

}
