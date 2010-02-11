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
package com.redhat.rhn.manager.kickstart;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.SelectMode;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.kickstart.KickstartableTree;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.ActivationKeyDto;
import com.redhat.rhn.frontend.dto.kickstart.CobblerProfileDto;
import com.redhat.rhn.frontend.dto.kickstart.KickstartDto;
import com.redhat.rhn.frontend.dto.kickstart.ScriptDto;
import com.redhat.rhn.frontend.listview.PageControl;
import com.redhat.rhn.manager.BaseManager;
import com.redhat.rhn.manager.kickstart.cobbler.CobblerXMLRPCHelper;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.cobbler.CobblerConnection;
import org.cobbler.Distro;
import org.cobbler.Profile;

import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * KickstartLister
 * @version $Rev$
 */
public class KickstartLister extends BaseManager {

    /**
     * Logger for this class
     */
    private static Logger logger = Logger.getLogger(KickstartLister.class);

    private static KickstartLister instance = new KickstartLister();

    /**
     * Default constructor
     */
    public KickstartLister() {

    }

    /**
     * Get the instance of the KickstartLister
     * @return KickstartLister instance
     */
    public static KickstartLister getInstance() {
        return instance;
    }

   /**
     * List the kickstart profiles in the Org.
     * Returns the list of Maps with x fields: , , .
     *
     * @param orgIn Org we want to fetch the kickstart profiles for
     * @param pc PageControl 
     * @return the kickstart profiles for <code>orgIn</code>
     */
    public DataResult<KickstartDto> kickstartsInOrg(Org orgIn, PageControl pc) {
        if (logger.isDebugEnabled()) {
            logger.debug("kickstartsInOrg(Org orgIn=" + orgIn.getId() +
                    ", PageControl pc=" + pc + ") - start");
        }

        SelectMode m = ModeFactory.getMode("General_queries", "kickstarts_for_org");
        Map params = new HashMap();
        params.put("org_id", orgIn.getId());
        Map elabParams = new HashMap();
        DataResult<KickstartDto> returnDataResult = makeDataResult(params,
                                                            elabParams, pc, m);
        if (logger.isDebugEnabled()) {
            logger.debug("kickstartsInOrg(Org, PageControl) - end - return value=" +
                    returnDataResult);
        }
        return returnDataResult;
    }

    /**
     * Finds all kickstartable trees for a given org
     * @param orgIn org to use for lookup
     * @param pc page control from calling listview
     * @return DataResult filled with KickstartableTreeDto instances
     */
    public DataResult kickstartTreesInOrg(Org orgIn, PageControl pc) {
        if (logger.isDebugEnabled()) {
            logger.debug("kickstartTreesInOrg(Org orgIn=" + orgIn +
                    ", PageControl pc=" + pc + ") - start");
        }
        SelectMode m = ModeFactory.getMode("General_queries", "kickstart_trees_for_org");
        Map params = new HashMap();
        params.put("org_id", orgIn.getId());
        DataResult retval = makeDataResult(params, null, pc, m);
        if (logger.isDebugEnabled()) {
            logger.debug("kickstartTreesInOrg(Org, PageControl) - end - return value=" +
                    retval);
        }
        return retval;
    }
    
    /**
     * List the kickstart scripts for a particular kickstart.
     * Returns the list of Maps with x fields: , , .
     *
     * @param orgIn Org coming in. 
     * @param ksIn Kickstart Id we want to fetch scripts for
     * @param pc PageControl
     * @return the kickstart profiles for <code>orgIn</code>
     */
    public DataResult scriptsInKickstart(Org orgIn, Long ksIn, PageControl pc) {
        
        SelectMode m = ModeFactory.getMode("General_queries", "scripts_for_kickstart");
        Map params = new HashMap();        
        params.put("kickstart_id", ksIn);
        params.put("org_id", orgIn.getId());
        Map elabParams = new HashMap();
        DataResult returnDataResult = makeDataResult(params, elabParams, pc, m);
        if (logger.isDebugEnabled()) {
            logger.debug("scriptsInKickstart(KS, PageControl) - end - return value=" +
                    returnDataResult);
        }
        int i = 1;
        for (Iterator itr = returnDataResult.iterator(); itr.hasNext();) {
            ScriptDto script = (ScriptDto)itr.next();
            script.setPosition(i++);           
        }
        return returnDataResult;
    }
    
