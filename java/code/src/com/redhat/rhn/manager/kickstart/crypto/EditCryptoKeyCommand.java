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

import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.user.User;

/**
 * CryptoKeyCommand
 * @version $Rev$
 */
public class EditCryptoKeyCommand extends BaseCryptoKeyCommand {
    
    /**
     * Create new Command and Key
     * @param currentUser who wants to create the key
     * @param keyId of key to lookup.
     */
    public EditCryptoKeyCommand(User currentUser, Long keyId) {
        super();
        this.key = KickstartFactory.lookupCryptoKeyById(keyId, currentUser.getOrg());
    }

    /**
     * Creates a new edit command, loading the key by the given description and user's org.
     *
     * @param currentUser used to identify the org under which the key is;
     *                    cannot be <code>null</code>
     * @param description used to identify the key; cannot be <code>null</code> 
     */
    public EditCryptoKeyCommand(User currentUser, String description) {
        super();

        if (currentUser == null) {
            throw new IllegalArgumentException("currentUser cannot be null");
        }

        if (description == null) {
            throw new IllegalArgumentException("description cannot be null");
        }

        this.key = KickstartFactory.lookupCryptoKey(description, currentUser.getOrg());
    }
}
