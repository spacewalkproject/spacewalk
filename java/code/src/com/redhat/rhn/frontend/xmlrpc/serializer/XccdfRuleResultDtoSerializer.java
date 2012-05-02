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

import com.redhat.rhn.frontend.dto.XccdfRuleResultDto;
import com.redhat.rhn.frontend.xmlrpc.serializer.util.SerializerHelper;


/**
 * XccdfRuleResultDtoSerializer
 * @version $Rev$
 * @xmlrpc.doc
 * #struct("OpenSCAP XCCDF RuleResult")
 *   #prop_desc("string", "idref", "idref from XCCDF document.")
 *   #prop_desc("string", "result", "Result of evaluation.")
 *   #prop_desc("string", "idents", "Comma separated list of XCCDF idents.")
 * #struct_end()
 */
public class XccdfRuleResultDtoSerializer implements XmlRpcCustomSerializer {

    /**
     * {@inheritDoc}
     */
    public Class getSupportedClass() {
        return XccdfRuleResultDto.class;
    }

    /**
     * {@inheritDoc}
     */
    public void serialize(Object value, Writer output,
            XmlRpcSerializer builtInSerializer) throws XmlRpcException, IOException {
        XccdfRuleResultDto dto = (XccdfRuleResultDto) value;
        SerializerHelper helper = new SerializerHelper(builtInSerializer);
        helper.add("idref", dto.getDocumentIdref());
        helper.add("result", dto.getLabel());
        helper.add("idents", dto.getIdentsString());
        helper.writeTo(output);
    }
}
