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

package com.redhat.rhn.frontend.action.renderers;

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.listview.PageControl;
import com.redhat.rhn.frontend.struts.RequestContext;

import org.apache.commons.lang.StringUtils;
import org.directwebremoting.WebContext;
import org.directwebremoting.WebContextFactory;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Simple implementation of a fragment renderer which automates 
 * the boilerplate work done rendering a fragment
 * 
 * @version $Rev$
 */
public abstract class BaseFragmentRenderer implements FragmentRenderer {

    private static final int PAGE_SIZE = 5;
    /**
     * {@inheritDoc}
     */
    public String renderAsync() throws ServletException, IOException {
        WebContext ctx = WebContextFactory.get();
        HttpServletRequest req = ctx.getHttpServletRequest();
        RequestContext rhnCtx = new RequestContext(req);
        User user = rhnCtx.getCurrentUser();
        PageControl pc = new PageControl();
        pc.setStart(1);
        pc.setPageSize(PAGE_SIZE);
        render(user, pc, req);
        HttpServletResponse resp = ctx.getHttpServletResponse();
        return RendererHelper.renderRequest(
                getPageUrl(), 
                req, 
                resp);
    }
    
    /**
     * Gentlemen, render your fragments!
     * @param user logged in user
     * @param pc  controls list displays
     * @param req incoming request
     */
    protected abstract void render(User user, PageControl pc, HttpServletRequest req);
    
    /**
     * Hook method for child classes to return a URL to the page
     * which renders the generated content
     * @return page url
     */
    protected abstract String getPageUrl();
    
    /**
     * Util method to return the page size in a accessible way. 
     * @param totalSize the total size of page
     * @param descriptionKey the message key for description 
     * @return the appropriate pagination message.
     */
    protected String makePaginationMessage(int end, int totalSize, String descriptionKey) {
        LocalizationService ls = LocalizationService.getInstance();
        int start = 0;
        if (totalSize > 0) {
            start  = 1;
        }
        if (StringUtils.isBlank(descriptionKey)) {
            return ls.getMessage("message.range", start, end, totalSize);
        }
        return ls.getMessage("message.range.withtypedescription", start, end,
                                        totalSize, ls.getMessage(descriptionKey));
    }

}
