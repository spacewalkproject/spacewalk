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
package com.redhat.rhn.frontend.action.channel.manage;

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.security.PermissionException;
import com.redhat.rhn.domain.errata.Bug;
import com.redhat.rhn.domain.errata.Errata;
import com.redhat.rhn.domain.errata.ErrataFactory;
import com.redhat.rhn.domain.errata.Keyword;
import com.redhat.rhn.domain.errata.impl.PublishedClonedErrata;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.manager.errata.ErrataManager;

import java.util.HashSet;
import java.util.Set;

/**
 *
 * PublishErrataHelper
 * @version $Rev$
 */
public class PublishErrataHelper {


    private PublishErrataHelper() {

    }

    /**
     * Perform a check to see if the user can modify channels, throws an
     *          PermissionException if the user does not have permission
     * @param user the user to check
     *
     */
    public static void checkPermissions(User user) {
        if (!user.hasRole(RoleFactory.CHANNEL_ADMIN) &&
                !user.hasRole(RoleFactory.ORG_ADMIN)) {
            LocalizationService ls = LocalizationService.getInstance();
            throw new PermissionException(
                    ls.getMessage("frontend.actions.channels.manager.add.permsfailure"));
        }
    }


    /**
     * Clones an errata Similarly to ErrataFactory.createClone, but creates a published
     *      errata instead of going through the stupid process of being unpublished and
     *       then copying all the data to 4 tables
     * @param original the original errata to clone
     * @param org the org to clone it for
     * @return The cloned (and published) errata
     */
    public static Errata cloneErrataFast(Errata original, Org  org) {

        Errata clone = new PublishedClonedErrata();


        clone.setAdvisoryType(original.getAdvisoryType());
        clone.setProduct(original.getProduct());
        clone.setDescription(original.getDescription());
        clone.setSynopsis(original.getSynopsis());
        clone.setTopic(original.getTopic());
        clone.setSolution(original.getSolution());
        clone.setIssueDate(original.getIssueDate());
        clone.setUpdateDate(original.getUpdateDate());
        clone.setNotes(original.getNotes());
        clone.setRefersTo(original.getRefersTo());
        clone.setAdvisoryName(original.getAdvisoryName());
        clone.setAdvisoryRel(original.getAdvisoryRel());
        clone.setLocallyModified(original.getLocallyModified());
        clone.setLastModified(original.getLastModified());
        clone.setOrg(org);
        clone.getCves().addAll(original.getCves());

        clone.setPackages(new HashSet(original.getPackages()));


        for (Keyword k : (Set<Keyword>)original.getKeywords()) {
            clone.addKeyword(k.getKeyword());
        }


        for (Bug bugIn : (Set<Bug>) original.getBugs()) {
            Bug bClone;
                bClone = ErrataManager.createNewPublishedBug(bugIn.getId(),
                                                            bugIn.getSummary());
           clone.addBug(bClone);
        }


        String baseClonedAdvisoryName = "CL" + original.getAdvisoryName().substring(3);
        String baseClonedAdvisory = "CL" + original.getAdvisory().substring(3);
        String clonedAdvisory = baseClonedAdvisory;
        String clonedAdvisoryName = baseClonedAdvisoryName;
        boolean unusedNameFound = false;


        for (int j = 1; !unusedNameFound; ++j) {
            Errata advisoryNameMatch = ErrataFactory.lookupByAdvisory(
                    clonedAdvisoryName);
            Errata advisoryMatch = ErrataFactory.lookupByAdvisoryId(clonedAdvisory);

            if ((advisoryNameMatch == null) && (advisoryMatch == null)) {
                unusedNameFound = true;
            }
            else {
                clonedAdvisoryName = baseClonedAdvisoryName + '-' +
                                     new Integer(j).toString();
                clonedAdvisory = baseClonedAdvisory + '-' +
                                 new Integer(j).toString();
            }
        }


        clone.setAdvisoryName(clonedAdvisoryName);
        clone.setAdvisory(clonedAdvisory);
        ((PublishedClonedErrata) clone).setOriginal(original);
        clone.setOrg(org);
        ErrataFactory.save(clone);

        return clone;

    }

}
