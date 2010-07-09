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

import com.redhat.rhn.frontend.dto.VirtualSystemOverview;

import javax.servlet.jsp.JspException;

/**
 * The VirtualListDisplayTag defines the structure of the ListView
 * when viewing virtual systems and their hosts.
 *
 * @version $Rev$
 * @see com.redhat.rhn.frontend.taglibs.ListDisplayTag
 */
public class VirtualListDisplayTag extends ListDisplayTag {

    protected int outerRowCnt = 0;

    /** {@inheritDoc}
     *
     * We need to override getTrElement because we are doing two
     * different 'levels' of background color.  One for the 'host'
     * systems, and another for the 'virtual' systems.
     */
    protected String getTrElement(Object o) {
        StringBuffer retval;

        VirtualSystemOverview system = (VirtualSystemOverview) o;

        if (system.getIsVirtualHost()) {
            outerRowCnt++;
            outerRowCnt = outerRowCnt % 2;
            rowCnt = 0;

            if (outerRowCnt == 0) {
                retval = new StringBuffer("<tr class=\"list-row-virtual-host-even\"");
            }
            else {
                retval = new StringBuffer("<tr class=\"list-row-virtual-host-odd\"");
            }
        }
        else {
            rowCnt++;
            rowCnt = rowCnt % 2;

            if (rowCnt == 1 || isTransparent()) {
                retval = new StringBuffer("<tr class=\"list-row-virtual-odd\"");
            }
            else {
                retval = new StringBuffer("<tr class=\"list-row-virtual-even\"");
            }
        }

        return retval.append(">").toString();
    }

    /** {@inheritDoc}
     *
     * Overriding doStartTag just to reset outerRowCnt
     */
    public int doStartTag() throws JspException {
        outerRowCnt = 0;

        return super.doStartTag();
    }

    /** {@inheritDoc}
     *
     * Overriding release just to reset outerRowCnt
     */
    public void release() {
        outerRowCnt = 0;

        super.release();
    }
}
