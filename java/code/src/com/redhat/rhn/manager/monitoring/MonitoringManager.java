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
package com.redhat.rhn.manager.monitoring;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.SelectMode;
import com.redhat.rhn.domain.monitoring.MonitoringConstants;
import com.redhat.rhn.domain.monitoring.MonitoringFactory;
import com.redhat.rhn.domain.monitoring.Probe;
import com.redhat.rhn.domain.monitoring.ServerProbe;
import com.redhat.rhn.domain.monitoring.TemplateProbe;
import com.redhat.rhn.domain.monitoring.command.Command;
import com.redhat.rhn.domain.monitoring.command.CommandGroup;
import com.redhat.rhn.domain.monitoring.config.ConfigMacro;
import com.redhat.rhn.domain.monitoring.config.MonitoringConfigFactory;
import com.redhat.rhn.domain.monitoring.notification.Filter;
import com.redhat.rhn.domain.monitoring.notification.NotificationFactory;
import com.redhat.rhn.domain.monitoring.satcluster.SatCluster;
import com.redhat.rhn.domain.monitoring.satcluster.SatClusterFactory;
import com.redhat.rhn.domain.monitoring.suite.ProbeSuite;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerConstants;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.SystemOverview;
import com.redhat.rhn.frontend.dto.monitoring.ServerProbeDto;
import com.redhat.rhn.frontend.dto.monitoring.TimeSeriesData;
import com.redhat.rhn.frontend.listview.PageControl;
import com.redhat.rhn.manager.BaseManager;
import com.redhat.rhn.manager.satellite.SystemCommandExecutor;
import com.redhat.rhn.manager.system.SystemManager;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * MonitoringManager
 * @version $Rev: 51332 $
 */
/**
 * MonitoringManager
 * @version $Rev$
 */
public class MonitoringManager extends BaseManager {
    
    private static MonitoringManager instance = new MonitoringManager();
    private static Logger log = Logger.getLogger(MonitoringManager.class);
    
    /**
     * Default constructor
     */
    public MonitoringManager() {
    
    }
    
    /**
     * Get the instance of the MonitoringManager
     * @return MonitoringManager instance
     */
    public static MonitoringManager getInstance() {
        return instance;
    }
    
    
    /**
     * Get the List of com.redhat.rhn.frontend.dto.monitoring.StateChangeData associated
     * with this probe between the two Timestamps
     * @param probeIn probe we want to lookup
     * @param startTime starting time
     * @param endTime ending time
     * @return List of StateChangeData DTO objects
     */
    public DataResult getProbeStateChangeData(Probe probeIn, 
            Timestamp startTime, Timestamp endTime) {
        
        SelectMode scMode = 
            ModeFactory.getMode("Monitoring_queries", "state_change_for_probe");
        Map params = new HashMap();
        // Convert to millis to minutes
        Long startMinutes = new Long(startTime.getTime() / 1000);
        Long endMinutes = new Long(endTime.getTime() / 1000);
        
        params.put("oid", probeIn.getId().toString());
        params.put("start_time", startMinutes);
        params.put("end_time", endMinutes);
        return makeDataResultNoPagination(params, new HashMap(), scMode);
    }
    
    /**
     * Get a List of TimeSeriesData DTOs 
     * 
     * @param probeIn probe to get data from
     * @param metrics array of metrics we want to fetch
     * @param startTime start time to lookup
     * @param endTime end time to lookup
     * @return List of TimeSeriesData DTO objects
     */
    public List getProbeDataList(Probe probeIn, String[] metrics, 
            Timestamp startTime, 
            Timestamp endTime) {
        
        List retval = new LinkedList();
        // Some Probes have no metrics
        if (metrics == null) {
            return retval;
        }
        for (int i = 0; i < metrics.length; i++) {
            TimeSeriesData[] tsd = getProbeData(probeIn, metrics[i], 
                    startTime, endTime);
            if (tsd != null) {
                retval.add(tsd);
            }
        }
        return retval;
    }
    
