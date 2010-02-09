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
package com.redhat.rhn.domain.action.errata;

import com.redhat.rhn.common.util.StringUtil;
import com.redhat.rhn.domain.action.ActionFormatter;
import com.redhat.rhn.domain.errata.Errata;

import java.util.Set;

/**
 * ErrataActionFormatter - Class that overrides getNotes()
 * to display Errata specific information.
 * 
 * @version $Rev$
 */
public class ErrataActionFormatter extends ActionFormatter {
    
    /**
     * Create a new ErrataActionFormatter
     * @param actionIn the ErrataAction we want to use to format
     */
    public ErrataActionFormatter(ErrataAction actionIn) {
        super(actionIn);
    }
    
    /**
     * Output the Errata info into the body.
     * @return String of the Errata HTML
     */
    protected String getNotesBody() {
        StringBuffer retval = new StringBuffer();
        Set erratas = ((ErrataAction) this.getAction()).getErrata();
        if (erratas != null && erratas.size() > 0) {
            Errata errata = (Errata) erratas.toArray()[0];
            retval.append("<strong><a href=\"/rhn/errata/details/Details.do?eid=");
            retval.append(errata.getId().toString());
            retval.append("\">");
            retval.append(errata.getAdvisory());
            retval.append("</a></strong><br/><br/>");
            retval.append("<strong>");
            retval.append(errata.getSynopsis());
            retval.append("</strong><br/><br/>");
            retval.append(errata.getAdvisoryType());
            retval.append("<br/><br/>");
            if (errata.getTopic() != null) {
                retval.append(StringUtil.htmlifyText(errata.getTopic()));
            }
            retval.append("<br/>");
            if (errata.getDescription() != null) {
                retval.append(StringUtil.htmlifyText(errata.getDescription()));
            }
            retval.append("<br/>");
        }
        
        return retval.toString();
    }
    
    
}
