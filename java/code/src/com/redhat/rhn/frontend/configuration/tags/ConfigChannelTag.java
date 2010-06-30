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

import com.redhat.rhn.domain.config.ConfigChannelType;

import org.apache.log4j.Logger;

import java.util.HashMap;
import java.util.Map;

import javax.servlet.jsp.JspException;
import javax.servlet.jsp.tagext.BodyTagSupport;
import javax.servlet.jsp.tagext.TagSupport;


/**
 * ConfigChannelTag
 * @version $Rev$
 */
public class ConfigChannelTag extends TagSupport {

    /**
    * <cfg:channel id="" value="" type="" size="large|small" nolink="">  
    */
    private String id;
    private String name;
    private String type;
    private boolean nolink;
    private static final Logger LOG = Logger.getLogger(ConfigChannelTag.class);
    private static final Map ICON_PATH_RETRIEVER = new HashMap();

    public static final String CENTRAL_ALT_KEY = "config.common.globalAlt";
    public static final String LOCAL_ALT_KEY = "config.common.localAlt";
    public static final String SANDBOX_ALT_KEY = "config.common.sandboxAlt";
    
    public static final String CENTRAL_LIST_ICON = "/img/rhn-listicon-channel.gif";
    public static final String LOCAL_LIST_ICON = "/img/rhn-listicon-system.gif";
    public static final String SANDBOX_LIST_ICON = "/img/rhn-listicon-sandbox.gif";
    
    public static final String CENTRAL_HEADER_ICON = "/img/rhn-config_central.gif";
    public static final String LOCAL_HEADER_ICON = "/img/rhn-config_system.gif";
    public static final String SANDBOX_HEADER_ICON = "/img/rhn-config_sandbox.gif";
    
    public static final String CHANNEL_URL = 
                                        "/rhn/configuration/ChannelOverview.do";
    
    /**
     * 
     * Comment for <code>serialVersionUID</code>
     */
    private static final long serialVersionUID = -8093937572650589326L;

    /**
     * {@inheritDoc}
     */
    public int doEndTag() throws JspException {
        if (nolink || id == null) {
            writeIcon();
            ConfigTagHelper.write("&nbsp;" + name, pageContext);
        }
        else {
            ConfigTagHelper.write("<a href=\"" + 
                        ConfigChannelTag.makeConfigChannelUrl(id) + 
                        "\">", pageContext);
            writeIcon();
            ConfigTagHelper.write("&nbsp;" + name + "</a>", pageContext);
        }
        return BodyTagSupport.SKIP_BODY;
    }
    
