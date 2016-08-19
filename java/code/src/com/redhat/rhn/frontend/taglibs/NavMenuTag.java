/**
 * Copyright (c) 2009--2014 Red Hat, Inc.
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

import com.redhat.rhn.frontend.taglibs.helpers.RenderUtils;

import javax.servlet.jsp.JspException;
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

    /** minimum depth to display */
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
        try {
            pageContext.getOut().print(RenderUtils.getInstance().renderNavigationMenu(
                    pageContext, definition, renderer, mindepth, maxdepth));
        }
        catch (Exception e) {
            throw new JspException("Error writing to JSP file:", e);
        }

        return (SKIP_BODY);
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
