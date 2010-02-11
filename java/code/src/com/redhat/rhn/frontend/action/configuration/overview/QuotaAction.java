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
package com.redhat.rhn.frontend.action.configuration.overview;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.util.StringUtil;
import com.redhat.rhn.domain.org.OrgQuota;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.listview.PageControl;
import com.redhat.rhn.frontend.struts.BaseListAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.configuration.ConfigurationManager;

import javax.servlet.http.HttpServletRequest;

/**
 * QuotaAction extends RhnListAction.  
 * For showing org-wide config file quota and quota usage.
 * @version $Rev$
 */
public class QuotaAction extends BaseListAction {

    /**
     * Gets a data result containing all of the files configured by the given user's org.
     * @param context Current request context
     * @param pc A page control for this user
     * @return A list of Config Files as a DTO
     */
    protected DataResult getDataResult(RequestContext context, PageControl pc) {
        User user = context.getLoggedInUser();
        DataResult dr = ConfigurationManager.getInstance()
                .listAllFilesWithTotalSize(user, pc);
        return dr;
    }
    
    protected void processRequestAttributes(RequestContext context) {
        HttpServletRequest request = context.getRequest();
        User user = context.getLoggedInUser();
        
        OrgQuota quota = user.getOrg().getOrgQuota();
        long total = quota.getTotal().longValue() + quota.getBonus().longValue();
        long used = quota.getUsed().longValue();
        long left = total - used;
        
        request.setAttribute("total", StringUtil.displayFileSize(total));
        request.setAttribute("used", StringUtil.displayFileSize(used));
        request.setAttribute("left", StringUtil.displayFileSize(left));
    }
    
    protected void processPageControl(PageControl pc) {
        pc.setFilter(true);
        pc.setFilterColumn("path");
    }
    
}
