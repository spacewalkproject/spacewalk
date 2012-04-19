/**
 * Copyright (c) 2009--2011 Red Hat, Inc.
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
/*
 * Copyright (c) 2010 SUSE LINUX Products GmbH, Nuernberg, Germany.
 */
package com.redhat.rhn.frontend.action.channel.manage;

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.security.PermissionException;
import com.redhat.rhn.domain.channel.ChannelFactory;
import com.redhat.rhn.domain.errata.Bug;
import com.redhat.rhn.domain.errata.Errata;
import com.redhat.rhn.domain.errata.ErrataFactory;
import com.redhat.rhn.domain.errata.Keyword;
import com.redhat.rhn.domain.errata.impl.PublishedClonedErrata;
import com.redhat.rhn.domain.org.Org;
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

    private static final String DEFAULT_ERRATA_CLONE_PREFIX = "CL-";
    private static final String REDHAT_ERRATA_PREFIX = "RH";

    private PublishErrataHelper() {

    }

    /**
     * Perform a check to see if the user can modify channels, throws an
     *          PermissionException if the user does not have permission
     * @param user the user to check
     * @param cid TODO
     *
     */
    public static void checkPermissions(User user, Long cid) {
        if (ChannelFactory.lookupByIdAndUser(cid, user) == null) {
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


        for (Keyword k : original.getKeywords()) {
            clone.addKeyword(k.getKeyword());
        }


        for (Bug bugIn : (Set<Bug>) original.getBugs()) {
            Bug bClone;
                bClone = ErrataManager.createNewPublishedBug(bugIn.getId(),
                                                             bugIn.getSummary(),
                                                             bugIn.getUrl());
           clone.addBug(bClone);
        }

        setUniqueAdvisoryCloneName(original, clone);
        ((PublishedClonedErrata) clone).setOriginal(original);
        clone.setOrg(org);
        ErrataFactory.save(clone);

        return clone;

    }

    /**
     * Generates a unique errata clone advisory and advisoryName and sets them
     * to the errata clone
     * @param original original erratum
     * @param clone cloned erratum
     */
    public static void setUniqueAdvisoryCloneName(Errata original, Errata clone) {
        String clonedAdvisory, clonedAdvisoryName;

        if (!original.isCloned()) {
            if (original.getAdvisory().startsWith(REDHAT_ERRATA_PREFIX)) {
                // RHBA-1234:1234 -> CL-BA-1234:1234
                clonedAdvisory = DEFAULT_ERRATA_CLONE_PREFIX +
                        original.getAdvisory().substring(
                                REDHAT_ERRATA_PREFIX.length());
                clonedAdvisoryName = DEFAULT_ERRATA_CLONE_PREFIX +
                        original.getAdvisoryName().substring(
                                REDHAT_ERRATA_PREFIX.length());
            }
            else {
                // CUSTOM-ERRATA -> CL-CUSTOM-ERRATA
                clonedAdvisory = DEFAULT_ERRATA_CLONE_PREFIX +
                        original.getAdvisory();
                clonedAdvisoryName = DEFAULT_ERRATA_CLONE_PREFIX +
                        original.getAdvisoryName();
            }
        }
        else {
            // increment CL -> CM only advisories with 3rd char '-'
            if ('-' == original.getAdvisory().charAt(2) &&
                    '-' == original.getAdvisoryName().charAt(2)) {
                clonedAdvisory = new String(original.getAdvisory());
                clonedAdvisoryName = new String(original.getAdvisoryName());
            }
            else {
                clonedAdvisory = DEFAULT_ERRATA_CLONE_PREFIX +
                        original.getAdvisory();
                clonedAdvisoryName = DEFAULT_ERRATA_CLONE_PREFIX +
                        original.getAdvisoryName();
            }
        }

        boolean unusedNameFound = false;

        while (!unusedNameFound) {
            Errata advisoryNameMatch = ErrataFactory.lookupByAdvisory(
                    clonedAdvisoryName);
            Errata advisoryMatch = ErrataFactory.lookupByAdvisoryId(clonedAdvisory);

            if ((advisoryNameMatch == null) && (advisoryMatch == null)) {
                unusedNameFound = true;
            }
            else {
                // use the advisory prefix for both - advisory and advisory_name
                char c1 = clonedAdvisory.charAt(1);
                if ('Z' == c1) {
                    char c0next = (char) (clonedAdvisory.charAt(0) + 1);
                    clonedAdvisory = "" + c0next + 'A' +
                            clonedAdvisory.substring(2);
                    clonedAdvisoryName = "" + c0next + 'A' +
                            clonedAdvisoryName.substring(2);
                }
                else {
                    char c1next = (char) (c1 + 1);
                    clonedAdvisory = "" + clonedAdvisory.charAt(0) + c1next +
                            clonedAdvisory.substring(2);
                    clonedAdvisoryName = "" + clonedAdvisoryName.charAt(0) +
                            c1next + clonedAdvisoryName.substring(2);
                }
            }
        }

        clone.setAdvisoryName(clonedAdvisoryName);
        clone.setAdvisory(clonedAdvisory);
    }
}
