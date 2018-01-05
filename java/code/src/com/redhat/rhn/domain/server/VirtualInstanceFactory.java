/**
 * Copyright (c) 2009--2014 Red Hat, Inc.
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
package com.redhat.rhn.domain.server;

import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.domain.org.Org;

import org.apache.log4j.Logger;
import org.hibernate.Session;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Set;

/**
 * VirtualInstanceFactory provides data access operations for virtual instances.
 *
 * @see VirtualInstance
 * @version $Rev$
 */
public class VirtualInstanceFactory extends HibernateFactory {

    private static VirtualInstanceFactory instance = new VirtualInstanceFactory();

    /**
     * Logger for this class
     */
    private static Logger log = Logger
            .getLogger(VirtualInstanceFactory.class);

    private interface HibernateCallback {
        Object executeInSession(Session session);
    }

    @Override
    protected Logger getLogger() {
        return log;
    }

    private Object execute(HibernateCallback command) {
        return command.executeInSession(HibernateFactory.getSession());
    }

    /**
     * Get instance of this factory.
     * @return VirtualInstanceFactory instance
     */
    public static VirtualInstanceFactory getInstance() {
        return instance;
    }

    /**
     * Saves the virtual instance to the database. The save is cascading so that if the
     * virtual instance is a registered guest, then any changes to this virtual instance's
     * guest server will be persisted as well.
     *
     * @param virtualInstance The virtual instance to save
     */
    public void saveVirtualInstance(VirtualInstance virtualInstance) {
        saveObject(virtualInstance);
    }

    /**
     * Gets the virtual Instance for a given Sid for a guest
     * @param id the system id of the guest
     * @param org the org to check against
     * @return the guest's virtual instance
     */
    public VirtualInstance lookupByGuestId(Org org, Long id) {
        Session session = HibernateFactory.getSession();

        return (VirtualInstance) session.getNamedQuery("VirtualInstance.lookupGuestBySid")
                .setParameter("org", org).setParameter("sid", id).uniqueResult();

    }

    /**
     * Check if the given guest instance is outdated. (i.e. a newer instance
     * exists with the same UUID)
     *
     * @param guest Virtual instance to check.
     * @return True if outdated, false otherwise.
     */
    public boolean isOutdated(VirtualInstance guest) {
        Session session = HibernateFactory.getSession();
        VirtualInstance results = (VirtualInstance) session.getNamedQuery(
                "VirtualInstance.isOutdatedVirtualInstance").
                setParameter("guest", guest).uniqueResult();

        return results != null;
    }


    /**
     * Retrieves the virtual instance with the specified ID.
     *
     * @param id The primary key
     * @return The virtual instance with the specified ID or <code>null</code> if no match
     * is found.
     */
    public VirtualInstance lookupById(final Long id) {
        return (VirtualInstance)execute(new HibernateCallback() {
           public Object executeInSession(Session session) {
                return session.get(VirtualInstance.class, id);
            }
        });
    }

    /**
     * Deletes the virtual instance from the database.
     * If the virtual instance has an association to a guest system (i.e. it is
     * a registered guest), remove this association.
     * If the virtual instance has an association to a host system, remove this
     * association.
     *
     * @param virtualInstance The virtual instance to delete
     */
    public void deleteVirtualInstanceOnly(VirtualInstance virtualInstance) {
        log.debug("Deleting virtual instance without removing associated objects " +
                virtualInstance);
        Server hostSystem = virtualInstance.getHostSystem();
        if (hostSystem != null) {
            hostSystem.removeGuest(virtualInstance);
        }
        Server guestSystem = virtualInstance.getGuestSystem();
        if (guestSystem != null) {
            guestSystem.setVirtualInstance(null);
        }
        removeObject(virtualInstance);
    }

    /**
     * Finds all registered guests, within a particular org, whose hosts do not have any
     * virtualization entitlements.
     *
     * @param org The org to search in
     *
     * @return A set of GuestAndNonVirtHostView objects
     *
     * @see GuestAndNonVirtHostView
     */
    public Set findGuestsWithNonVirtHostByOrg(Org org) {
        Session session = HibernateFactory.getSession();
        List results = session.getNamedQuery(
                "VirtualInstance.findGuestsWithNonVirtHostByOrg").
                setParameter("org_id", org.getId()).list();

        return new HashSet(convertToView(results));
    }

