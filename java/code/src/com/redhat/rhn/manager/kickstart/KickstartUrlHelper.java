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

import com.redhat.rhn.common.security.SessionSwap;
import com.redhat.rhn.domain.common.CommonFactory;
import com.redhat.rhn.domain.common.TinyUrl;
import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.KickstartSession;

import org.apache.commons.lang.StringEscapeUtils;
import org.apache.log4j.Logger;

import java.util.Date;


/**
 * Simple helper class to ecapsulate logic around determining 
 * kickstart file and media urls.
 * 
 * @version $Rev$
 */
public class KickstartUrlHelper {

    private static Logger log = Logger.getLogger(KickstartUrlHelper.class);
    
    public static final String KS_DIST = "/ks/dist";
    public static final String KS_CFG = "/ks/cfg";
    
    private KickstartData ksData;
    private String host;
    private String protocol;
    
    /**
     * Constructor.
     * 
     * @param ksDataIn who's URL you desire.
     * @param hostIn who is hosting the kickstart file.
     */
    public KickstartUrlHelper(KickstartData ksDataIn, String hostIn) {
        this.ksData = ksDataIn;
        this.host = hostIn;
        this.protocol = "http://";
    }
    
    /**
     * Constructor with specification of protocol
     * 
     * @param ksDataIn who's URL you desire.
     * @param hostIn who is hosting the kickstart file.
     * @param protocolIn to use in the URL
     */
    public KickstartUrlHelper(KickstartData ksDataIn, String hostIn, String protocolIn) {
        this.ksData = ksDataIn;
        this.host = hostIn;
        this.protocol = protocolIn;
    }
    
    /**
     * Get the 'view only' url for a Kickstart cfg file
     * 
     * @return String url
     */
    public String getKickstartViewUrl() {

        StringBuffer urlBuf = new StringBuffer();        
        urlBuf.append("/view_label/");
        urlBuf.append(StringEscapeUtils.escapeHtml(ksData.getLabel()));

        return getKickstartFileUrlBase() + urlBuf.toString();
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
        urlBase.append(protocol);
        urlBase.append(host);
        urlBase.append(KS_CFG + "/org/"); 
        urlBase.append(ksData.getOrg().getId().toString()); 
        
        return urlBase.toString();
    }
    
    /**
     * Get the URL to the org_default for this Org.  Looks like this:
     * 
     * https://rhn.redhat.com/kickstart/ks/org/
     *   2824120xe553d920d21606ccfc668e13bd8d8e3f/org_default
     * 
     * @return String url
    */
    public String getKickstartOrgDefaultUrl() { 
        return getKickstartFileUrlBase() + "/org_default";
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

    /**
     * Get the --url parameter for this kickstart.
     * 
     * @return String url to this KickstartData's --url
     */
    public String getKickstartMediaUrl() {
        log.debug("Formatting for view use.");
        // /kickstart/dist/ks-rhel-i386-as-4-u2
        StringBuffer file = new StringBuffer();
        file.append(KS_DIST);
        file.append(ksData.getTree().getLabel());
        StringBuffer url = new StringBuffer();
        url.append(protocol + host + file.toString());
        log.debug("returning: " + url);
        return url.toString();
    }
    
    
    /**
     * Get the --url parameter for this kickstart that is used
     * during a Kickstart Session that tracks the downloads.
     * 
     * eg: http://spacewalk.example.com/ks/dist/session/  
     *                35x45fed383beaeb31a184166b4c1040633/ks-f9-x86_64
     * @param session to compute tracking URL for.
     *                
     * @return String url to this KickstartData's media (packages, kernel
     * etc...)
     */
    public String getKickstartMediaSessionUrl(KickstartSession session) {
        log.debug("Formatting for session use.");
        // /ks/dist/session/
        // 94xe86321bae3cb74551d995e5eafa065c0/ks-rhel-i386-as-4-u2
        StringBuffer file = new StringBuffer();
        file.append(KS_DIST + "/session/");
        file.append(SessionSwap.encodeData(session.getId().toString()));
        file.append("/");
        file.append(ksData.getTree().getLabel());
        TinyUrl turl = CommonFactory.createTinyUrl(file.toString(), 
                new Date());
        CommonFactory.saveTinyUrl(turl);
        log.debug("returning: " + turl.computeTinyUrl(this.host));
        return turl.computeTinyUrl(this.host);
    }
    
    
    
    
}
