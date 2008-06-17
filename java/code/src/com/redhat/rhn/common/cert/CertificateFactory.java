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

import org.jdom.Document;
import org.jdom.Element;
import org.jdom.JDOMException;
import org.jdom.input.SAXBuilder;

import java.io.File;
import java.io.IOException;
import java.io.StringReader;
import java.net.URL;
import java.util.HashMap;
import java.util.List;

/**
 * A class for parsing satellite certificates from their
 * XML form. The XML format is identical to the one used by the
 * perl code.
 * 
 * @version $Rev$
 */
public class CertificateFactory {
    
    private static final String ELEM_SIGNATURE = "rhn-cert-signature";
    private static final String ELEM_FIELD = "rhn-cert-field";
    private static final String ELEM_CERT = "rhn-cert";

    private static final FieldExtractor[] FIELD_EXTRACTORS = {
            new SimpleExtractor("product", true),
            new SimpleExtractor("owner", true),
            new SimpleExtractor("issued", true),
            new SimpleExtractor("expires", true),
            new SimpleExtractor("slots", true),
            new SimpleExtractor("monitoring-slots", "monitoringSlots"),
            new SimpleExtractor("provisioning-slots", "provisioningSlots"),
            new SimpleExtractor("virtualization_host", "virtualizationSlots"),
            new SimpleExtractor("virtualization_host_platform", 
                                              "virtualizationPlatformSlots"),
            new SimpleExtractor("nonlinux-slots", "nonlinuxSlots"),
            new SimpleExtractor("satellite-version", "satelliteVersion"),
            new SimpleExtractor("generation"),
            new ChannelFamilyExtractor("channel-families") };

    private static final HashMap FIELD_MAP = new HashMap();

    static {
        for (int i = 0; i < FIELD_EXTRACTORS.length; i++) {
            FIELD_MAP.put(FIELD_EXTRACTORS[i].getFieldName(),
                    FIELD_EXTRACTORS[i]);
        }
    }

    private CertificateFactory() { }

    /**
     * Parse the certificate from <code>certString</code>.
     * @param certString valid Spacewalk Certificate in string form
     * @return the certificate from <code>certString</code>
     * @throws JDOMException XML parsing fails
     * @throws IOException unknown
     */
    public static Certificate read(String certString) throws JDOMException, IOException {
        return readDocument(new SAXBuilder().build(new StringReader(certString)),
                            certString);
    }
    /**
     * Parse a certificate from <code>file</code>. The file must contain
     * the certificate in XML form.
     * 
     * @param file the file with the XML certificate
     * @return the certificate from <code>fle</code>
     * @throws JDOMException if parsing the XML fails
     * @throws IOException if reading the file fails
     */
    public static Certificate read(File file) throws JDOMException, IOException {
        return readDocument(new SAXBuilder().build(file), file.getAbsolutePath());
    }

    /**
     * Parse a certificate from the contents of <code>url</code>. The file must contain
     * the certificate in XML form.
     * 
     * @param url the URL at which the XML certificate is located
     * @return the certificate from <code>fle</code>
     * @throws JDOMException if parsing the XML fails
     * @throws IOException if reading the contents of <code>url</code> fails
     */
    public static Certificate read(URL url) throws JDOMException, IOException {
        return readDocument(new SAXBuilder().build(url), url.toExternalForm());
    }
    
    private static Certificate readDocument(Document doc, String source) 
        throws JDOMException {
        Certificate result = new Certificate();
        Element root = doc.getRootElement();
        if (!ELEM_CERT.equals(root.getName())) {
            throw new JDOMException("Expected root element in " + source +
                    " to be " + ELEM_CERT + " but found " + root.getName());
        }
        Element signature = root.getChild(ELEM_SIGNATURE);
        if (signature == null) {
            throw new JDOMException("Could not find signature element ");
        }
        result.setSignature(signature.getText());
        List children = root.getChildren(ELEM_FIELD);
        for (int i = 0; i < children.size(); i++) {
            Element child = (Element) children.get(i);
            extractField(result, child);
        }
        return result;
    }

    private static void extractField(Certificate result, Element child)
        throws JDOMException {
        String name = child.getAttributeValue("name");
        FieldExtractor e = (FieldExtractor) FIELD_MAP.get(name);
        if (name == null) {
            throw new JDOMException("The field " + name + 
                    " is not one of the possible fields for " + ELEM_FIELD);
        }
        e.extract(result, child);
    }
}
