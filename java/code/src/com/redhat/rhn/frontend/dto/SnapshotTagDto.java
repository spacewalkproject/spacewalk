/**
 * Copyright (c) 2009--2012 Red Hat, Inc.
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

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;

import com.redhat.rhn.common.localization.LocalizationService;

/**
 * @version $Rev$
 */
public class SnapshotTagDto extends BaseDto {

    private Long id;
    private String name;
    private Date created;
    private Long ssId;  // snapshot ID
    private boolean selectable;

    /**
     * @return Returns date of creation
     */
    public Date getCreated() {
        return created;
    }

    /**
     * @param createdIn Date of creation to set
     */
    public void setCreated(String createdIn) {
        if (createdIn == null) {
            this.created = null;
        }
        else {
            try {
                this.created = new SimpleDateFormat(
                        LocalizationService.RHN_DB_DATEFORMAT).parse(createdIn);
            }
            catch (ParseException e) {
                throw new IllegalArgumentException("lastCheckin must be of the: [" +
                        LocalizationService.RHN_DB_DATEFORMAT + "] it was: " + createdIn);
            }
        }
    }

    /**
     * @return SnapshotTagName
     */
    public String getName() {
        return name;
    }

    /**
     * @param nameIn SnapshotTagName
     */
    public void setName(String nameIn) {
        this.name = nameIn;
    }

    /**
     * @return snapshot ID
     */
    public Long getSsId() {
        return ssId;
    }

    /**
     * @param ssIdIn snapshot ID
     */
    public void setSsId(Long ssIdIn) {
        this.ssId = ssIdIn;
    }

    /**
     * @return SnapshotTag ID
     */
    public Long getId() {
        return id;
    }

    /**
     * @param idIn SnapshotTag ID
     */
    public void setId(Long idIn) {
        this.id = idIn;
    }

    /**
    *
    * {@inheritDoc}
    */
   public String getSelectionKey() {
       return String.valueOf(getId());
   }

   /**
    * For compatibility reasons with PostgreSQL we accept also Integer.
    *
    * @param selectableIn Whether a server is selectable one if selectable,
    * null if not selectable
    */
   public void setSelectable(Integer selectableIn) {
       selectable = (selectableIn != null);
   }

   /**
    * @param selectableIn Whether a server is selectable one if selectable,
    * null if not selectable
    */
   public void setSelectable(Long selectableIn) {
       selectable = (selectableIn != null);
   }

   /**
    * Tells whether a system is selectable for the SSM
    * All management and provisioning entitled servers are true
    * They are false otherwise
    * @return whether the current system is UI selectable
    */
   @Override
   public boolean isSelectable() {
       return selectable;
   }

}
