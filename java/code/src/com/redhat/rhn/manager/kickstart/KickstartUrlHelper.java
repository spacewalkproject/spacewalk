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
package com.redhat.rhn.manager.kickstart;

import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.common.security.SessionSwap;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.common.CommonFactory;
import com.redhat.rhn.domain.common.TinyUrl;
import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.KickstartSession;
import com.redhat.rhn.domain.kickstart.KickstartableTree;
import com.redhat.rhn.domain.kickstart.RepoInfo;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.manager.kickstart.cobbler.CobblerXMLRPCHelper;

import org.apache.commons.lang.StringEscapeUtils;
import org.apache.log4j.Logger;
import org.cobbler.Profile;

import java.util.Date;


/**
 * Simple helper class to ecapsulate logic around determining
 * kickstart file and media urls.
 *
 * @version $Rev$
 */
public class KickstartUrlHelper {

    private static Logger log = Logger.getLogger(KickstartUrlHelper.class);
    public static final String COBBLER_URL_BASE_PATH = "/cblr/svc/op/ks/profile/";
    public static final String KS_DIST = "/ks/dist";
    public static final String KS_CFG = "/ks/cfg";
    public static final String COBBLER_SERVER_VARIABLE = "$http_server";
    public static final String COBBLER_MEDIA_VARIABLE = "media_path";
    private static final String KS_RAW_PAGE_URL =
                        "/rhn/kickstart/KickstartFileDownloadAdvanced.do?ksid=%s";
    private static final String KS_WIZARD_PAGE_URL =
            "/rhn/kickstart/KickstartFileDownload.do?ksid=%s";
    private KickstartData ksData;
    private String host;
    private String protocol;
    private KickstartableTree ksTree;


    /**
     * Constructor.
     *
     * @param ksDataIn who's URL you desire.
     */
    public KickstartUrlHelper(KickstartData ksDataIn) {
        this(ksDataIn, COBBLER_SERVER_VARIABLE);
    }

    /**
     * Constructor.
     *
     * @param ksTreeIn who's URL you desire.
     */
    public KickstartUrlHelper(KickstartableTree ksTreeIn) {
        this(null, COBBLER_SERVER_VARIABLE);
        this.ksTree = ksTreeIn;
    }

    /**
     * Constructor.
     *
     * @param ksDataIn who's URL you desire.
     * @param hostIn who is hosting the kickstart file.
     */
    public KickstartUrlHelper(KickstartData ksDataIn, String hostIn) {
        this.ksData = ksDataIn;
        this.host = hostIn;
        if (this.ksData != null) {
            this.ksTree = ksDataIn.getTree();
        }
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
        return getKickstartFileUrlBase(ksData.getOrg(), host, protocol);
    }


    /**
     * The base for a kickstart URL including the org:
     *
     * http://spacewalk.example.com/kickstart/ks/cfg/org/1/
     * @param org the org of the kickstart data
     * @param host the host name
     * @param protocol the protocol used.
     * @return  base url to kickstart file
     */
    public static String getKickstartFileUrlBase(Org org, String host, String protocol) {
        StringBuilder urlBase = new StringBuilder();
        urlBase.append(protocol);
        if (!protocol.endsWith("://")) {
            urlBase.append("://");
        }
        urlBase.append(host);
        urlBase.append(KS_CFG + "/org/");
        urlBase.append(org.getId().toString());
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
        return getKickstartFileUrlIpRange(ksData.getOrg(), host, protocol);
    }

    /**
     * Get the URL for the ip_range file server. Example:
     *
     * http://spacewalk.example.com/kickstart/ks/org/1/mode/ip_range
     * @param org the org of the kickstart data
     * @param host the host name
     * @param protocol the protocol used.
     * @return  base url to kickstart iprange file.
     */
    public static String getKickstartFileUrlIpRange(Org org, String host, String protocol) {
        return getKickstartFileUrlBase(org, host, protocol) + "/mode/ip_range";
    }

    /**
     * Get the --url parameter for this kickstart.  This is
     * the full url including media path:
     *
     * http://somehost.example.com/ks/dist/ks-rhel-i386-as-4-u2
     *
     * @return String url to this KickstartData's --url
     */
    public String getKickstartMediaUrl() {
        log.debug("Formatting for view use.");
        StringBuffer url = new StringBuffer();
        url.append(protocol + host + getKickstartMediaPath());
        log.debug("returning: " + url);
        return url.toString();
    }

