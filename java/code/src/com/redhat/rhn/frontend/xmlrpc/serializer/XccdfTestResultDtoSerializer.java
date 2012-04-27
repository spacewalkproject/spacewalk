/**
 * Copyright (c) 2012 Red Hat, Inc.
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

import redstone.xmlrpc.XmlRpcCustomSerializer;
import redstone.xmlrpc.XmlRpcException;
import redstone.xmlrpc.XmlRpcSerializer;

import com.redhat.rhn.frontend.dto.XccdfTestResultDto;
import com.redhat.rhn.frontend.xmlrpc.serializer.util.SerializerHelper;


/**
 * XccdfTestResultDtoSerializer
 * @version $Rev$
 * @xmlrpc.doc
 * #struct("OpenSCAP XCCDF Scan")
 *   #prop_desc("int", "xid", "XCCDF TestResult ID")
 *   #prop_desc("string", "profile", "XCCDF Profile")
 *   #prop_desc("string", "path", "Path to XCCDF document")
 *   #prop_desc($date, "completed", "Scan completion time")
 * #struct_end()
 */
public class XccdfTestResultDtoSerializer implements XmlRpcCustomSerializer {

    /**
     * {@inheritDoc}
     */
    public Class getSupportedClass() {
        return XccdfTestResultDto.class;
    }

    /**
     * {@inheritDoc}
     */
    public void serialize(Object value, Writer output,
            XmlRpcSerializer builtInSerializer) throws XmlRpcException, IOException {
        XccdfTestResultDto dto = (XccdfTestResultDto) value;
        SerializerHelper helper = new SerializerHelper(builtInSerializer);
        addToHelper(helper, "xid", dto.getXid());
        addToHelper(helper, "profile", dto.getProfile());
        addToHelper(helper, "path", dto.getPath());
        addToHelper(helper, "completed", dto.getCompleted());
        helper.writeTo(output);
    }

    private static void addToHelper(SerializerHelper helper, String label, Object value) {
        if (value != null) {
            helper.add(label, value);
        }
    }
}
