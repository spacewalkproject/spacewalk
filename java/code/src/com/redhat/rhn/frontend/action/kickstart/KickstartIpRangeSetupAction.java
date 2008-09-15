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
package com.redhat.rhn.frontend.action.kickstart;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.security.SessionSwap;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.frontend.listview.PageControl;
import com.redhat.rhn.frontend.struts.BaseListAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.kickstart.KickstartLister;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;

import java.net.MalformedURLException;
import java.net.URL;

/**
 * KickstartsSetupAction.
 * @version $Rev: 1 $
 */
public class KickstartIpRangeSetupAction extends BaseListAction {
    
    /**
     * 
     * {@inheritDoc}
     */
    protected DataResult getDataResult(RequestContext rctx, PageControl pc) {
        Org org = rctx.getCurrentUser().getOrg();
        return KickstartLister.getInstance().kickstartIpRangesInOrg(org, pc);
    }

    /**
     * 
     * @return the kickstart profile security label
     */
    public RhnSetDecl getSetDecl() {
        return RhnSetDecl.KICSKTART_IPRANGES;
    }
    
    protected void processRequestAttributes(RequestContext rctx) {
        String org = rctx.getCurrentUser().getOrg().getId().toString();
        String urlStr;
        //TODO: look into refactoring this with the ipranges page...probably stick in 
        // the kickstart factory along with the profile url as well. 
        try {                        
            URL url = new URL(rctx.getRequest().getRequestURL().toString());            
            urlStr = "ks=" + url.getProtocol() + "://" + url.getHost() + 
            "/ks/org/" + org + "x" + 
            SessionSwap.generateSwapKey(org) + "/mode/ip_range";                        
        }
        catch (MalformedURLException e) {
            throw new IllegalArgumentException("Bad argument when creating URL for " +
                    "Kickstart IP Ranges");
        }
        String urlRange = 
            LocalizationService.getInstance().getMessage("kickstart.iprange.url", urlStr);
        rctx.getRequest().setAttribute("urlrange", urlRange);
        return;
    }
}
