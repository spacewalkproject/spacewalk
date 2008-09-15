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

import org.bouncycastle.bcpg.ArmoredInputStream;
import org.bouncycastle.jce.provider.BouncyCastleProvider;
import org.bouncycastle.openpgp.PGPException;
import org.bouncycastle.openpgp.PGPObjectFactory;
import org.bouncycastle.openpgp.PGPPublicKey;
import org.bouncycastle.openpgp.PGPPublicKeyRingCollection;
import org.bouncycastle.openpgp.PGPSignature;
import org.bouncycastle.openpgp.PGPSignatureList;
import org.bouncycastle.openpgp.PGPUtil;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.security.KeyException;
import java.security.NoSuchProviderException;
import java.security.Security;
import java.security.SignatureException;

/**
 * A GPG public keyring.
 * 
 * @version $Rev$
 */
public class PublicKeyRing {

    static {
        Security.addProvider(new BouncyCastleProvider());
        Security.addProvider(new RhnSecurityProvider());
    }

    private PGPPublicKeyRingCollection keyRing;

    /**
     * Read the key ring from <code>keyRingStream</code>.
     * @param keyRingStream the stream from which the key ring will be read
     * @throws IOException if reading the stream fails
     * @throws KeyException if the keyring can not be created from the stream
     */
    public PublicKeyRing(InputStream keyRingStream) throws IOException, KeyException {
        super();
        try {
            keyRing = new PGPPublicKeyRingCollection(PGPUtil
                    .getDecoderStream(keyRingStream));
        }
        catch (PGPException e) {
            // We recast this as a KeyException so that we don't leak
            // any dependency on bouncycastle here
            throw (KeyException) new KeyException(
                    "Reading the keyring failed - " + e.getMessage())
                    .initCause(e);
        }
    }

    /**
     * Verify that <code>asciiSig</code> is a valid signature for
     * <code>message</code> using this key ring.
     * 
     * @param message the cleartext message
     * @param asciiSig the ASCII armored sigature
     * @return <code>true</code> if the signature was generated from
     * <code>message</code> using one of the private keys corresponding to the
     * public keys on this key ring
     * @throws SignatureException if processing hte signature fails
     */
    public boolean verifySignature(String message, String asciiSig)
        throws SignatureException {
        PGPSignature sig = decodeSignature(asciiSig);
        PGPPublicKey key;
        boolean result = false;
        try {
            key = keyRing.getPublicKey(sig.getKeyID());
            sig.initVerify(key, RhnSecurityProvider.NAME);
            sig.update(message.getBytes());

            result = sig.verify();
        }
        catch (PGPException e) {
            // We recast this as a SignatureException so that we don't leak
            // any dependency on bouncycastle here
            throw (SignatureException) new SignatureException("Verification failed - " +
                    e.getMessage()).initCause(e);
        }
        catch (NoSuchProviderException e) {
            // We define the provider in the static block. Something weird is
            // afoot
            throw (IllegalStateException) new IllegalStateException(
                    "The provider " + RhnSecurityProvider.NAME + 
                    " should be defined").initCause(e);
        }
        return result;
    }

    /**
     * Turn the ASCII armored signature <code>asciiSig</code> into a
     * <code>PGPSignature</code>
     * @param asciiSig an ASCII armored signature
     * @return the signature
     */
    private static PGPSignature decodeSignature(String asciiSig) {
        PGPSignature result = null;
        ByteArrayInputStream bais = new ByteArrayInputStream(asciiSig
                .getBytes());
        try {
            InputStream in = PGPUtil.getDecoderStream(new ArmoredInputStream(
                    bais));
            result = ((PGPSignatureList) new PGPObjectFactory(in).nextObject())
                    .get(0);
            in.close();
        }
        catch (IOException e) {
            // This is so unlikely that we convert it to a runtime exception
            throw (IllegalArgumentException) new IllegalArgumentException(
                    "The string asciiSig is not a valid signature")
                    .initCause(e);
        }
        return result;
    }

}
