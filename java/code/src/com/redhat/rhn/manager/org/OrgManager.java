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
package com.redhat.rhn.manager.org;

import com.redhat.rhn.common.db.datasource.DataList;
import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.SelectMode;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.security.PermissionException;
import com.redhat.rhn.common.validator.ValidatorException;
import com.redhat.rhn.domain.channel.ChannelFamily;
import com.redhat.rhn.domain.entitlement.Entitlement;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.MultiOrgSystemEntitlementsDto;
import com.redhat.rhn.frontend.dto.MultiOrgUserOverview;
import com.redhat.rhn.frontend.dto.OrgChannelDto;
import com.redhat.rhn.frontend.dto.OrgDto;
import com.redhat.rhn.frontend.dto.OrgEntitlementDto;
import com.redhat.rhn.frontend.dto.OrgTrustOverview;
import com.redhat.rhn.frontend.dto.TrustedOrgDto;
import com.redhat.rhn.manager.BaseManager;
import com.redhat.rhn.manager.entitlement.EntitlementManager;

import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * OrgManager - Manages MultiOrg tasks
 * @version $Rev$
 */
public class OrgManager extends BaseManager {

    private OrgManager() {
    }


    /**
     * Basically transfers relevant data
     * from Org object to the Dto object
     * returns a new OrgDto object.
     * This method is typically used in OrgDetails views
     * @param org the org object to transfer from
     * @return the created Dto.
     */
    public static OrgDto toDetailsDto(Org org) {
        OrgDto dto = new OrgDto();
        dto.setId(org.getId());
        dto.setName(org.getName());
        dto.setUsers(OrgFactory.getActiveUsers(org));
        dto.setSystems(OrgFactory.getActiveSystems(org));
        dto.setActivationKeys(OrgFactory.getActivationKeys(org));
        dto.setKickstartProfiles(OrgFactory.getKickstarts(org));
        dto.setServerGroups(OrgFactory.getServerGroups(org));
        dto.setConfigChannels(OrgFactory.getConfigChannels(org));
        return dto;
    }


    /**
     *
     * @param user User to cross security check
     * @return List of Orgs on satellite
     */
    public static DataList<OrgDto> activeOrgs(User user) {
        if (!user.hasRole(RoleFactory.SAT_ADMIN)) {
            // Throw an exception w/error msg so the user knows what went wrong.
            LocalizationService ls = LocalizationService.getInstance();
            PermissionException pex = new PermissionException("User must be a " +
                    RoleFactory.SAT_ADMIN.getName() + " to access the org list");
            pex.setLocalizedTitle(ls.getMessage("permission.jsp.title.orglist"));
            pex.setLocalizedSummary(ls.getMessage("permission.jsp.summary.general"));
            throw pex;
        }
        SelectMode m = ModeFactory.getMode("Org_queries", "orgs_in_satellite");

        return DataList.getDataList(m, Collections.EMPTY_MAP,
                Collections.EMPTY_MAP);
    }

    /**
     *
     * @param user User to cross security check
     * @return List of Orgs on satellite
     */
    public static DataList<TrustedOrgDto> trustedOrgs(User user) {
        if (!user.hasRole(RoleFactory.ORG_ADMIN)) {
            // Throw an exception w/error msg so the user knows what went wrong.
            LocalizationService ls = LocalizationService.getInstance();
            PermissionException pex = new PermissionException("User must be a " +
                    RoleFactory.ORG_ADMIN.getName() + " to access the trusted org list");
            pex.setLocalizedTitle(ls.getMessage("permission.jsp.title.orglist"));
            pex.setLocalizedSummary(ls.getMessage("permission.jsp.summary.general"));
            throw pex;
        }
        SelectMode m = ModeFactory.getMode("Org_queries", "trusted_orgs");

        Long orgIdIn = user.getOrg().getId();
        Map params = new HashMap();
        params.put("org_id", orgIdIn);

        return DataList.getDataList(m, params,
                Collections.EMPTY_MAP);
    }

