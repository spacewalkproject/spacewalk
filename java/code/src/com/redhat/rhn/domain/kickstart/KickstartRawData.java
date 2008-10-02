/**
 * Copyright (c) 2008 Red Hat, Inc.
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

package com.redhat.rhn.domain.kickstart;

import com.redhat.rhn.common.hibernate.HibernateFactory;

import java.sql.Blob;


/**
 * @author paji
 * KickstartRawData
 * @version $Rev$
 */
public class KickstartRawData extends KickstartData {
    private Blob dataBlob;
    
    /**
     * the actual raw data asa string. ....
     * @return the raw data
     */
    public String getData() {
        return HibernateFactory.blobToString(getDataBlob());
    }
    
    /**
     * set the raw data info.
     * @param data raw data
     */
    public void setData(String data) {
        setDataBlob(HibernateFactory.stringToBlob(data));
    }
    
    /**
     * internal for hibernate only
     * @return the dataBlob
     */
    Blob getDataBlob() {
        return dataBlob;
    }

    
    /**
     * internal for hibernate only
     * @param blob the dataBlob to set
     */
    void setDataBlob(Blob blob) {
        this.dataBlob = blob;
    }
    
    /**
     * Returns true if this is a 
     * raw mode data .
     * @return true or false.
     */
    @Override
    public boolean isRawData() {
        return true;
    }
    
}
