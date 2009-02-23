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
package com.redhat.rhn.frontend.action.errata;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.frontend.listview.PageControl;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.errata.ErrataManager;

import org.apache.commons.lang.BooleanUtils;
import org.apache.struts.action.DynaActionForm;

/**
 * CloneErrataActionHelper
 * Helper class to allow the CloneErrataAction and CloneErrataSetupAction
 * to share data retrieval logic.
 * @version $Rev$
 */
public class CloneErrataActionHelper {
    
    public static final String CHANNEL = "channel";
    public static final String SHOW_ALREADY_CLONED = "showalreadycloned";
    public static final String ANY_CHANNEL = "any_channel";

    /** utility class */
    private CloneErrataActionHelper() {
        
    }
    /**
     * Returns the dataresult for this page.
     * @param rctx Current RequestContext
     * @param daForm DynaActionForm submitted
     * @param pc PageControl
     * @return the list of clonable errata.
     */
    protected static DataResult getSubmittedDataResult(RequestContext rctx,
                                                DynaActionForm daForm,
                                                PageControl pc) {
        Long orgId = rctx.getCurrentUser().getOrg().getId();
        
        String channel = daForm.getString(CHANNEL);
            
            /* Our form has already been validated so we are guaranteed
             * to have a channel value off the form equaling either
             * 'any_channel' or 'channel_somenumber'
             */
            if (channel.equals(ANY_CHANNEL)) {
                return ErrataManager.clonableErrata(orgId, pc, isShowCloned(daForm));
            }
            else {
                return ErrataManager.clonableErrataForChannel(orgId, 
                                                              new Long(channel.
                                                                       substring(8)), 
                                                                       pc, 
                                                                       isShowCloned(
                                                                               daForm));
            }
    }
    
    protected static DataResult getUnsubmittedDataResult(RequestContext rctx,
                                                         PageControl pc) {
        Long orgId = rctx.getCurrentUser().getOrg().getId();
        
        return ErrataManager.clonableErrata(orgId, pc, false);
    }
    
    protected static boolean isShowCloned(DynaActionForm daForm) {
        return BooleanUtils.toBoolean((Boolean) daForm.get(SHOW_ALREADY_CLONED));
    }
    
}