    /**
     * Get the timeseries data for a probe
     * @param probeIn probe we want data for
     * @param metricId probe metric we are going to search for
     * @param startTime start time to lookup
     * @param endTime end time to lookup
     * @return array of TimeSeriesData DTO objects
     */
    public TimeSeriesData[] getProbeData(Probe probeIn, String metricId,
            Timestamp startTime, 
            Timestamp endTime) {
        
        SelectMode tsMode = ModeFactory.getMode("Monitoring_queries",
            "time_series_for_probe");
        // Convert to minutes from millis
        Long startMinutes = new Long(startTime.getTime() / 1000);
        Long endMinutes = new Long(endTime.getTime() / 1000);
        
        Map params = new HashMap();
        //Must concat the values together
        //to produce the oid: 1-3-pctfree
        //     orgId-probeId-metric
        StringBuffer oid = new StringBuffer();
        oid.append(probeIn.getOrg().getId());
        oid.append("-");
        oid.append(probeIn.getId());
        oid.append("-");
        oid.append(metricId);
        params.put("oid", oid.toString());
        params.put("start_time", startMinutes);
        params.put("end_time", endMinutes);
        log.debug("Params: " + params);
        DataResult dr = tsMode.execute(params);
        log.debug("results: " + dr);
        if (dr.size() == 0) {
            return null;
        }
        
        Iterator i = dr.iterator();
        List retval = new LinkedList();
        while (i.hasNext()) {
            Map row = (Map) i.next();
            // Have to multiply by 1000 since
            // this table stores the data as seconds since 1970, 
            // not millis.
            Timestamp entryTime = new Timestamp(
                    ((Long) row.get("entry_time")).longValue() * 1000);
            String sdata =  (String) row.get("data");
            
            if (sdata == null) {
                sdata = "0.0";
            }
            Float data = new Float(sdata); 
            TimeSeriesData tsd = 
                new TimeSeriesData(oid.toString(), data, entryTime, metricId);
            retval.add(tsd);
        }
        return (TimeSeriesData[]) retval.toArray(new TimeSeriesData[0]);
    }
    
    /**
     * Lookup a probe 
     * @param currentUser current User who wants to lookup the probe
     * @param id id of the probe we want to lookup
     * @return ServerProbe 
     */
    public Probe lookupProbe(User currentUser, Long id) {
        return MonitoringFactory.lookupProbeByIdAndOrg(
                id, currentUser.getOrg());
    }
    
    /**
     * Stores a ServerProbe to the DB
     * @param probeIn The ServerProbe to store.
     * @param userIn The user who wants to store the ServerProbe
     */
    public void storeProbe(Probe probeIn, User userIn) {
        MonitoringFactory.save(probeIn, userIn);
    }

    /**
     * Get the list of ConfigMacro classes that are used to store
     * the Monitoring configuration.
     * @param adminUser User who is requesting the config, checked to 
     * make sure they have either the MONITORING_ADMIN or ORG_ADMIN roles.
     * @return List of com.redhat.rhn.domain.monitoring.config.ConfigMacro
     * objects, Collections.EMPTY_LIST if User doesnt have ORG_ADMIN
     */
    public List getEditableConfigMacros(User adminUser) {
        if (!adminUser.hasRole(RoleFactory.MONITORING_ADMIN) && 
                !adminUser.hasRole(RoleFactory.ORG_ADMIN)) {
            return Collections.EMPTY_LIST;
        }
        return MonitoringConfigFactory.lookupConfigMacros(true);
    }
    
    /**
     * Store a ConfigMacro to the DB.
     * @param cMacroIn the ConfigMacro that you want to store
     */
    public void storeConfigMacro(ConfigMacro cMacroIn) {
        MonitoringConfigFactory.saveConfigMacro(cMacroIn);
    }
    
    /**
     * Restarts the Monitoring services.  WARNING:  This calls Runtime.exec()
     * to restart the services.
     * 
     * @param userIn user who wants to restart the sat, must be ORG_ADMIN
     * @return did we restart
     */
    public boolean restartMonitoringServices(User userIn) {
        if (!userIn.hasRole(RoleFactory.ORG_ADMIN) && 
                !userIn.hasRole(RoleFactory.MONITORING_ADMIN)) {
            return false;
        }
        restartService("MonitoringScout");
        restartService("Monitoring");
        return true;
    }
    
    /**
     * Delete a probe
     * @param probeIn probe to delete
     * @param currentUser user who wants to delete the probe
     */
    public void deleteProbe(Probe probeIn, User currentUser) {
        if (probeIn.getOrg() != currentUser.getOrg()) {
            throw new 
                IllegalArgumentException("currentUser not in same Org as ServerProbe");
        }
        MonitoringFactory.deleteProbe(probeIn);
    }
    
