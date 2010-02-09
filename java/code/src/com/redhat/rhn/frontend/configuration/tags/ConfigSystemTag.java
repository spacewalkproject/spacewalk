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
package com.redhat.rhn.frontend.configuration.tags;

import org.apache.commons.lang.StringEscapeUtils;

import javax.servlet.jsp.JspException;
import javax.servlet.jsp.tagext.BodyTagSupport;
import javax.servlet.jsp.tagext.TagSupport;

/**
 * ConfigSystemTag
 * @version $Rev$
 */
public class ConfigSystemTag extends TagSupport {

    /**
     * Comment for <code>serialVersionUID</code>
     */
    private static final long serialVersionUID = 1582063245840138731L;

    public static final String SYSTEM_ALT_KEY = "system.common.systemAlt";
    public static final String SYSTEM_LIST_ICON = "/img/rhn-listicon-system.gif";
    public static final String SYSTEM_HEADER_ICON = "/img/rhn-icon-system.gif";
    public static final String SYSTEM_URL = 
        "/rhn/systems/details/configuration/Overview.do";
    
    /**
     * <cfg:system id=""  name="" nolink="">  
     */
     private String id;
     private String name;
     private boolean nolink;

     /**
      * {@inheritDoc}
      */
     public int doEndTag() throws JspException {
         if (nolink  || id == null) {
             writeIcon();
             ConfigTagHelper.write(StringEscapeUtils.escapeXml(name), pageContext);
         }
         else {
             String url = makeConfigSystemUrl(id);
             ConfigTagHelper.write("<a href=\"" + url + "\">", pageContext);
             writeIcon();
             ConfigTagHelper.write(StringEscapeUtils.escapeXml(name) + "</a>", pageContext);
         }
         return BodyTagSupport.SKIP_BODY;
     }
     
     /**
      * {@inheritDoc}
      */
     public void release() {
         id = null;
         name = null;
         nolink = false;
         super.release();
     }

     
     /**
      * @param val the id to set
      */
     public void setId(String val) {
         this.id = val;
     }

     
     /**
      * @param isNoLink the nolink to set
      */
     public void setNolink(String isNoLink) {
         this.nolink = Boolean.TRUE.toString().equalsIgnoreCase(isNoLink);
     }

     
     /**
      * @param value the name to set
      */
     public void setName(String value) {
         this.name = value;
     }
     
     private void writeIcon() throws JspException {
        ConfigTagHelper.writeIcon(SYSTEM_LIST_ICON, SYSTEM_ALT_KEY, pageContext);
     }
     
     /**
     * Returns the URL to reach the SDC\ConfigOverview page for a system. 
     * This method may also be used with the el expression
     * ${config:systemUrl('id')}
     * This method is public static because
     * EL functions defined in a TLD file, 
     * need to be public static methods.. systemConfig file
     * @param id the SID of the system in question
     * @return the URL to reach the cfg-overview page in the SDC
     */
    public static String makeConfigSystemUrl(String id) {
        return SYSTEM_URL + "?sid=" + id;
    }

    /**
      * Returns the Header icon image path for a system
      * This method is public static because
      * EL functions defined in a TLD file, 
      * need to be public static methods.. 
      * @return the image path
      */
     public static final String getHeaderIconFor() {
         return SYSTEM_HEADER_ICON;
     }

     /**
      * Returns the List icon image path for a system
      * This method is public static because
      * EL functions defined in a TLD file, 
      * need to be public static methods.. 
      * @return the image path
      */
     public static final String getListIconFor() {
         return SYSTEM_LIST_ICON;
     }
          
     
     /**
      * Returns the Header alt key  for a system
      * This method is public static because
      * EL functions defined in a TLD file, 
      * need to be public static methods..  
      * @return the alt key 
      */
     public static final String getAltKeyFor() {
         return SYSTEM_ALT_KEY;     
     }     
}