    /**
     * get a kickstart repo url for a child channel
     * @param child the child channel
     * @return string that represents the repo url
     */
    public String getKickstartChildRepoUrl(Channel child) {
        StringBuffer url = new StringBuffer();
        url.append(protocol + host + "/ks/dist/");
        url.append("child/" + child.getLabel() + "/");
        url.append(ksData.getTree().getLabel());
        return url.toString();
    }


    /**
     * Get the media path for the KickstartableTree. Example:
     * /ks/dist/ks-rhel-i386-as-4-u2
     *
     * @return media path to the KickstartableTree ..
     * /ks/dist/ks-rhel-i386-as-4-u2
     */
    public String getKickstartMediaPath() {
        // /kickstart/dist/ks-rhel-i386-as-4-u2
        StringBuffer file = new StringBuffer();
        file.append(KS_DIST);
        file.append("/");
        file.append(this.ksTree.getLabel());
        return file.toString();
    }

    /**
     * Get the cobbler style --url:
     *
     * http://$http_server/$media_url
     *
     * To be filled out by cobbler.  not spacewalk.
     *
     * @return String url , cobbler style: http://$http_server/$media_url
     */
    public String getCobblerMediaUrl() {
        StringBuilder url = new StringBuilder();
        url.append(protocol + host + "$" + COBBLER_MEDIA_VARIABLE);
        log.debug("returning: " + url);
        return url.toString();
    }

    /**
     * Return the repo URL to be used in the formatted
     * @param repo the repo object
     * @return the repo url.
     */
    public String getRepoUrl(RepoInfo repo) {
        return getCobblerMediaUrl() + "/" + repo.getUrl();
    }

    /**
     * Get the url path portion for this kickstart that is used
     * during a Kickstart Session that tracks the downloads.
     *
     * Computes:
     * /ks/dist/session/35x45fed383beaeb31a184166b4c1040633/ks-f9-x86_64
     *
     * reformated to a tinyurl:
     *
     * /ty/xZ38
     *
     * @param session to compute tracking URL for.
     *
     * @return String url to this KickstartData's media (packages, kernel
     * etc...)
     */
    public String getKickstartMediaPath(KickstartSession session) {
        log.debug("Formatting for session use.");
        // /ks/dist/session/
        // 94xe86321bae3cb74551d995e5eafa065c0/ks-rhel-i386-as-4-u2
        String file = getLongMediaPath(session);
        TinyUrl turl = CommonFactory.createTinyUrl(file.toString(),
                new Date());
        CommonFactory.saveTinyUrl(turl);
        log.debug("returning: " + turl.computeTinyPath());
        return turl.computeTinyPath();
    }

    private String getLongMediaPath(KickstartSession session) {
        StringBuffer file = new StringBuffer();
        file.append(KS_DIST + "/session/");
        file.append(SessionSwap.encodeData(session.getId().toString()));
        file.append("/");
        file.append(this.ksTree.getLabel());
        return file.toString();
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
        String file = getLongMediaPath(session);
        TinyUrl turl = CommonFactory.createTinyUrl(file.toString(),
                new Date());
        CommonFactory.saveTinyUrl(turl);
        log.debug("returning: " + turl.computeTinyUrl(this.host));
        return turl.computeTinyUrl(this.host);
    }

    /**
     * Returns the actual kickstart url
     * @param profileName the name of the profile
     * @return the KS url.
     */
    public static String getCobblerProfilePath(String profileName) {
        return COBBLER_URL_BASE_PATH + profileName;
    }

    /**
     * Get the cobbler profile url
     * @param data the kickstart data
     * @return the url
     */
    public static String getCobblerProfileUrl(KickstartData data) {
        Profile prof = Profile.lookupById(
                CobblerXMLRPCHelper.getAutomatedConnection(),
                        data.getCobblerId());
        return "http://" + ConfigDefaults.get().getCobblerHost() + COBBLER_URL_BASE_PATH +
                    prof.getName();
    }

    /**
     * Returns the file download page URL
     * @param data the kickstart data
     * @return the url
     */
    public static String getFileDowloadPageUrl(KickstartData data) {
        if (data.isRawData()) {
            return String.format(KS_RAW_PAGE_URL, data.getId().toString());
        }
        return String.format(KS_WIZARD_PAGE_URL, data.getId().toString());
    }
}