    /**
     * {@inheritDoc}
     */
    public void release() {
        id = null;
        name = null;
        type = null;
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
     * @param tp the type to set
     */
    public void setType(String tp) {
        this.type = tp;
        
    }

    /**
     * Checks to see if no invalid values are specified
     */
    private boolean checkType() {
        try {
            ConfigChannelType.lookup(type);
            return true;
        }
        catch (IllegalArgumentException ie) {
            LOG.warn(ie.getMessage());
            return false;
        }
        
        
    }

    
    /**
     * @param value the value to set
     */
    public void setName(String value) {
        this.name = value;
    }
    
    private void writeIcon() throws JspException {
        if (checkType()) {
            Map iconMap = getIconMap();
            
            String imgPath = (String)iconMap.get("LIST_" + type.toUpperCase());
            String altKey = (String)iconMap.get("KEY_" + type.toUpperCase());
            ConfigTagHelper.writeIcon(imgPath, altKey, pageContext);            
        }
        else {
            ConfigTagHelper.writeErrorIcon(pageContext);
        }

    }
    
    private static Map getIconMap() {
        if (ICON_PATH_RETRIEVER.isEmpty()) {
            ICON_PATH_RETRIEVER.put("LIST_LOCAL_OVERRIDE", LOCAL_LIST_ICON);
            ICON_PATH_RETRIEVER.put("HEADER_LOCAL_OVERRIDE", LOCAL_HEADER_ICON);
            ICON_PATH_RETRIEVER.put("KEY_LOCAL_OVERRIDE", LOCAL_ALT_KEY);            
            
            ICON_PATH_RETRIEVER.put("LIST_LOCAL", LOCAL_LIST_ICON);
            ICON_PATH_RETRIEVER.put("HEADER_LOCAL", LOCAL_HEADER_ICON);
            ICON_PATH_RETRIEVER.put("KEY_LOCAL", LOCAL_ALT_KEY);            
            
            
            ICON_PATH_RETRIEVER.put("LIST_NORMAL", CENTRAL_LIST_ICON);
            ICON_PATH_RETRIEVER.put("HEADER_NORMAL", CENTRAL_HEADER_ICON);
            ICON_PATH_RETRIEVER.put("KEY_NORMAL", CENTRAL_ALT_KEY);
            
            ICON_PATH_RETRIEVER.put("LIST_CENTRAL", CENTRAL_LIST_ICON);
            ICON_PATH_RETRIEVER.put("HEADER_CENTRAL", CENTRAL_HEADER_ICON);
            ICON_PATH_RETRIEVER.put("KEY_CENTRAL", CENTRAL_ALT_KEY);
            
            ICON_PATH_RETRIEVER.put("LIST_GLOBAL", CENTRAL_LIST_ICON);
            ICON_PATH_RETRIEVER.put("HEADER_GLOBAL", CENTRAL_HEADER_ICON);
            ICON_PATH_RETRIEVER.put("KEY_GLOBAL", CENTRAL_ALT_KEY);            
            
            ICON_PATH_RETRIEVER.put("LIST_SERVER_IMPORT", SANDBOX_LIST_ICON);            
            ICON_PATH_RETRIEVER.put("HEADER_SERVER_IMPORT", SANDBOX_HEADER_ICON);
            ICON_PATH_RETRIEVER.put("KEY_SERVER_IMPORT", SANDBOX_ALT_KEY);
            
            ICON_PATH_RETRIEVER.put("LIST_SANDBOX", SANDBOX_LIST_ICON);            
            ICON_PATH_RETRIEVER.put("HEADER_SANDBOX", SANDBOX_HEADER_ICON);
            ICON_PATH_RETRIEVER.put("KEY_SANDBOX", SANDBOX_ALT_KEY);            
        }
        
        return ICON_PATH_RETRIEVER;
    }

    
    /**
     * Returns the URL to view a config channel 
     * This method may also be used with the el expression
     * ${cfg:channelUrl(ccid)}
     * This method is public static because
     * EL functions defined in a TLD file, 
     * need to be public static methods..
     * @param ccId the id of the given Config Channel
     * @return the URL to view a config channel
     */
    public static String makeConfigChannelUrl(String ccId) {
        return CHANNEL_URL + "?ccid=" + ccId;
    }

    /**
     * Returns the Header icon image path  for a given channel type
     * This method is public static because
     * EL functions defined in a TLD file, 
     * need to be public static methods..     
     * @param type the config channel type
     * @return the image path
     */
    public static final String getHeaderIconFor(String type) {
        Map map = getIconMap();
        return (String) map.get("HEADER_" + type.toUpperCase());
    }

    /**
     * Returns the list icon image path  for a given channel type
     * This method is public static because
     * EL functions defined in a TLD file, 
     * need to be public static methods..     
     * @param type the config channel type
     * @return the image path
     */
    public static final String getListIconFor(String type) {
        Map map = getIconMap();
        return (String) map.get("LIST_" + type.toUpperCase());
    }    
    
    /**
     * Returns the Header alt key  for a given channel type
     * This method is public static because
     * EL functions defined in a TLD file, 
     * need to be public static methods.. 
     * @param type the config channel type
     * @return the alt key 
     */
    public static final String getAltKeyFor(String type) {
        Map map = getIconMap();
        return (String) map.get("KEY_" + type.toUpperCase());
    }    
}
