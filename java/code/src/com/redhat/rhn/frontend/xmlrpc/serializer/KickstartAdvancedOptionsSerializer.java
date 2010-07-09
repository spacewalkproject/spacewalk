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

package com.redhat.rhn.frontend.xmlrpc.serializer;

import com.redhat.rhn.domain.kickstart.KickstartCommand;
import com.redhat.rhn.frontend.xmlrpc.serializer.util.SerializerHelper;

import java.io.IOException;
import java.io.Writer;

import redstone.xmlrpc.XmlRpcCustomSerializer;
import redstone.xmlrpc.XmlRpcException;
import redstone.xmlrpc.XmlRpcSerializer;

/**
 * KickstartAdvancedOptionsSerializer: Converts a KickstartCommand object for
 * representation as an XMLRPC struct.
 *
 * @version $Rev$
 *
 * @xmlrpc.doc
 *      #struct("option")
 *          #prop("string", "name")
 *          #prop("string", "arguments")
 *      #struct_end()
 */
public class KickstartAdvancedOptionsSerializer implements XmlRpcCustomSerializer {

    /**
     * {@inheritDoc}
     */
    public Class getSupportedClass() {
        return KickstartCommand.class;
    }

    /**
     * {@inheritDoc}
     */
    public void serialize(Object value, Writer output, XmlRpcSerializer builtInSerializer)
        throws XmlRpcException, IOException {
        KickstartCommand cmd = (KickstartCommand)value;

        SerializerHelper helper = new SerializerHelper(builtInSerializer);

        helper.add("name", cmd.getCommandName().getName());
        helper.add("arguments", cmd.getArguments());
        helper.writeTo(output);
    }
}
