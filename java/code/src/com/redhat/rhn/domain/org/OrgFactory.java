/**
 * Copyright (c) 2009--2012 Red Hat, Inc.
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
package com.redhat.rhn.domain.org;

import com.redhat.rhn.common.db.datasource.CallableMode;
import com.redhat.rhn.common.db.datasource.DataList;
import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.SelectMode;
import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.domain.channel.ChannelFamily;
import com.redhat.rhn.domain.iss.IssFactory;
import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.kickstart.KickstartDto;
import com.redhat.rhn.manager.kickstart.KickstartDeleteCommand;
import com.redhat.rhn.manager.kickstart.KickstartLister;

import org.apache.log4j.Logger;
import org.hibernate.Session;

import java.sql.Types;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * A small wrapper around hibernate files to remove some of the complexities
 * of writing to hibernate.
 */
public class OrgFactory extends HibernateFactory {


    private static OrgFactory singleton = new OrgFactory();
    private static Logger log = Logger.getLogger(OrgFactory.class);

    private OrgFactory() {
        super();
    }

    /**
     * Get the Logger for the derived class so log messages
     * show up on the correct class
     * @return Logger to use
     */
    @Override
    protected Logger getLogger() {
        return log;
    }

    /**
     * Create a new Org from scratch
     * @return Org to be used.
     */
    public static Org createOrg() {
        Org retval = new Org();
        return retval;

    }

    /**
     * the org id is passed to pl/sql to wipe out
     * @param oid Org Id to delete
     * @param user User who initiated this action
     */
    public static void deleteOrg(Long oid, User user) {
        Org org = OrgFactory.lookupById(oid);

        // delete kickstart profiles (to clean up cobbler profiles)
        DataResult<KickstartDto> results = KickstartLister.getInstance()
                .kickstartsInOrg(org, null);
        for (KickstartDto ks : results) {
            KickstartData ksdata = KickstartFactory
                    .lookupKickstartDataByLabelAndOrgId(ks.getLabel(), oid);
            if (ksdata != null) {
                KickstartDeleteCommand kdc = new KickstartDeleteCommand(ksdata,
                        user);
                kdc.store();
            }
        }

        IssFactory.unmapLocalOrg(org);

        Map<String, Object> in = new HashMap<String, Object>();
        in.put("org_id", oid);
        CallableMode m = ModeFactory.getCallableMode(
                "Org_queries", "delete_organization");
        m.execute(in, new HashMap<String, Integer>());
    }

    /**
     * Find the org with the name, name.
     * @param name the org name
     * @return Org found or null
     */
    public static Org lookupByName(String name) {
        Session session = HibernateFactory.getSession();
        return  (Org) session.getNamedQuery("Org.findByName")
                .setString("name", name)
                .uniqueResult();
    }

    /**
     * Get the CustomDataKey represented by the passed in label and org
     * @param label The label of the key you want
     * @param org The org the key is in
     * @return CustomDataKey that was found, null if not.
     */
    public static CustomDataKey lookupKeyByLabelAndOrg(String label, Org org) {
        Session session = HibernateFactory.getSession();

        return (CustomDataKey) session.getNamedQuery("CustomDataKey.findByLabelAndOrg")
                .setString("label", label)
                .setEntity("org", org)
                //Retrieve from cache if there
                .setCacheable(true)
                .uniqueResult();
    }

    /**
     * Get the CustomDataKey represented by the passed in ID
     * @param cikid The ID of the key you want
     * @return CustomDataKey that was found, null if not.
     */
    public static CustomDataKey lookupKeyById(Long cikid) {
        Session session = HibernateFactory.getSession();

        return (CustomDataKey) session.getNamedQuery("CustomDataKey.findById")
                .setLong("id", cikid)
                //Retrieve from cache if there
                .setCacheable(true)
                .uniqueResult();
    }

