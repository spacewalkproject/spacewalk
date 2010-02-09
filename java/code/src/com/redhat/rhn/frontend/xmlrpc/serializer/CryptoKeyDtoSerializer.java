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

import com.redhat.rhn.frontend.dto.CryptoKeyDto;
import com.redhat.rhn.frontend.xmlrpc.serializer.util.SerializerHelper;

import java.io.IOException;
import java.io.Writer;

import redstone.xmlrpc.XmlRpcCustomSerializer;
import redstone.xmlrpc.XmlRpcException;
import redstone.xmlrpc.XmlRpcSerializer;

/**
 * Serializes instances of {@link com.redhat.rhn.frontend.dto.CryptoKeyDto}.
 * 
 * @version $Revision$
 * 
 * @xmlrpc.doc
 *      #struct("key")
 *          #prop("string", "description")
 *          #prop("string", "type")
 *      #struct_end()
 */
public class CryptoKeyDtoSerializer implements XmlRpcCustomSerializer {

    /** {@inheritDoc} */
    public Class getSupportedClass() {
        return CryptoKeyDto.class;
    }
          
    /** {@inheritDoc} */
    public void serialize(Object o, Writer writer, XmlRpcSerializer xmlRpcSerializer)
        throws XmlRpcException, IOException {
        if (!(o instanceof CryptoKeyDto)) {
            throw new XmlRpcException("Object of incorrect type to be serialized. " +
                "Expected: CryptoKeyDetails, Found: " + 
                (o != null ? o.getClass() : null));
        }
        
        CryptoKeyDto key = (CryptoKeyDto) o;
        
        SerializerHelper serializer = new SerializerHelper(xmlRpcSerializer);
        serializer.add("description", key.getDescription());
        serializer.add("type", key.getLabel());
        serializer.writeTo(writer);
        
    }
}
