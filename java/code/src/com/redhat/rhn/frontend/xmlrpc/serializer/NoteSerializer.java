/**
 * Copyright (c) 2009--2011 Red Hat, Inc.
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

import com.redhat.rhn.domain.server.Note;
import com.redhat.rhn.frontend.xmlrpc.serializer.util.SerializerHelper;


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
 *   #prop_desc("string", "creator",  "Creator of the note if exists (optional)")
 *   #prop_desc("date", "updated",  "Date of the last note update")
 * #struct_end()
 */
public class NoteSerializer extends RhnXmlRpcCustomSerializer {

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
    protected void doSerialize(Object value, Writer output,
            XmlRpcSerializer serializer)
        throws XmlRpcException, IOException {
        SerializerHelper helper = new SerializerHelper(serializer);

        Note note = (Note) value;
        helper.add("id", note.getId());
        helper.add("subject", note.getSubject());
        add(helper, "note", note.getNote());
        add(helper, "system_id", note.getServer().getId());
        // Creator account may be deleted.
        if (note.getCreator() != null) {
            add(helper, "creator", note.getCreator().getLogin());
        }
        add(helper, "updated", note.getModified());
        helper.writeTo(output);
    }

    private void add(SerializerHelper helper, String name, Object value) {
        if (value != null) {
            helper.add(name, value);
        }
    }
}
