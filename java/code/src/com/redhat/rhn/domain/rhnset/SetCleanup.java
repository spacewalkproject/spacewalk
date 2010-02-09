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
package com.redhat.rhn.domain.rhnset;

import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.WriteMode;
import com.redhat.rhn.domain.user.UserFactory;

import org.apache.log4j.Logger;

import java.util.HashMap;

/**
 * Encapsulate the query/method that needs to be run after
 * a specific set has been saved to ensure that the user
 * does indeed have permissions to see all the entries in the set.
 * After the {@link RhnSetFactory} saves a set, it calls {@link #cleanup}
 * with the set being saved as an argument; that method must remove anything
 * from the set in the database that the user does not have permission to.
 * @version $Rev$
 */
public class SetCleanup {

    private static final Logger LOG = Logger.getLogger(SetCleanup.class);

    public static final SetCleanup NOOP = new NoopCleanup();

    public static final SetCleanup ILLEGAL_SERVERS =
        new SetCleanup("remove_illegal_servers");
    public static final SetCleanup ILLEGAL_ERRATA =
        new SetCleanupWithOrg("remove_illegal_errata");

    public static final SetCleanup UNOWNED_ACTIONS =
        new SetCleanup("remove_unowned_actions");
    public static final SetCleanup UNOWNED_CHANNELS =
        new SetCleanup("remove_unowned_channels");
    public static final SetCleanup UNOWNED_ERRATA =
        new SetCleanup("remove_unowned_errata");
    public static final SetCleanup UNOWNED_NONRHN_ERRATA =
        new SetCleanup("remove_nonrhn_unowned_errata");
    public static final SetCleanup UNOWNED_PACKAGES =
        new SetCleanup("remove_unowned_packages");
    public static final SetCleanup UNOWNED_PROBES =
        new SetCleanup("remove_unowned_probes");
    public static final SetCleanup UNOWNED_SERVERS =
        new SetCleanup("remove_unowned_servers");
    public static final SetCleanup UNOWNED_VIRTUAL_SERVERS =
        new SetCleanup("remove_unowned_virtual_servers");
    public static final SetCleanup UNOWNED_SYSTEM_GROUPS =
        new SetCleanup("remove_unowned_system_groups");
    public static final SetCleanup UNOWNED_SYSTEM_PROFILES =
        new SetCleanup("remove_unowned_system_profiles");
    public static final SetCleanup UNOWNED_USERS =
        new SetCleanup("remove_unowned_users");
    public static final SetCleanup UNOWNED_FILTERS =
        new SetCleanup("remove_unowned_filters");
    public static final SetCleanup UNOWNED_SUITES =
        new SetCleanup("remove_unowned_suites");
    public static final SetCleanup UNOWNED_METHODS = 
        new SetCleanup("remove_unowned_methods");
    public static final SetCleanup UNOWNED_ACTIVATION_KEYS = 
        new SetCleanup("remove_unowned_activation_keys");
    public static final SetCleanup UNOWNED_GPGSSL_KEYS = 
        new SetCleanup("remove_unowned_gpgssl_keys");
    public static final SetCleanup UNOWNED_FILE_LIST = 
        new SetCleanup("remove_unowned_file_list");
    public static final SetCleanup UNOWNED_PACKAGE_PROFILES = 
        new SetCleanup("remove_unowned_package_profiles");
    public static final SetCleanup INACCESSIBLE_CONFIG_REVISIONS =
        new SetCleanup("remove_inaccessible_config_revs");
    public static final SetCleanup INACCESSIBLE_CONFIG_FILES =
        new SetCleanup("remove_inaccessible_config_files");
    public static final SetCleanup INACCESSIBLE_CONFIG_CHANNELS =
        new SetCleanup("remove_inaccessible_config_channels");

    private String catalogName;
    private String modeName;

    /**
     * Create a new cleanup object. The {@link #cleanup} method
     * will look up a <code>WriteMode</code> with the given name
     * and execute it. The <code>WriteMode</code> must take two arguments:
     * the <tt>user_id</tt> and the <tt>label</tt>
     * @param catalogName0 the name of the mode catalog
     * @param modeName0 the name of the mode within the catalog
     */
    public SetCleanup(String catalogName0, String modeName0) {
        catalogName = catalogName0;
        modeName = modeName0;
    }

    /**
     * Create a new cleanup object. The {@link #cleanup} method will look up a
     * <code>WriteMode</code> with the given name from the
     * <tt>Set_queries</tt> and execute it. The <code>WriteMode</code> must
     * take two arguments: the <tt>user_id</tt> and the <tt>label</tt>
     * @param modeName0 the name of the mode with the <tt>Set_queries</tt>
     */
    public SetCleanup(String modeName0) {
        this("Set_queries", modeName0);
    }
    
    protected String getMode() {
        return modeName;
    }

    protected int cleanup(RhnSet set) {
        WriteMode m = ModeFactory.getWriteMode(catalogName, modeName);
        HashMap p = new HashMap();
        p.put("user_id", set.getUserId());
        p.put("label", set.getLabel());
        return m.executeUpdate(p);
    }

    private static class NoopCleanup extends SetCleanup {
        public NoopCleanup() {
            super("noop", "noop");
        }

        protected int cleanup(RhnSet set) {
            if (LOG.isDebugEnabled()) {
                LOG.debug("Noop cleanup for set " + set.getLabel() +
                    " and user " + set.getUserId(), new Throwable());
            }
            // this is a noop
            return 0;
        }
    }
    
    /**
     * This is somewhat ugly.  The reason this is here is because accessible
     * errata depends upon org rather than user.  The attempts at making
     * queries decently quick given only user_id and label have failed.
     * Looking up a user object getting the org_id and then running the
     * cleaner query is surprisingly faster.
     * 
     * I've left this a little open in case similar cases are found, though
     * I expect this may be the only one.
     * @version $Rev$
     */
    private static class SetCleanupWithOrg extends SetCleanup {
        public SetCleanupWithOrg(String mode) {
            super(mode);
        }
        
        protected int cleanup(RhnSet set) {
            WriteMode m = ModeFactory.getWriteMode("Set_queries", getMode());
            HashMap p = new HashMap();
            p.put("org_id", UserFactory.lookupById(set.getUserId()).getOrg().getId());
            p.put("user_id", set.getUserId());
            p.put("label", set.getLabel());
            return m.executeUpdate(p);
        }
    }

}
