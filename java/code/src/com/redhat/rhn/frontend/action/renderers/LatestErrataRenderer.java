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

package com.redhat.rhn.frontend.action.renderers;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.errata.ErrataFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.listview.PageControl;
import com.redhat.rhn.manager.errata.ErrataManager;

import javax.servlet.http.HttpServletRequest;

/**
 * Renders YourRhn fragment for latest errata
 *
 * @version $Rev$
 */
public class LatestErrataRenderer extends BaseFragmentRenderer {

    private static final String ERRATA_BUGFIX_LIST = "errataBugfixList";
    private static final String ERRATA_EMPTY = "errataEmpty";
    private static final String ERRATA_SECURITY_LIST = "errataSecurityfixList";
    private static final String SHOW_ERRATA = "showErrata";

    /**
     * {@inheritDoc}
     */
    protected void render(User user, PageControl pc, HttpServletRequest request) {
        PageControl erratapc = new PageControl();
        erratapc.setStart(1);
        erratapc.setPageSize(10);
        DataResult sedr = ErrataManager.relevantErrataByType(user, erratapc,
                ErrataFactory.ERRATA_TYPE_SECURITY);

        String securityErrataCSSTable = null;

        if (sedr.isEmpty()) {
            securityErrataCSSTable = RendererHelper.makeEmptyTable(false,
                    "yourrhn.jsp.securityerrata", "yourrhn.jsp.noerrata");
        }

        request.setAttribute(ERRATA_EMPTY, securityErrataCSSTable);
        request.setAttribute(ERRATA_BUGFIX_LIST, ErrataManager
                .relevantErrataByType(user, erratapc,
                        ErrataFactory.ERRATA_TYPE_BUG));
        request.setAttribute(ERRATA_SECURITY_LIST, sedr);
        request.setAttribute(SHOW_ERRATA, Boolean.TRUE);
    }

    /**
     * {@inheritDoc}
     */
    protected String getPageUrl() {
        return "/WEB-INF/pages/common/fragments/yourrhn/errata.jsp";
    }

}