    /**
     * Get a list of orgs with a trusted indicator for each.
     * @param user The user making the request.
     * @param orgIdIn The org to check.
     * @return A list of orgs with a trusted indicator for each.
     */
    @SuppressWarnings("unchecked")
    public static DataList<OrgTrustOverview> orgTrusts(User user, Long orgIdIn) {
        if (!user.hasRole(RoleFactory.SAT_ADMIN)) {
            // Throw an exception w/error msg so the user knows what went wrong.
            LocalizationService ls = LocalizationService.getInstance();
            PermissionException pex = new PermissionException("User must be a " +
                    RoleFactory.SAT_ADMIN.getName() + " to access the trusted org list");
            pex.setLocalizedTitle(ls.getMessage("permission.jsp.title.orglist"));
            pex.setLocalizedSummary(ls.getMessage("permission.jsp.summary.general"));
            throw pex;
        }
        SelectMode m = ModeFactory.getMode("Org_queries", "trust_overview");
        Map params = new HashMap();
        params.put("org_id", orgIdIn);
        return DataList.getDataList(m, params, Collections.EMPTY_MAP);
    }

    /**
     *
     * @param orgIdIn to check active users
     * @return DataList of UserOverview Objects
     */
    public static DataList<MultiOrgUserOverview> activeUsers(Long orgIdIn) {
        SelectMode m = ModeFactory.getMode("User_queries", "users_in_multiorg");
        Map params = new HashMap();
        params.put("org_id", orgIdIn);
        return DataList.getDataList(m, params, Collections.EMPTY_MAP);
    }

    /**
     *
     * @param cid Channel ID
     * @param org Org used to check trust relationships
     * @return list of trusted relationships with access to cid
     */
    public static DataList<OrgChannelDto> orgChannelTrusts(Long cid, Org org) {
        SelectMode m = ModeFactory.getMode("Channel_queries",
                "protected_trust_channel");
        Map params = new HashMap();
        params.put("org_id", org.getId());
        params.put("cid", cid);
        return DataList.getDataList(m, params, Collections.EMPTY_MAP);
    }

    /**
     *
     * @return all users on sat
     */
    public static DataList allUsers() {
        SelectMode m = ModeFactory.getMode("User_queries",
                "all_users_in_multiorg");
        return DataList.getDataList(m, Collections.EMPTY_MAP,
                Collections.EMPTY_MAP);
    }

    /**
     *
     * @return all entitlements across all orgs on sat
     */
    public static DataList <MultiOrgSystemEntitlementsDto> allOrgsEntitlements() {
        SelectMode m = ModeFactory.getMode("Org_queries",
                "get_total_entitlement_counts");
        return DataList.getDataList(m, Collections.EMPTY_MAP,
                Collections.EMPTY_MAP);
    }

    /**
     * @param entLabel Entitlement Label
     * @return single entitlement, entLabel, across all orgs on sat
     */
    public static DataList allOrgsSingleEntitlement(String entLabel) {
        SelectMode m = ModeFactory.getMode("Org_queries",
                "get_org_entitlement_counts");
        Map params = new HashMap();
        params.put("label", entLabel);
        return DataList.getDataList(m, params,
                Collections.EMPTY_MAP);
    }