    /**
     * List the kickstart ip ranges in the Org.
     * Returns the list of Maps with x fields: , , .
     *
     * @param orgIn Org we want to fetch the kickstart ip ranges for
     * @param pc PageControl
     * @return the kickstart profiles for <code>orgIn</code>
     */
    public DataResult kickstartIpRangesInOrg(Org orgIn, PageControl pc) {
        if (logger.isDebugEnabled()) {
            logger.debug("kickstartIpRangesInOrg(Org orgIn=" + orgIn +
                    ", PageControl pc=" + pc + ") - start");
        }

        SelectMode m = ModeFactory.getMode("General_queries", "org_ks_ip_ranges");
        Map params = new HashMap();
        params.put("org_id", orgIn.getId());
        Map elabParams = new HashMap();
        DataResult returnDataResult = makeDataResult(params, elabParams, pc, m);
        if (logger.isDebugEnabled()) {
            logger.debug("kickstartIpRangesInOrg(Org, PageControl) - end - return value=" +
                    returnDataResult);
        }
        return returnDataResult;
    }

    
    /**
     * Get the list of GPG keys definied for this org.  Returns
     * DataResult of CryptoKeyDto.
     * @param orgIn that has the GPG keys
     * @param pc the page control
     * @return DataResult of GPG keys
     */
    public DataResult cryptoKeysInOrg(Org orgIn, PageControl pc) {
        if (logger.isDebugEnabled()) {
            logger.debug("gpgKeysInOrg(Org orgIn=" + 
                    orgIn + ") - start");
        }
        SelectMode m = ModeFactory.getMode("General_queries", "crypto_keys_for_org");
        Map params = new HashMap();
        params.put("org_id", orgIn.getId());
        DataResult returnDataResult = makeDataResult(params, new HashMap(), null, m);
        if (logger.isDebugEnabled()) {
            logger.debug("gpgKeysInOrg(Org, PageControl) - end - return value=" + null);
        }
        return returnDataResult;
    }

    /**
     * Get the list of File Preservation lists.
     * @param orgIn to lookup
     * @param pc to filter 
     * @return DataResult list.
     */
    public DataResult preservationListsInOrg(Org orgIn, PageControl pc) {
        if (logger.isDebugEnabled()) {
            logger.debug("preservationListsInOrg(Org orgIn=" + orgIn +
                    ", PageControl pc=" + pc + ") - start");
        }

        SelectMode m = ModeFactory.getMode("General_queries", "preservations_for_org");
        Map params = new HashMap();
        params.put("org_id", orgIn.getId());
        DataResult returnDataResult = makeDataResult(params, new HashMap(), pc, m);

        if (logger.isDebugEnabled()) {
            logger.debug("preservationListsInOrg(Org, PageControl) - end - return value=" +
                    returnDataResult);
        }
        return returnDataResult;
    }

    /**
     * Get the list of Activation Keys
     * @param orgIn Org
     * @param pc to filter 
     * @return DataResult list.
     */
    public DataResult <ActivationKeyDto> getActivationKeysInOrg(Org orgIn, 
                                                              PageControl pc) {
        if (logger.isDebugEnabled()) {
            logger.debug("activationKeysForKickstartProfile(Org orgIn=" + orgIn +
                    ", PageControl pc=" + pc + ") - start");
        }

        SelectMode m = ModeFactory.getMode("General_queries",
                                           "activation_keys_for_org");
        Map params = new HashMap();
        params.put("org_id", orgIn.getId());
        DataResult <ActivationKeyDto>  returnDataResult = makeDataResult(params, 
                                                    Collections.EMPTY_MAP, pc, m);

        if (logger.isDebugEnabled()) {
            logger.debug("activationKeysForKickstartProfile(Org, PageControl) - " +
                         "end - return value=" + returnDataResult);
        }
        return returnDataResult;
    }
    
