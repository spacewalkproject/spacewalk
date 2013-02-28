/**
 * Copyright (c) 2013 Red Hat, Inc.
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

import com.redhat.rhn.common.localization.LocalizationService;

import java.util.Date;

/**
 * SoftwareCrashDto
 * @version $Rev$
 */
public class SoftwareCrashDto extends BaseDto {

    private Long id;
    private String crash;
    private Long count;
    private String component;
    private Date modified;

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
     * @return Returns the crash.
     */
    public String getCrash() {
        return crash;
    }

    /**
     * @param crashIn The crash to set.
     */
    public void setCrash(String crashIn) {
        crash = crashIn;
    }

    /**
     * @return Returns the count.
     */
    public Long getCount() {
        return count;
    }

    /**
     * @param countIn The count to set.
     */
    public void setCount(Long countIn) {
        count = countIn;
    }

    /**
     * @return Returns the component.
     */
    public String getComponent() {
        return component;
    }

    /**
     * @param componentIn The component to set.
     */
    public void setComponent(String componentIn) {
        component = componentIn;
    }

    /**
     * @return Returns the modified string.
     */
    public String getModified() {
        return LocalizationService.getInstance().formatDate(modified);
    }

    /**
     * @return Returns the modified sort object.
     */
    public Date getModifiedObject() {
        return modified;
    }

    /**
     * @param modifiedIn The modified to set.
     */
    public void setModified(Date modifiedIn) {
        modified = modifiedIn;
    }

}
