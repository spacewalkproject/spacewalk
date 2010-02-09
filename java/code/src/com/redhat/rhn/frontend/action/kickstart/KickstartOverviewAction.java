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

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.util.StringUtil;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.kickstart.KickstartOverviewSummaryDto;
import com.redhat.rhn.frontend.dto.kickstart.KickstartOverviewSystemsDto;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.manager.kickstart.KickstartLister;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.util.Date;
import java.util.Iterator;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * KickstartOverviewAction
 * @version $Rev$
 */
public class KickstartOverviewAction extends RhnAction {

    public static final String FULL_TABLE_HEADER = 
        "<div style=\"clear:both; padding-top: 30px;\">" +
        "<table width=\"100%\" cellspacing=\"0\" cellpadding=\"0\" class=\"list\">" +
        "<thead><tr><th style=\"text-align:left;\">";
    
    public static final String HALF_TABLE_HEADER = 
        "<table cellspacing=\"0\"  cellpadding=\"0\" class=\"half-table\"" +
          "class=\"border-bottom: 1px solid #ffffff;\">" +
              "<thead><tr><th style=\"text-align: left;\">";
    
    public static final String TABLE_BODY = 
        "</th></tr></thead><tr class=\"list-row-odd\">" +
        "<td style=\"padding-bottom: 24px;\" class=\"first-column last-column\">";
    
    public static final String HALF_TABLE_BODY =
        " </th></tr></thead><tr class=\"list-row-odd\">" +
                "<td style=\"text-align: left;\" class=\"first-column last-column\">";
    
    public static final String FULL_TABLE_FOOTER = "</td></tr></table></div>";
    
    public static final String HALF_TABLE_FOOTER = "</td></tr></table> ";
    
    public static final String SYSTEMS_TO_BE_KICKSTARTED = "sysToBeKickstarted";
    public static final String SYSTEMS_CURRENTLY_KICKSTARTING = "sysKickstarting";
    public static final String KICKSTART_SUMMARY = "kickstartSummaryList";
    public static final String SYS_TO_BE_KS_EMPTY = "sysToBeKSEmpty";
    public static final String SYS_CUR_KS_EMPTY = "sysKSEmpty";
    public static final String KSPROFILES_EMPTY = "emptyKSProfiles";
    
    
    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping, ActionForm form, 
                                 HttpServletRequest request,
                                 HttpServletResponse response) {
       RequestContext rctx = new RequestContext(request);
       User user = rctx.getCurrentUser();
       
       DataResult ksdr = KickstartLister.getInstance()
                                  .getKickstartSummary(user.getOrg(), null);
       DataResult ckdr = KickstartLister.getInstance()
                            .getSystemsCurrentlyKickstarting(user.getOrg(), null);
       DataResult skdr = KickstartLister.getInstance()
                              .getSystemsScheduledToBeKickstarted(user.getOrg(), null);
             
       formatKSSummary(ksdr);
       formatKSSystemInfo(ckdr);
       formatKSSystemInfo(skdr);
       
       String ckEmpty = renderEmptyCSSTable("kickstart.jsp.system", 
                                                  "kickstartoverview.jsp.nocurrentlyks");
       String skEmpty = renderEmptyCSSTable("kickstart.jsp.system",
                                              "kickstartoverview.jsp.noscheduledtobeks");
       String emptyKSProfiles = renderEmptyCSSHalfTable(
                 "kickstartoverview.jsp.kickstartsummary", "kickstart.jsp.nokickstarts");
       
       
       rctx.getRequest().setAttribute(SYS_CUR_KS_EMPTY, ckEmpty);
       rctx.getRequest().setAttribute(SYS_TO_BE_KS_EMPTY , skEmpty);
       rctx.getRequest().setAttribute(KSPROFILES_EMPTY, emptyKSProfiles);
       rctx.getRequest().setAttribute(KICKSTART_SUMMARY, ksdr);
       rctx.getRequest().setAttribute(SYSTEMS_CURRENTLY_KICKSTARTING, ckdr);
       rctx.getRequest().setAttribute(SYSTEMS_TO_BE_KICKSTARTED, skdr);
       rctx.getRequest().setAttribute("parentUrl", request.getRequestURI());

       
       return mapping.findForward("default");
    }
    
    /**
     * formats dr for web UI
     * @param dr The dr to format
     */
    public void formatKSSummary(DataResult dr) {
        if (!dr.isEmpty()) {
            LocalizationService ls = LocalizationService.getInstance();
            KickstartOverviewSummaryDto kdto = new KickstartOverviewSummaryDto();
            for (Iterator i = dr.iterator(); i.hasNext();) {
                 kdto = (KickstartOverviewSummaryDto)i.next(); 
                 kdto.setName(kdto.getName() + 
                                 ls.getMessage("filter-form.jsp.ksoverviewprofiles"));
            }
        }
    }
   
    /**
     * formats dr for web UI
     * @param dr The dr to format
     */
    public void formatKSSystemInfo(DataResult dr) {
       if (!dr.isEmpty()) {
         for (Iterator i = dr.iterator(); i.hasNext();) {
            KickstartOverviewSystemsDto ksdto = (KickstartOverviewSystemsDto)i.next();
            Date modified = ksdto.getLastModified();
            String timeStr = StringUtil.categorizeTime(modified.getTime(),
                StringUtil.DAYS_UNITS);
            ksdto.setElapsedTimeAfterModify(timeStr);
          }
       }
    }
    
    /**
     * This renders an empty list view using our CSS defs for full tables. 
     * @param tableHeaderKey the String that goes between "<th></th>" tags
     * @param tableMessageKey the message inside the table
     * @return String representation of rendered table
     */
    public String renderEmptyCSSTable(String tableHeaderKey, String tableMessageKey) {
        return FULL_TABLE_HEADER + 
        LocalizationService.getInstance().getMessage(tableHeaderKey)  + TABLE_BODY +
        LocalizationService.getInstance().getMessage(tableMessageKey) + 
        FULL_TABLE_FOOTER;
    }

    /**
     * This renders an empty list view using our CSS defs for half tables. 
     * @param tableHeaderKey the String that goes between "<th></th>" tags
     * @param tableMessageKey the message inside the table
     * @return String representation of rendered table
     */
    public String renderEmptyCSSHalfTable(String tableHeaderKey, 
                                          String tableMessageKey) {
        return HALF_TABLE_HEADER + 
        LocalizationService.getInstance().getMessage(tableHeaderKey)  + 
        HALF_TABLE_BODY + 
        LocalizationService.getInstance().getMessage(tableMessageKey) + 
        HALF_TABLE_FOOTER;
    }
    
}
