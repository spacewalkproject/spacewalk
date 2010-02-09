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
package com.redhat.rhn.common.security.acl;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.ChannelFactory;
import com.redhat.rhn.domain.channel.ChannelFamilyFactory;
import com.redhat.rhn.domain.channel.ChannelVersion;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.manager.channel.ChannelManager;
import com.redhat.rhn.manager.user.UserManager;

import java.util.HashMap;
import java.util.Map;
import java.util.Set;


/**
 * ChannelAclHandler - implements ACLs associated with channel_detail.xml
 * @version $Rev$
 */
public class ChannelAclHandler extends BaseHandler {
    
    public static final String USER = "user";
    public static final String CID = "cid";
    public static final String NOT_GLOBAL_SUBSCRIBE = "not_globally_subscribable";
    public static final String ERRATA = "errata";
    public static final String RPM = "rpm";
    
    /*
     * Sometimes we have a context where key "cid" is the cid-string (nav-xml)
     * Sometimes, "cid" is an array of strings of len-1 where the -entry- is the 
     * cid-str (rhn:require) Sigh.
     */
    protected Channel getChannel(User usr, Map ctx) {
        Object cidObj = ctx.get(CID);
        String cidStr = null;
        if (cidObj instanceof String) {
            cidStr = (String)cidObj;
        }
        else if (cidObj instanceof String[]) {
            cidStr = ((String[])cidObj)[0];
        }
        
        Long cid = null;
        try {
            cid = Long.valueOf(cidStr);
        }
        catch (NumberFormatException nfe) {
            cid = null;
        }
        
        if (cid != null) {
            Channel chan = ChannelManager.lookupByIdAndUser(cid, usr);
            return chan;
        }
        else {
            return null;
        }
    }
    
    /**
     * Is the user allowed to administer the specified channel?
     * @param ctx request context (user,cid)
     * @param params check parameters
     * @return true if allowed, false else
     */
    public boolean aclUserCanAdminChannel(Object ctx, String[] params) {
        HashMap ctxMap = (HashMap)ctx;
        User usr = (User)ctxMap.get(USER);
        Channel chan = getChannel(usr, ctxMap);
        if (chan != null) {
            return UserManager.verifyChannelAdmin(usr, chan);
        }
        else {
            return false;
        }
    }
    
    /**
     * Does the channel have the specified setting? (??)
     * @param ctx request context  (user,cid)
     * @param params check parameters [not_globally_subscribable]
     * @return true if allowed, false else
     */
    public boolean aclOrgChannelSetting(Object ctx, String[] params) {
        HashMap ctxMap = (HashMap)ctx;
        User usr = (User)ctxMap.get(USER);
        Channel chan = getChannel(usr, ctxMap);
        if (chan != null) {
            String p0 = (params.length > 0 ? params[0] : null);
            boolean subscribable = ChannelFactory.isGloballySubscribable(usr.getOrg(), 
                    chan);
            if (NOT_GLOBAL_SUBSCRIBE.equals(p0)) {
                return !subscribable;
            }
            else {
                return subscribable;
            }
        }
        else {
            return false;
        }
    }
    
    /**
     * if a channel-arch is 'rpm', we are NOT capable of handling errata.
     * Otherwise, we -are- capable of handling errata.
     * Currently, we only recognize 'errata' as the type in question.
     * @param ctx request context (use,r cid)
     * @param params check parameters [errata]
     * @return true if allowed, false else
     */
    public boolean aclChannelTypeCapable(Object ctx, String[] params) {
        
        if (params == null || params.length == 0) {
            return true;
        }
        
        if (!ERRATA.equals(params[0])) {
            return false;
        }
        
        HashMap ctxMap = (HashMap)ctx;
        User usr = (User)ctxMap.get(USER);
        Channel chan = getChannel(usr, ctxMap); 
        String archType = chan.getChannelArch().getArchType().getLabel();
        return archType.equals(RPM);
    }
    
    /**
     * Does the channel handle the specified type of packaging? (??)
     * @param ctx request context (user, cid)
     * @param params check parameters [sysv-solaris]
     * @return true if allowed, false else
     */
    public boolean aclChannelPackagingType(Object ctx, String[] params) {
        HashMap ctxMap = (HashMap)ctx;
        User usr = (User)ctxMap.get(USER);
        Channel chan = getChannel(usr, ctxMap); 
        String archType = chan.getChannelArch().getArchType().getLabel();
        return archType.equals(params[0]);
    }
    
