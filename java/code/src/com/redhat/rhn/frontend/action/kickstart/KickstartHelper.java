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
package com.redhat.rhn.frontend.action.kickstart;

import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.security.SessionSwap;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.manager.channel.ChannelManager;
import com.redhat.rhn.manager.kickstart.IpAddress;
import com.redhat.rhn.manager.kickstart.KickstartFormatter;
import com.redhat.rhn.manager.kickstart.KickstartManager;
import com.redhat.rhn.manager.kickstart.KickstartSessionCreateCommand;
import com.redhat.rhn.manager.kickstart.KickstartSessionUpdateCommand;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;

import java.net.MalformedURLException;
import java.net.URL;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.servlet.http.HttpServletRequest;

/**
 * KickstartHelper - helper class for KS UI processing
 * @version $Rev$
 */
public class KickstartHelper {
    
    private static Logger log = Logger.getLogger(KickstartHelper.class);
    
    private HttpServletRequest request;
    private static final String VIEW_LABEL = "view_label";
    private static final String LABEL = "label";
    private static final String ORG_DEFAULT = "org_default";
    private static final String IP_RANGE = "ip_range";
    private static final String SESSION = "session";
    private static final String SESSION_ID = "session_id";
    private static final String ORG = "org";
    private static final String HOST = "host";
    private static final String ORG_ID = "org_id";
    private static final String XFORWARD = "X-Forwarded-For";
    private static final String XFORWARD_REGEX = 
        "(\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}.\\d{1,3})";
    private static final String KSDATA = "ksdata";
    
    public static final String XRHNPROXYAUTH = "X-RHN-Proxy-Auth";
    
    /**
     * Constructor 
     * @param reqIn associated with this helper.
     */
    public KickstartHelper(HttpServletRequest reqIn) {
        this.request = reqIn;
    }
    
    /**
     * Parse a ks url and return a Map of options
     * Example: 
     *     "ks/org/3756992x3d9f6e2d5717e264c89b5ac18eb0c59e/label/kslabelfoo";
     *     
     * NOTE: This method also updates the KickstartSession.state field 
     * to "configuration_accessed"
     * 
     * @param url to parse
     * @return Map of options.  Usually containing host, ksdata, label and org_id
     */
    public Map parseKickstartUrl(String url) {
        Map retval = new HashMap();
        KickstartData ksdata = null;
        Map options = new HashMap();
        log.debug("url: " + url);
        List rawopts = Arrays.asList(
                StringUtils.split(url, '/'));

        for (Iterator iter = rawopts.iterator(); iter.hasNext();) {
            String name = (String) iter.next();
            if (iter.hasNext()) {
                String value = (String) iter.next();
                options.put(name, value);
            }
        }        
        
        log.debug("Options: " + options);
        
        String remoteAddr = getClientIp();
        
        // Process the org
        if (options.containsKey(ORG)) {
            String id = (String) options.get(ORG);
            retval.put(ORG_ID, id);
        }
        else {
            retval.put(ORG_ID, OrgFactory.getSatelliteOrg().getId().toString());
        }
        String mode = ORG_DEFAULT; // go ahead and make this the default profile
        // Process the session
        // /kickstart/ks/session/2xb7d56e8958b0425e762cc74e8705d8e7
        if (options.containsKey(SESSION)) {
            // update session
            String hashed = (String) options.get(SESSION);
            String[] ids = SessionSwap.extractData(hashed);
            retval.put(SESSION_ID, ids[0]);
            Long kssid = new Long(ids[0]);
            log.debug("sessionid: " + kssid);
            KickstartSessionUpdateCommand cmd = new KickstartSessionUpdateCommand(kssid);
            ksdata = cmd.getKsdata();
            retval.put(SESSION, cmd.getKickstartSession());
            log.debug("session: " + retval.get(SESSION));
            cmd.setSessionState(KickstartFactory.SESSION_STATE_CONFIG_ACCESSED);
            cmd.store();
            mode = SESSION;
        }

        log.debug("org_id: " + retval.get(ORG_ID));
        
        //TODO: reconsider/cleanup this logic flow
        if (retval.get(ORG_ID) != null) {       
            
            // Process label            
            if (options.containsKey(LABEL)) {
                retval.put(LABEL, options.get(LABEL));
                mode = LABEL;
            }
            else if (options.containsKey(VIEW_LABEL)) {
                retval.put(VIEW_LABEL, options.get(VIEW_LABEL));
                retval.put(LABEL, options.get(VIEW_LABEL));
                mode = LABEL;
            }
            else if (options.containsValue(IP_RANGE)) {                
                mode = IP_RANGE;
            }
            
            
            Org org = OrgFactory.lookupById(new Long((String) retval.get(ORG_ID)));
            if (mode.equals(LABEL)) {                
                String label = (String) retval.get(LABEL);
                ksdata = KickstartFactory.
                    lookupKickstartDataByLabelAndOrgId(label, org.getId()); 
            }
            else if (mode.equals(IP_RANGE)) {
                log.debug("Ip_range mode");
                IpAddress clientIp = new IpAddress(remoteAddr);       
                ksdata = KickstartManager.getInstance().findProfileForIpAddress(
                        clientIp, org);
            }
            else if (mode.equals(ORG_DEFAULT)) {
                //process org_default
                log.debug("Org_default mode.");
                ksdata = getOrgDefaultProfile(org);
            }
            
            
            if (log.isDebugEnabled()) {
                log.debug("session                        : " +  
                        retval.get(SESSION));
                log.debug("options.containsKey(VIEW_LABEL): " + 
                        options.containsKey(VIEW_LABEL));
                log.debug("ksdata                         : " +
                        ksdata);
            }
            // Create and add a KickstartSession if there isn't one already
            if (retval.get(SESSION) == null && !options.containsKey(VIEW_LABEL) &&
                    ksdata != null) {
                
                
                log.debug("Creating KickstartSession since there isnt one already.");
                KickstartSessionCreateCommand cmd = 
                    new KickstartSessionCreateCommand(org, ksdata, remoteAddr);
                cmd.store();
                
                retval.put(SESSION, cmd.getKickstartSession());
            }
        }
        // Add the host.
        retval.put(HOST, getKickstartHost());
        // Add ksdata
        retval.put(KSDATA, ksdata);
        
        
        if (retval.size() == 0) {
            retval = null;
        }
        return retval;
    }