    private static Org saveNewOrg(Org org) {
        CallableMode m = ModeFactory.getCallableMode("General_queries",
                "create_org");

        Map<String, Object> inParams = new HashMap<String, Object>();
        Map<String, Integer> outParams = new HashMap<String, Integer>();

        inParams.put("name", org.getName());
        // password is currently required as an input to the create_new_org
        // stored proc; however, it is not used by the proc.
        inParams.put("password", org.getName());
        outParams.put("org_id", new Integer(Types.NUMERIC));

        Map<String, Object> row = m.execute(inParams, outParams);
        // Get the out params
        Org retval = lookupById((Long) row.get("org_id"));

        retval.addRole(RoleFactory.ACTIVATION_KEY_ADMIN);
        retval.addRole(RoleFactory.CHANNEL_ADMIN);
        retval.addRole(RoleFactory.CONFIG_ADMIN);
        retval.addRole(RoleFactory.SYSTEM_GROUP_ADMIN);
        retval.addRole(RoleFactory.SAT_ADMIN);

        // Save the object since we may have in memory items to write\
        singleton.saveInternal(retval);
        retval = (Org) HibernateFactory.reload(retval);
        return retval;
    }

    /**
     * Commit the Org
     * @param org Org object we want to commit.
     * @return the saved Org.
     */
    public static Org save(Org org) {
        return singleton.saveInternal(org);
    }

    /**
     * Commit the Org
     */
    private Org saveInternal(Org org) {
        if (org.getId() == null) {
            // New org, gotta use the stored procedure.
            return saveNewOrg(org);
        }
        saveObject(org);
        return org;
    }

    /**
     * Lookup an Org by id.
     * @param id id to lookup Org by
     * @return the requested orgd
     */
    public static Org lookupById(Long id) {
        Session session = HibernateFactory.getSession();
        Org u = (Org)session.get(Org.class, id);
        return u;
    }

    /**
     *
     * @param orgIn Org to calculate users
     * @return number of active Users
     */
    public static Long getActiveUsers(Org orgIn) {
        Session session = HibernateFactory.getSession();
        return  (Long) session.getNamedQuery("Org.numOfActiveUsers")
                .setLong("org_id", orgIn.getId().longValue())
                .uniqueResult();

    }

    /**
     *
     * @param orgIn to calculate systems
     * @return number of active systems
     */
    public static Long getActiveSystems(Org orgIn) {
        Session session = HibernateFactory.getSession();
        return  (Long) session.getNamedQuery("Org.numOfSystems")
                .setLong("org_id", orgIn.getId().longValue())
                .uniqueResult();
    }

    /**
     *
     * @param orgIn Org to calculate number of server groups for
     * @return number of Server Groups for Org
     */
    public static Long getServerGroups(Org orgIn) {
        Session session = HibernateFactory.getSession();
        return  (Long) session.getNamedQuery("Org.numOfServerGroups")
                .setLong("org_id", orgIn.getId().longValue())
                .uniqueResult();
    }

    /**
     *
     * @param orgIn to calculate number of Config Channels
     * @return number of config channels for Org
     */
    public static Long getConfigChannels(Org orgIn) {
        Session session = HibernateFactory.getSession();
        return  (Long) session.getNamedQuery("Org.numOfConfigChannels")
                .setLong("org_id", orgIn.getId().longValue())
                .uniqueResult();
    }

    /**
     *
     * @param orgIn to calculate activations keys
     * @return number of activations keys for Org
     */
    public static Long getActivationKeys(Org orgIn) {

        SelectMode m = ModeFactory.getMode("General_queries",
                "activation_keys_for_org");
        Map<String, Long> params = new HashMap<String, Long>();
        params.put("org_id", orgIn.getId());
        DataList keys = DataList.getDataList(m, params, Collections.EMPTY_MAP);
        return new Long(keys.size());
    }

