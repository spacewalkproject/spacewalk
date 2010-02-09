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

import com.redhat.rhn.domain.config.ConfigFileType;

import org.apache.commons.lang.StringEscapeUtils;
import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;

import javax.servlet.jsp.JspException;
import javax.servlet.jsp.tagext.BodyTagSupport;
import javax.servlet.jsp.tagext.TagSupport;


/**
 * ConfigFileTag
 * @version $Rev$
 */
public class ConfigFileTag extends TagSupport {

    /**
     * Comment for <code>serialVersionUID</code>
     */
    private static final long serialVersionUID = 1582063245840138731L;

    private static final Logger LOG = Logger.getLogger(ConfigFileTag.class);    
    
    public static final String DIR_ALT_KEY = "config.common.dirAlt";
    public static final String FILE_ALT_KEY = "config.common.fileAlt";
    public static final String SYMLINK_ALT_KEY = "config.common.symlinkAlt";

    
    public static final String DIR_LIST_ICON = "/img/rhn-listicon-cfg_folder.gif";
    public static final String FILE_LIST_ICON = "/img/rhn-listicon-cfg_file.gif";
    public static final String SYMLINK_LIST_ICON = "/img/rhn-listicon-cfg_symlink.gif";

    
    public static final String DIR_HEADER_ICON = "/img/folder-config.png";
    public static final String FILE_HEADER_ICON = "/img/file-config.png";

    
    public static final String FILE_URL = "/rhn/configuration/file/FileDetails.do";
    public static final String FILE_COMPARE_URL =
                                    "/rhn/configuration/file/CompareRevision.do";
    
    /**
     * <cfg:file id=""  value="" type="file|dir" revision="" nolink="">  
     */
     private String id;
     private String path;
     private String type;
     private boolean nolink;
     private String revisionId;

     /**
      * {@inheritDoc}
      */
     public int doEndTag() throws JspException {
         if (nolink  || id == null) {
             writeIcon();
             ConfigTagHelper.write(StringEscapeUtils.escapeXml(path), pageContext);
         }
         else {
             String url;
             if (revisionId != null) {
                 url = makeConfigFileRevisionUrl(id, revisionId);
             }
             else {
                 url = makeConfigFileUrl(id);
             }
             
             ConfigTagHelper.write("<a href=\"" + url + "\">", pageContext);
             writeIcon();
             ConfigTagHelper.write(StringEscapeUtils.escapeXml(path) + "</a>", pageContext);
         }
         return BodyTagSupport.SKIP_BODY;
     }
     
