/**
 * Copyright (c) 2008 Red Hat, Inc.
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
package com.redhat.rhn.manager.kickstart;

import com.redhat.rhn.domain.kickstart.KickstartData;

import org.apache.commons.lang.StringEscapeUtils;


/**
 * Simple helper class to ecapsulate logic around determining 
 * kickstart file and media urls.
 * 
 * @version $Rev$
 */
public class KickstartUrlHelper {
    
    private KickstartData ksData;
    private String host;
    
    /**
     * Constructor.
     * 
     * @param ksDataIn who's URL you desire.
     * @param hostIn who is hosting the kickstart file.
     */
    public KickstartUrlHelper(KickstartData ksDataIn, String hostIn) {
        this.ksData = ksDataIn;
        this.host = hostIn;
    }
    

    /**
     * The definitive method for getting the URL to a given 
     * Kickstart profile on the Spacewalk server.  If your Kickstart 
     * profile is named 'rhel5-Server-i386' the url would be:
     * 
     * http://spacewalk.example.com/kickstart/ks/org/1/label/rhel5-Server-i386 
     * 
     * @return String url to kickstart file
     */
    public String getKickstartFileUrl() {
        
        StringBuffer urlBuf = new StringBuffer();        
        urlBuf.append("/label/");
        urlBuf.append(StringEscapeUtils.escapeHtml(ksData.getLabel()));

        return getKickstartFileUrlBase() + urlBuf.toString();
    }
    
    /**
     * The base for a kickstart URL including the org:
     * 
     * http://spacewalk.example.com/kickstart/ks/org/1/ 
     * 
     * @return String url to kickstart file
     */
    public String getKickstartFileUrlBase() {
        
        StringBuffer urlBase = new StringBuffer();
        urlBase.append("http://");
        urlBase.append(host);
        urlBase.append("/kickstart/ks/org/"); 
        urlBase.append(ksData.getOrg().getId().toString()); 
        
        /*String host = helper.getKickstartHost();

        StringBuffer urlBase = new StringBuffer();
        urlBase.append("http://");
        urlBase.append(host);
        urlBase.append("/kickstart/ks/org/");
        urlBase.append(encodedData);

        StringBuffer urlBuf = new StringBuffer();
        urlBuf.append("/label/");
        urlBuf.append(StringEscapeUtils.escapeHtml(cmd.getKickstartData().getLabel()));

        request.setAttribute(URL, urlBase.toString() + urlBuf.toString());
        request.setAttribute(URLRANGE, urlBase.toString() + "/mode/ip_range");
        */
        
        return urlBase.toString();
    }
    
    
    /**
     * Get the URL for the ip_range file server. Example:
     * 
     * http://spacewalk.example.com/kickstart/ks/org/1/mode/ip_range
     * 
     * The above URL examines the requesters IP address to determine what ks profile
     * they should get.
     * 
     * @return String URL 
     */
    public String getKickstartFileUrlIpRange() {
        return getKickstartFileUrlBase() + "/mode/ip_range";
    }
    
    
}
