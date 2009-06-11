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
import com.redhat.rhn.common.util.download.DownloadException;
import com.redhat.rhn.common.util.download.DownloadUtils;
import com.redhat.rhn.common.validator.ValidatorException;
import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.manager.BaseManager;

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
                        KickstartUrlHelper.getCobblerProfileUrl(ksdata));
            }
        }
        catch (DownloadException de) {
            ValidatorException.raiseException("kickstart.jsp.error.template_generation",
                                        KickstartUrlHelper.getFileDowloadPageUrl(ksdata));
        }
    }    
}