    /**
     * Get the list of active (non-disabled) Activation Keys
     * @param orgIn Org
     * @param pc to filter 
     * @return DataResult list.
     */
    public DataResult getActiveActivationKeysInOrg(Org orgIn, PageControl pc) {
        if (logger.isDebugEnabled()) {
            logger.debug("activationKeysForKickstartProfile(Org orgIn=" + orgIn +
                    ", PageControl pc=" + pc + ") - start");
        }

        SelectMode m = ModeFactory.getMode("General_queries",
                                           "active_activation_keys_for_org");
        Map params = new HashMap();
        params.put("org_id", orgIn.getId());
        DataResult returnDataResult = makeDataResult(params, new HashMap(), pc, m);

        if (logger.isDebugEnabled()) {
            logger.debug("activationKeysForKickstartProfile(Org, PageControl) - " +
                         "end - return value=" + returnDataResult);
        }
        return returnDataResult;
    }    
    
    /**
     * Get the list of systems that are currently kickstarting
     * @param orgIn to lookup
     * @param pc to filter 
     * @return DataResult list of systems.
     */
    public DataResult getSystemsCurrentlyKickstarting(Org orgIn, PageControl pc) {
        if (logger.isDebugEnabled()) {
            logger.debug("getSystemsCurrentlyKickstarting(Org orgIn=" + orgIn +
                    ", PageControl pc=" + pc + ") - start");
        }

        SelectMode m = ModeFactory.getMode("General_queries", 
                                           "systems_currently_kickstarted_for_org");
        Map params = new HashMap();
        params.put("org_id", orgIn.getId());
        DataResult returnDataResult = makeDataResult(params, new HashMap(), pc, m);
        if (logger.isDebugEnabled()) {
            logger.debug("getSystemsCurrentlyKickstarting(Org, PageControl)" +
                         " - end - return value=" + returnDataResult);
        }
        return returnDataResult;
    }
    
    /**
     * Get the list of systems that are scheduled to be kickstarted
     * @param orgIn to lookup
     * @param pc to filter 
     * @return DataResult list of systems.
     */
    public DataResult getSystemsScheduledToBeKickstarted(Org orgIn, PageControl pc) {
        if (logger.isDebugEnabled()) {
            logger.debug("getSystemsScheduledToBeKickstarted(Org orgIn=" + orgIn +
                    ", PageControl pc=" + pc + ") - start");
        }

        SelectMode m = ModeFactory.getMode("General_queries", 
                                     "systems_scheduled_tobe_kickstarted_for_org");
        Map params = new HashMap();
        params.put("org_id", orgIn.getId());
        DataResult returnDataResult = makeDataResult(params, new HashMap(), pc, m);
        if (logger.isDebugEnabled()) {
            logger.debug("getSystemsScheduledToBeKickstarted(Org, PageControl)" +
                         " - end - return value=" + returnDataResult);
        }
        return returnDataResult;
    }
    
    /**
     * Get the list of possible kickstart profiles 
     * and the number of their base channels 
     * @param orgIn to lookup
     * @param pc to filter 
     * @return DataResult list of systems.
     */
    public DataResult getKickstartSummary(Org orgIn, PageControl pc) {
        if (logger.isDebugEnabled()) {
            logger.debug("getKickstartSummary(Org orgIn=" + orgIn +
                    ", PageControl pc=" + pc + ") - start");
        }

        SelectMode m = ModeFactory.getMode("General_queries", 
                                     "kickstart_summary_for_org");
        Map params = new HashMap();
        params.put("org_id", orgIn.getId());
        DataResult returnDataResult = makeDataResultNoPagination(params, 
                                                                 new HashMap(), m);
        if (logger.isDebugEnabled()) {
            logger.debug("getKickstartSummary(Org, PageControl)" +
                         " - end - return value=" + returnDataResult);
        }
        return returnDataResult;
    }

