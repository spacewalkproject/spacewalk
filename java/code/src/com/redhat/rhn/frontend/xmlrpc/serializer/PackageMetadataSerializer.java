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

import com.redhat.rhn.frontend.dto.PackageMetadata;
import com.redhat.rhn.frontend.xmlrpc.serializer.util.SerializerHelper;

import java.io.IOException;
import java.io.Writer;

import redstone.xmlrpc.XmlRpcCustomSerializer;
import redstone.xmlrpc.XmlRpcException;
import redstone.xmlrpc.XmlRpcSerializer;

/**
 * Converts PackageMetadata to an XMLRPC &lt;struct&gt;.
 * @version $Rev$
 * 
 * @xmlrpc.doc
 *  #struct("Package Metadata")
 *      #prop("int", "package_name_id")
 *      #prop("string", "package_name")
 *      #prop_desc("string", "this_system", "Version of package on this system.")
 *      #prop_desc("string", "other_system", "Version of package on the other system.")
 *      #prop("int", "comparison")
 *          #options()
 *              #item("0 - No difference.")
 *              #item("1 - Package on this system only.")
 *              #item("2 - Newer package version on this system.")
 *              #item("3 - Package on other system only.")
 *              #item("4 - Newer package version on other system.")
 *           #options_end()
 *   #struct_end()
 * 
 * 
 */
public class PackageMetadataSerializer implements XmlRpcCustomSerializer {

    /** {@inheritDoc} */
    public Class getSupportedClass() {
        return PackageMetadata.class;
    }

    /** {@inheritDoc} */
    public void serialize(Object value, Writer output, XmlRpcSerializer builtInSerializer)
        throws XmlRpcException, IOException {
        
        PackageMetadata pkg = (PackageMetadata)value;
        SerializerHelper helper = new SerializerHelper(builtInSerializer);
        helper.add("package_name_id", pkg.getId());
        helper.add("package_name", pkg.getName());
        helper.add("this_system", pkg.getSystemEvr());
        helper.add("other_system", pkg.getOtherEvr());
        helper.add("comparison", pkg.getComparisonAsInt());
        helper.writeTo(output);
    }
}
