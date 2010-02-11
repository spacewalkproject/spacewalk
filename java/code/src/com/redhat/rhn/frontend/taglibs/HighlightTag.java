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

import org.apache.log4j.Logger;

import java.io.IOException;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.regex.PatternSyntaxException;

import javax.servlet.jsp.JspException;
import javax.servlet.jsp.tagext.BodyContent;
import javax.servlet.jsp.tagext.BodyTagSupport;

/**
 * HighlightTag
 * The highlight tag is used to wrap a certain string in a body
 * of text with an html tag. Example usage:
 * 
 * &lt;rhn:highlight tag="foo" text="test"&gt;
 *     This is a test body of text.
 * &lt;/rhn:highlight&gt;
 * Result: This is a &lt;foo&gt;test&lt;/foo&gt; body of text.
 * 
 * &lt;rhn:highlight startTag="&lt;foo color=blue&gt;" 
 *                   endTag="&lt;/foo&gt;" text="test"&gt;
 *     This is a test body of text.
 * &lt;/rhn:highlight&gt;
 * Result: This is a &lt;foo color=blue&gt;test&lt;/foo&gt; body of text.
 * 
 * &lt;rhn:highlight tag="font" startTag="&lt;foo color=blue&gt;" text="test"&gt;
 *     This is a test body of text.
 * &lt;/rhn:highlight&gt;
 * Result: This is a &lt;foo color=blue&gt;test&lt;/foo&gt; body of text.
 * 
 * Note: This is currently *not* to be used with formatted text. For example, If I 
 * had the following:
 *     &lt;rhn:highlight tag="foo" text="as"&gt;
 *         This is a &lt;div class="bar"&gt;test&lt;/div&gt; body of text.
 *     &lt;/rhn:highlight&gt;
 * we would get the result:
 *     This is a &lt;div cl&lt;foo&gt;as&lt;/foo&gt;s = "bar" &gt;test&lt;/div&gt; 
 *     body of text.
 * 
 * It would be cool if this tag was smart enough to tell whether or not it was inside 
 * of a tag and if so, skip the matching text, but that will have to wait for a future 
 * version.
 * 
 * @version $Rev$
 */
public class HighlightTag extends BodyTagSupport {

    private String tag;
    private String startTag;
    private String endTag;
    private String text;
    private static Logger log = Logger.getLogger(HighlightTag.class);
    
    /**
     * {@inheritDoc}
     */
    public int doEndTag() throws JspException {

        // Make sure there is something in the body for this tag
        // to process
        BodyContent bc = getBodyContent();
        if (bc == null) {
            return SKIP_BODY;
        }
        
        // Make sure tags are set and valid.
        initTags();

        String body = bc.getString();
        String search = "(" + text + ")"; //add grouping so we can get correct case out
        
        try {
            Pattern pattern = Pattern.compile(search, 
                                              Pattern.CASE_INSENSITIVE | 
                                              Pattern.UNICODE_CASE);
            
            Matcher matcher = pattern.matcher(body);
            
            body = matcher.replaceAll(startTag + "$1" + endTag);
        }
        catch (PatternSyntaxException e) {
            log.warn("highlighting disabled. Invalid pattern [" + search +
                    "]." + e.getMessage());
        }

        try {
            pageContext.getOut().println(body);
        }
        catch (IOException ioe) {
            throw new JspException("IO error writing to JSP file:", ioe);
        }
        
        return EVAL_PAGE;
    }
    
    /**
     * initTags
     * Since there are a few ways to use this tag, we need to 
     * make sure that we have the minimum amount of data we need
     * to work with.
     * @throws JspException
     */
    private void initTags() throws JspException {

        if (tag == null) {
            /*
             * If tag is null, that means startTag and endTag should have 
             * been set in the tag and shouldn't be messed with. Make sure 
             * both startTag and endTag exist and return.
             */
            if (startTag == null || endTag == null) {
                throw new JspException("Tag error: must define tag " +
                                       "or both startTag and endTag");
            }
            else {
                return;
            }
        }
        
        /*
         * Set start/end Tags. Leave over-ridden tags alone. For example,
         * someone could use the tag like:
         * <rhn:highlight tag="font" startTag="<font color=blue>"...
         * leaving the endTag out.
         */
        if (startTag == null) {
            startTag = "<" + tag + ">";
        }
        
        if (endTag == null) {
            endTag = "</" + tag + ">";
        }
    }
    
    /**
     * @return Returns the tag.
     */
    public String getTag() {
        return tag;
    }
    
    /**
     * @param t The tag to set.
     */
    public void setTag(String t) {
        this.tag = t;
    }
    
    /**
     * @return Returns the endTag.
     */
    public String getEndTag() {
        return endTag;
    }
    
    /**
     * @param e The endTag to set.
     */
    public void setEndTag(String e) {
        this.endTag = e;
    }
    
    /**
     * @return Returns the startTag.
     */
    public String getStartTag() {
        return startTag;
    }
    
    /**
     * @param s The startTag to set.
     */
    public void setStartTag(String s) {
        this.startTag = s;
    } 
    
    /**
     * @return Returns the text.
     */
    public String getText() {
        return text;
    }
    
    /**
     * @param t The text to set.
     */
    public void setText(String t) {
        this.text = t;
    }

    /**
     * {@inheritDoc}
     */
    public void release() {
        tag = null;
        startTag = null;
        endTag = null;
        text = null;
        super.release();
    }
}
