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

import com.redhat.rhn.frontend.dto.PackageDto;
import com.redhat.rhn.frontend.xmlrpc.serializer.util.SerializerHelper;

import java.io.IOException;
import java.io.Writer;

import redstone.xmlrpc.XmlRpcCustomSerializer;
import redstone.xmlrpc.XmlRpcException;
import redstone.xmlrpc.XmlRpcSerializer;

/**
 *
 * PackageSerializer
 * @version $Rev$
 * @xmlrpc.doc
 * #struct("package")
 *      #prop("string", "name")
 *      #prop("string", "version")
 *      #prop("string", "release")
 *      #prop("string", "epoch")
 *      #prop("int", "id")
 *      #prop("string", "arch_label")
 *      #prop("string", "last_modified_date")
 *      #prop_desc("string", "last_modified", "(Deprecated)")
 *  #struct_end()
 *
 */
public class PackageDtoSerializer implements XmlRpcCustomSerializer {

    /**
     * {@inheritDoc}
     */
    public Class getSupportedClass() {
        return PackageDto.class;
    }

    /**
     * {@inheritDoc}
     */
    public void serialize(Object value, Writer output, XmlRpcSerializer builtInSerializer)
        throws XmlRpcException, IOException {
        PackageDto pack = (PackageDto) value;

        SerializerHelper helper = new SerializerHelper(builtInSerializer);
        helper.add("name", pack.getName());
        helper.add("version", pack.getVersion());
        helper.add("release", pack.getRelease());
        String epoch = pack.getEpoch();
        if (epoch == null || epoch.equals(" ")) {
            epoch = "";
        }
        helper.add("epoch", epoch == null ? "" : epoch);
        helper.add("checksum", pack.getChecksum());
        helper.add("checksum_type", pack.getChecksumType());
        helper.add("id", pack.getId());
        helper.add("arch_label", pack.getArchLabel());
        helper.add("last_modified_date", pack.getLastModified());

        // Deprecated and should eventually be removed, were returning this
        // for some time although it was undocumented. All other occurrences of
        // last_modified are actual date objects, whereas last_modified_date is
        // used whenever we return a string.
        helper.add("last_modified", pack.getLastModified());

        helper.writeTo(output);
    }
}
