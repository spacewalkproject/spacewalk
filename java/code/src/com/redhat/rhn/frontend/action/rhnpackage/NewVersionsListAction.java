package com.redhat.rhn.frontend.action.rhnpackage;

import java.util.Map;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.listview.PageControl;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.rhnpackage.PackageManager;

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
