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

import com.redhat.rhn.frontend.dto.ServerPath;
import com.redhat.rhn.frontend.xmlrpc.serializer.util.SerializerHelper;

import java.io.IOException;
import java.io.Writer;

import redstone.xmlrpc.XmlRpcCustomSerializer;
import redstone.xmlrpc.XmlRpcException;
import redstone.xmlrpc.XmlRpcSerializer;


/**
 * ServerPathSerializer: Converts a ServerPathSerializer object for representation as an 
 * XMLRPC struct.
 *
 * @version $Rev$
 * 
 * @xmlrpc.doc
 *  #struct("proxy connection path details")
 *         #prop_desc("int", "position", "Position of proxy in chain. The proxy that the 
 *             system connects directly to is listed in position 1.")
 *         #prop_desc("int", "id", "Proxy system id")
 *         #prop_desc("string", "hostname", "Proxy host name")
 *  #struct_end()
 */
public class ServerPathSerializer implements XmlRpcCustomSerializer {

    /**
     * {@inheritDoc}
     */
    public Class getSupportedClass() {
        return ServerPath.class;
    }

    /**
     * {@inheritDoc}
     */
    public void serialize(Object value, Writer output, XmlRpcSerializer builtInSerializer)
        throws XmlRpcException, IOException {
        
        ServerPath serverPath = (ServerPath)value;
        
        SerializerHelper helper = new SerializerHelper(builtInSerializer);
        helper.add("position", serverPath.getPosition());
        helper.add("id", serverPath.getId());
        helper.add("hostname", serverPath.getHostname());
        
        helper.writeTo(output);
    }
}
