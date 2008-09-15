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

package com.redhat.rhn.common.cert;
import org.bouncycastle.crypto.digests.RIPEMD160Digest;
import org.bouncycastle.crypto.signers.DSASigner;
import org.bouncycastle.jce.provider.JDKDSASigner;
import org.bouncycastle.jce.provider.JDKKeyFactory;

import java.security.Provider;

/**
 * This JCE provider exists solely to hack around the fact that
 * the bouncycastle provider does not offer <code>RIPEMD160 + DSA</code>
 * signature processing. It cobbles the existing bits from bouncycastle
 * together to add processing of these signatures.
 * 
 * TODO: Generate a patch for bouncycastle to add <code>RIPEMD160 + DSA</code>
 * signatures to obviate the need for this class.
 * @version $Rev$
 */
final class RhnSecurityProvider extends Provider {
    
    /**
     * The name under which this provider registers
     */
    public static final String NAME = "RHNSP";
    private static final String INFO = 
        "RHN Security Provider (provides RIPEMD160WithDSA signatures)";

    /**
     * Create the provider
     */
    public RhnSecurityProvider() {
        super(NAME, 1.0, INFO);
        put("KeyFactory.DSA", JDKKeyFactory.DSA.class.getName());
        put("Signature.RIPEMD160WithDSA", RIPEMD160WithDSA.class.getName());
    }

    /**
     * The signer that combines <code>RIPEMD160</code> hashing
     * with DSA signing.
     */
    public static class RIPEMD160WithDSA extends JDKDSASigner {

        public RIPEMD160WithDSA() {
            super("RIPEMD160WithDSA", new RIPEMD160Digest(), new DSASigner());
        }

    }

}