    /**
     * Returns a list of organziations and their entitlement numbers (usage, total) for
     * the given entitlement. This call <strong>will include orgs that have a zero count
     * for the given entitlement.</strong>
     *
     * @param entitlementLabel identifies the entitlement; cannot be <code>null</code>
     * @return one entry for each organization in the system (including the default org)
     *         with details on the entitlement count for that org
     */
    public static DataList<Map> allOrgsSingleEntitlementWithEmptyOrgs(
        String entitlementLabel) {

        /* The data model isn't conducive to doing all of the work in the query. There
           are only mapping entries from entitlement <-> org present if that mapping has
           been established previously (it will still exist if the mapping specifies
           zero for the title).

           This method will first load all of the mappings. For every org that does not
           have a mapping, one will be created populating zero for the total and usage.
           These new mappings are added to the original list pulled from the database
           and then explicitly sorted to maintain the ordering in the query (currently
           ordered by org name).

           jdobies: May 6, 2009
         */

        // Only returns orgs that have been mapped to the entitlements
        SelectMode m = ModeFactory.getMode("Org_queries", "get_org_entitlement_counts");
        Map<String, String> params = new HashMap<String, String>(1);
        params.put("label", entitlementLabel);
        DataList<Map> result = DataList.getDataList(m, params, Collections.EMPTY_MAP);

        // Stuff into a set to easily check if the org is already present in the result
        Set<Long> mappedOrgIds = new HashSet<Long>(result.size());
        for (Iterator it = result.iterator(); it.hasNext();) {
            Map mappedOrgData = (Map) it.next();
            Long orgId = (Long) mappedOrgData.get("orgid");
            mappedOrgIds.add(orgId);
        }

        // One piece of data necessary for each manually added org is the number of
        // available entitlements, for instance to be displayed in a "0 out of XXXX"
        // message.
        m = ModeFactory.getMode("Org_queries", "get_available_entitlements_for_label");
        DataResult upperHolder = m.execute(params);
        Map upperMap = (Map) upperHolder.get(0);
        long upper = (Long) upperMap.get("upper");

        // For each org not already mapped, add a new entry to the existing result list
        List<Org> allOrgs = OrgFactory.lookupAllOrgs();
        for (Org checkMe : allOrgs) {

            if (!mappedOrgIds.contains(checkMe.getId())) {
                Map<String, Object> emptyOrgData = new HashMap<String, Object>(6);
                emptyOrgData.put("name", checkMe.getName());
                emptyOrgData.put("orgid", checkMe.getId());
                emptyOrgData.put("label", entitlementLabel);

                // The reason we're here is because it has no entitlements, so use zero
                emptyOrgData.put("total", 0L);

                // If there were no entitlements, none are used
                emptyOrgData.put("usage", 0L);

                // Upper limit takes into account the total, so we can use the calculated
                // value from above in all of these cases
                emptyOrgData.put("upper", upper);

                result.add(emptyOrgData);
            }
        }

        // Resort the list. If we don't, the orgs with entitlements will appear at the top
        // and the ones we explicitly add with zero entries appear at the bottom. This
        // gets really confusing in the UI.
        Comparator<Map> compareByName = new Comparator<Map>() {
            public int compare(Map result1, Map result2) {
                String name1 = (String) result1.get("name");
                String name2 = (String) result2.get("name");

                return name1.compareTo(name2);
            }
        };
        Collections.sort(result, compareByName);

        return result;
    }

    /**
     * @param entLabel Entitlement Label
     * @return single entitlement, entLabel, across all orgs on sat
     */
    public static DataList getSatEntitlementUsage(String entLabel) {
        SelectMode m = ModeFactory.getMode("Org_queries",
                "get_sat_entitlement_usage");
        Map params = new HashMap();
        params.put("label", entLabel);
        return DataList.getDataList(m, params,
                Collections.EMPTY_MAP);
    }


    /**
     * Lookup orgs with servers with access to any channel that's a part of the
     * given family.
     * @param family Channel family
     * @param user User performing the query
     * @return List of orgs.
     */
    public static List<Org> orgsUsingChannelFamily(ChannelFamily family,
            User user) {

        if (!user.hasRole(RoleFactory.SAT_ADMIN)) {
            // Throw an exception w/error msg so the user knows what went wrong.
            LocalizationService ls = LocalizationService.getInstance();
            PermissionException pex = new PermissionException("User must be a " +
                    RoleFactory.SAT_ADMIN.getName() + " to access the org list");
            pex.setLocalizedTitle(ls.getMessage("permission.jsp.title.orglist"));
            pex.setLocalizedSummary(ls.getMessage("permission.jsp.summary.general"));
            throw pex;
        }

        return OrgFactory.lookupOrgsUsingChannelFamily(family);
    }

    /**
     *
     * @param entLabel to check used active orgs
     * @return DataList of Objects
     */
    public static DataList getUsedActiveOrgCount(String entLabel) {
        SelectMode m = ModeFactory
                .getMode("Org_queries", "get_used_org_counts");
        Map params = new HashMap();
        params.put("label", entLabel);
        return DataList.getDataList(m, params, Collections.EMPTY_MAP);
    }

