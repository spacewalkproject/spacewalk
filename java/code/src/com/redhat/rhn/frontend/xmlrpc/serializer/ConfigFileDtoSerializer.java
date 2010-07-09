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

import com.redhat.rhn.frontend.dto.ConfigFileDto;
import com.redhat.rhn.frontend.xmlrpc.serializer.util.SerializerHelper;

import java.io.IOException;
import java.io.Writer;

import redstone.xmlrpc.XmlRpcCustomSerializer;
import redstone.xmlrpc.XmlRpcException;
import redstone.xmlrpc.XmlRpcSerializer;


/**
 * ConfigFileDtoSerializer
 * @version $Rev$
 *
 * @xmlrpc.doc
 * #struct("Configuration File information")
 *   #prop("string", "type")
 *              #options()
 *                  #item("file")
 *                  #item("directory")
 *              #options_end()
 *   #prop_desc("string", "path","File Path")
 *   #prop_desc($date, "last_modified","Last Modified Date")
 * #struct_end()
 */
public class ConfigFileDtoSerializer implements XmlRpcCustomSerializer {

    /**
     * {@inheritDoc}
     */
    public Class getSupportedClass() {
        return ConfigFileDto.class;
    }

    /**
     * {@inheritDoc}builtInSerializer
     */
    public void serialize(Object value, Writer output, XmlRpcSerializer builtInSerializer)
        throws XmlRpcException, IOException {
        ConfigFileDto dto = (ConfigFileDto) value;
        SerializerHelper helper = new SerializerHelper(builtInSerializer);
        helper.add("type", dto.getType());
        helper.add("path", dto.getPath());
        helper.add("last_modified", dto.getModified());
        helper.writeTo(output);
    }

}
