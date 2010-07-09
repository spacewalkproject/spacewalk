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
package com.redhat.rhn.frontend.xmlrpc.serializer.util;

import java.io.IOException;
import java.io.StringWriter;
import java.io.Writer;

import redstone.xmlrpc.XmlRpcException;
import redstone.xmlrpc.XmlRpcSerializer;

/**
 * SimpleSerializer
 * @version $Rev$
 */
public class SerializerHelper {
    private Writer output = new StringWriter();
    private XmlRpcSerializer serializer;

    /**
     * Constructs a SerializerHelper
     * @param basicSerializer serializer to convert basic objects to
     * XMLRPC format
     */
    public SerializerHelper(XmlRpcSerializer basicSerializer) {
        serializer = basicSerializer;
    }

    /**
     * Adds an xml rpc value to be written
     * @param name name of the property
     * @param value value of the property
     * @throws XmlRpcException in the case of the serialization failure
     */
    public void add(String name, Object value) throws XmlRpcException {
        genMember(name, value);
    }

    /**
     * Writes the xml rpc snippet  to the out param
     * @param out the writer to whom the output will be written
     * @throws IOException problem writing to given Writer
     */
    public void writeTo(Writer out) throws IOException {
        out.write("<struct>");
        out.write(output.toString());
        out.write("</struct>");
        out.write("\n");
    }

    /**
     * resets the saved xmlrpc data so one can
     * start over with a new snippet
     */
    public void clear() {
        output = new StringWriter();
    }
    /**
     * Generates an XMLRPC <member>.
     * @param name Member name.
     * @param value Value to be serialized.
     * @param output Buffer to serialize the value to.
     * @throws XmlRpcException thrown if a problem occurs with serializing
     * the value.
     */
    private void genMember(String name, Object value)
        throws XmlRpcException {

        if (value == null) {
            return;
        }

        try {
            output.write("<member><name>");
            output.write(name);
            output.write("</name>");
            serializer.serialize(value, output);
            output.write("</member>\n");
        }
        catch (IOException e) {
            throw new XmlRpcException(e.getMessage(), e);
        }
    }
}
