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

import com.redhat.rhn.frontend.dto.HistoryEvent;
import com.redhat.rhn.frontend.xmlrpc.serializer.util.SerializerHelper;

import java.io.IOException;
import java.io.Writer;

import redstone.xmlrpc.XmlRpcCustomSerializer;
import redstone.xmlrpc.XmlRpcException;
import redstone.xmlrpc.XmlRpcSerializer;

/**
 *
 * HistoryEventSerializer
 * @version $Rev$
 *
 * @xmlrpc.doc
 *  #struct("History Event")
 *      #prop_desc("dateTime.iso8601", "completed", "Date that
 *          the event occurred (optional)")
 *      #prop_desc("string", "summary", "Summary of the event")
 *      #prop_desc("string", "details", "Details of the event")
 *  #struct_end()
 *
 *
 */
public class HistoryEventSerializer implements XmlRpcCustomSerializer {

    /**
     * {@inheritDoc}
     */
    public Class getSupportedClass() {

        return HistoryEvent.class;
    }

    /**
     * {@inheritDoc}
     */
    public void serialize(Object value, Writer output, XmlRpcSerializer builtInSerializer)
        throws XmlRpcException, IOException {

        SerializerHelper helper = new SerializerHelper(builtInSerializer);
        HistoryEvent event = (HistoryEvent) value;

       helper.add("summary", event.getSummary());
       helper.add("completed", event.getCompleted());
       if (event.getDetails() != null) {
           helper.add("details", event.getDetails());
       }
       else {
           helper.add("details", new String(""));
       }

       helper.writeTo(output);
    }
}
