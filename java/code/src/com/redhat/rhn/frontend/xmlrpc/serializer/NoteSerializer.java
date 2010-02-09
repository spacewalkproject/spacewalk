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

import com.redhat.rhn.domain.server.Note;
import com.redhat.rhn.frontend.xmlrpc.serializer.util.SerializerHelper;

import java.io.IOException;
import java.io.Writer;

import redstone.xmlrpc.XmlRpcCustomSerializer;
import redstone.xmlrpc.XmlRpcException;
import redstone.xmlrpc.XmlRpcSerializer;


/**
 * 
 * NoteSerializer: Converts a Note object for representation as an XMLRPC struct.
 * @version $Rev$
 *
 * @xmlrpc.doc
 * #struct("note details") 
 *   #prop("int", "id")
 *   #prop_desc("string", "subject", "Subject of the note")
 *   #prop_desc("string", "note", "Contents of the note")
 *   #prop_desc("int", "system_id", "The id of the system associated with the note")
 *   #prop_desc("string", "creator",  "Creator of the note")
 * #struct_end()
 */
public class NoteSerializer implements XmlRpcCustomSerializer {

    /**
     * {@inheritDoc}
     */
    public Class getSupportedClass() {
        return Note.class;
    }

    /**
     * 
     * {@inheritDoc}
     */
    public void serialize(Object value, Writer output,
            XmlRpcSerializer builtInSerializer)
        throws XmlRpcException, IOException {
        SerializerHelper helper = new SerializerHelper(builtInSerializer);

        Note note = (Note) value; 
        helper.add("id", note.getId()); 
        helper.add("subject", note.getSubject());
        add(helper, "note", note.getNote());
        add(helper, "system_id", note.getServer().getId());
        add(helper, "creator", note.getCreator().getLogin());
        helper.writeTo(output);
    }

    private void add(SerializerHelper helper, String name, Object value) {
        if (value != null) {
            helper.add(name, value);
        }
    }
}
