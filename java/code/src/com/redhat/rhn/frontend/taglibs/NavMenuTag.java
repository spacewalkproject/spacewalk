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

import java.io.IOException;
import java.net.URL;
import java.util.HashMap;
import java.util.Map;
import java.util.StringTokenizer;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.jsp.JspException;
import javax.servlet.jsp.JspWriter;
import javax.servlet.jsp.tagext.TagSupport;

/**
 * NavMenuTag displays the navigation menu defined in a JSP.
 * <pre>
 * &lt;rhn:menu mindepth="0" maxdepth="0"
 *     definition="/WEB-INF/navigation.xml"
 *     renderer="com.redhat.rhn.frontend.nav.CustomRenderer" /&gt;
 * </pre>
 * <p>
 * Depending on which renderer is specified the output is different.
 * The renderer architecture gives this tag lots of flexibility
 * as to what it can render, from a table with lots of cells,
 * to an ASCII tree of nodes, to a simple unorder list which can
 * decorated by CSS.  The possibilities are endless.
 * @version $Rev$
 */
public class NavMenuTag extends TagSupport {

    /** minimum mindepth to display */
    private int mindepth = 0;
    /** maximum depth to be rendered */
    private int maxdepth = Integer.MAX_VALUE;
    /** name of xml menu definition */
    private String definition;
    /** rendering classname which implements the Renderable interface */
    private String renderer;

    /** {@inheritDoc}
     * @throws JspException*/
    public int doStartTag() throws JspException {

        JspWriter out = null;
        try {
            /*
             * There should probably be a Nav service to inquire to handle the
             * rendering.
             *
             */

            /*
             * Find the NavTree by looking it up in the smart cache.
             * Then create a new NavTreeIndex passing in NavTree.
             */

            out = pageContext.getOut();

            URL url = pageContext.getServletContext().getResource(definition);

            NavTree nt = NavCache.getTree(url);
            NavTreeIndex nti = new NavTreeIndex(nt);

            HttpServletRequest req =
                (HttpServletRequest) pageContext.getRequest();
            String requestPath = ServletUtils.getRequestPath(req);

            RequestContext requestContext = new RequestContext(req);

            Map aclContext = new HashMap();
            User user = requestContext.getLoggedInUser();
            aclContext.put("user", user);
            // Add the formvar(s) to the context as well.
            if (nt.getFormvar() != null) {
                StringTokenizer st = new StringTokenizer(nt.getFormvar());
                while (st.hasMoreTokens()) {
                    String token = st.nextToken();
                    aclContext.put(token, req.getParameter(token));
                }
            }
            AclGuard guard = new AclGuard(aclContext, nt.getAclMixins());
            nt.setGuard(guard);

            // Here we try and fetch the previously
            // successfull navigation match from the Session
            // This is used as a fallback if the current URL doesnt
            // have a matching navigation map
            StringBuffer locationKey = new StringBuffer();
            locationKey.append(nt.getLabel());
            locationKey.append("navi_location");

            String naviLocation =
                (String) req.getSession().getAttribute(locationKey.toString());

            String lastActive = nti.computeActiveNodes(requestPath, naviLocation);

            // Store the computed URL in the Session
            req.getSession().setAttribute(locationKey.toString(), lastActive);

            Renderable r =
                (Renderable) Class.forName(getRenderer()).newInstance();
            //r.setRenderGuard(new DepthGuard(getMindepth(), getMaxdepth()));
            RenderGuardComposite comp = new RenderGuardComposite();
            comp.addRenderGuard(new DepthGuard(getMindepth(), getMaxdepth()));
            comp.addRenderGuard(guard);

            out.print(renderNav(nti, r, comp, req.getParameterMap()));
        }
        catch (IOException ioe) {
            throw new JspException("Error writing to JSP file:", ioe);
        }
        catch (Exception e) {
            throw new JspException("Error writing to JSP file:", e);
        }

        return (SKIP_BODY);
    }

    protected String renderNav(NavTreeIndex nti, Renderable r,
                               RenderGuard guard, Map params) {
        r.setRenderGuard(guard);
        RenderEngine re = new RenderEngine(nti);
        return re.render(r, params);
    }

    /**
     * Returns the maximum depth to render.
     * @return int
     */
    public int getMaxdepth() {
        return maxdepth;
    }

    /**
     * Sets maximum depth to render.
     * @param depth maximum depth to render.
     */
    public void setMaxdepth(int depth) {
        maxdepth = depth;
    }

    /**
     * Sets menu xml definition filename.
     * @param def xml definition filename.
     */
    public void setDefinition(String def) {
        definition = def;
    }

    /**
     * Returns the menu definition xml filename.
     * @return String
     */
    public String getDefinition() {
        return definition;
    }

    /**
     * Sets the rendering class.
     * @param r Renderer classname.
     */
    public void setRenderer(String r) {
        renderer = r;
    }

    /**
     * Return the class which renders the menu.
     * @return String
     */
    public String getRenderer() {
        return renderer;
    }

    /**
     * Sets the level to start rendering.  Defaults to level zero.
     * @param min Initial level to start.
     */
    public void setMindepth(int min) {
        mindepth = min;
    }

    /**
     * Return start level to render.
     * @return int
     */
    public int getMindepth() {
        return mindepth;
    }

    /**
     * {@inheritDoc}
     */
    public void release() {
        mindepth = 0;
        maxdepth = Integer.MAX_VALUE;
        definition = null;
        renderer = null;
        super.release();
    }


}
