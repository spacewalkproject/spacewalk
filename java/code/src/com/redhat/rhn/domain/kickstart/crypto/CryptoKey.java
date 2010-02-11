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
package com.redhat.rhn.domain.kickstart.crypto;

import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.domain.Identifiable;
import com.redhat.rhn.domain.org.Org;

import org.apache.commons.lang.StringUtils;
import org.hibernate.Hibernate;

import java.io.UnsupportedEncodingException;
import java.sql.Blob;

/**
 * CryptoKey - Class representation of the table rhnCryptoKey.
 * @version $Rev: 1 $
 */
public class CryptoKey implements Identifiable {

    private Long id;
    private String description;
    private byte[] key;
    
    private CryptoKeyType cryptoKeyType;
    private Org org;
    
    
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
     * Getter for description 
     * @return String to get
    */
    public String getDescription() {
        return this.description;
    }

    /** 
     * Setter for description 
     * @param descriptionIn to set
    */
    public void setDescription(String descriptionIn) {
        this.description = descriptionIn;
    }

    /** 
     * Getter for key 
     * @return Blob to get
    */
    private Blob getKeyBlob() {
        if (this.key == null) {
            return null;
        }
        else {
            return Hibernate.createBlob(this.key);
        }
    }

    /** 
     * Setter for key 
     * @param keyIn to set
    */
    private void setKeyBlob(Blob keyIn) {
        this.key = HibernateFactory.blobToByteArray(keyIn);
    }

    
    /**
     * @return Returns the cryptoKeyType.
     */
    public CryptoKeyType getCryptoKeyType() {
        return cryptoKeyType;
    }

    
    /**
     * @param cryptoKeyTypeIn The cryptoKeyType to set.
     */
    public void setCryptoKeyType(CryptoKeyType cryptoKeyTypeIn) {
        this.cryptoKeyType = cryptoKeyTypeIn;
    }
    
    /**
     * 
     * @return true if this is a SSL key
     */
    public boolean isSSL() {
        return this.getCryptoKeyType().getLabel().equals("SSL");
    }
    
    /**
     * 
     * @return if this is a GPG key 
     */
    public boolean isGPG() {
        return this.getCryptoKeyType().getLabel().equals("GPG");
    }
    
    /**
     * @return Returns the org.
     */
    public Org getOrg() {
        return org;
    }

    
    /**
     * @param orgIn The org to set.
     */
    public void setOrg(Org orgIn) {
        this.org = orgIn;
    }

    
    /**
     * @return Returns the key.
     */
    public byte[] getKey() {
        return key;
    }

    
    /**
     * @param keyIn The key to set.
     */
    public void setKey(byte[] keyIn) {
        this.key = keyIn;
    }
    
    /**
     * Get a string version of this key.  Convenience method.
     * 
     * @return String version of the key.
     */
    public String getKeyString() {
        try {
            if (this.key != null) {
                String retval = new String(this.key, "UTF-8");
                if (!StringUtils.isEmpty(retval)) {
                    return retval;
                }
            }
        }
        catch (UnsupportedEncodingException e) {
            throw new RuntimeException(e);
        }
        return null;
    }

}
