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
package com.redhat.rhn.domain.monitoring;

import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.WriteMode;
import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.domain.monitoring.command.Command;
import com.redhat.rhn.domain.monitoring.command.CommandGroup;
import com.redhat.rhn.domain.monitoring.suite.ProbeSuite;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.user.User;

import org.apache.log4j.Logger;

import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

/**
 * MonitoringFactory - the singleton class used to fetch and store
 * com.redhat.rhn.domain.monitoring.ServerProbe objects from the
 * database.
 * @version $Rev: 51602 $
 */
public class MonitoringFactory extends HibernateFactory {

    private static MonitoringFactory singleton = new MonitoringFactory();
    private static Logger log = Logger.getLogger(MonitoringFactory.class);

    private MonitoringFactory() {
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
     * Remove a ServerProbe from the DB
     * @param probeIn to remove
     */
    public static void deleteProbe(Probe probeIn) {
        // This is ugly, but since we delete the probe,
        // we also need to make sure it gets removed from
        // the set of probes in the suite (if there is one)
        if (probeIn instanceof TemplateProbe) {
            TemplateProbe t = (TemplateProbe) probeIn;
            t.getProbeSuite().removeProbe(t);
        }

        // remove relevant entries for probe from time_series table
        WriteMode m = ModeFactory.getWriteMode("Monitoring_queries",
                    "delete_time_series_for_probe");
        Map params = new HashMap();
        params.put("probe_id", probeIn.getId());
        m.executeUpdate(params);

        singleton.removeObject(probeIn);
    }

    /**
     * Lookup a ServerProbe from the DB by its id
     * @param probeId id of the probe we are looking up
     * @param org who owns the probe
     * @return return the ServerProbe if found
     */
    public static Probe lookupProbeByIdAndOrg(Long probeId, Org org) {

        Map params = new HashMap();
        params.put("pid", probeId);
        params.put("orgId", org.getId());
        return (Probe) singleton.lookupObjectByNamedQuery(
                                       "Probe.findByIdandOrgId", params);
    }

    /**
     * Create a new ProbeSuite
     * @param userIn who is creating the ProbeSuite
     * @return newly created ProbeSuite
     */
    public static ProbeSuite createProbeSuite(User userIn) {
        ProbeSuite suite = new ProbeSuite();
        suite.setOrg(userIn.getOrg());
        suite.setLastUpdateDate(new Date());
        suite.setLastUpdateUser(userIn.getLogin());
        return suite;

    }

    /**
     * Lookup a ProbeSuite by its ID as well as the Org owning the Suite.
     * @param psId of the ProbeSuite
     * @param orgIn who owns the ProbeSuite
     * @return ProbeSuite if found.
     */
    public static ProbeSuite lookupProbeSuiteByIdAndOrg(Long psId, Org orgIn) {
        if (psId == null || orgIn == null) {
            throw new IllegalArgumentException("Probe ID or Org are null");
        }
        Map params = new HashMap();
        params.put("psid", psId);
        params.put("orgId", orgIn.getId());
        return (ProbeSuite) singleton.lookupObjectByNamedQuery(
                                       "ProbeSuite.findByIdandOrgId", params);

    }

    /**
     * Save a ProbeSuite to the DB.
     *
     * @param probeSuiteIn ProbeSuite to
     * @param userIn User who is saving the suite.
     */
    public static void saveProbeSuite(ProbeSuite probeSuiteIn, User userIn) {
        probeSuiteIn.setLastUpdateUser(userIn.getLogin());
        probeSuiteIn.setLastUpdateDate(new Date());
        Iterator i = probeSuiteIn.getProbes().iterator();
        while (i.hasNext()) {
            TemplateProbe p = (TemplateProbe) i.next();
            p.setLastUpdateDate(new Date());
        }
        singleton.saveObject(probeSuiteIn);

    }

    /**
     * Delete a probeSuite - deletes all the child probes and probes a
     * assigned to systems.
     * @param probeSuiteIn to delete
     */
    public static void deleteProbeSuite(ProbeSuite probeSuiteIn) {
        singleton.removeObject(probeSuiteIn);
    }
    /**
     * Return a list of command groups. The list is not sorted in any way.
     * @return a list of command groups.
     */
    public static List loadAllCommandGroups() {
        return unmodifiableListFromQuery("CommandGroup.loadAll");
    }

    /**
     * Return a list of all commands. The list is not sorted in any way.
     * @return a list of commands
     */
    public static List loadAllCommands() {
        return unmodifiableListFromQuery("Command.loadAll");
    }

    /**
     * Return the command with the name <code>name</code>, or
     * <code>null</code> if no such command exists.
     * @param name the name of the command to look up
     * @return the command with the name <code>name</code>, or
     * <code>null</code> if no such command exists.
     */
    public static Command lookupCommand(String name) {
        Map params = new HashMap();
        params.put("name", name);
        return (Command)
            singleton.lookupObjectByNamedQuery("Command.findByName", params, true);
    }

    // Util to lookup the probetypes
    static ProbeType lookupProbeType(String type) {
        Map params = new HashMap();
        params.put("type", type);
        return (ProbeType)
            singleton.lookupObjectByNamedQuery("ProbeType.findByType", params, true);

    }
    /**
     * Commit a ServerProbe to the DB
     * @param pIn probe to be saved
     * @param userIn User who is committing the ServerProbe
     */
    public static void save(Probe pIn, User userIn) {
        // Need to set the updatedate so the scout will indicate
        // that it needs pushing.  See BZ: 161796
        pIn.setLastUpdateDate(new Date());
        pIn.setLastUpdateUser(userIn.getLogin());
        singleton.saveObject(pIn);
    }

    /**
     * Return the command group whose group name is <code>name</code> or
     * <code>null</code> if no such group exists.
     * @param name the name of the command group to look up
     * @return a command group with group name <code>name</code> or
     * <code>null</code> if no such group exists.
     */
    public static CommandGroup lookupCommandGroup(String name) {
        List groups = loadAllCommandGroups();
        for (Iterator iter = groups.iterator(); iter.hasNext();) {
            CommandGroup g = (CommandGroup) iter.next();
            if (g.getGroupName().equals(name)) {
                return g;
            }
        }
        return null;
    }

    private static List unmodifiableListFromQuery(String query) {
        List l = singleton.listObjectsByNamedQuery(query, null);
        return Collections.unmodifiableList(l);
    }
}