    // Restart the a named service.
    // WARNING: Dangerous code here, actually calls out to the 
    // native system and restarts services
    protected void restartService(String serviceName) {

        log.debug("Restarting service");
        String[] args = new String[4];
        args[0] = "/usr/bin/sudo";
        args[1] = "/sbin/service";
        args[2] = serviceName;
        args[3] = "restart";
        SystemCommandExecutor ce = new SystemCommandExecutor();
        ce.execute(args);
    }
    
    /**
     * Return the command group whose group name is <code>name</code> or
     * <code>null</code> if no such group exists.
     * @param name the name of the command group to look up
     * @return a command group with group name <code>name</code> or
     * <code>null</code> if no such group exists.
     */
    public CommandGroup lookupCommandGroup(String name) {
        return MonitoringFactory.lookupCommandGroup(name);
    }

    /**
     * Return the command with the name <code>name</code>, or
     * <code>null</code> if no such command exists.
     * @param name the name of the command to look up
     * @return the command with the name <code>name</code>, or
     * <code>null</code> if no such command exists.
     */
    public Command lookupCommand(String name) {
        return MonitoringFactory.lookupCommand(name);
    }

    /** 
     * Create a new ProbeSuite.
     * @param creatorIn User who created the ProbeSuite
     * @return newly created ProbeSuite.
     */
    public ProbeSuite createProbeSuite(User creatorIn) {
        return MonitoringFactory.createProbeSuite(creatorIn);
    }
    
    /**
     * Return the probe suites for the user's org, listed
     * as <code>ProbeSuiteDto</code>s
     * @param user the user for whom to list the suites
     * @param pc page control
     * @return a list of probe suites in the user's org, listed
     * as <code>ProbeSuiteDto</code>s 
     */
    public DataResult listProbeSuites(User user, PageControl pc) {
        SelectMode m = ModeFactory.getMode("Monitoring_queries", "probe_suites_in_org");
        Map params = new HashMap();
        params.put("user_id", user.getId());
        params.put("org_id", user.getOrg().getId());
        Map elabParams = new HashMap();
        return makeDataResult(params, elabParams, pc, m);
    }
    
    /** 
     * Lookup a ProbeSuite
     * @param suiteId id of the Suite
     * @param userIn who is wanting to lookup the ProbeSuite
     * @return ProbeSuite if found
     */
    public ProbeSuite lookupProbeSuite(Long suiteId, User userIn) {
        return MonitoringFactory.lookupProbeSuiteByIdAndOrg(suiteId, userIn.getOrg());
    }
    
    /**
     * Store the ProbeSuite to the DB.
     * @param suiteIn to store
     * @param userIn who is wanting to store the ProbeSuite
     */
    public void storeProbeSuite(ProbeSuite suiteIn, User userIn) {
        MonitoringFactory.saveProbeSuite(suiteIn, userIn);
    }
    
    /**
     * Add a System to a ServerProbe suite.
     * @param suiteIn to add the System to
     * @param serverIn system to add
     * @param clusterIn SatCluster to use for the probes in the Suite
     * @param userIn user wanting to add
     */
    public void addSystemToProbeSuite(ProbeSuite suiteIn, Server serverIn, 
            SatCluster clusterIn, User userIn) {
        suiteIn.addServerToSuite(clusterIn, serverIn, userIn);        
    }
    
    /**
     * This deletes Server from this ProbeSuite. Deletes the 
     * assocation between this ProbeSuite and the Server as 
     * well as deletes ALL the Probes in this Suite from 
     * this Server.
     * 
     * @param suiteIn probesuite that we want to remove the server from.
     * @param serverIn Server to add to the ProbeSuite.
     * @param userIn who is adding the suite
     * 
     * 
     */    
    public void removeServerFromSuite(ProbeSuite suiteIn, Server serverIn, User userIn) {
        removeServerAndProbes(suiteIn, serverIn, userIn, true);
    }

    /**
     * Convenience method to detach a Server from this ProbeSuite. 
     * This makes all the Probes assigned to the Server only.
     * 
     * @param suiteIn probesuite that we want to detatch the server from.
     * @param serverIn Server to add to the ProbeSuite.
     * @param userIn who is adding the suite
     * 
     */
    public void detatchServerFromSuite(ProbeSuite suiteIn, Server serverIn, User userIn) {
        removeServerAndProbes(suiteIn, serverIn, userIn, false);
    }
    
