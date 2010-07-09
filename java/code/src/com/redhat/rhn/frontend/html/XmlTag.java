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
package com.redhat.rhn.frontend.html;



/**
 * XmlTag a simple class to render an XML tag
 * @version $Rev$
 */
public class XmlTag extends BaseTag {
    /**
     * Standard xml header with utf-8 encoding.
     * Example usage:<br />
     * <code>
     * StringBuffer buf = new StringBuffer();
     * buf.append(XmlTag.XML_HDR_UTF8);
     * buf.append(new XmlTag("foo").render());
     * </code>
     */
    public static final String XML_HDR_UTF8 = "<?xml version=\"1.0\" encoding=\"utf-8\"?>";

    /**
     * Standard xml header with no encoding.
     * Example usage:<br />
     * <code>
     * StringBuffer buf = new StringBuffer();
     * buf.append(XmlTag.XML_HDR);
     * buf.append(new XmlTag("foo").render());
     * </code>
     */
    public static final String XML_HDR = "<?xml version=\"1.0\"?>";

    /**
     * Constructs an XmlTag.
     * @param tagIn the name of the tag
     */
    public XmlTag(String tagIn) {
        this(tagIn, false);
    }

    /**
     * Constructs an XmlTag.  The <code>spaceBefore</code> attribute controls
     * whether a space is inserted before the closing tag of a single line
     * element.<br />
     * For example, a true value for spaceBefore and a tagIn of "foo" will
     * render &lt;foo /&gt;.  A spaceBefore value of false would've rendered
     * &lt;foo/&gt;.
     * @param tagIn the name of the tag
     * @param spaceBefore true if you want a space before the closing tag.
     */
    public XmlTag(String tagIn, boolean spaceBefore) {
        super(tagIn, spaceBefore);
    }
}
