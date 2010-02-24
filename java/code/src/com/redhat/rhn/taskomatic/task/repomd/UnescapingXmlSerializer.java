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
package com.redhat.rhn.taskomatic.task.repomd;

import org.apache.xml.serialize.OutputFormat;
import org.apache.xml.serialize.XMLSerializer;

import java.io.IOException;
import java.io.Writer;

/**
 * 
 * UnescapingXmlSerializer
 * 
 * An XML Serializer that does no escaping.  Be very careful! 
 * 
 * @version $Rev$
 */
public class UnescapingXmlSerializer extends XMLSerializer {
    
    /**
     * Constructor 
     * @param writer the writer 
     * @param format the output format
     */
    public UnescapingXmlSerializer(Writer writer, OutputFormat format) {
        super(writer, format);
    }
    
    /**
     * 
     * {@inheritDoc}
     */
    protected void printEscaped(String source) throws IOException {
        _printer.printText(source);
    }
    
    /**
     * 
     * {@inheritDoc}
     */
    protected void printXMLChar(int ch) throws IOException {
        _printer.printText((char)ch);
    }
    
}
