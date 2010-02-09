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

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.frontend.html.HtmlTag;
import com.redhat.rhn.manager.acl.AclManager;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.jsp.JspException;
import javax.servlet.jsp.JspWriter;
import javax.servlet.jsp.tagext.TagSupport;

/**
 * The ToolbarTag generates a toolbar showing the page title, optional 
 * help link, and action buttons to the right of the page.
 * <p>
 * <pre>
 * &lt;rhn:toolbar base="h1" img="/img/somegraphic.gif"&gt;
 * </pre>
 * <p> 
 * Basic Attributes:<br>
 * <ul>
 * <li>base - base html tag for wrapping the toolbar.
 * <li>img - img url which is displayed to the left of the page title.
 * <li>altImg - alt text for the img
 * <li>helpUrl - link to the help pages.
 * </ul>
 * <P>
 * Action Attributes:<br>
 * <ul>
 * <li>create button
 *     <ul>
 *     <li>url (required) - location of action button
 *     <li>acl - Acl limiting view of button
 *     <li>type (required) - type action is taken upon i.e. user
 *     </ul>
 * <li>delete button
 *     <ul>
 *     <li>url (required) - location of action button
 *     <li>acl - Acl limiting view of button
 *     <li>type (required) - type action is taken upon i.e. user
 *     </ul>
 * <li>misc link
 *     <ul>
 *     <li>url (required) - link location
 *     <li>acl - Acl limiting view of link
 *     <li>text (required) - link text
 *     <li>alt (required) - alternate link text
 *     <li>img (required) - image to be displayed for link
 *     </ul>
 * </ul>
 * @version $Rev$
 */
public class ToolbarTag extends TagSupport {
    private String base;
    private String img;
    private String imgAlt;
    private String helpUrl;
    private String aclMixins;
    private String miscImg;
    private String miscAcl;
    private String miscUrl;
    private String miscText;
    private String miscAlt;
    private String creationUrl;
    private String creationAcl;
    private String creationType;
    private String uploadUrl;
    private String uploadAcl;
    private String uploadType;
    private String cloneUrl;
    private String cloneAcl;
    private String cloneType;
    private String deletionUrl;
    private String deletionAcl;
    private String deletionType;
    private HtmlTag baseTag;
    private HtmlTag toolbarDivTag;


    /**
     * Constructor for tag.
     */
    public ToolbarTag() {
        super();
    }

    /**
     * 
     */
    private void assertBase() {
        if (base == null || "".equals(base)) {
            throw new IllegalArgumentException("No base url");
        }
    }
    
    /**
     * Sets the required base HTML tag used to surround the toolbar.
     * @param b valid html tag.
     */
    public void setBase(String b) {
        base = b;
    }
    
    /**
     * Returns the required base HTML tag used to surround the toolbar.
     * @return the required base HTML tag used to surround the toolbar.
     */
    public String getBase() {
        assertBase();
        return base;
    }
    
    /**
     * Sets the help url which is used to link to the help pages.
     * @param helpurl the help url which is used to link to the help pages.
     */
    public void setHelpUrl(String helpurl) {
        helpUrl = helpurl;
    }
    
    /**
     * Returns the help url which is used to link to the help pages.
     * @return the help url which is used to link to the help pages.
     */
    public String getHelpUrl() {
        return helpUrl;
    }
    
    /**
     * Sets the Acl classnames to be mixed in.  The mixins
     * are applied in addition to the other acls.
     * @param mixins A comma separated list of Acl classnames.
     * @see ToolbarTag#getCreationAcl()
     * @see ToolbarTag#getDeletionAcl()
     * @see ToolbarTag#getMiscAcl()
     */
    public void setAclMixins(String mixins) {
        aclMixins = mixins;
    }
    
    /**
     * @return a comma separated list of Acl classnames to be mixed in.
     * @see ToolbarTag#getCreationAcl()
     * @see ToolbarTag#getDeletionAcl()
     * @see ToolbarTag#getMiscAcl()
     */
    public String getAclMixins() {
        return aclMixins;
    }
    
    /**
     * Sets the image location which is displayed.
     * @param imgurl the location of the image.
     */
    public void setImg(String imgurl) {
        img = imgurl;
    }
    
