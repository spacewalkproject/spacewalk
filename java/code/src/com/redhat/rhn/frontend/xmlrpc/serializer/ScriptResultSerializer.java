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

import com.redhat.rhn.domain.action.script.ScriptResult;
import com.redhat.rhn.frontend.xmlrpc.serializer.util.SerializerHelper;

import java.io.IOException;
import java.io.Writer;

import redstone.xmlrpc.XmlRpcCustomSerializer;
import redstone.xmlrpc.XmlRpcException;
import redstone.xmlrpc.XmlRpcSerializer;


/**
 * Converts a ScriptResult to an XMLRPC &lt;struct&gt;.
 * @version $Rev$
 *
 * @xmlrpc.doc
 *  #struct("script result")
 *      #prop_desc("dateTime.iso8601", "startDate", "Time script began execution.")
 *      #prop_desc("dateTime.iso8601", "stopDate", "Time script stopped execution.")
 *      #prop_desc("int", "returnCode", "Script execution return code.")
 *      #prop_desc("string", "output", "Output of the script")
 *  #struct_end()
 *
 */
public class ScriptResultSerializer implements XmlRpcCustomSerializer {

    /**
     * {@inheritDoc}
     */
    public Class getSupportedClass() {
        return ScriptResult.class;
    }

    /** {@inheritDoc} */
    public void serialize(Object value, Writer output, XmlRpcSerializer builtInSerializer)
        throws XmlRpcException, IOException {
        ScriptResult scriptResult = (ScriptResult)value;
        SerializerHelper helper = new SerializerHelper(builtInSerializer);
        helper.add("startDate", scriptResult.getStartDate());
        helper.add("stopDate", scriptResult.getStopDate());
        helper.add("returnCode", scriptResult.getReturnCode());
        helper.add("output", scriptResult.getOutputContents());
        helper.writeTo(output);
    }

}
