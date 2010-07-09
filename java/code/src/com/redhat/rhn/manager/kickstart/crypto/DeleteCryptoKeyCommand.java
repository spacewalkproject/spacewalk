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
import com.redhat.rhn.domain.user.User;

/**
 * DeleteCryptoKeyCommand
 * @version $Rev$
 */
public class DeleteCryptoKeyCommand extends BaseCryptoKeyCommand {

    /**
     * Create new Command and Key
     * @param currentUser who wants to create the key
     * @param keyId of key to lookup.
     */
    public DeleteCryptoKeyCommand(User currentUser, Long keyId) {
        super();
        this.key = KickstartFactory.lookupCryptoKeyById(keyId, currentUser.getOrg());
    }

    /**
     * Creates a new delete command, loading the key by the given description
     * and user's org.
     *
     * @param currentUser used to identify the org under which the key is;
     *                    cannot be <code>null</code>
     * @param description used to identify the key; cannot be <code>null</code>
     */
    public DeleteCryptoKeyCommand(User currentUser, String description) {
        super();

        if (currentUser == null) {
            throw new IllegalArgumentException("currentUser cannot be null");
        }

        if (description == null) {
            throw new IllegalArgumentException("description cannot be null");
        }

        this.key = KickstartFactory.lookupCryptoKey(description, currentUser.getOrg());
    }

    /**
     * {@inheritDoc}
     */
    public void setDescription(String descIn) {
       // no op
    }

    /**
     * {@inheritDoc}
     */
    public void setType(String typeIn) {
        // no op
    }

    /**
     * {@inheritDoc}
     */
    public void setContents(String contentsIn) {
        // no op
    }

    /**
     * remove the key from the DB.
     * store() is counter-intuitive but it is done
     * this way so CryptoKeyDeleteAction can reuse
     * BaseCryptoKeyEditAction
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

        KickstartFactory.removeCryptoKey(this.key);
        return null;
    }
}