    /** 
     * Util method to remove the Server from the ProbeSuite 
     * 
     * @param serverIn to remove
     * @param currentUser User who wants to remove it
     * @param delete if we want to delete the Probes assigned to the Server 
     *        or not.  
     */
    private void removeServerAndProbes(ProbeSuite suiteIn, Server serverIn, 
            User currentUser, boolean delete) {
        
        if (suiteIn.getProbes() == null || suiteIn.getProbes().size() == 0) {
            throw new IllegalArgumentException(
                    "Must add Probes to the Suite before we can remove Servers");
        }
        Iterator i = suiteIn.getProbes().iterator();
        
        while (i.hasNext()) {
            TemplateProbe tProbe = (TemplateProbe) i.next();
            Iterator j = tProbe.getServerProbes().iterator();
            while (j.hasNext()) {
                ServerProbe sProbe = (ServerProbe) j.next();
                if (sProbe.getServer().equals(serverIn)) {
                    j.remove();
                    tProbe.removeServerProbe(sProbe);
                    if (delete) {
                        MonitoringFactory.deleteProbe(sProbe);
                    }
                }
            }
        }
    }
    
    
    /**
     * Delete a ProbeSuite
     * 
     * @param suiteIn suite to delete
     */
    public void deleteProbeSuite(ProbeSuite suiteIn) {
        MonitoringFactory.deleteProbeSuite(suiteIn);
    }
    
    /** 
     * Lookup a notification Filter.
     * @param id of the Filter
     * @param currentUser who wants to look up
     * @return Filter if found, null if not.
     */
    public Filter lookupFilter(Long id, User currentUser) {
       return NotificationFactory.lookupFilter(id, currentUser);
    }
    
    /**
     * Save the Filter
     * @param filterIn to save
     * @param currentUser who wants to save
     */
    public void storeFilter(Filter filterIn, User currentUser) {
        NotificationFactory.saveFilter(filterIn, currentUser);
    }
    
    /**
     * List the notification Filters in the Org.
     * Returns the list of Maps with 3 fields: name, type, expiration. 
     *  
     * @param orgIn Org we want to fetch the Suites for
     * @param pc PageControl
     * @param active if we want to show active filters or expired filters (false).  
     * @return the probe suites for <code>orgIn</code>
     */
    public DataResult filtersInOrg(Org orgIn, PageControl pc, boolean active) {
        String mode;
        if (active) {
            mode = "active_filters_in_org";
        } 
        else {
            mode = "expired_filters_in_org";
        }
        SelectMode m = ModeFactory.getMode("Monitoring_queries", mode);
        Map params = new HashMap();
        params.put("org_id", orgIn.getId());
        Map elabParams = new HashMap();
        return makeDataResult(params, elabParams, pc, m);
    }
    
    /**
     * Return an iterator over all the commands in <code>group</code>. If
     * <code>group</code> has the group name
     * {@link CommandGroup#ALL_GROUP_NAME}all commands are returned.
     * 
     * @param group the group for which to return the commands
     * @return a list of all the {@link Command} objects in the given group
     */
    public List listCommands(CommandGroup group) {
        if (CommandGroup.ALL_GROUP_NAME.equals(group.getGroupName())) {
            return MonitoringFactory.loadAllCommands();
        }
        else {
            return new ArrayList(group.getCommands());
        }
    }
   
    /**
     * List all the scouts a user has access to
     * @param currentUser the current user
     * @return a list of scouts for the user
     */
    public Set listScouts(User currentUser) {
        Org defaultOrg = OrgFactory.getSatelliteOrg();

        // Start with the scouts for this users org:
        Set scouts = new HashSet();
        scouts.addAll(currentUser.getOrg().getMonitoringScouts());

        // If user is not in the default org, add in the default scout:
        if (currentUser.getOrg().getId() != defaultOrg.getId()) {
            scouts.add(SatClusterFactory.getDefaultSatCluster());
        }
        return scouts;
    }

