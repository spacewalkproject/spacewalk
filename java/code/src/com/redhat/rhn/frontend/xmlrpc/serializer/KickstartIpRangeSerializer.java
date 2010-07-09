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

import com.redhat.rhn.domain.kickstart.KickstartIpRange;
import com.redhat.rhn.frontend.xmlrpc.serializer.util.SerializerHelper;

import java.io.IOException;
import java.io.Writer;

import redstone.xmlrpc.XmlRpcCustomSerializer;
import redstone.xmlrpc.XmlRpcException;
import redstone.xmlrpc.XmlRpcSerializer;


/**
 * KickstartIpRangeSerializer
 * @version $Rev$
 *
 * @xmlrpc.doc
 *   #struct("Kickstart Ip Range")
 *     #prop_desc("string", "ksLabel", "The kickstart label associated with the ip range")
 *     #prop_desc("string", "max", "The max ip of the range")
 *     #prop_desc("string", "min", "The min ip of the range")
 *   #struct_end()
 */
public class KickstartIpRangeSerializer implements XmlRpcCustomSerializer {

    /**
     * {@inheritDoc}
     */
    public Class getSupportedClass() {
        return KickstartIpRange.class;
    }

    /** {@inheritDoc} */
    public void serialize(Object value, Writer output, XmlRpcSerializer builtInSerializer)
        throws XmlRpcException, IOException {
        KickstartIpRange range = (KickstartIpRange)value;
        SerializerHelper helper = new SerializerHelper(builtInSerializer);

        helper.add("ksLabel", range.getKsdata().getLabel());
        helper.add("min", range.getMinString());
        helper.add("max", range.getMaxString());
        helper.writeTo(output);
    }

}
