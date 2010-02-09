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
package com.redhat.rhn.manager.kickstart.crypto;

import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.kickstart.crypto.CryptoKey;

import java.io.UnsupportedEncodingException;

/**
 * BaseCryptoKeyCommand - base for edit/create CryptKeys
 * @version $Rev$
 */
public abstract class BaseCryptoKeyCommand {
    
    protected CryptoKey key;

    /**
     * Constructor
     */
    public BaseCryptoKeyCommand() {
    }
    
    /**
     * Set the Description on the key
     * @param descIn to set
     */
    public void setDescription(String descIn) {
        this.key.setDescription(descIn);
    }
    
    /**
     * Get the CryptoKey used by this cmd
     * @return CryptoKey instance
     */
    public CryptoKey getCryptoKey() {
        return key;
    }

    /**
     * Set the type of the key
     * @param typeIn label to set.
     */
    public void setType(String typeIn) {
        if (typeIn.equals(KickstartFactory.KEY_TYPE_GPG.getLabel())) {
            this.key.setCryptoKeyType(KickstartFactory.KEY_TYPE_GPG);
        } 
        else if (typeIn.equals(KickstartFactory.KEY_TYPE_SSL.getLabel())) {
            this.key.setCryptoKeyType(KickstartFactory.KEY_TYPE_SSL);
        }
        else {
            throw new IllegalArgumentException("Invalid key type: " + 
                    typeIn + " we support GPG and SSL");
        }
        
    }
    
    /**
     * Get the String type of this Key
     *
     * @return String CryptoKey.label if defined.  Null if not.
     */
    public String getType() {
        if (this.key != null && this.key.getCryptoKeyType() != null) {
            return this.key.getCryptoKeyType().getLabel();
        }
        else {
            return null;
        }
    }
    
    /**
     * Set the contents of the key itself.  Translates
     * the string into a blob. 
     * @param contentsIn to set
     */
    public void setContents(String contentsIn) {
        if (contentsIn != null) {
            try {
                this.key.setKey(contentsIn.getBytes("UTF-8"));
            }
            catch (UnsupportedEncodingException e) {
                throw new IllegalArgumentException("Unsupported encoding!");
            }
        }
    }

    /**
     * Save the key to the DB.
     * @return ValidatorError[] array of errors.
     */
    public ValidatorError[] store() {
        if (this.key.getOrg() != null) {
            CryptoKey foundKey = KickstartFactory.lookupCryptoKey(
                    this.key.getDescription(), this.key.getOrg());
            if (foundKey != null && !foundKey.getId().equals(this.key.getId())) {
                ValidatorError[] retval = new ValidatorError[1];
                retval[0] = new ValidatorError("crypto.key.descinuse");
                return retval;
            }
        }
        KickstartFactory.saveCryptoKey(this.key);
        return null;
    }
    
    
}
