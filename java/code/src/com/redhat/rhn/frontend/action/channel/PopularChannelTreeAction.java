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
package com.redhat.rhn.frontend.action.channel;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.listview.ListControl;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.channel.ChannelManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * ChannelTreeRelevantSetupAction
 * @version $Rev$
 */
public class PopularChannelTreeAction extends BaseChannelTreeAction {

    private final Long DEFAULT_COUNT = 10L;
    private final Long[] preSetCounts = {1L, 10L, 50L, 100L, 250L, 500L, 1000L};

    private final String SERVER_COUNT = "server_count";
    private final String COUNTS = "counts";

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
            ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response) {

        RequestContext requestContext = new RequestContext(request);

        User user = requestContext.getLoggedInUser();
        String countStr = request.getParameter(SERVER_COUNT);
        Long count;
        if (countStr == null) {
            count = DEFAULT_COUNT;
            /**
            Long sysPercent = new Long(UserManager.visibleSystemsAsDto(user).size()/10);

            for (Long l : preSetCounts) {
                if (l.longValue() < sysPercent.longValue()) {
                    count = l;
                }
            }
            if (count == null) {
                count = 500L;
            } **/
        }
        else {
            count = Long.parseLong(countStr);
        }

        List<Map> preSetList = new ArrayList<Map>();
        for (Long l : preSetCounts) {
            Map countMap = new HashMap();
            countMap.put("count", l);
            countMap.put("selected", l.equals(count));
            preSetList.add(countMap);
        }

        request.setAttribute("count", count); //passing to get dataresult
        request.setAttribute(COUNTS, preSetList);
        request.setAttribute(SERVER_COUNT, count);
        return super.execute(mapping, formIn, request, response);
    }




    /** {@inheritDoc} */
    protected DataResult getDataResult(RequestContext requestContext, ListControl lc) {
        User user = requestContext.getCurrentUser();
        DataResult dr = ChannelManager.popularChannelTree(user,
                (Long) requestContext.getRequest().getAttribute("count"), lc);
        return  dr;
    }
}
