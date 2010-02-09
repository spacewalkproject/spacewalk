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
package com.redhat.rhn.manager.rhnset;

import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.rhnset.RhnSetFactory;
import com.redhat.rhn.domain.rhnset.SetCleanup;
import com.redhat.rhn.manager.BaseManager;

/**
 * RhnSetManager
 * offers management methods for RhnSet objects giving you the ability
 * to create, delete, update, and find them.
 * @version $Rev$
 */
public class RhnSetManager extends BaseManager {

    /**
     *  Constructor.
     */
    private RhnSetManager() {
    }
    
    /**
     * Returns a list of RhnSets found for the given label and userid.
     * @param userId User Id for the RhnSet.
     * @param label Label for the RhnSet.
     * @param cleanup the cleanup that should be run when the set is stored
     * @return List of RhnSets.
     */
    public static RhnSet findByLabel(Long userId, String label, SetCleanup cleanup) {
        return RhnSetFactory.lookupByLabel(userId, label, cleanup);
    }

    /**
     * Creates a new RhnSet.
     * @param userId Userid to associate with the RhnSet.
     * @param label Label to associate with the RhnSet.
     * @param cleanup the cleanup that should be run when the set is stored
     * @return a new instance of RhnSet associated with the given userId and
     * label, and an empty list of elements.
     */
    public static RhnSet createSet(Long userId, String label, SetCleanup cleanup) {
        return RhnSetFactory.createRhnSet(userId, label, cleanup);
    }

    /**
     * Removes the RhnSet which matches the given UserId and label.
     * @param userId UserId of set
     * @param label Set label
     */
    public static void deleteByLabel(Long userId, String label) {
        RhnSetFactory.removeByLabel(userId, label);
    }
    
    /**
     * Removes the RhnSet
     * @param set The set to remove.
     */
    public static void remove(RhnSet set) {
        if (set == null) {
            return;
        }
        RhnSetFactory.remove(set);
    }
    
    /**
     * Stores the RhnSet in the db
     * Replaces old set if one exists.
     * @param set The set to store/save.
     */
    public static void store(RhnSet set) {
        if (set == null) {
            return;
        }
        RhnSetFactory.save(set);
    }
}