     /** 
      * {@inheritDoc}
      */
     public void release() {
         id = null;
         path = null;
         type = null;
         nolink = false;
         revisionId = null;
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
      * @param tp the type to set
      */
     public void setType(String tp) {
         this.type = tp;
     }

     
     /**
      * @param value the value to set
      */
     public void setPath(String value) {
         this.path = value;
     }
     
     /**
      * @param rev the revision to set
      */
     public void setRevisionId(String rev) {
         this.revisionId = rev;
     }
     
     private void writeIcon() throws JspException {
         if (checkType()) {
             if ("dir".equalsIgnoreCase(type) || 
                     "directory".equalsIgnoreCase(type) ||
                     "folder".equalsIgnoreCase(type)) {
                 ConfigTagHelper.writeIcon(DIR_LIST_ICON, DIR_ALT_KEY, pageContext);
             }
             else if ("symlink".equalsIgnoreCase(type)) {
                 ConfigTagHelper.writeIcon(SYMLINK_LIST_ICON, SYMLINK_ALT_KEY, pageContext);
             }
             else {
                 ConfigTagHelper.writeIcon(FILE_LIST_ICON, 
                                             FILE_ALT_KEY, pageContext);             
             }
         }
         else {
             ConfigTagHelper.writeErrorIcon(pageContext);
         }
     }

     /**
      * Checks to see if no invalid values are specified
      */
     private boolean checkType() {
         if ((StringUtils.isBlank(id) && StringUtils.isBlank(path)) || 
             (StringUtils.isBlank(type))) {
             return false;
         }
         try {
             ConfigFileType.lookup(type);
             return true;
         }
         catch (IllegalArgumentException ie) {
             String message = String.format("Error encoountered when " +
                                                     "handling -> %s  -  %s", id, path);
             LOG.warn(message + "\n" + ie.toString(), ie);
             return false;
         }
     }     
     
     /**
     * Returns the URL to view/edit a config file. 
     * This method may also be used with the el expression
     * ${config:fileUrl('id')}
     * This method is public static because
     * EL functions defined in a TLD file, 
     * need to be public static methods.. 
     * @param fileId the id of the given Config file
     * @return the URL to view/edit a config file
     */
    public static String makeConfigFileUrl(String fileId) {
        return FILE_URL + "?cfid=" + fileId;
    }

    /**
     * Returns the URL to view/edit a config revision. 
     * This method may also be used with the el expression
     * ${config:revisionUrl('fileId','revisionId')}
     * This method is public static because
     * EL functions defined in a TLD file, 
     * need to be public static methods.. 
     * @param fileId the id of the given Config file
     * @param revisionId the id of the given Config revision
     * @return the URL to view/edit a config revision
     */
    public static String makeConfigFileRevisionUrl(String fileId, 
                                                        String revisionId) {
        return FILE_URL + "?cfid=" +  fileId + "&amp;crid=" + revisionId;
    }

    /**
     * Returns the URL to compare different revisions of a config file. 
     * This method may also be used with the el expression
     * ${config:compareUrl('id')}
     * This method is public static because
     * EL functions defined in a TLD file, 
     * need to be public static methods.. 
     * @param fileId the id of the given Config file
     * @return the URL to view/edit a config file
     */
    public static String makeFileCompareUrl(String fileId) {
        return FILE_COMPARE_URL + "?cfid=" + fileId;
    }

    /**
      * Returns the Header icon image path for given config file type (file|dir)
      * This method is public static because
      * EL functions defined in a TLD file, 
      * need to be public static methods.. 
      * 
      * @param type (file|dir)
      * @return the image path
      */
     public static final String getHeaderIconFor(String type) {
         
         if ("dir".equalsIgnoreCase(type) || 
                 "directory".equalsIgnoreCase(type) ||
                 "folder".equalsIgnoreCase(type)) {
             return DIR_HEADER_ICON;
         }
         return FILE_HEADER_ICON;
     }
     
     /**
      * Returns the Header icon image path for given config file type (file|dir|symlink)
      * This method is public static because
      * EL functions defined in a TLD file, 
      * need to be public static methods.. 
      * 
      * @param type (file|dir)
      * @return the image path
      */
     public static final String getListIconFor(String type) {
         
         if ("dir".equalsIgnoreCase(type) || 
                 "directory".equalsIgnoreCase(type) ||
                 "folder".equalsIgnoreCase(type)) {
             return DIR_LIST_ICON;
         }
         else if ("symlink".equalsIgnoreCase(type)) {
             return SYMLINK_LIST_ICON;
         }
         return FILE_LIST_ICON;
     }
     
     
     /**
      * Returns the Header alt key  for a given config file type (file|dir|symlink)
      * This method is public static because
      * EL functions defined in a TLD file, 
      * need to be public static methods..  
      * @param type (file|dir)
      * @return the alt key 
      */
     public static final String getAltKeyFor(String type) {
         if ("dir".equalsIgnoreCase(type) || 
                 "directory".equalsIgnoreCase(type) ||
                 "folder".equalsIgnoreCase(type)) {
             return DIR_ALT_KEY;
         }
         else if ("symlink".equalsIgnoreCase(type)) {
             return SYMLINK_ALT_KEY;
         }
         return FILE_ALT_KEY;     
     }
}
