/**
 * Copyright (c) 2013--2014 Red Hat, Inc.
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

package com.redhat.rhn.manager.system;

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.common.hibernate.LookupException;
import com.redhat.rhn.domain.server.Crash;
import com.redhat.rhn.domain.server.CrashFactory;
import com.redhat.rhn.domain.server.CrashFile;
import com.redhat.rhn.domain.server.CrashNote;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.xmlrpc.NoSuchCrashException;
import com.redhat.rhn.frontend.xmlrpc.NoSuchSystemException;
import com.redhat.rhn.manager.BaseManager;

import java.io.File;

/**
 * CrashManager
 * @version $Rev$
 */
public class CrashManager extends BaseManager {

    /**
     * Lookup Crash by its ID and User.
     * @param user User to check the permissions for.
     * @param crashId ID of the crash to search for.
     * @return The crash for given ID.
     */
    public static Crash lookupCrashByUserAndId(User user, Long crashId) {
        Crash crash = CrashFactory.lookupById(crashId);
        if (crash == null) {
            throw new NoSuchCrashException();
        }

        Long serverId = crash.getServer().getId();

        Server server = null;
        try {
            server = SystemManager.lookupByIdAndUser(new Long(serverId.longValue()), user);
        }
        catch (LookupException e) {
            throw new NoSuchSystemException();
        }

        return crash;
    }

    /**
     * Lookup CrashFile by its ID and User.
     * @param user The user to check the permissions for.
     * @param crashFileId ID of the crash file to search for.
     * @return The crash file for given ID.
     */
    public static CrashFile lookupCrashFileByUserAndId(User user, Long crashFileId) {
        CrashFile crashFile = CrashFactory.lookupCrashFileById(crashFileId);
        Long serverId = crashFile.getCrash().getServer().getId();

        Server server = null;
        try {
            server = SystemManager.lookupByIdAndUser(new Long(serverId.longValue()), user);
        }
        catch (LookupException e) {
            throw new NoSuchSystemException();
        }

        return crashFile;
    }

    /**
     * Delete a crash from database and filer.
     * @param user User to check the permissions for.
     * @param crashId The id of the crash to delete.
     */
    public static void deleteCrash(User user, Long crashId) {
        Crash crash = lookupCrashByUserAndId(user, crashId);

        // FIXME: async deletion via taskomatic?
        if (crash.getStoragePath() != null) {
            File storageDir = new File(Config.get().getString("web.mount_point"),
                    crash.getStoragePath());

            for (CrashFile cf : crash.getCrashFiles()) {
                File crashFile = new File(storageDir, cf.getFilename());
                if (crashFile.exists() && crashFile.isFile()) {
                    crashFile.delete();
                }
            }
            storageDir.delete();
        }

        CrashFactory.delete(crash);
    }

    /**
     * Lookup CrashNote by id and crash
     * @param crashNoteId crash note id
     * @param crash crash
     * @return crash note for given id
     */
    public static CrashNote lookupCrashNoteByIdAndCrash(Long crashNoteId, Crash crash) {
        return CrashFactory.lookupCrashNoteByIdAndCrash(crashNoteId, crash);
    }

    /**
     * @param user User to check permissions for
     * @param crashNoteId Crash note id to lookup for
     * @return Crash note for given ID
     */
    public static CrashNote lookupCrashNoteByUserAndId(User user, Long crashNoteId) {
        CrashNote cn = CrashFactory.lookupCrashNoteById(crashNoteId);
        lookupCrashByUserAndId(user, cn.getCrash().getId());
        return cn;
    }
}
