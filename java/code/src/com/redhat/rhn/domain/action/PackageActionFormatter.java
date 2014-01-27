/**
 * Copyright (c) 2014 SUSE
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
package com.redhat.rhn.domain.action;

import com.redhat.rhn.common.util.StringUtil;
import com.redhat.rhn.domain.action.rhnpackage.PackageAction;
import com.redhat.rhn.domain.action.rhnpackage.PackageActionDetails;

import org.apache.commons.lang.StringEscapeUtils;

import java.util.LinkedList;
import java.util.List;
import java.util.Set;

/**
 * Formatter for PackageActions.
 * @author Silvio Moioli <smoioli@suse.de>
 */
public class PackageActionFormatter extends ActionFormatter {

    /**
     * Standard constructor.
     * @param actionIn the action
     */
    public PackageActionFormatter(Action actionIn) {
        super(actionIn);
    }

    /**
     * {@inheritDoc}
     */
    @Override
    @SuppressWarnings("unchecked")
    public String getRelatedObjectDescription() {
        Set<PackageActionDetails> packages = ((PackageAction) this.getAction())
            .getDetails();
        List<String> result = new LinkedList<String>();
        if (packages != null) {
            for (PackageActionDetails packageDetail : packages) {
                result.add(
                    "<a href=\"/rhn/software/packages/Details.do?pid=" +
                    packageDetail.getPackageId().toString() +
                    "\">" +
                    StringEscapeUtils.escapeHtml(packageDetail.getPackageName().getName()) +
                    "</a>"
                );
            }
        }
        return StringUtil.join(", ", result);
    }
}