    /**
     * List all the probes a user has access to
     * @param currentUser the current user
     * @return a list of probes for the user
     */
    public DataResult listProbes(User currentUser) {
        SelectMode m = ModeFactory.getMode("Monitoring_queries", "probes_in_org");
        Map params = new HashMap();
        params.put("org_id", currentUser.getOrg().getId());
        Map elabParams = new HashMap();
        
        return makeDataResult(params, elabParams, null, m);
    }

    /**
     * List the probes in a suite
     * @param suiteID the id of the suite
     * @param currentUser the user requesting the list
     * @param pc the page control
     * @return a list of probes, containing <code>id</code>, <code>description</code> and
     * <code>cmd_description</code>
     */
    public DataResult listProbesInSuite(Long suiteID, User currentUser, PageControl pc) {
        SelectMode m = ModeFactory.getMode("Monitoring_queries", "probes_in_probe_suite");
        Map params = new HashMap();
        params.put("org_id", currentUser.getOrg().getId());
        params.put("suite_id", suiteID);
        Map elabParams = new HashMap();
        return makeDataResult(params, elabParams, pc, m);
    }
    
    /**
     * List all the contact groups a user has access to
     * @param currentUser the current user
     * @return a list of contact groups for the user
     */
    public DataResult listContactGroups(User currentUser) {
        SelectMode m = ModeFactory.getMode("Monitoring_queries", "contact_groups_in_org");
        Map params = new HashMap();
        params.put("org_id", currentUser.getOrg().getId());
        Map elabParams = new HashMap();
        return makeDataResult(params, elabParams, null, m);
    }
    
    /**
     * Get the list of Systems that aren't in this suite.  Only lists Monitoring entitled
     * Systems.
     * @param currentUser of the site
     * @param suiteIn current ProbeSuite we want to look up against.
     * @param pc pageControl we are using
     * @return DataResult of SystemOverview DTOs
     */
    public DataResult systemsNotInSuite(User currentUser, 
                                        ProbeSuite suiteIn, 
                                        PageControl pc) {
        // First fetch *all* relavent systems.  Pass
        // in a NULL PageControl so we can do some manual
        // filtering below.  Easier than doing it in a query
        // because we get to reuse a lot of business logic.
        DataResult retval = 
            SystemManager.systemsWithFeature(currentUser, 
                    ServerConstants.FEATURE_PROBES, null);
        // Now we filter out the selected items.  We could
        // do this in the query, but its easier to just filter
        // them out here.
        Set s = suiteIn.getServersInSuite();
        Set sIds = new HashSet();
        Iterator i = s.iterator();
        while (i.hasNext()) {
            Server sInSuite = (Server) i.next();
            sIds.add(sInSuite.getId());
        }
        i = retval.iterator();
        // Now iterate over list of DTOs
        // and make sure we remove any items
        // that are already part of the suite.
        Long someValue = new Long(1);
        while (i.hasNext()) {
            SystemOverview so = (SystemOverview) i.next();
            if (sIds.contains(new Long(so.getId().longValue()))) {
                i.remove();
            }
            else {
                so.setSelectable(someValue);
            }
        }
        //  Now we filter based on the PageControl.
        return processPageControl(retval, pc, new HashMap());
    }
    
    /**
     * Get the Probes running against a system.  Much faster than Hibernate.
     * 
     * @param currentUser  who is requesting the probes
     * @param serverIn who's probes you want to see 
     * @param pc for pagnation.  Null if you want them all.
     * @return DataResult of ServerProbeDto objects
     */
    public DataResult<ServerProbeDto> probesForSystem(User currentUser, Server serverIn, 
            PageControl pc) {

        SelectMode m = ModeFactory.getMode("Monitoring_queries", "probes_in_server");
        Map params = new HashMap();
        params.put("sid", serverIn.getId());
        Map elabParams = new HashMap();
        return makeDataResultNoPagination(params, elabParams, m);
        
    }
    
    /**
     * Get the Probes running against a system that are in the warning or critical status
     * 
     * @param currentUser  who is requesting the probes
     * @param serverIn who's probes you want to see 
     * @param pc for pagnation.  Null if you want them all.
     * @return DataResult of ServerProbeDto objects
     */
    public DataResult probesForSystemWithAlerts(User currentUser, 
                                                Server serverIn, 
                                                PageControl pc) {

        SelectMode m = ModeFactory.getMode("Monitoring_queries", 
                                           "probes_in_server_with_alerts");
        Map params = new HashMap();
        params.put("sid", serverIn.getId());
        Map elabParams = new HashMap();
        return makeDataResultNoPagination(params, elabParams, m);
        
    }
    
