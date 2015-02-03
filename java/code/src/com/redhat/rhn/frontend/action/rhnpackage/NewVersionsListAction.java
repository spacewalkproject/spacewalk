/**
 * Copyright (c) 2014 Red Hat, Inc.
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

import java.util.Map;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.listview.PageControl;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.rhnpackage.PackageManager;

/**
 * List newer versions of the given package
 * @author sherr
 */
public class NewVersionsListAction extends BasePackageListAction {
    /**
     * list all packages updating the given package that the user can see
     * @param rctx the request context
     * @param pc the page control
     * @return The dataresult
     */
    @Override
    protected DataResult<Map<String, Object>> getDataResult(RequestContext rctx,
            PageControl pc) {
        Long pid = rctx.getRequiredParam("pid");
        User user = rctx.getCurrentUser();
        return PackageManager.obsoletingPackages(user, pid);
    }

}
