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
package com.redhat.rhn.frontend.action.systems.sdc;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.util.DynamicComparator;
import com.redhat.rhn.domain.action.Action;
import com.redhat.rhn.domain.action.ActionFactory;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.domain.user.UserServerPreferenceId;
import com.redhat.rhn.frontend.dto.monitoring.ServerProbeComparator;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.manager.action.ActionManager;
import com.redhat.rhn.manager.entitlement.EntitlementManager;
import com.redhat.rhn.manager.monitoring.MonitoringManager;
import com.redhat.rhn.manager.rhnpackage.PackageManager;
import com.redhat.rhn.manager.system.SystemManager;
import com.redhat.rhn.manager.user.UserManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Date;
import java.util.Iterator;
import java.util.List;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * SystemOverviewAction
 * @version $Rev$
 */
public class SystemOverviewAction extends RhnAction {

    public static final String[] SERVER_PREFERENCES = {UserServerPreferenceId
                                                       .INCLUDE_IN_DAILY_SUMMARY,
                                                       UserServerPreferenceId
                                                       .RECEIVE_NOTIFICATIONS};

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping, ActionForm form,
            HttpServletRequest request, HttpServletResponse response) {
        RequestContext rctx = new RequestContext(request);
        Long sid = rctx.getRequiredParam("sid");
        User user = rctx.getLoggedInUser();
        Server s  = SystemManager.lookupByIdAndUser(sid, user);

        /* Here we htmlify the description stored in the database such that end line's
         * are represented correctly
         */
        String description = null;

        if (s.getDescription() != null) {
            description = new String(s.getDescription()).replaceAll("\\n", "<br/>");
        }

        // Secondary Channels
        List secondaryChannelList = secondaryChannelList(s.getChannels(),
                                                         s.getBaseChannel());
        Collections.sort(secondaryChannelList,
                new DynamicComparator("name", RequestContext.SORT_ASC));

        // Errata Counts
        int criticalErrataCount = SystemManager.countCriticalErrataForSystem(user, sid);
        int nonCriticalErrataCount =
            SystemManager.countNoncriticalErrataForSystem(user, sid);


        // Upgradable Packages
        int upgradablePackagesCount = PackageManager.countUpgradable(sid);

        boolean hasUpdates =
            criticalErrataCount + nonCriticalErrataCount + upgradablePackagesCount > 0;

        // Monitoring
        processRequestForMonitoring(user, s, request);

        if (!processLock(user, s, rctx)) {
            request.setAttribute("serverLock", s.getLock());
        }

        processPing(user, s, rctx);
        proccessSatApplet(user, s, rctx);

        SdcHelper.ssmCheck(request, sid, user);

        request.setAttribute("unentitled", new Boolean(s.getEntitlements().isEmpty()));
        request.setAttribute("systemInactive", new Boolean(s.isInactive()));
        request.setAttribute("criticalErrataCount", criticalErrataCount);
        request.setAttribute("nonCriticalErrataCount", nonCriticalErrataCount);
        request.setAttribute("upgradablePackagesCount", upgradablePackagesCount);
        request.setAttribute("hasUpdates", hasUpdates);
        request.setAttribute("secondaryChannels", secondaryChannelList);
        request.setAttribute("description", description);
        request.setAttribute("prefs", findUserServerPreferences(user, s));
        request.setAttribute("system", s);
        request.setAttribute("hasLocation",
                !(s.getLocation() == null || s.getLocation().isEmpty()));
        return mapping.findForward("default");
    }

    protected List secondaryChannelList(Set channels, Channel baseChannel) {
        List list = new ArrayList();

        Iterator i = channels.iterator();

        while (i.hasNext()) {
            Channel c = (Channel) i.next();

            if (!c.equals(baseChannel)) {
                list.add(c);
            }
        }

        return list;
    }

    protected List findUserServerPreferences(User user, Server s) {
        List serverPreferenceList = new ArrayList();

        if (user.getEmailNotify() == 0) {
            serverPreferenceList.add("sdc.details.overview.notifications.disabled");

            return serverPreferenceList;
        }

        for (int j = 0; j < SERVER_PREFERENCES.length; ++j) {
            if (UserManager.lookupUserServerPreferenceValue(user,
                                                            s,
                                                            SERVER_PREFERENCES[j])) {
                serverPreferenceList.add(SERVER_PREFERENCES[j]);
            }
        }

        return serverPreferenceList;
    }

    protected void processRequestForMonitoring(User user,
                                               Server s,
                                               HttpServletRequest request) {
        if (s.hasEntitlement(EntitlementManager.MONITORING)) {
            DataResult dr = MonitoringManager.getInstance()
                            .probesForSystemWithAlerts(user, s, null);

            if (!dr.isEmpty()) {
                request.setAttribute("probeListEmpty", Boolean.FALSE);
                dr = sortProbes(dr);
                request.setAttribute("probeList", dr);
            }
            else {
                request.setAttribute("probeListEmpty", Boolean.TRUE);
            }
        }
        else {
            request.setAttribute("probeListEmpty", Boolean.TRUE);
        }
    }

    protected DataResult sortProbes(DataResult dr) {
        Object[] probes = dr.toArray();
        if (probes != null && probes.length > 0) {
            Arrays.sort(probes, new ServerProbeComparator());
            return new DataResult(Arrays.asList(probes));
        }
        else {
            return dr;
        }
    }

    /**
     * @return true if the server was unlocked, false otherwise
     */
    protected boolean processLock(User user, Server s, RequestContext rctx) {
        Long lockValue = rctx.getParamAsLong("lock");
        LocalizationService ls = LocalizationService.getInstance();

        if (lockValue != null) {

            if (lockValue.longValue() == 1) {
                if (s.getLock() == null) {
                    SystemManager.lockServer(user,
                                             s,
                                             ls.getMessage
                                             ("sdc.details.overview.lock.reason"));

                    createSuccessMessage(rctx.getRequest(),
                                         "sdc.details.overview.locked.alert",
                                         s.getName());
                }
            }
            else if (lockValue.longValue() == 0) {
                if (s.getLock() != null) {

                    SystemManager.unlockServer(user, s);
                    createSuccessMessage(rctx.getRequest(),
                            "sdc.details.overview.unlocked.alert",
                            s.getName());

                    return true;
                }
            }
        }

        return false;
    }

    protected void processPing(User user, Server s, RequestContext rctx) {
        Long pingValue = rctx.getParamAsLong("ping");

        if (pingValue != null && pingValue.longValue() == 1) {
            s.getPushClient().setLastPingTime(new Date(System.currentTimeMillis()));
            s.getPushClient().setNextActionTime(null);
            SystemManager.storeServer(s);
            createSuccessMessage(rctx.getRequest(),
                    "sdc.details.overview.osa.status.pinged",
                    s.getName());
        }

    }

    protected void proccessSatApplet(User user, Server s, RequestContext rctx) {
        Long appValue = rctx.getParamAsLong("applet");

        if (appValue != null && appValue.longValue() == 1) {
            Action a = ActionManager.createBaseAction(user,
                                                      s,
                                                      ActionFactory
                                                      .TYPE_RHN_APPLET_USE_SATELLITE);
            ActionManager.storeAction(a);
            createSuccessMessage(rctx.getRequest(),
                                 "sdc.details.overview.applet.scheduled",
                                 "/network/systems/details/history/event.pxt?sid=" +
                                 s.getId() +
                                 "&hid=" +
                                 a.getId());
        }
    }
}
