/**
 * Copyright (c) 2015 SUSE LLC
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
package com.redhat.rhn.frontend.taglibs.helpers;

import com.redhat.rhn.common.util.ServletUtils;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.nav.AclGuard;
import com.redhat.rhn.frontend.nav.DepthGuard;
import com.redhat.rhn.frontend.nav.NavCache;
import com.redhat.rhn.frontend.nav.NavTree;
import com.redhat.rhn.frontend.nav.NavTreeIndex;
import com.redhat.rhn.frontend.nav.RenderEngine;
import com.redhat.rhn.frontend.nav.RenderGuard;
import com.redhat.rhn.frontend.nav.RenderGuardComposite;
import com.redhat.rhn.frontend.nav.Renderable;
import com.redhat.rhn.frontend.struts.RequestContext;

import java.net.URL;
import java.util.HashMap;
import java.util.Map;
import java.util.StringTokenizer;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.jsp.PageContext;

/**
 * Utility methods for rendering navigation menus that are defined in XML files.
 */
public enum RenderUtils {
    /**
     * Singleton instance
     */
    INSTANCE;

    RenderUtils() { }

    /**
     * Singleton implementation
     * @return an instance of this class
     */
    public static RenderUtils getInstance() {
        return INSTANCE;
    }

    /**
     * Render the navigation menu for a given page context and menu definition using the
     * given renderer class.
     *
     * @param pageContext the JSP page context
     * @param menuDefinition the menu definition XML file
     * @param rendererClass the renderer class to use
     * @param minDepth minimal depth
     * @param maxDepth maximal depth
     * @return the rendered navigation menu as string
     * @throws Exception in case of an error
     */
    public String renderNavigationMenu(PageContext pageContext, String menuDefinition,
            String rendererClass, int minDepth, int maxDepth) throws Exception {
        URL url = pageContext.getServletContext().getResource(menuDefinition);
        HttpServletRequest request = (HttpServletRequest) pageContext.getRequest();
        return renderNavigationMenu(url, request, rendererClass, minDepth, maxDepth);
    }

    /**
     * Render the navigation menu for a given request and menu definition using the given
     * renderer class.
     *
     * @param request the request object
     * @param menuDefinition the menu definition XML file
     * @param rendererClass the renderer class to use
     * @param minDepth minimal depth
     * @param maxDepth maximal depth
     * @return the rendered navigation menu as string
     * @throws Exception in case of an error
     */
    public String renderNavigationMenu(HttpServletRequest request, String menuDefinition,
            String rendererClass, int minDepth, int maxDepth) throws Exception {
        URL url = request.getServletContext().getResource(menuDefinition);
        return renderNavigationMenu(url, request, rendererClass, minDepth, maxDepth);
    }

    private String renderNavigationMenu(URL url, HttpServletRequest req,
            String rendererClass, int minDepth, int maxDepth) throws Exception {
        // Try to find the NavTree in the cache and index it
        NavTree navTree = NavCache.getTree(url);
        NavTreeIndex navTreeIndex = new NavTreeIndex(navTree);

        User user = new RequestContext(req).getCurrentUser();
        Map<String, Object> aclContext = new HashMap<>();
        aclContext.put("user", user);
        // Add the formvar(s) to the context as well
        if (navTree.getFormvar() != null) {
            StringTokenizer st = new StringTokenizer(navTree.getFormvar());
            while (st.hasMoreTokens()) {
                String token = st.nextToken();
                aclContext.put(token, req.getParameter(token));
            }
        }
        AclGuard guard = new AclGuard(aclContext, navTree.getAclMixins());
        navTree.setGuard(guard);

        // We try to fetch the previously successful navigation match from the Session.
        // Used as fallback if the current URL doesn't have a matching navigation map.
        StringBuilder locationKey = new StringBuilder();
        locationKey.append(navTree.getLabel());
        locationKey.append("navi_location");

        String location = (String) req.getSession().getAttribute(locationKey.toString());
        String lastActive = navTreeIndex.computeActiveNodes(
                ServletUtils.getRequestPath(req), location);

        // Store the computed URL in the Session
        req.getSession().setAttribute(locationKey.toString(), lastActive);

        Renderable renderable = (Renderable) Class.forName(rendererClass).newInstance();
        RenderGuardComposite comp = new RenderGuardComposite();
        comp.addRenderGuard(new DepthGuard(minDepth, maxDepth));
        comp.addRenderGuard(guard);

        return render(navTreeIndex, renderable, comp, req.getParameterMap());
    }

    /**
     * Call the {@link RenderEngine} to render a given {@link Renderable}.
     *
     * @param navTreeIndex the navigation tree index
     * @param renderable the renderable
     * @param guard the guard
     * @param params parameters
     * @return the rendered string
     */
    public String render(NavTreeIndex navTreeIndex, Renderable renderable,
            RenderGuard guard, Map<String, String[]> params) {
        renderable.setRenderGuard(guard);
        RenderEngine engine = new RenderEngine(navTreeIndex);
        return engine.render(renderable, params);
    }
}
