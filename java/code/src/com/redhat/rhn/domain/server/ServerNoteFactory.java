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
package com.redhat.rhn.domain.server;

import com.redhat.rhn.common.db.datasource.CallableMode;
import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.hibernate.HibernateFactory;

import org.apache.log4j.Logger;

import java.util.HashMap;
import java.util.Map;

/**
 * ServerFactory - the singleton class used to fetch and store
 * com.redhat.rhn.domain.server.Server objects from the database.
 * @version $Rev$
 */
public class ServerNoteFactory extends HibernateFactory {

    private static ServerNoteFactory singleton = new ServerNoteFactory();
    private static Logger log = Logger.getLogger(ServerFactory.class);

    private ServerNoteFactory() {
        super();
    }

    /**
     * Get the Logger for the derived class so log messages show up on the
     * correct class
     */
    protected Logger getLogger() {
        return log;
    }

    /**
     * Insert or Update a Note.
     * @param noteIn Note to be stored in database.
     */
    public static void save(Note noteIn) {
        singleton.saveObject(noteIn);
    }

    /**
     * Deletes a note
     *
     * @param note The note to delete
     */
    public static void delete(Note note) {
        HibernateFactory.getSession().evict(note);
        CallableMode m = ModeFactory.getCallableMode("System_queries", "delete_note");
        Map map = new HashMap();
        map.put("id", note.getId());
        map.put("server_id", note.getServer().getId());
        m.execute(map, new HashMap());
        HibernateFactory.getSession().evict(note);
    }
}