    /**
     * Returns the image location to be displayed.
     * @return the image location to be displayed.
     */
    public String getImg() {
        return img;
    }
    
    /**
     * @return Returns the localization key that will resolve to the alt text of the img.
     */
    public String getImgAlt() {
        return imgAlt;
    }

    /**
     * @param imgAltIn Sets the localization key that will resolve 
     * to the alt text of the img
     */
    public void setImgAlt(String imgAltIn) {
        this.imgAlt = imgAltIn;
    }
    
    /**
     * Sets the image used for the misc link.
     * @param miscimg URL to image file.
     */
    public void setMiscImg(String miscimg) {
        miscImg = miscimg;
    }
    
    /**
     * Returns the url for the misc image file.
     * @return the url for the misc image file.
     */
    public String getMiscImg() {
        return miscImg;
    }
    
    /**
     * Sets the deletion type to be acted upon.
     * @param deltype the deletion type to be acted upon.
     */
    public void setDeletionType(String deltype) {
        deletionType = deltype;
    }
    
    /**
     * Returns the deletion type to be acted upon.
     * @return the deletion type to be acted upon.
     */
    public String getDeletionType() {
        return deletionType;
    }
    
    /**
     * Sets the acl used to control access to the deletion action button.
     * @param delacl the acl used to control access to the deletion action
     * button.
     */
    public void setDeletionAcl(String delacl) {
        deletionAcl = delacl;
    }
    
    /**
     * Returns the acl used to control access to the deletion action button.
     * @return the acl used to control access to the deletion action button.
     */
    public String getDeletionAcl() {
        return deletionAcl;
    }
    
    /**
     * Sets the url pointed by the deletion action button.
     * @param delurl the url pointed by the deletion action button.
     */
    public void setDeletionUrl(String delurl) {
        deletionUrl = delurl;
    }
    
    /**
     * Returns the url pointed by the deletion action button.
     * @return the url pointed by the deletion action button.
     */
    public String getDeletionUrl() {
        return deletionUrl;
    }
    
    /**
     * Sets the creation type to be acted upon.
     * @param createtype the creation type to be acted upon.
     */
    public void setCreationType(String createtype) {
        creationType = createtype;
    }
    
    /**
     * Returns the creation type to be acted upon.
     * @return the creation type to be acted upon.
     */
    public String getCreationType() {
        return creationType;
    }
    
    /**
     * Sets the acl used to control access to the creation action button.
     * @param createacl the acl used to control access to the creation
     * action button.
     */
    public void setCreationAcl(String createacl) {
        creationAcl = createacl;
    }
    
    /**
     * Returns the acl used to control access to the creation action button.
     * @return the acl used to control access to the creation action button.
     */
    public String getCreationAcl() {
        return creationAcl;
    }
    
    /**
     * Sets the url pointed by the creation action button.
     * @param createurl the url pointed by the creation action button.
     */
    public void setCreationUrl(String createurl) {
        creationUrl = createurl;
    }
    
    /**
     * Returns the url pointed by the creation action button.
     * @return the url pointed by the creation action button.
     */
    public String getCreationUrl() {
        return creationUrl;
    }
    
    
    /**
     * Sets the clone type to be acted upon.
     * @param clonetype the creation type to be acted upon.
     */
    public void setCloneType(String clonetype) {
        cloneType = clonetype;
    }
    
    /**
     * Returns the clone type to be acted upon.
     * @return the clone type to be acted upon.
     */
    public String getCloneType() {
        return cloneType;
    }
    
    /**
     * Sets the acl used to control access to the clone action button.
     * @param cloneacl the acl used to control access to the clone
     * action button.
     */
    public void setCloneAcl(String cloneacl) {
        cloneAcl = cloneacl;
    }
    
    /**
     * Returns the acl used to control access to the clone action button.
     * @return the acl used to control access to the clone action button.
     */
    public String getCloneAcl() {
        return cloneAcl;
    }
    
    /**
     * Sets the url pointed by the clone action button.
     * @param cloneurl the url pointed by the clone action button.
     */
    public void setCloneUrl(String cloneurl) {
        cloneUrl = cloneurl;
    }
    
