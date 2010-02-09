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
package com.redhat.rhn.common.client;

import org.apache.commons.digester.Digester;
import org.xml.sax.SAXException;

import java.io.IOException;
import java.io.InputStream;
import java.io.Reader;
import java.net.URL;
import java.util.ArrayList;

/**
 * ClientCertificateDigester
 * @version $Rev$
 */
public class ClientCertificateDigester {

    private ClientCertificateDigester() { }
    
    private static void configureDigester(Digester digester) {
        digester.setValidating(false);
        
        digester.addObjectCreate("params", ClientCertificate.class);
        digester.addObjectCreate("*/param/value/struct/member/", Member.class);
        digester.addCallMethod("*/param/value/struct/member/name",
                "setName", 0);
        digester.addCallMethod("*/param/value/struct/member/value/string",
                "addValue", 0);
        digester.addObjectCreate("*/param/value/struct/member/value/array",
                ArrayList.class);
        digester.addCallMethod(
                "*/param/value/struct/member/value/array/data/value/string",
                "add", 0);
        digester.addSetNext("*/param/value/struct/member/value/array",
                "setValues");
        digester.addSetNext("*/param/value/struct/member", "addMember");
    }
    
    /**
     * Creates a ClientCertificate from the given URL.
     * @param url to client certificate
     * @return a ClientCertificate
     * @throws IOException thrown if there is a problem reading the certificate.
     * @throws SAXException thrown if there is a problem reading the certificate.
     */
    public static ClientCertificate buildCertificate(URL url)
        throws IOException, SAXException {
        
        if (url == null) {
            throw new IllegalArgumentException("URL is null, your definition " +
                    "tag probably points to a non existing file.");
        }
        
        return ClientCertificateDigester.buildCertificate(url.openStream());
    }
    
    /**
     * Creates a ClientCertificate from the given inputstream.
     * @param is to client certificate
     * @return a ClientCertificate
     * @throws IOException thrown if there is a problem reading the certificate.
     * @throws SAXException thrown if there is a problem reading the certificate.
     */
    public static ClientCertificate buildCertificate(InputStream is)
        throws IOException, SAXException {
        
        Digester digester = new Digester();
        configureDigester(digester);
        
        return (ClientCertificate)digester.parse(is);
    }
    
    /**
     * @param rdr to client certificate
     * @return a ClientCertificate
     * @throws IOException thrown if there is a problem reading the certificate.
     * @throws SAXException thrown if there is a problem reading the certificate.
     */
    public static ClientCertificate buildCertificate(Reader rdr)
        throws IOException, SAXException {
        
        Digester digester = new Digester();
        configureDigester(digester);
        
        return (ClientCertificate)digester.parse(rdr);
    }
}