    /**
     * transforms a result set of
     * guest.id as guest_id,
     * guest.org_id as guest_org_id,
     * guest.name as guest_name,
     * host.org_id as host_org_id,
     * host.id as host_id,
     * host.name as host_name
     * @param result a list of Object array of  id,name, count
     * @return list of GuestAndNonVirtHostView objects
     */
    private static List convertToView(List out) {
        List ret = new ArrayList(out.size());
        for (Iterator itr = out.iterator(); itr.hasNext();) {
            Object [] row = (Object [])itr.next();

            /**
             * guest.id as guest_id,
                            guest.org_id as guest_org_id,
                            guest.name as guest_name,
                            host.org_id as host_org_id,
                            host.id as host_id,
                            host.name as host_name
             */

            Number guestId = (Number) row[0];
            Number guestOrgId = (Number) row[1];
            String guestName = (String) row[2];

            Number hostId = (Number) row[3];
            Number hostOrgId = (Number) row[4];
            String hostName = (String) row[5];

            GuestAndNonVirtHostView view = new GuestAndNonVirtHostView(
                                                new Long(guestId.longValue()),
                                                new Long(guestOrgId.longValue()),
                                                guestName,
                                                new Long(hostId.longValue()),
                                                new Long(hostOrgId.longValue()),
                                                hostName);
            ret.add(view);
        }
        return ret;
    }


    /**
     * Finds all registered guests, within a particular org, who do not have a registered
     * host.
     *
     * @param org The org to search in
     *
     * @return set A set of GuestAndNonVirtHostView objects
     *
     * @see GuestAndNonVirtHostView
     */
    public Set findGuestsWithoutAHostByOrg(Org org) {
        Session session = HibernateFactory.getSession();

        List results = session.getNamedQuery(
                "VirtualInstance.findGuestsWithoutAHostByOrg").setParameter("org", org)
                .list();

        return new HashSet(results);
    }

    /**
     * Returns the para-virt type.
     *
     * @return  The para-virt type
     */
    public VirtualInstanceType getParaVirtType() {
        return (VirtualInstanceType)getSession().getNamedQuery(
                "VirtualInstanceType.findByLabel").setString("label", "para_virtualized")
                .setCacheable(true).uniqueResult();
    }

    /**
     * Returns the fully-virt type.
     *
     * @return The fully-virt type.
     */
    public VirtualInstanceType getFullyVirtType() {
        return (VirtualInstanceType)getSession().getNamedQuery(
                "VirtualInstanceType.findByLabel").setString("label", "fully_virtualized")
                .setCacheable(true).uniqueResult();
    }

    /**
     * Returns the running state.
     *
     * @return The running state
     */
    public VirtualInstanceState getRunningState() {
        return (VirtualInstanceState)getSession().getNamedQuery(
                "VirtualInstanceState.findByLabel").setString("label", "running")
                .uniqueResult();
    }

    /**
     * Returns the stopped state.
     *
     * @return The stopped state
     */
    public VirtualInstanceState getStoppedState() {
        return (VirtualInstanceState)getSession().getNamedQuery(
            "VirtualInstanceState.findByLabel").setString("label", "stopped")
            .uniqueResult();
    }

    /**
     * Returns the paused state.
     *
     * @return The paused state
     */
    public VirtualInstanceState getPausedState() {
        return (VirtualInstanceState)getSession().getNamedQuery(
            "VirtualInstanceState.findByLabel").setString("label", "paused")
            .uniqueResult();
    }

    /**
     * Return the crashed state.
     *
     * @return The crashed state
     */
    public VirtualInstanceState getCrashedState() {
        return (VirtualInstanceState)getSession().getNamedQuery(
            "VirtualInstanceState.findByLabel").setString("label", "crashed")
            .uniqueResult();
    }

    /**
     * Return the unknown state
     *
     *  @return The unknown state
     */
    public VirtualInstanceState getUnknownState() {
        return (VirtualInstanceState)getSession().getNamedQuery(
                "VirtualInstanceState.findByLabel").setString("label", "unknown")
                .uniqueResult();
    }
}