    /**
     *
     * @param orgIn to calculate number of kickstarts
     * @return number of kicktarts for Org
     */
    public static Long getKickstarts(Org orgIn) {
        SelectMode m = ModeFactory.getMode("General_queries",
                "kickstarts_for_org");
        Map<String, Long> params = new HashMap<String, Long>();
        params.put("org_id", orgIn.getId());
        DataList kickstarts = DataList.getDataList(m, params, Collections.EMPTY_MAP);
        return new Long(kickstarts.size());
    }
    /**
     * Lookup a Template String by label
     * @param label to search for
     * @return the Template found
     */
    public static TemplateString lookupTemplateByLabel(String label) {
        Session session = HibernateFactory.getSession();
        return (TemplateString) session.getNamedQuery("TemplateString.findByLabel")
                .setString("label", label)
                //Retrieve from cache if there
                .setCacheable(true)
                .uniqueResult();
    }

    public static final TemplateString EMAIL_FOOTER =
            lookupTemplateByLabel("email_footer");
    public static final TemplateString EMAIL_ACCOUNT_INFO =
            lookupTemplateByLabel("email_account_info");

    /**
     * Get the default organization.
     *
     * Currently looks up the org with ID 1.
     *
     * @return Default organization
     */
    public static Org getSatelliteOrg() {
        return lookupById(new Long(1));
    }

    /**
     * Lookup orgs with servers with access to any channel that's a part of the given
     * family.
     * @param channelFamily Channel family to search for.
     * @return List of orgs.
     */
    public static List<Org> lookupOrgsUsingChannelFamily(
            ChannelFamily channelFamily) {
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("cf", channelFamily);
        return singleton.listObjectsByNamedQuery(
                "Org.findOrgsWithSystemsInChannelFamily", params);
    }

    /**
     *
     * @return Total number of orgs.
     */
    public static Long getTotalOrgCount() {
        Map<String, Object> params = new HashMap<String, Object>();

        return (Long)singleton.lookupObjectByNamedQuery(
                "Org.numOfOrgs", params);
    }

    /**
     *  @param org Our org
     *  @param trustedOrg the org we trust
     *  @return date created for Trusted Org
     */
    public static Date getTrustedSince(Long org, Long trustedOrg) {
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("org_id", org);
        params.put("trusted_org_id", trustedOrg);
        return (Date)singleton.lookupObjectByNamedQuery(
                "Org.getTrustedSince", params);
    }

    /**
     * @param orgTo Org to caclulate system migrations to
     * @param orgFrom Org to caclulate system migrations from
     * @return number of systems migrated to orgIn
     */
    public static Long getMigratedSystems(Long orgTo, Long orgFrom) {
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("org_to_id", orgTo);
        params.put("org_from_id", orgFrom);
        Long systems  = (Long)singleton.lookupObjectByNamedQuery(
                "Org.getMigratedSystems", params);
        return systems;
    }

    /**
     * @param orgId Org to caclulate systems
     * @param trustId Org to calculate channel sharing to
     * @return number of systems migrated to orgIn
     */
    public static Long getSharedChannels(Long orgId, Long trustId) {
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("org_id", orgId);
        params.put("org_trust_id", trustId);
        Long systems  = (Long)singleton.lookupObjectByNamedQuery(
                "Org.getSharedChannels", params);
        return systems;
    }

    /**
     * @param orgId Org sharing
     * @param trustId subscribing systems to orgId channels
     * @return number of systems trustId has subscribed to orgId channels
     */
    public static Long getSharedSubscribedSys(Long orgId, Long trustId) {
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("org_id", orgId);
        params.put("org_trust_id", trustId);
        Long systems  = (Long)singleton.lookupObjectByNamedQuery(
                "Org.getSharedSubscribedSys", params);
        return systems;
    }

    /**
     * Lookup all orgs on the satellite.
     * @return List of orgs.
     */
    public static List<Org> lookupAllOrgs() {
        Map<String, Object> params = new HashMap<String, Object>();
        return singleton.listObjectsByNamedQuery(
                "Org.findAll", params);
    }

}