    /**
     * Check to see if this request came through a proxy
     * @return boolean if proxied or not.
     */
    public boolean isProxyRequest() {
        return request.getHeader(XFORWARD) != null;
    }
    
    private String getClientIp() {
        String remoteAddr = request.getRemoteAddr();
        String proxyHeader = request.getHeader(XFORWARD);                
        
        // check if we are going through a proxy, grab real IP if so
        if (proxyHeader != null) {
            log.debug("proxy header in: " + proxyHeader);
            Matcher matcher = 
                Pattern.compile(XFORWARD_REGEX)
                .matcher(proxyHeader);
            if (matcher.lookingAt()) {
                remoteAddr = matcher.group(1);           
                log.debug("origination ip from pchain: " + remoteAddr);
            }        
        }              
        
        return remoteAddr;
    }
    
    
    /**
     * 
     * @param orgIdIn Org Id
     * @return Default Kickstart Data for Org
     */
    private KickstartData getOrgDefaultProfile(Org orgIn) {
        return KickstartFactory.lookupOrgDefault(orgIn);        
    }
    
    /**
     * Get the kickstart host to use. Will use the host of the proxy if the header is 
     * present. If not the code then resorts to getting the cobbler hostname from our
     * rhn.conf Config.
     * 
     * @return String representing the Kickstart Host
     */
    public String getKickstartHost() {
        log.debug("KickstartHelper.getKickstartHost()");
        
        // Example proxy header:
        // X-RHN-Proxy-Auth : 1006681409::1151513167.96:21600.0:VV/xF
        // NEmCYOuHxEBAs7BEw==:fjs-0-08.rhndev.redhat.com,1006681408
        // ::1151513034.3:21600.0:w2lm+XWSFJMVCGBK1dZXXQ==:fjs-0-11.
        // rhndev.redhat.com,1006678487::1152567362.02:21600.0:t15l
        // gsaTRKpX6AxkUFQ11A==:fjs-0-12.rhndev.redhat.com

        String proxyHeader = request.getHeader(XRHNPROXYAUTH);
        log.debug("X-RHN-Proxy-Auth : " + proxyHeader);
        
        if (!StringUtils.isEmpty(proxyHeader)) {
            String[] proxies = StringUtils.split(proxyHeader, ",");
            String firstProxy = proxies[0];
            // Now we have: 1006681409::1151513167.96:21600.0:VV/xF
            // NEmCYOuHxEBAs7BEw==:fjs-0-08.rhndev.redhat.com
            log.debug("first1: " + firstProxy);
            String[] chunks = StringUtils.split(firstProxy, ":");
            firstProxy = chunks[chunks.length - 1];
            log.debug("first2: " + firstProxy);
            log.debug("Kickstart host from proxy header: " + firstProxy);
            return firstProxy;
        }
        else {
            return ConfigDefaults.get().getCobblerHost();
        }
    }

