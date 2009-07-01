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
package com.redhat.rhn.manager.kickstart;

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.SelectMode;
import com.redhat.rhn.common.security.PermissionException;
import com.redhat.rhn.common.util.download.DownloadException;
import com.redhat.rhn.common.util.download.DownloadUtils;
import com.redhat.rhn.common.validator.ValidatorException;
import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.kickstart.KickstartIpRange;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.SystemOverview;
import com.redhat.rhn.manager.BaseManager;

import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 
 * KickstartManager
 * @version $Rev$
 */
public class KickstartManager extends BaseManager {
    private static final KickstartManager INSTANCE = new KickstartManager();
    
    /**
     * Returns an instance of kickstart manager
     * @return an instance 
     */
    public static KickstartManager getInstance() {
        return INSTANCE;
    }
    
    /**
     * Render the kickstart using cobbler and return the contents with the Cobbler host 
     * search/replaced.
     * 
     * @param host the host to force into the ks file.  searches and replaces all 
     * instances of the Cobbler Host with whatever you pass in.  Use with Proxies.
     * @param data the KickstartData
     * @return the rendered kickstart contents
     */
    public String renderKickstart(String host, KickstartData data) {
        String retval = renderKickstart(data);
        // Search/replacing all instances of cobbler host with host
        // we pass in, for use with rhn proxy.
        retval = retval.replaceAll(Config.get().getCobblerHost(), host);
        return retval;    
    }
    
    /**
     * Render the kickstart using cobbler and return the contents
     * @param data the KickstartData
     * @return the rendered kickstart contents
     */
    public String renderKickstart(KickstartData data) {
        return DownloadUtils.downloadUrl(KickstartUrlHelper.getCobblerProfileUrl(data));    
    }

    /**
     * Simple method to validate a generated kickstart 
     * @param ksdata the kickstart data file whose ks 
     * templates will be checked
     * @throws ValidatorException on parse error or ISE..
     */
    public void validateKickstartFile(KickstartData ksdata) {
        try {
            String text = renderKickstart(ksdata);
            if (text.contains("Traceback (most recent call last):")) {
                ValidatorException.raiseException("kickstart.jsp.error.template_generation",
                        KickstartUrlHelper.getFileDowloadPageUrl(ksdata));
            }
        }
        catch (DownloadException de) {
            ValidatorException.raiseException("kickstart.jsp.error.template_generation",
                                        KickstartUrlHelper.getFileDowloadPageUrl(ksdata));
        }
    }  
    
    /**
     * returns a list of systems in SSM
     * that are kickstartable
     * @param user the user for access info
     * @return the list of kickstartable systems 
     */
    public DataResult<SystemOverview> kickstartableSystemsInSsm(User user) {
        SelectMode m = ModeFactory.getMode("System_queries", "ssm_kickstartable");
        Map params = new HashMap();
        params.put("user_id", user.getId());
        return makeDataResult(params, Collections.EMPTY_MAP, null, m);
    }
    
    /**
     * returns a list of IP ranges accessible to the
     * user
     * @param user the current user needed for org information 
     * @return the the list of ip ranges accessible to the user.
     */
    public List<KickstartIpRange> listIpRanges(User user) {
        if (!user.hasRole(RoleFactory.CONFIG_ADMIN)) {
            throw new PermissionException(RoleFactory.CONFIG_ADMIN);
        }
        return KickstartFactory.lookupRangeByOrg(user.getOrg()); 
    }
}
