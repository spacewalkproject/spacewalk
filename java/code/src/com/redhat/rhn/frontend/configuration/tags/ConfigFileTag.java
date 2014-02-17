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

import java.io.IOException;

import com.redhat.rhn.frontend.taglibs.IconTag;

import org.apache.commons.lang.StringEscapeUtils;

import javax.servlet.jsp.JspException;
import javax.servlet.jsp.JspWriter;
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

    public static final String FILE_URL = "/rhn/configuration/file/FileDetails.do";
    public static final String FILE_COMPARE_URL =
                                        "/rhn/configuration/file/CompareRevision.do";

    /**
     * <cfg:file id=""  value="" type="file|dir" revision="" nolink="">
     */
     private String path;
     private String type;
     private boolean nolink;
     private String revisionId;

     /**
      * {@inheritDoc}
      */
     @Override
    public int doEndTag() throws JspException {
         StringBuilder result = new StringBuilder();
         if (nolink  || id == null) {
             result.append(writeIcon());
             result.append(StringEscapeUtils.escapeXml(path));
         }
         else {
             String url;
             if (revisionId != null) {
                 url = makeConfigFileRevisionUrl(id, revisionId);
             }
             else {
                 url = makeConfigFileUrl(id);
             }

             result.append("<a href=\"" + url + "\">");
             result.append(writeIcon());
             result.append(StringEscapeUtils.escapeXml(path) + "</a>");
         }
         JspWriter writer = pageContext.getOut();
         try {
             writer.write(result.toString());
         }
         catch (IOException e) {
             throw new JspException(e);
         }
         return BodyTagSupport.SKIP_BODY;
     }

     /**
      * {@inheritDoc}
      */
     @Override
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
     @Override
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

     private String writeIcon() throws JspException {
         IconTag i = new IconTag();
         if ("dir".equalsIgnoreCase(type) || "directory".equalsIgnoreCase(type) ||
                 "folder".equalsIgnoreCase(type)) {
             i.setType("file-directory");
         }
         else if ("symlink".equalsIgnoreCase(type)) {
             i.setType("file-symlink");
         }
         else {
             i.setType("file-file");
         }
         String result = i.renderStartTag();
         i.release();
         return result;
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

}