    /**
     * @return String representing the kickstart protocol.
     */
    public String getKickstartProtocol() {

        String protocol = null;
        try {
            URL url = new URL(request.getRequestURL().toString());
            protocol = url.getProtocol();
        }
        catch (MalformedURLException e) {
            throw new IllegalArgumentException(
                "Bad argument when determining kickstart protocol.");
        }

        return protocol;
    }
    
    /**
     * Get the protocol plus the host:
     * 
     * http://host1.rhndev.redhat.com
     * 
     * @return proto plus host url
     */
    public String getKickstartProtocolAndHost() {
        String retval = getKickstartProtocol();
        
        
        retval = retval + "://" + getKickstartHost();
        return retval;
    }
    

    /**
     * @param org The Org to generate the token for.
     * @return A session-specific token for the given Org.
     */
    public String generateOrgToken(Org org) {
        String orgStr = org.getId().toString();
        return orgStr + "x" + SessionSwap.generateSwapKey(orgStr);
    }

    /**
     * Generates a URL suitable for downloading things related to a specific
     * kickstart session.
     * @param org The Org to generate the ks url for.
     * @param function The function that will be appended to the returned 
     *        kickstart url.
     * @return A string suitable for downloading kickstart-related things.
     */
    public String generateKickstartUrl(Org org, String function) {
        String protocol = getKickstartProtocol();
        String hostname = getKickstartHost();

        String orgToken = generateOrgToken(org);

        String url =
            protocol                            +
            "://"                               +
            hostname                            +
            "/kickstart/ks/org/"                +
            orgToken                            +
            "/"                                 +
            function                            +
            "/";

        return url;
    }
    
    /**
     * Verify that the kickstart channel is valid.
     * Valid kickstart channels must have a set list of packages described
     * by KickstartFormatter.UPDATE_PKG_NAMES and KickstartFormatter.FRESH_PKG_NAMES_RHEL34
     *
     * Also checks for auto-kickstart packages.
     * @param ksdata kickstart data containing the kickstart channel.
     * @param user The logged in user.
     * @return Whether the kickstart channel is a valid one.
     */
    public boolean verifyKickstartChannel(KickstartData ksdata, User user) {
        return verifyKickstartChannel(ksdata, user, true);
    }
    
    /**
     * Verify that the kickstart channel is valid.
     * Valid kickstart channels must have a set list of packages described
     * by KickstartFormatter.UPDATE_PKG_NAMES and KickstartFormatter.FRESH_PKG_NAMES_RHEL34
     * 
     * Non bare metal kickstarts also must have auto kickstart packages.
     * @param ksdata kickstart data containing the kickstart channel.
     * @param user The logged in user.
     * @param checkAutoKickstart Whether or not to verify the existence of
     *        auto-kickstart files. These are needed for many tasks, but are
     *        not necessary for generating kickstart files.
     * @return Whether the kickstart channel is a valid one.
     */
    public boolean verifyKickstartChannel(KickstartData ksdata, User user,
            boolean checkAutoKickstart) {
        if (ksdata.isRawData()) {
            //well this is Rawdata I am going to assume
            // its fine and dandy
            // In the future if we instead decide
            // that we need to do a channel
            // check on  a rawdata this is the place to fix that
            return true;
        }
        //I tried to make this readable while still maintaining all the boolean
        //shortcutting. Here is the one liner boolean:
        if (hasUpdates(ksdata) && hasFresh(ksdata) &&
                (!checkAutoKickstart || hasKickstartPackage(ksdata, user))) {
            return true;
        }
        return false;
    }
    
