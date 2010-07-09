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
package com.redhat.rhn.domain.monitoring.notification;



/**
 * MethodType - Class representation of the table rhn_method_types.
 * @version $Rev: 1 $
 */
public class MethodType {

    private Long id;
    private String methodTypeName;
    private Long notificationFormatId;
    /**
     * Getter for id
     * @return Long to get
    */
    public Long getId() {
        return this.id;
    }

    /**
     * Setter for id
     * @param idIn to set
    */
    public void setId(Long idIn) {
        this.id = idIn;
    }

    /**
     * Getter for methodTypeName
     * @return String to get
    */
    public String getMethodTypeName() {
        return this.methodTypeName;
    }

    /**
     * Setter for methodTypeName
     * @param methodTypeNameIn to set
    */
    public void setMethodTypeName(String methodTypeNameIn) {
        this.methodTypeName = methodTypeNameIn;
    }

    /**
     * Getter for notificationFormatId
     * @return Long to get
    */
    public Long getNotificationFormatId() {
        return this.notificationFormatId;
    }

    /**
     * Setter for notificationFormatId
     * @param notificationFormatIdIn to set
    */
    public void setNotificationFormatId(Long notificationFormatIdIn) {
        this.notificationFormatId = notificationFormatIdIn;
    }

}