    /**
     * Get the valid timezones for a given ks profile
     * @param ksId kickstart profile
     * @return DataResult list of timezones.
     */
    public DataResult getValidTimezones(String ksId) {
        if (logger.isDebugEnabled()) {
            logger.debug("getValidTimezones(ksId=" + ksId +
                         ") - start");
        }

        SelectMode m = ModeFactory.getMode("General_queries", 
                                     "valid_timezones_for_kickstart_profile");
        Map params = new HashMap();
        params.put("ksid", ksId);
        DataResult returnDataResult = makeDataResultNoPagination(params, 
                                                                 new HashMap(), m);
        if (logger.isDebugEnabled()) {
            logger.debug("getValidTimezones(ksId)" +
                         " - end - return value=" + returnDataResult);
        }

        return returnDataResult;
    }
    
    /**
     * Returns a list of Cobbler only profiles. 
     * i.e profiles that are not part of spacewalk
     * but are part of cobbler. 
     * @param user the user object needed for cobbler conneciton
     * @return list of cobbler profile dtos.
     */
    public List <CobblerProfileDto> listCobblerProfiles(User user) {
        logger.debug("Adding cobblerProfiles to the list");
        Set<String> excludes = new HashSet<String>(
                    KickstartFactory.listKickstartDataCobblerIds());
        
        List <CobblerProfileDto> profiles = new LinkedList<CobblerProfileDto>();
        
        List<Profile> cProfiles = Profile.list(CobblerXMLRPCHelper.getConnection(user),
                                                                excludes);
        for (Profile profile : cProfiles) {
            Distro distro = profile.getDistro();
            Object orgId = distro.getKsMeta().get("org");
            if (orgId == null || user.getOrg().getId().toString().
                                        equals(String.valueOf(orgId))) {
                profiles.add(CobblerProfileDto.create(profile));    
            }
        }
        logger.debug("Returning cobbler profiles: " + profiles);
        return profiles;
    }
    
    /**
     * Sets the kickstart url for the passed in cobbler profiles.
     * @param dtos the kickstart dto
     * @param user the user object needed to connect to cobbler
     */
    public void setKickstartUrls(List <KickstartDto> dtos, User user) {
        CobblerConnection conn = CobblerXMLRPCHelper.getConnection(user);

        for (KickstartDto dto : dtos) {
            Profile p = Profile.lookupById(conn, dto.getCobblerId());
            if (p != null) {
                dto.setCobblerUrl(KickstartUrlHelper.getCobblerProfilePath(p.getName()));
            }
        }
    }

    /**
     * Returns a list of all the kickstart profiles
     *  available to the user
     *  Spacewalk Managed + Cobbler Only profiles
     * @param user the user object needed to get access to cobbler
     * @return a list of cobbler profiles or empty list.
     */
    public List <KickstartDto> listProfilesForSsm(User user) {
        List <KickstartDto> ret = new LinkedList<KickstartDto>();
        ret.addAll(kickstartsInOrg(user.getOrg(), null));
        pruneInvalid(user, ret);
        ret.addAll(listCobblerProfiles(user));
        setKickstartUrls(ret, user);
        return ret;
    }
    
    /**
     * Given a list of Kickstart DTOs
     * the code below removes all the profiles
     * that are associated to an invalid distro.
     * or not synced to spacewalk. Mainly used in schedule* pages
     * @param user the user to get org info.
     * @param profiles the kickstart dto list to be pruned
     */
    public void pruneInvalid(User user, List<KickstartDto> profiles) {
        Set<Long> ids = new HashSet<Long>();
        List<KickstartableTree> trees = KickstartManager.getInstance().
                        removeInvalid(KickstartFactory.
                                    lookupAccessibleTreesByOrg(user.getOrg()));
        for (KickstartableTree tree : trees) {
            ids.add(tree.getId());
        }
        for (Iterator<KickstartDto> itr = profiles.iterator(); itr.hasNext();) {
            KickstartDto dto = itr.next();
            if (StringUtils.isBlank(dto.getCobblerId()) || 
                            !ids.contains(dto.getKstreeId())) {
                itr.remove();
            }
        }
    }
}
