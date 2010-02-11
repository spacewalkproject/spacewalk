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
package com.redhat.rhn.frontend.dto;


/**
 * ReportingUser
 * @version $Rev$
 */
public class ReportingUser {

    private Long id;
    private String emailAddress;
    private String login;
    
    /**
     * @return Returns the emailAddress.
     */
    public String getAddress() {
        return emailAddress;
    }
    
    /**
     * @param emailAddressIn The emailAddress to set.
     */
    public void setAddress(String emailAddressIn) {
        emailAddress = emailAddressIn;
    }
    
    /**
     * @return Returns the id.
     */
    public Long getId() {
        return id;
    }
    
    /**
     * @param idIn The id to set.
     */
    public void setId(Long idIn) {
        id = idIn;
    }
    
    /**
     * returns id as a Long.
     * @return id as a Long
     */
    public Long idAsLong() {
        return new Long(id.longValue());
    }

    
    /**
     * @return Returns the login.
     */
    public String getLogin() {
        return login;
    }

    
    /**
     * @param loginIn The login to set.
     */
    public void setLogin(String loginIn) {
        login = loginIn;
    }
}
