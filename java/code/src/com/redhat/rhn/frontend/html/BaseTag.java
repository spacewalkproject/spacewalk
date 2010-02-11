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



import java.util.ArrayList;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * BaseTag
 * @version $Rev: 60021 $
 */
public abstract class BaseTag {
    private String tag;
    private Map<String, String> attribs;
    private List body;
    private boolean spaceBeforeEndTag;

    /**
     * Public constructor
     * @param tagIn the name of the tag
     */
    protected BaseTag(String tagIn) {
        this(tagIn, true);
    }
    
    protected BaseTag(String tagIn, boolean spaceBefore) {
        attribs = new LinkedHashMap<String, String>();
        tag = tagIn;
        body = new ArrayList();
        spaceBeforeEndTag = spaceBefore;
    }

    /**
     * set an attribute of the html tag
     * @param name the attribute name
     * @param value the attribute value
     */
    public void setAttribute(String name, String value) {
        attribs.put(name, value);

    }
    
    /**
     * Removes an attribute of the html tag.
     * @param name the attribute name to be removed.
     */
    public void removeAttribute(String name) {
        attribs.remove(name);
    }

    /**
     * set the body of the tag
     * @param bodyIn the new body
     */
    public void addBody(String bodyIn) {
        body.add(bodyIn);
    }
    
    /**
     * Adds the given tag to the body of this tag.
     * @param bodyTag Tag to be added to the body of this tag.
     */
    public void addBody(BaseTag bodyTag) {
        body.add(bodyTag);
    }

    /**
     * render the tag into a string
     * @return the string version
     */
    public String render() {
        StringBuilder ret = new StringBuilder();
        ret.append(renderOpenTag());
        if (!hasBody()) {
            ret.deleteCharAt(ret.length() - 1);
            if (spaceBeforeEndTag) {
                ret.append(" />");
            }
            else {
                ret.append("/>");
            }
        }
        else {
            ret.append(renderBody());
            ret.append(renderCloseTag());
        }
        return ret.toString();
    }

    /**
     * render the open tag and attributes
     * @return the open tag as a string
     */
    public String renderOpenTag() {
        StringBuilder ret = new StringBuilder("<");
        ret.append(tag);
        for (String key : attribs.keySet()) {
            ret.append(" ");
            ret.append(key);
            ret.append("=\"");
            ret.append((String)attribs.get(key));
            ret.append("\"");
        }
        ret.append(">");
        return ret.toString();
    }

    /**
     * render the tag body
     * @return the tag body as a string
     */
    public String renderBody() {
        StringBuilder buf = new StringBuilder();
        
        for (Iterator itr = body.iterator(); itr.hasNext();) {
            buf.append(convertToString(itr.next()));
        }

        return buf.toString();
    }
    
    private String convertToString(Object o) {
        if (o instanceof BaseTag) {
            return ((BaseTag)o).render();
        }
        else if (o instanceof String) {
            return (String) o;
        }
        else {
            return o.toString();
        }
    }

    /**
     * render the close tag
     * @return the close tag as a string
     */
    public String renderCloseTag() {
        return "</" + tag + ">";
    }

    /**
     * Returns true if this tag has a body defined.
     * @return true if this tag has a body defined.
     */
    public boolean hasBody() {
        return (body.size() > 0);
    }

}
