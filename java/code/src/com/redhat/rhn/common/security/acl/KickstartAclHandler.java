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

import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.kickstart.KickstartableTree;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;

import org.apache.commons.lang.StringUtils;

import java.util.HashMap;


/**
 * KickstartAclHandler - implements ACLs associated with kickstart_detail.xml
 * @version $Rev$
 */
public class KickstartAclHandler extends BaseHandler {
    private static final String USER = "user";
    private KickstartData getKickstart(User usr, String[] params) {
        String ksStr = params[0];        
        Long id = null;
        try {
            id = Long.valueOf(ksStr);
        }
        catch (NumberFormatException nfe) {
            return null;
        }

        if (id != null) {
            KickstartData ks = KickstartFactory.lookupKickstartDataByIdAndOrg(
                    usr.getOrg(), id);
            return ks;
        }
        else {
            return null;
        }
    }

    /**
     * Is the user allowed to administer the specified channel?
     * @param ctx request context (user,cid)
     * @param params check parameters
     * @return true if a raw format, false else
     */
    public boolean aclIsKsRaw(Object ctx, String[] params) {
        HashMap ctxMap = (HashMap)ctx;
        User usr = (User)ctxMap.get(USER);
        KickstartData ks =  getKickstart(usr, params);
        if (ks != null) {
            return ks.isRawData();
        }
        else {
            return false;
        }
    }
    
    /**
     * Returns true if the kickstart is a 'wizard format'
     * @param ctx request context (user,cid)
     * @param params check parameters
     * @return true if a wizard format, false else
     */
    public boolean aclIsKsNotRaw(Object ctx, String[] params) {
        HashMap ctxMap = (HashMap)ctx;
        User usr = (User)ctxMap.get(USER);
        KickstartData ks =  getKickstart(usr, params);
        if (ks == null) {
            return false;
        }
        return !ks.isRawData();        
    }
    
    /**
     * Returns true if the kickstart  tree 
     * is synced to cobbler
     * @param ctx request context (user,kstid)
     * @param params check parameters
     * @return true if the kickstart tree is synced
     * to cobbler
     */
    public boolean aclTreeIsSynced(Object ctx, String[] params) {
        HashMap ctxMap = (HashMap)ctx;
        User usr = (User)ctxMap.get(USER);
        Long id = getAsLong(ctxMap.get(RequestContext.KSTREE_ID));
        if (id == null) {
            return false;
        }        
        KickstartableTree ks =  KickstartFactory.
                        lookupKickstartTreeByIdAndOrg(id, usr.getOrg());
        return !StringUtils.isBlank(ks.getCobblerId());        
    }

    /**
     * Returns true if the kickstart  profile 
     * is synced to cobbler and if the profile 
     * has a valid distribution
     * @param ctx request context (user,kstid)
     * @param params check parameters
     * @return true if the kickstart profile is valid
     * to cobbler
     */
    public boolean aclProfileIsValid(Object ctx, String[] params) {
        HashMap ctxMap = (HashMap)ctx;
        User usr = (User)ctxMap.get(USER);
        Long id = getAsLong(ctxMap.get(RequestContext.KICKSTART_ID));
        if (id == null) {
            return false;
        }
        KickstartData ks =  KickstartFactory.
                        lookupKickstartDataByIdAndOrg(usr.getOrg(), id);
        return !StringUtils.isBlank(ks.getCobblerId()) && ks.getTree().isValid();
    }
}
