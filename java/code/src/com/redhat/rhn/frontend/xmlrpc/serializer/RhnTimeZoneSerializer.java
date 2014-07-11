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

import redstone.xmlrpc.XmlRpcException;
import redstone.xmlrpc.XmlRpcSerializer;

import com.redhat.rhn.domain.user.RhnTimeZone;
import com.redhat.rhn.frontend.xmlrpc.serializer.util.SerializerHelper;

/**
 * RhnTimeZoneSerializer will serialize an RhnTimeZone object to XMLRPC
 * syntax.
 * @version $Rev$
 *
 * @xmlrpc.doc
 *
 * #struct("timezone")
 *   #prop_desc("int", "time_zone_id", "Unique identifier for timezone.")
 *   #prop_desc("string", "olson_name", "Name as identified by the Olson database.")
 * #struct_end()
 */
public class RhnTimeZoneSerializer extends RhnXmlRpcCustomSerializer {

    /** {@inheritDoc} */
    public Class getSupportedClass() {
        return RhnTimeZone.class;
    }

    /** {@inheritDoc} */
    protected void doSerialize(Object value, Writer output, XmlRpcSerializer serializer)
        throws XmlRpcException, IOException {
        RhnTimeZone tz = (RhnTimeZone) value;

        SerializerHelper helper = new SerializerHelper(serializer);
        helper.add("time_zone_id", new Integer(tz.getTimeZoneId()));
        helper.add("olson_name", tz.getOlsonName());
        helper.writeTo(output);
    }
}
