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
package com.redhat.rhn.frontend.taglibs;

import com.redhat.rhn.frontend.nav.NavTreeIndex;
import com.redhat.rhn.frontend.nav.RenderGuard;
import com.redhat.rhn.frontend.nav.Renderable;
import com.redhat.rhn.frontend.nav.TitleRenderer;

import java.util.Map;

import javax.servlet.http.HttpServletRequest;

/**
 * NavDialogMenuTag is a specialization of the NavMenuTag.
 * This tag will capture the title of the page based
 * on the current selection of the main global navigation
 * menu and the current selection in the dialog menu.
 * <pre>
 * &lt;rhn:dialogmenu mindepth="0" maxdepth="1"
 *     definition="/WEB-INF/dialognav.xml"
 *     renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" /&gt;
 * </pre>
 * @version $Rev$
 */
public class NavDialogMenuTag extends NavMenuTag {

    /** constructor */
    public NavDialogMenuTag() {
        super();
    }

    /** {@inheritDoc} */
    protected String renderNav(NavTreeIndex nti, Renderable r,
                               RenderGuard guard, Map params) {
        String body = super.renderNav(nti, r, guard, params);
        String title = super.renderNav(nti, new TitleRenderer(), guard, params);
        HttpServletRequest req =
            (HttpServletRequest) pageContext.getRequest();
        req.setAttribute("innernavtitle", title);
        return body;
    }

}
