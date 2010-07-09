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

import com.redhat.rhn.frontend.dto.FilePreservationDto;
import com.redhat.rhn.frontend.xmlrpc.serializer.util.SerializerHelper;

import java.io.IOException;
import java.io.Writer;

import redstone.xmlrpc.XmlRpcCustomSerializer;
import redstone.xmlrpc.XmlRpcException;
import redstone.xmlrpc.XmlRpcSerializer;

/**
 * FilePreservationDtoSerializer
 * @version $Rev$
 *
 * @xmlrpc.doc
 *   #struct("file preservation")
 *      #prop("int", "id")
 *      #prop("string", "name")
 *      #prop("dateTime.iso8601", "created")
 *      #prop("dateTime.iso8601", "last_modified")
 *   #struct_end()
 */
public class FilePreservationDtoSerializer implements XmlRpcCustomSerializer {

    /**
     * {@inheritDoc}
     */
    public Class getSupportedClass() {
        return FilePreservationDto.class;
    }

    /** {@inheritDoc} */
    public void serialize(Object value, Writer output, XmlRpcSerializer builtInSerializer)
        throws XmlRpcException, IOException {
        FilePreservationDto fs = (FilePreservationDto)value;
        SerializerHelper helper = new SerializerHelper(builtInSerializer);

        helper.add("name", fs.getLabel());
        helper.add("id", fs.getId());
        helper.add("created", fs.getCreated());
        helper.add("last_modified", fs.getModified());

        helper.writeTo(output);
    }
}