    /**
     * Returns the url pointed by the clone action button.
     * @return the url pointed by the clone action button.
     */
    public String getCloneUrl() {
        return cloneUrl;
    }
    
    
    /**
     * Sets the acl used to control access to the miscellaneous link.
     * @param miscacl the acl used to control access to the miscellaneous link.
     */
    public void setMiscAcl(String miscacl) {
        miscAcl = miscacl;
    }
    
    /**
     * Returns the acl used to control access to the miscellaneous link.
     * @return the acl used to control access to the miscellaneous link.
     */
    public String getMiscAcl() {
        return miscAcl;
    }
    
    /**
     * Sets the url pointed by the miscellaneous link.
     * @param miscurl url for the miscellaneous link.
     */
    public void setMiscUrl(String miscurl) {
        miscUrl = miscurl;
    }
    
    /**
     * Returns the url pointed by the miscellaneous link.
     * @return the url pointed by the miscellaneous link.
     */
    public String getMiscUrl() {
        return miscUrl;
    }
    
    /**
     * Sets the alternate text for the miscellaneous link.
     * @param alt alternate text for the miscellaneous link.
     */
    public void setMiscAlt(String alt) {
        miscAlt = alt;
    }
    
    /**
     * Returns the alternate text for the miscellaneous link.
     * @return the alternate text for the miscellaneous link.
     */
    public String getMiscAlt() {
        return miscAlt;
    }
    
    /**
     * Sets the text for the miscellaneous link.
     * @param text text for the miscellaneous link.
     */
    public void setMiscText(String text) {
        miscText = text;
    }
    
    /**
     * Returns the text for the miscellaneous link.
     * @return the text for the miscellaneous link.
     */
    public String getMiscText() {
        return miscText;
    }
    
    
    /** 
     * {@inheritDoc} 
     * @throws JspException
     */
    public int doStartTag() throws JspException {
        JspWriter out = null;
        try {
            StringBuffer buf = new StringBuffer();
            out = pageContext.getOut();
            
            baseTag = new HtmlTag("div");
            baseTag.setAttribute("class", "toolbar-" + getBase());
            
            toolbarDivTag = new HtmlTag("div");
            toolbarDivTag.setAttribute("class", "toolbar");
            buf.append(baseTag.renderOpenTag());
            buf.append(toolbarDivTag.renderOpenTag());
            
            buf.append(renderCreationLink());
            buf.append(renderCloneLink());
            buf.append(renderUploadLink());
            buf.append(renderDeletionLink());
            buf.append(renderMiscLink());
            buf.append(toolbarDivTag.renderCloseTag());
            buf.append(renderImgUrl());
            
            out.print(buf.toString());
            return (EVAL_BODY_INCLUDE);
        }
        catch (Exception e) {
            throw new JspException("Error writing to JSP file:", e);
        }
    }
    
    /**
     * {@inheritDoc}
     */
    public int doEndTag() throws JspException {
        JspWriter out = null;
        try {
            StringBuffer buf = new StringBuffer();
            out = pageContext.getOut();
            
            buf.append(renderHelpUrl());

            buf.append(baseTag.renderCloseTag());
            
            out.print(buf.toString());
            return (EVAL_PAGE);
        }
        catch (Exception e) {
            e.printStackTrace();
            throw new JspException("Error writing to JSP file:", e);
        }
    }
    
    private String renderHelpUrl() {
        if (assertNotEmpty(getHelpUrl())) {

            HtmlTag tag = new HtmlTag("a");
            tag.setAttribute("href", getHelpUrl());
            tag.setAttribute("target", "_new");
            tag.setAttribute("class", "help-title");
            HtmlTag helpImg = new HtmlTag("img");
            helpImg.setAttribute("src", "/img/rhn-icon-help.gif");
            helpImg.setAttribute("alt", 
                                 LocalizationService.getInstance().
                                 getMessage("toolbar.jsp.helpicon.alt"));
            tag.addBody(helpImg);
            return tag.render();
        }
        return "";
    }
    
    private String renderImgUrl() {
        if (assertNotEmpty(getImg())) {
            HtmlTag tag = new HtmlTag("img");
            tag.setAttribute("src", getImg());
            
            if (imgAlt != null) {
                tag.setAttribute("alt", LocalizationService.getInstance().
                getMessage(imgAlt));
            }
            return tag.render();           
        }
        return "";
    }
    
