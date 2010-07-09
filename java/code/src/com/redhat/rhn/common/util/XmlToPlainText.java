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
package com.redhat.rhn.common.util;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.jdom.Document;
import org.jdom.Element;
import org.jdom.JDOMException;
import org.jdom.Text;
import org.jdom.input.SAXBuilder;

import java.io.IOException;
import java.io.StringReader;


/**
 * XmlToPlainText - Helper class that uses StringResources XML
 * @version $Rev$
 */
class XmlToPlainText {
    private static Logger log = Logger.getLogger(XmlToPlainText.class);

    private static final String IGNORABLES = ".,;'\"?";
    private StringBuilder plainText;
    private String href;

    /**
     * Converts an xml/html snippet to a plain text string..
     * @param snippet the xml snippet to convert..
     * @return returns the converted plain text or
     *           the orignal xml in the case of an error.
     */
    public String convert(String snippet) {
        String xmlSnippet = "<foo>" + snippet + "</foo>";
        plainText = new StringBuilder();
        SAXBuilder builder = new SAXBuilder();
        try {
            Document doc = builder.build(new StringReader(xmlSnippet));
            toPlainText(doc);
            return plainText.toString();
        }
        catch (JDOMException e) {
            log.warn("Couldn't parse the snippet -> [" + snippet + "]", e);
        }
        catch (IOException e) {
            log.warn("Couldn't parse the snippet -> [" + snippet + "]", e);
        }
        return snippet;
    }

    private void toPlainText(Object current) {
        if (current instanceof Text) {
            process((Text)current);
        }
        else if (current instanceof Element) {
            Element elem = (Element)current;
            if ("a".equalsIgnoreCase(elem.getName())) {
                href = elem.getAttributeValue("href").trim();
            }
            for (Object o : elem.getContent()) {
                toPlainText(o);
            }
        }
        else if (current instanceof Document) {
            for (Object o : ((Document)current).getContent()) {
                toPlainText(o);
            }
        }

    }

    private void process(Text current) {
        String text = current.getTextTrim();
        if (!StringUtils.isBlank(text)) {
            if (plainText.length() > 0 && IGNORABLES.indexOf(text) < 0) {
                plainText.append(" ");
            }
            plainText.append(text);
            if (!StringUtils.isBlank(href)) {
                plainText.append(" (").append(href).append(")");
                href = null;
            }
        }
    }
}