    private boolean hasUpdates(KickstartData ksdata) {
        if (ksdata.isRhel4() || ksdata.isRhel3() || ksdata.isRhel2()) {
            return hasPackages(ksdata.getChannel(), KickstartFormatter.UPDATE_PKG_NAMES);
        }
        else {
            return true;   
        }
    }
    
    private boolean hasFresh(KickstartData ksdata) {
        //There are different 'fresh packages' for different RHEL releases.
        //TODO: right now we do this a pretty ugly way -> we have a static
        //      list of fresh packages for the different releases and we
        //      check which one to use based on the install type suffix number.
        //      If we need to support more than two lists, we should probably
        //      make this a little more data driven.
        if (ksdata.isRhel2()) {
            return hasPackages(ksdata.getChannel(),
                    KickstartFormatter.FRESH_PKG_NAMES_RHEL2);
        }
        if (ksdata.isRhel3() || ksdata.isRhel4()) {
            return hasPackages(ksdata.getChannel(),
                    KickstartFormatter.FRESH_PKG_NAMES_RHEL34);
        }
        else {
            return true;
        }
    }
    
    private boolean hasPackages(Channel c, String[] packageNames) {
        log.debug("HasPackages: " + c.getId());
        //Go through every package name.
        for (int i = 0; i < packageNames.length; i++) {
            log.debug("hasPackages : Checking for package: " + packageNames[i]);
            Long pid = ChannelManager.getLatestPackageEqual(c.getId(), packageNames[i]);
            //No package by this name exists in this package.
            if (pid == null) {
                log.debug("hasPackages : not found");
                return false;
            }
        }
        //We have a pid from every package.
        return true;
    }
    
    private boolean hasKickstartPackage(KickstartData ksdata, User user) {
        //We expect this to be in the RHN Tools channel.
        //Check in the channel and all of its children channels
        Channel channel = ksdata.getChannel();
        log.debug("Checking on auto-ks in channel : " + channel.getId());
        List channelsToCheck = ChannelManager.userAccessibleChildChannels(
                user.getOrg().getId(), channel.getId());
        channelsToCheck.add(channel);
        
        Iterator i = channelsToCheck.iterator();
        while (i.hasNext()) {
            Channel current = (Channel) i.next();
            log.debug("Current.channel : " + current.getId());
            //Look for the auto-kickstart package.
            List kspackages = ChannelManager.listLatestPackagesLike(
                    current.getId(), 
                    ksdata.getKickstartPackageName());
            //found it, this channel is good.
            if (kspackages.size() > 0) {
                return true;
            }
            log.debug("package not found");
        }
        //We have checked every channel without luck.
        return false;
    }
    
    /**
     * Create a message to the user about having a kickstart channel that is missing
     * required packages.
     * @param ksdata The kickstart data that contains the kickstart channel.
     * @return Messages to add to the request.
     */
    public ActionMessages createInvalidChannelMsg(KickstartData ksdata) {
        ActionMessages msg = new ActionMessages();
        Object[] args = new Object[] {createPackageNameList(ksdata)};
        msg.add(ActionMessages.GLOBAL_MESSAGE,
                new ActionMessage("kickstart.invalidchannel.message", args));
        if (ksdata.getChannel().getOrg() == null) { //if not a custom channel
          //Tell them that they should sync the RHN Tools channel.
          msg.add(ActionMessages.GLOBAL_MESSAGE,
                  new ActionMessage("kickstart.invalidchannel.satmessage"));
        }
        return msg;
    }
    
    private String createPackageNameList(KickstartData ksdata) {
        //First create a list of all the packages needed
        List packages = new ArrayList();
        packages.addAll(Arrays.asList(KickstartFormatter.UPDATE_PKG_NAMES));
        //different 'fresh' packages for RHEL2
        if (ksdata.isRhel2()) {
            packages.addAll(Arrays.asList(KickstartFormatter.FRESH_PKG_NAMES_RHEL2));
        }
        if (ksdata.isRhel3() || ksdata.isRhel4()) {
            packages.addAll(Arrays.asList(KickstartFormatter.FRESH_PKG_NAMES_RHEL34));
        }
        //add a '*' at the end because the auto kickstart is a prefix
        packages.add(ksdata.getKickstartPackageName() + "*");
        
        //Now convert the list to a delimited string.
        String delimiter = LocalizationService.getInstance().getMessage("list delimiter");
        return StringUtils.join(packages.toArray(), delimiter);
    }
}