    private String renderCreationLink() {
        if (evalAcl(getCreationAcl()) && assertNotEmpty(getCreationType()) &&
                assertNotEmpty(getCreationUrl())) {
            
            String create = "toolbar.create." + getCreationType();
            return renderActionLink(getCreationUrl(), create,
                                    create, "action-add.gif");
        }
        return "";
    }
    
    private String renderCloneLink() {
        if (evalAcl(getCloneAcl()) && assertNotEmpty(getCloneType()) &&
                assertNotEmpty(getCloneUrl())) {
            
            String clone = "toolbar.clone." + getCloneType();
            return renderActionLink(getCloneUrl(), clone,
                                    clone, "action-clone.gif");
        }
        return "";
    }
    
    private String renderDeletionLink() {
        if (evalAcl(getDeletionAcl()) && assertNotEmpty(getDeletionType()) &&
                assertNotEmpty(getDeletionUrl())) {

            String del = "toolbar.delete." + getDeletionType();
            return renderActionLink(getDeletionUrl(), del, del, "action-del.gif");
        }
        return "";
    }

    private String renderUploadLink() {
        if (evalAcl(getUploadAcl()) && assertNotEmpty(getUploadType()) &&
                assertNotEmpty(getUploadUrl())) {

            String del = "toolbar.upload." + getUploadType();
            return renderActionLink(getUploadUrl(), del, del, "action-upload.gif");
        }
        return "";
    }    
    private String renderMiscLink() {
        if (evalAcl(getMiscAcl()) &&
                assertNotEmpty(getMiscUrl()) &&
                assertNotEmpty(getMiscText()) &&
                assertNotEmpty(getMiscImg())) {
            return renderActionLink(getMiscUrl(), getMiscText(),
                                    getMiscAlt(), getMiscImg());
        }
        return "";
    }
    
    private String renderActionLink(String url, String text,
                                    String alt, String imgName) {
        if (url == null) {
            return "";
        }
        
        alt = LocalizationService.getInstance().getMessage(alt);
        text = LocalizationService.getInstance().getMessage(text);
        
        HtmlTag span = new HtmlTag("span");
        HtmlTag a = new HtmlTag("a");
        HtmlTag imgTag = new HtmlTag("img");
        
        span.setAttribute("class", "toolbar");
        a.setAttribute("href", url);
        imgTag.setAttribute("src", "/img/" + imgName);
        imgTag.setAttribute("alt", alt);
        imgTag.setAttribute("title", alt);

        span.addBody(a);
        a.addBody(imgTag);
        a.addBody(text);
        
        return span.render();
    }

    
    private boolean evalAcl(String acl) {
        HttpServletRequest request = (HttpServletRequest) pageContext.getRequest();
        return AclManager.hasAcl(acl, request, getAclMixins());
    }

    private boolean assertNotEmpty(String str) {
        return (str != null && !"".equals(str));
    }

    /**
     * {@inheritDoc}
     */
    public void release() {
        base = null;
        img = null;
        imgAlt = null;
        helpUrl = null;
        aclMixins = null;
        miscImg = null;
        miscAcl = null;
        miscUrl = null;
        miscText = null;
        miscAlt = null;
        creationUrl = null;
        creationAcl = null;
        creationType = null;
        cloneUrl = null;
        cloneAcl = null;
        cloneType = null;
        deletionUrl = null;
        deletionAcl = null;
        deletionType = null;
        baseTag = null;
        toolbarDivTag = null;
        
        super.release();
    }

    
    /**
     * @return the uploadUrl
     */
    public String getUploadUrl() {
        return uploadUrl;
    }

    
    /**
     * @param url the uploadUrl to set
     */
    public void setUploadUrl(String url) {
        this.uploadUrl = url;
    }

    
    /**
     * @return the uploadAcl
     */
    public String getUploadAcl() {
        return uploadAcl;
    }

    
    /**
     * @param acl the uploadAcl to set
     */
    public void setUploadAcl(String acl) {
        this.uploadAcl = acl;
    }

    
    /**
     * @return the uploadType
     */
    public String getUploadType() {
        return uploadType;
    }

    
    /**
     * @param type the uploadType to set
     */
    public void setUploadType(String type) {
        this.uploadType = type;
    }
}
