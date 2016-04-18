/**
 * Copyright (c) 2016 Red Hat, Inc.
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

import com.redhat.rhn.frontend.dto.PackageSourceOverview;

import redstone.xmlrpc.XmlRpcException;
import redstone.xmlrpc.XmlRpcSerializer;

import com.redhat.rhn.frontend.xmlrpc.serializer.util.SerializerHelper;

/**
 * PackageSourceOverviewSerializer
 * @version $Rev$
 *
 * @xmlrpc.doc
 *   #struct("package source overview")
 *   #prop("int", "id")
 *   #prop("string", "name")
 *   #struct_end()
 */
public class PackageSourceOverviewSerializer extends RhnXmlRpcCustomSerializer {
    /**
     * {@inheritDoc}
     */
    public Class getSupportedClass() { return PackageSourceOverview.class; }

    /** {@inheritDoc} */
    protected void doSerialize(Object value, Writer output, XmlRpcSerializer serializer)
            throws XmlRpcException, IOException {
        PackageSourceOverview pO = (PackageSourceOverview)value;
        SerializerHelper helper = new SerializerHelper(serializer);
        helper.add("id", pO.getId());
        helper.add("name", pO.getNvrea());
        helper.writeTo(output);
    }
}
