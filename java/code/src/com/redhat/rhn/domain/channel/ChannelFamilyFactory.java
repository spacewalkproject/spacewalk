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
package com.redhat.rhn.domain.channel;

import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.SelectMode;
import com.redhat.rhn.common.db.datasource.WriteMode;
import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.frontend.dto.ChannelOverview;

import org.apache.log4j.Logger;
import org.hibernate.Criteria;
import org.hibernate.Session;
import org.hibernate.criterion.Restrictions;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

/**
 * ChannelFamilyFactory
 * @version $Rev$
 */
public class ChannelFamilyFactory extends HibernateFactory {

    private static ChannelFamilyFactory singleton = new ChannelFamilyFactory();
    private static Logger log = Logger.getLogger(ChannelFamilyFactory.class);
    public static final String SATELLITE_CHANNEL_FAMILY_LABEL = "rhn-satellite";
    public static final String PROXY_CHANNEL_FAMILY_LABEL = "rhn-proxy";

    private ChannelFamilyFactory() {
        super();
    }

    /**
     * Get the Logger for the derived class so log messages
     * show up on the correct class
     */
    protected Logger getLogger() {
        return log;
    }

    /**
     * Lookup a ChannelFamily by its id
     * @param id the id to search for
     * @return the ChannelFamily found
     */
    public static ChannelFamily lookupById(Long id) {
        ChannelFamily cfam = (ChannelFamily)
            HibernateFactory.getSession().get(ChannelFamily.class, id);
        return cfam;
    }

    /**
     * Lookup a ChannelFamily by its label
     * @param label the label to search for
     * @param org the Org the Family belongs to, use null if looking for
     *        official RedHat ChannelFamilies
     * @return the ChannelFamily found
     */
    public static ChannelFamily lookupByLabel(String label, Org org) {
        Session session = getSession();
        Criteria c = session.createCriteria(ChannelFamily.class);
        c.add(Restrictions.eq("label", label));
        c.add(Restrictions.or(Restrictions.eq("org", org),
              Restrictions.isNull("org")));
        return (ChannelFamily) c.uniqueResult();
    }

    /**
     * Lookup a ChannelFamily by org - this is the org's private
     * channel family, which has all of the org's custom channels in
     * it.
     * @param orgIn the org who's family this is
     * @return the ChannelFamily found
     */
    public static ChannelFamily lookupByOrg(Org orgIn) {
        Map params = new HashMap();
        params.put("orgId", orgIn.getId());
        return (ChannelFamily) singleton.lookupObjectByNamedQuery(
                                       "ChannelFamily.findByOrgId", params);
    }

    /**
     * Checks that an org has a channel family associated with it.  If
     * not, creates the org's channel family.
     *
     * @param orgIn the org to verify
     * @return the ChannelFamily found or created
     */
    public static ChannelFamily lookupOrCreatePrivateFamily(Org orgIn) {
        ChannelFamily cfam = lookupByOrg(orgIn);

        if (cfam == null) {
            String label = "private-channel-family-" + orgIn.getId();
            String suffix = " (" + orgIn.getId() + ") Channel Family";
            String prefix = orgIn.getName();
            int len = prefix.length() + suffix.length();
            if (len > 128) {
                int diff = len - 128;
                prefix = prefix.substring(1, prefix.length() - diff);
            }

            String name = prefix.concat(suffix);

            cfam = new ChannelFamily();
            cfam.setOrg(orgIn);
            cfam.setLabel(label);
            cfam.setName(name);

            // TODO: The productUrl should change to a java page, with
            // a redirect from the old URL to the new, when we rewrite
            // the page in question.

            cfam.setProductUrl("org_channel_family.pxt");

            ChannelFamilyFactory.save(cfam);

            //If we're creating a new channel fam, make sure the org has
            updateFamilyPermissions(orgIn);
            //permission to use it.
        }
        return cfam;
    }

    /**
     * Checks if the org has permission to its channel family.
     * If it does not, grants permissions.
     * Based on modules/rhn/RHN/DB/ChannelEditor.pm->verify_family_permissions
     * @param org The org for which we are verifing channel family permissions.
     * @return A list of ids as Longs of the channel families for which
     *         permissions were updated.
     */
    private static List updateFamilyPermissions(Org org) {
        //Get a list of channel families that belong to this org
        //for which this org does not have appropriate permissions
        SelectMode m = ModeFactory.getMode("Channel_queries",
                "families_for_org_without_permissions");
        Map params = new HashMap();
        params.put("org_id", org.getId());
        Iterator i = m.execute(params).iterator();

        //Insert permissions for this org
        List ids = new ArrayList();
        WriteMode m2 = ModeFactory.getWriteMode("Channel_queries", "insert_family_perms");
        while (i.hasNext()) {
            Long next = new Long(((ChannelOverview) i.next()).getId().longValue());
            ids.add(next);

            params.clear();
            params.put("org_id", org.getId());
            params.put("id", next);
            m2.executeUpdate(params);
        }

        //return the list of ids
        return ids;
    }

    /**
     * Insert or Update a ChannelFamily.
     * @param cfam ChannelFamily to be stored in database.
     */
    public static void save(ChannelFamily cfam) {
        singleton.saveObject(cfam);
    }

    /**
     * Remove a ChannelFamily from the DB
     * @param cfam ChannelFamily to be removed from database.
     */
    public static void remove(ChannelFamily cfam) {
        singleton.removeObject(cfam);
    }

    /**
     * Lookup the List of ChannelFamily objects that are labled starting
     * with the passed in label param
     * @param label to query against
     * @param orgIn owning the Channel.  Pass in NULL if you want a NULL org channel
     * @return List of Channel objects
     */
    public static List lookupByLabelLike(String label, Org orgIn) {
        Session session = getSession();
        Criteria c = session.createCriteria(ChannelFamily.class);
        c.add(Restrictions.like("label", label + "%"));
        c.add(Restrictions.or(Restrictions.eq("org", orgIn),
              Restrictions.isNull("org")));
        return  c.list();
    }

}
