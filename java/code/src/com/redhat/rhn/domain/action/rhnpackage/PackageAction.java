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
package com.redhat.rhn.domain.action.rhnpackage;

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.domain.action.Action;
import com.redhat.rhn.domain.action.ActionFormatter;
import com.redhat.rhn.domain.action.PackageActionFormatter;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.manager.rhnpackage.PackageManager;

import org.apache.commons.lang.StringEscapeUtils;

import java.util.HashSet;
import java.util.Set;

/**
 * PackageAction
 * @version $Rev$
 */
public class PackageAction extends Action {

    private Set details = new HashSet();
    private Set <PackageActionDetails> affectedPackages;

    /**
     * @return packages affected by this action
     */
    public Set <PackageActionDetails> getAffectedPackages() {
        return affectedPackages;
    }

    /**
     * @param affectedPackagesIn affected packages to be set
     */
    public void setAffectedPackages(Set <PackageActionDetails> affectedPackagesIn) {
        this.affectedPackages = affectedPackagesIn;
    }

    /**
     * Add a PackageActionDetails to the set of details
     * for a PackageAction.
     * @param d PackageActionDetails to add
     */
    public void addDetail(PackageActionDetails d) {
        d.setParentAction(this);
        details.add(d);
    }

    /**
     * @return Returns the details.
     */
    public Set getDetails() {
        return details;
    }

    /**
     * @param d The details to set.
     */
    public void setDetails(Set d) {
        this.details = d;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public ActionFormatter getFormatter() {
        if (formatter == null) {
            formatter = new PackageActionFormatter(this);
        }
        return formatter;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public String getHistoryDetails(Server server) {
        LocalizationService ls = LocalizationService.getInstance();
        StringBuilder retval = new StringBuilder();
        retval.append("</br>");
        if (this.getClass().equals(PackageUpdateAction.class)) {
            retval.append(ls.getMessage("system.event.packagesSchedule"));
        }
        else if (this.getClass().equals(PackageVerifyAction.class)) {
            retval.append(ls.getMessage("system.event.packagesVerify"));
        }
        if (this.getClass().equals(PackageRemoveAction.class)) {
            retval.append(ls.getMessage("system.event.packagesRemove"));
        }
        retval.append("</br><ul>");
        for (PackageActionDetails pad : affectedPackages) {
            retval.append("<li>");
            Long evrId = pad.getEvr() != null ? pad.getEvr().getId() : null;
            Long archId = pad.getArch() != null ? pad.getArch().getId() : null;
            String nevra = PackageManager.buildPackageNevra(pad.getPackageName().getId(),
                    evrId, archId);
            retval.append(StringEscapeUtils.escapeHtml(nevra));
            retval.append("</li>");
        }
        retval.append("</ul>");
        return retval.toString();
    }

}