    /**
     * Get the Systems assigned to the passed in ProbeSuite.  Much
     * faster than using Hibernate. 
     * @param currentUser who is requesting the systems
     * @param suiteIn who you want to get the servers for
     * @param pc for pagination. Null if you want them all.
     * @return DataResult of MonitoredServerDto objects.
     */
    public DataResult systemsInSuite(User currentUser, 
                                        ProbeSuite suiteIn, 
                                        PageControl pc) {
        
        SelectMode m = ModeFactory.getMode("Monitoring_queries", "servers_in_suite");
        Map params = new HashMap();
        params.put("suite_id", suiteIn.getId());
        Map elabParams = new HashMap();
        return makeDataResult(params, elabParams, pc, m);

    }
    
    /**
     * Get the list of Notification Methods associated with the org.
     * @param currentUser who is requesting
     * @param pc to filter results
     * @return DataResult containing the notification methods
     */
    public DataResult notificationMethodsInOrg(User currentUser, 
                                               PageControl pc) {
        SelectMode m = ModeFactory.getMode("Monitoring_queries", "methods_in_org");
        Map params = new HashMap();
        params.put("org_id", currentUser.getOrg().getId());
        Map elabParams = new HashMap();
        return makeDataResult(params, elabParams, pc, m);
    }

    /**
     * Get list of probe summary records 
     * @param user making the query
     * @param probeStateIn String representation of the probe state.  
     * @param pc PageControl to be used for making the returned DataResults
     * See MonitoringConstants.PROBE_STATE_*
     * @return DataResult list of Maps.
     */
    public DataResult listProbeCountsByState(User user, 
            String probeStateIn, PageControl pc) {
        SelectMode m = ModeFactory.getMode("Monitoring_queries", "probe_counts_by_state");
        Map params = new HashMap();
        params.put("user_id", user.getId());
        params.put("org_id", user.getOrg().getId());
        params.put("state", probeStateIn);
        Map elabParams = new HashMap();
        return makeDataResult(params, elabParams, pc, m);
    }
    
    /**
     * Get list of probe summary records 
     * @param user making the query
     * @param probeStateIn String representation of the probe state.  
     * @param pc PageControl to be used for making the returned DataResults
     * See MonitoringConstants.PROBE_STATE_*
     * @return DataResult list of Maps.
    */ 
    public DataResult listProbesByState(User user, String probeStateIn, PageControl pc) {
        String modeName = null;
        Map params = new HashMap();
        if (StringUtils.isEmpty(probeStateIn)) {
            modeName = "probes";
        }
        else {
            if (!probeStateIn.equals(MonitoringConstants.PROBE_STATE_CRITICAL) && 
                    !probeStateIn.equals(MonitoringConstants.PROBE_STATE_OK) &&
                    !probeStateIn.equals(MonitoringConstants.PROBE_STATE_PENDING) &&
                    !probeStateIn.equals(MonitoringConstants.PROBE_STATE_WARN) &&
                    !probeStateIn.equals(MonitoringConstants.PROBE_STATE_UNKNOWN)) {
                throw new IllegalArgumentException("Not a valid probe state: " + 
                        probeStateIn);
            }
            modeName = "probes_by_state";
            params.put("state", probeStateIn);
        }
        SelectMode m = ModeFactory.getMode("Monitoring_queries", modeName);
        params.put("user_id", user.getId());
        params.put("org_id", user.getOrg().getId());
                
        Map elabParams = new HashMap();
        return makeDataResult(params, elabParams, pc, m);
    }
    
    /**
     * Get summary of the probe states in the DB.  Returns 2 column result
     * with COUNT, STATE:
     *      22   , CRITICAL
     *      1    , OK
     *      20   , WARNING
     *      ....
     *      
     * @param user making the query
     * See MonitoringConstants.PROBE_STATE_*
     * @return DataResult list of Maps.
    */ 
    public DataResult listProbeStateSummary(User user) {
        
        SelectMode m = ModeFactory.getMode("Monitoring_queries", 
                "probe_state_count_by_user");
        Map params = new HashMap();
        params.put("user_id", user.getId());
        Map elabParams = new HashMap();
        return makeDataResult(params, elabParams, null, m);
    }    
    
}