    /**
     * @param user User to cross security check
     * @param entLabel to check used active orgs
     * @return DataList of Objects
     */
    public static DataList getAllOrgs(User user, String entLabel) {
        if (!user.hasRole(RoleFactory.SAT_ADMIN)) {
            // Throw an exception w/error msg so the user knows what went wrong.
            LocalizationService ls = LocalizationService.getInstance();
            PermissionException pex = new PermissionException("User must be a " +
                    RoleFactory.SAT_ADMIN.getName() + " to access the org list");
            pex.setLocalizedTitle(ls.getMessage("permission.jsp.title.orglist"));
            pex.setLocalizedSummary(ls.getMessage("permission.jsp.summary.general"));
            throw pex;
        }
        SelectMode m = ModeFactory
                .getMode("Org_queries", "get_all_orgs");
        Map params = new HashMap();
        params.put("label", entLabel);
        return DataList.getDataList(m, params, Collections.EMPTY_MAP);
    }

    /**
     * Returns the total number of orgs on this satellite.
     * @param user User performing the query.
     * @return Total number of orgs.
     */
    public static Long getTotalOrgCount(User user) {
        if (!user.hasRole(RoleFactory.SAT_ADMIN)) {
            // Throw an exception w/error msg so the user knows what went wrong.
            LocalizationService ls = LocalizationService.getInstance();
            PermissionException pex = new PermissionException("User must be a " +
                    RoleFactory.SAT_ADMIN.getName() + " to access the org list");
            pex.setLocalizedTitle(ls.getMessage("permission.jsp.title.orglist"));
            pex.setLocalizedSummary(ls.getMessage("permission.jsp.summary.general"));
            throw pex;
        }

        return OrgFactory.getTotalOrgCount();
    }

    /**
     * Returns the date which this org trusted the supplied orgId
     * @param user currently logged in user
     * @param org our org
     * @param trustOrg the org we trust
     * @return String representing date we started trusting this org
     */
    public static String getTrustedSince(User user, Org org, Org trustOrg) {
        if (!user.hasRole(RoleFactory.ORG_ADMIN)) {
            // Throw an exception w/error msg so the user knows what went wrong.
            LocalizationService ls = LocalizationService.getInstance();
            PermissionException pex = new PermissionException("User must be a " +
                    RoleFactory.ORG_ADMIN.getName() + " to access the trusted since data");
            pex.setLocalizedTitle(ls.getMessage("permission.jsp.title.orglist"));
            pex.setLocalizedSummary(ls.getMessage("permission.jsp.summary.general"));
            throw pex;
        }

        return OrgFactory.getTrustedSince(org.getId(), trustOrg.getId());
    }

    /**
     * Returns the date which this org trusted the supplied orgId
     * @param user currently logged in user
     * @param orgIn Org to calculate the number of System migrations to
     * @return number of systems migrated to OrgIn
     */
    public static Long getSysMigrationsTo(User user, Org orgIn) {
        if (!user.hasRole(RoleFactory.ORG_ADMIN)) {
            // Throw an exception w/error msg so the user knows what went wrong.
            LocalizationService ls = LocalizationService.getInstance();
            PermissionException pex = new PermissionException("User must be a " +
            RoleFactory.ORG_ADMIN.getName() + " to access the system migration data");
            pex.setLocalizedTitle(ls.getMessage("permission.jsp.title.orglist"));
            pex.setLocalizedSummary(ls.getMessage("permission.jsp.summary.general"));
            throw pex;
        }

        return OrgFactory.getSysMigrationsTo(orgIn.getId());
    }

    /**
     * Returns the date which this org trusted the supplied orgId
     * @param user currently logged in user
     * @param orgTo Org to calculate the number of System migrations to
     * @param orgFrom Org to calculate the number of System migrations from
     * @return number of systems migrated to OrgIn
     */
    public static Long getMigratedSystems(User user, Org orgTo, Org orgFrom) {
        if (!user.hasRole(RoleFactory.ORG_ADMIN)) {
            // Throw an exception w/error msg so the user knows what went wrong.
            LocalizationService ls = LocalizationService.getInstance();
            PermissionException pex = new PermissionException("User must be a " +
              RoleFactory.ORG_ADMIN.getName() + " to access the system migration data");
            pex.setLocalizedTitle(ls.getMessage("permission.jsp.title.orglist"));
            pex.setLocalizedSummary(ls.getMessage("permission.jsp.summary.general"));
            throw pex;
        }

        return OrgFactory.getMigratedSystems(orgTo.getId(), orgFrom.getId());
    }