    /**
     * Can the channel be subscribed to?
     * @param ctx request context (user, cid)
     * @param params check parameters
     * @return true if allowed, false else
     */
    public boolean aclChannelSubscribable(Object ctx, String[] params) {
        HashMap ctxMap = (HashMap)ctx;
        User usr = (User)ctxMap.get(USER);
        Channel chan = getChannel(usr, ctxMap);
        
        // From Channel.pm:
        // return 0 unless channel_accessible($pxt); 
        // return 0 if channel_is_base($pxt);
        // return 0 if channel_is_satellite($pxt);
        // return 0 if channel_is_proxy($pxt);
        // return 0 unless $pxt->user->verify_channel_subscribe($pxt->param('cid'));

        if (chan != null) {
            return  !chan.isBaseChannel() &&
                    !chan.isSatellite() &&
                    !chan.isProxy() &&
                    ChannelManager.verifyChannelSubscribe(usr, chan.getId());
        }
        else {
            return false;
        }
    }
    
    /**
     * Does this channel have an associated license to be displayed?
     * rhnChannel<--rhnChannelFamilyMembers-->rhnChannelFamily<--rhnChannelFamilyLicense 
     * @param ctx request context (user, cid)
     * @param params check parameters
     * @return true if allowed, false else
     */
    public boolean aclChannelLicensed(Object ctx, String[] params) {
        HashMap ctxMap = (HashMap)ctx;
        User usr = (User)ctxMap.get(USER);
        Channel chan = getChannel(usr, ctxMap);
        return (chan != null && 
                chan.getChannelFamily() != null && 
                ChannelFamilyFactory.lookupLicense(
                        chan.getChannelFamily().getId()) != null);
    }
    
    /**
     * Does the channel have anything to download?
     * @param ctx request context (user,cid)
     * @param params check parameters
     * @return true if allowed, false else
     */
    public boolean aclChannelHasDownloads(Object ctx, String[] params) {
        HashMap ctxMap = (HashMap)ctx;
        User usr = (User)ctxMap.get(USER);
        Channel chan = getChannel(usr, ctxMap);
        if (chan != null) {
            DataResult dr = ChannelManager.
                listDownloadImages(usr, chan.getLabel(), "iso", null, chan.isSatellite());
            return (dr == null ? false : (dr.size() > 0));
        }
        else {
            return false;
        }
    }
    
    /**
     * Is this a RHEL5 channel?
     * @param ctx request context (user,cid)
     * @param params check parameters
     * @return true if channel-vers is RHEL5, false else
     */
    public boolean aclIsRhel5(Object ctx, String[] params) {
        HashMap ctxMap = (HashMap)ctx;
        User usr = (User)ctxMap.get(USER);
        Channel chan = getChannel(usr, ctxMap);
        if (chan != null) {
            Set vers = ChannelManager.getChannelVersions(chan);
            return (vers != null && vers.contains(ChannelVersion.RHEL5));
        }
        else {
            return false;
        }
        
    }
    
    /**
     * Checks to see if a channel exists
     * @param ctx the map of params of the request
     * @param params  check params 
     * @return true if it does exist false otherwise
     */ 
    public boolean aclChannelExists(Object ctx, String[] params) {
        Map map = (Map) ctx;
        Object idObj = map.get("cid");
        
        if (idObj != null) {
            Long id = Long.parseLong((String)idObj);
            if (ChannelFactory.lookupById(id) != null) {
                return true;
            }
        }
        return false;        
    }    
    
    /**
     * Checks to see if a channel is a clone
     * @param ctx the map of params of the request
     * @param params  check params 
     * @return true if it is a clone
     */
    public boolean aclChannelIsClone(Object ctx, String[] params) {
        Map map = (Map) ctx;
        Object idObj = map.get("cid");
        Channel chan = getChannel((User)map.get(USER), map);
        if (chan == null) {
            return false;
        }
        return chan.isCloned();
    }     
    
    
}
