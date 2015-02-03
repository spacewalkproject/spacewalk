/**
 * Copyright (c) 2009--2013 Red Hat, Inc.
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

import java.io.IOException;
import java.io.Writer;
import java.util.LinkedList;
import java.util.List;

import redstone.xmlrpc.XmlRpcException;
import redstone.xmlrpc.XmlRpcSerializer;

import com.redhat.rhn.domain.common.FileList;
import com.redhat.rhn.domain.config.ConfigFileName;
import com.redhat.rhn.frontend.xmlrpc.serializer.util.SerializerHelper;

/**
 * FileListSerializer: Converts a FileList object for representation
 * as an XMLRPC struct.
 * @version $Rev$
 *
 * @xmlrpc.doc
 *   #struct("file list")
 *     #prop("string", "name")
 *     #prop_array("file_names", "string", "name")
 *   #struct_end()
 */
public class FileListSerializer extends RhnXmlRpcCustomSerializer {

    /**
     * {@inheritDoc}
     */
    public Class getSupportedClass() {
        return FileList.class;
    }

    /**
     * {@inheritDoc}
     */
    protected void doSerialize(Object value, Writer output, XmlRpcSerializer serializer)
        throws XmlRpcException, IOException {
        FileList fl = (FileList)value;

        SerializerHelper helper = new SerializerHelper(serializer);

        helper.add("name", fl.getLabel());

        List<String> fileNames = new LinkedList<String>();
        for (ConfigFileName cfn : fl.getFileNames()) {
            fileNames.add(cfn.getPath());
        }
        helper.add("file_names", fileNames);

        helper.writeTo(output);
    }
}
