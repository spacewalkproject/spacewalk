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
package com.redhat.rhn.frontend.taglibs;

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.util.StringUtil;
import com.redhat.rhn.domain.server.Server;

import java.util.Date;

import javax.servlet.jsp.JspException;
import javax.servlet.jsp.JspWriter;
import javax.servlet.jsp.tagext.TagSupport;

/**
 * SystemTimeMessageTag
 * @version $Rev$
 */
public class SystemTimeMessageTag extends TagSupport {
    
    private Server server;

    /**
     * @return Returns the server.
     */
    public Server getServer() {
        return server;
    }
    /**
     * @param serverIn The server to set.
     */
    public void setServer(Server serverIn) {
        this.server = serverIn;
    }
    
    /**
     * {@inheritDoc}
     */
    public int doEndTag() throws JspException {
        JspWriter out = null;
        try {
            out = pageContext.getOut();
            out.print(getMessage());
            return (EVAL_PAGE);
        }
        catch (Exception e) {
            throw new JspException("Error writing to JSP file:", e);
        }
    }
    
    private String getMessage() throws JspException {
        if (server == null) {
            throw new JspException("Tag error: Server must be defined");
        }
        StringBuffer retval = new StringBuffer();
        LocalizationService translate = LocalizationService.getInstance();
        
        Date now = new Date();
        Date lastCheckIn = server.getLastCheckin();
        Date expectedCheckIn = new Date(lastCheckIn.getTime() + (1000 * 60 * 60 * 2));
        //expected check in is two hours after last check in, regardless of threshold
        long checkInAgo = now.getTime() - lastCheckIn.getTime();
        Long days = new Long((((checkInAgo / 1000) / 60) / 60) / 24);
        boolean awol = days.intValue() > 
                       Config.get().getInt(ConfigDefaults.SYSTEM_CHECKIN_THRESHOLD);
        
        retval.append("<table border=\"0\" cellspacing=\"0\" cellpadding=\"6\">");
        
        //System last check-in: 2005-04-06 11:19:37 EDT
        //(14 days, 5 hours, and 31 minutes ago)
        retval.append("\n  <tr><td>");
        retval.append(translate.getMessage("timetag.lastcheckin"));
        retval.append("</td><td>");
        retval.append(translate.formatDate(lastCheckIn));
        retval.append(" (");
        retval.append(StringUtil.categorizeTime(lastCheckIn.getTime(), 
                StringUtil.DAYS_UNITS, StringUtil.MINUTES_UNITS));
        retval.append(")</td></tr>\n");
        
        //Current RHN time: 2005-04-06 11:19:37 EDT
        retval.append("  <tr><td>");
        retval.append(translate.getMessage("timetag.current"));
        retval.append("</td><td>");
        retval.append(translate.formatDate(now));
        retval.append("</td></tr>\n");
        
        //Expected check-in time: 2005-04-06 11:19:37 EDT
        //(14 days, 5 hours, and 31 minutes ago)
        if (!awol) {
            retval.append("  <tr><td>");
            retval.append(translate.getMessage("timetag.expected"));
            retval.append("</td><td>");
            retval.append(translate.formatDate(expectedCheckIn));
            retval.append(" (");
            retval.append(StringUtil.categorizeTime(expectedCheckIn.getTime(), 
                    StringUtil.DAYS_UNITS, StringUtil.MINUTES_UNITS));
            retval.append(")</td></tr>\n");
        }
        
        retval.append("</table><br/>");
        if (awol) {
            retval.append(translate.getMessage("timetag.awol"));
        }
        
        return retval.toString();
    }
    
    /**
     * {@inheritDoc}
     */
    public void release() {
        server = null;
        super.release();
    }
}
