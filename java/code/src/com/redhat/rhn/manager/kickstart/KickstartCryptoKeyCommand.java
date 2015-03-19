/**
 * Copyright (c) 2009--2015 Red Hat, Inc.
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
package com.redhat.rhn.manager.kickstart;

import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.kickstart.crypto.CryptoKey;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.manager.kickstart.crypto.NoSuchCryptoKeyException;

import java.util.HashSet;
import java.util.List;
import java.util.Set;

/**
 * KickstartCryptoKeyCommand - class for updating the crypto keys
 * associated with a kickstart profile
 * @version $Rev$
 */
public class KickstartCryptoKeyCommand extends BaseKickstartCommand {

    /**
     * Construct a new Command.
     * @param ksidIn of the Kicstart you want to edit
     * @param userIn who wants to edit the profile
     */
    public KickstartCryptoKeyCommand(Long ksidIn, User userIn) {
        super(ksidIn, userIn);
    }

    /**
     * Add a List of cryptoKey objects to the KickstartData
     * based on the Long IDs passed in on the list.
     * @param ids to add
     */
    public void addKeysByIds(List<Long> ids) {
        for (Long id : ids) {
            CryptoKey key = KickstartFactory.lookupCryptoKeyById(id, this.user.getOrg());
            ksdata.addCryptoKey(key);
        }
    }

    /**
     * Adds a list of crypto keys to the kickstart profile
     * where the list is a series of key descriptions.
     *
     * @param descriptions identifies all of the keys to associate
     * @param org          org in which the keys are located
     */
    public void addKeysByDescriptionAndOrg(List<String> descriptions, Org org) {
        for (String description : descriptions) {
            CryptoKey key = KickstartFactory.lookupCryptoKey(description, org);
            if (key == null) {
                throw new NoSuchCryptoKeyException(description);
            }
            ksdata.addCryptoKey(key);
        }
    }

    /**
     * Removes a list of crypto keys from the kickstart profile
     * where the list is a series of key descriptions.
     *
     * @param descriptions identifies all of the keys to associate
     * @param org          org in which the keys are located
     */
    public void removeKeysByDescriptionAndOrg(List<String> descriptions, Org org) {
        for (String description : descriptions) {
            CryptoKey key = KickstartFactory.lookupCryptoKey(description, org);
            ksdata.removeCryptoKey(key);
        }
    }

    /**
     * Remove the CryptoKeys from this Kickstart.  Takes
     * in a List of Long ids.
     * @param ids List of Long crypto key  IDs.
     */
    public void removeKeysById(List<Long> ids) {
        for (Long id : ids) {
            CryptoKey key = KickstartFactory.lookupCryptoKeyById(id, this.user.getOrg());
            ksdata.removeCryptoKey(key);
        }
    }

    /**
     * Get the Set of CryptoKeys associated with this Profile.  Returns
     * EMPTY_SET if null/undefined.
     * @return Set of CryptoKeys
     */
    public Set<CryptoKey> getCryptoKeys() {
        if (ksdata.getCryptoKeys() != null) {
            return ksdata.getCryptoKeys();
        }
        return new HashSet<CryptoKey>();
    }

}
