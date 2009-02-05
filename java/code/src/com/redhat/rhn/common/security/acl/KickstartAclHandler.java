/**
 * Copyright (c) 2009 Red Hat, Inc.
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
import com.redhat.rhn.domain.user.User;

import java.util.HashMap;


/**
 * KickstartAclHandler - implements ACLs associated with kickstart_detail.xml
 * @version $Rev$
 */
public class KickstartAclHandler extends BaseHandler {
    
    public static final String USER = "user";
    public static final String KSID = "ksid";

    
    /*
     * Sometimes we have a context where key "cid" is the cid-string (nav-xml)
     * Sometimes, "cid" is an array of strings of len-1 where the -entry- is the 
     * cid-str (rhn:require) Sigh.
     */
    protected KickstartData getKickstart(User usr, String[] params) {
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
    
    
    
    
}