    /**
     * Returns the date which this org trusted the supplied orgId
     * @param user currently logged in user
     * @param org Org calculate the number of channels from
     * @param orgTrust Org to calculate the number of channels to
     * @return number of systems migrated to OrgIn
     */
    public static Long getSharedChannels(User user, Org org, Org orgTrust) {
        if (!user.hasRole(RoleFactory.ORG_ADMIN)) {
            // Throw an exception w/error msg so the user knows what went wrong.
            LocalizationService ls = LocalizationService.getInstance();
            PermissionException pex = new PermissionException("User must be a " +
              RoleFactory.ORG_ADMIN.getName() + " to access the system migration data");
            pex.setLocalizedTitle(ls.getMessage("permission.jsp.title.orglist"));
            pex.setLocalizedSummary(ls.getMessage("permission.jsp.summary.general"));
            throw pex;
        }

        return OrgFactory.getSharedChannels(org.getId(), orgTrust.getId());
    }

    /**
     * Returns the date which this org trusted the supplied orgId
     * @param user currently logged in user
     * @param org Org calculate the number of channels from
     * @param orgTrust Org to calculate the number of channels to
     * @return number of systems orgTrust has subscribed to Org shared channels
     */
    public static Long getSharedSubscribedSys(User user, Org org, Org orgTrust) {
        if (!user.hasRole(RoleFactory.ORG_ADMIN)) {
            // Throw an exception w/error msg so the user knows what went wrong.
            LocalizationService ls = LocalizationService.getInstance();
            PermissionException pex = new PermissionException("User must be a " +
              RoleFactory.ORG_ADMIN.getName() + " to access the system channel data");
            pex.setLocalizedTitle(ls.getMessage("permission.jsp.title.orglist"));
            pex.setLocalizedSummary(ls.getMessage("permission.jsp.summary.general"));
            throw pex;
        }

        return OrgFactory.getSharedSubscribedSys(org.getId(), orgTrust.getId());
    }
    /**
     * Returns the total number of orgs on this satellite.
     * @param user User performing the query.
     * @return Total number of orgs.
     */
    public static List<Org> allOrgs(User user) {
        if (!user.hasRole(RoleFactory.SAT_ADMIN)) {
            // Throw an exception w/error msg so the user knows what went wrong.
            LocalizationService ls = LocalizationService.getInstance();
            PermissionException pex = new PermissionException("User must be a " +
                    RoleFactory.SAT_ADMIN.getName() + " to access the org list");
            pex.setLocalizedTitle(ls.getMessage("permission.jsp.title.orglist"));
            pex.setLocalizedSummary(ls.getMessage("permission.jsp.summary.general"));
            throw pex;
        }

        return OrgFactory.lookupAllOrgs();
    }

    /**
     * Check if the passed in org is a valid name and raises an
     * exception if its invalid..
     * @param newOrgName the orgname to be applied
     * @throws ValidatorException in case of bad/duplicate name
     */
    public static void checkOrgName(String newOrgName) throws ValidatorException {
        if (newOrgName == null ||
                newOrgName.trim().length() == 0 ||
                newOrgName.trim().length() < 3 ||
                newOrgName.trim().length() > 128) {
            ValidatorException.raiseException("orgname.jsp.error");
        }
        else if (OrgFactory.lookupByName(newOrgName) != null) {
            ValidatorException.raiseException("error.org_already_taken", newOrgName);
        }
    }

    /**
     * Returns a list of entitlement dtos for a given org ..
     * Basically collects a list of all entitlements and provides
     * a DTO with information abt the entitlements
     *  (like current members, available members etc.)
     * @param org the org to lookup on
     * @return List of dtos for all entitlements.
     */
    public static List <OrgEntitlementDto> listEntitlementsFor(Org org) {
        List <OrgEntitlementDto> dtos = new LinkedList<OrgEntitlementDto>();
        List <Entitlement> entitlements = new LinkedList<Entitlement>();
        entitlements.addAll(EntitlementManager.getBaseEntitlements());
        entitlements.addAll(EntitlementManager.getAddonEntitlements());
        for (Entitlement ent : entitlements) {
            dtos.add(new OrgEntitlementDto(ent, org));
        }
        return dtos;
    }
}
