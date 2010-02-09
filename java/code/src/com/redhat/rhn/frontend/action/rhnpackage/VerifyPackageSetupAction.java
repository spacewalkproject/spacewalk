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
package com.redhat.rhn.frontend.action.rhnpackage;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.manager.rhnpackage.PackageManager;

/**
 * VerifyPackageSetupAction
 * @version $Rev$
 */
public class VerifyPackageSetupAction extends BaseSystemPackagesAction {
    /**
     * Returns the list of packages that can be verified
     * @param server The system.
     * @return List of packages that can be installed..
     */
    protected DataResult getDataResult(Server server) {
        return PackageManager.systemPackageList(server.getId(), null);
    }

}
