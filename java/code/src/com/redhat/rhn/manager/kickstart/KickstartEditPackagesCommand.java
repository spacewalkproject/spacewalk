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
package com.redhat.rhn.manager.kickstart;

import com.redhat.rhn.domain.rhnpackage.PackageFactory;
import com.redhat.rhn.domain.rhnpackage.PackageName;
import com.redhat.rhn.domain.user.User;

/**
 * Simple class to reduce dependencies between Struts and database laysers
 *
 * @version $Rev $
 */
public class KickstartEditPackagesCommand extends BaseKickstartCommand {

    /**
     * Constructor.
     * @param ksidIn Kickstart ID.
     * @param userIn User performing the edit.
     */
    public KickstartEditPackagesCommand(Long ksidIn, User userIn) {
        super(ksidIn, userIn);
        // TODO Auto-generated constructor stub
    }

    /**
     * Lookup PackageName object by name
     * @param name used in lookup
     * @return found object, otherwise null
     */
    public PackageName fetchPackageByName(String name) {
        return PackageFactory.lookupOrCreatePackageByName(name);
    }

}
