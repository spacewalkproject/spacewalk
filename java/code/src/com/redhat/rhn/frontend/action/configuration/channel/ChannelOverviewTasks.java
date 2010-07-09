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
package com.redhat.rhn.frontend.action.configuration.channel;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.domain.action.Action;
import com.redhat.rhn.domain.config.ConfigChannel;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.configuration.ConfigActionHelper;
import com.redhat.rhn.frontend.dto.ConfigFileDto;
import com.redhat.rhn.frontend.dto.ConfigSystemDto;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnSetHelper;
import com.redhat.rhn.manager.action.ActionManager;
import com.redhat.rhn.manager.configuration.ConfigurationManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;

import org.apache.commons.lang.StringEscapeUtils;
import org.apache.struts.action.ActionErrors;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;

import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * ChannelOverviewTasks
 * @version $Rev$
 */
public class ChannelOverviewTasks extends RhnAction {

    public static final String MODE_PARAM = "mode";
    public static final String ALL_FILES_TO_ALL_SYS = "all2all";
    public static final String ALL_FILES_TO_SEL_SYS = "all2sel";
    public static final String SEL_FILES_TO_ALL_SYS = "sel2all";
    public static final String SEL_FILES_TO_SEL_SYS = "sel2sel";
    public static final String COMPARE = "compare";
    public static final String DEFAULT = "default";

    /**
     * {@inheritDoc}
     */
    public ActionForward execute(ActionMapping map,
            ActionForm form,
            HttpServletRequest req,
            HttpServletResponse resp) throws Exception {

        Map params = makeParamMap(req);
        String mode = req.getParameter(MODE_PARAM);

        if (ALL_FILES_TO_ALL_SYS.equals(mode)) {
            // Select everything and send the user to the confirm page
            initializeSets(map, req, params, true, true);
            return getStrutsDelegate().forwardParams(
                    map.findForward(ALL_FILES_TO_ALL_SYS), params);
        }
        else if (ALL_FILES_TO_SEL_SYS.equals(mode)) {
            // Select files and send the user to the system-select page
            initializeSets(map, req, params, true, false);
            return getStrutsDelegate().forwardParams(
                    map.findForward(ALL_FILES_TO_SEL_SYS), params);
        }
        else if (SEL_FILES_TO_ALL_SYS.equals(mode)) {
            // Select systems and send the user to the file-select page
            initializeSets(map, req, params, false, true);
            return getStrutsDelegate().forwardParams(
                    map.findForward(SEL_FILES_TO_ALL_SYS), params);
        }
        else if (SEL_FILES_TO_SEL_SYS.equals(mode)) {
            // Send the user to the file-select page
            initializeSets(map, req, params, false, false);
            return getStrutsDelegate().forwardParams(
                    map.findForward(SEL_FILES_TO_SEL_SYS), params);
        }
        else if (COMPARE.equals(mode)) {
            // Send the user to the file-select page
            submitDiffAction(map, req, params);
            return getStrutsDelegate().forwardParams(
                    map.findForward(COMPARE), params);
        }
        else {
            createErrorMessage(req, "deploytask.error.badmode", null);
            return getStrutsDelegate().forwardParams(
                    map.findForward(DEFAULT), params);
        }
    }

    private void initializeSets(
            ActionMapping map,
            HttpServletRequest req,
            Map params,
            boolean chooseFiles,
            boolean chooseSystems) {
        RequestContext ctx = new RequestContext(req);
        User usr = ctx.getLoggedInUser();
        ConfigChannel cc = ConfigActionHelper.getChannel(req);
        ConfigurationManager mgr = ConfigurationManager.getInstance();

        RhnSetDecl sysSet = RhnSetDecl.CONFIG_CHANNEL_DEPLOY_SYSTEMS;
        if (!chooseSystems) {
            sysSet.clear(usr);
            RhnSetManager.store(sysSet.get(usr));
        }

        RhnSetDecl revSet = RhnSetDecl.CONFIG_CHANNEL_DEPLOY_REVISIONS;
        if (!chooseFiles) {
            revSet.clear(usr);
            RhnSetManager.store(revSet.get(usr));
        }

        if (chooseSystems) {
            DataResult systems = mgr.listChannelSystems(usr, cc, null);
            RhnSetHelper sysHelper = new RhnSetHelper(map, sysSet, req);
            sysHelper.setForward(ALL_FILES_TO_ALL_SYS);
            sysHelper.selectall(systems, params);
        }

        if (chooseFiles) {
            DataResult files = mgr.listCurrentFiles(usr, cc, null);
            RhnSetHelper fileHelper = new RhnSetHelper(map, revSet, req);
            fileHelper.setForward(ALL_FILES_TO_ALL_SYS);
            fileHelper.selectall(files, params);
        }
    }

    private void submitDiffAction(
            ActionMapping map,
            HttpServletRequest req,
            Map params) {

        ConfigurationManager mgr = ConfigurationManager.getInstance();
        ConfigChannel cc = ConfigActionHelper.getChannel(req);
        User usr = new RequestContext(req).getLoggedInUser();

        DataResult systems = mgr.listChannelSystems(usr, cc, null);
        DataResult revs = mgr.listCurrentFiles(usr, cc, null);

        if (systems.size() == 0 || revs.size() == 0) {
            createErrorMessage(req, "comparetask.error.emptysets", null);
            return;
        }

        Set sids = new HashSet();
        for (Iterator itr = systems.iterator(); itr.hasNext();) {
            ConfigSystemDto csd = (ConfigSystemDto)itr.next();
            sids.add(new Long(csd.getId().longValue()));
        }

        Set crids = new HashSet();
        for (Iterator itr = revs.iterator(); itr.hasNext();) {
            ConfigFileDto cfd = (ConfigFileDto)itr.next();
            crids.add(new Long(cfd.getLatestConfigRevisionId().longValue()));
        }

        //create the action and then create the message to send the user.
        Action action = ActionManager.createConfigDiffAction(usr, crids, sids);
        makeMessage(action, req);
    }

    protected Map makeParamMap(HttpServletRequest req) {
        Map m = new HashMap();
        ConfigChannel cc = ConfigActionHelper.getChannel(req);
        ConfigActionHelper.processParamMap(cc, m);
        return m;
    }


    // TODO: generalize and move this somewhere it can be used by other
    // action-producers!
    private void makeMessage(Action action, HttpServletRequest request) {
        if (action != null) {
            //get how many servers this action was created for.
            int successes = action.getServerActions().size();
            String number = LocalizationService.getInstance()
                    .formatNumber(new Integer(successes));

            //build the url for the action we have created.
            String url = "/rhn/schedule/ActionDetails.do?aid=" + action.getId();

            //create the success message
            ActionMessages msg = new ActionMessages();
            String key;
            if (successes == 1) {
                key = "configdiff.schedule.success.singular";
            }
            else {
                key = "configdiff.schedule.success";
            }

            Object[] args = new Object[2];
            args[0] = StringEscapeUtils.escapeHtml(url);
            args[1] = StringEscapeUtils.escapeHtml(number);

            //add in the success message
            msg.add(ActionMessages.GLOBAL_MESSAGE, new ActionMessage(key, args));
            getStrutsDelegate().saveMessages(request, msg);
        }
        else {
            //Something went wrong, tell user!
            ActionErrors errors = new ActionErrors();
            getStrutsDelegate().addError("configdiff.schedule.error", errors);
            getStrutsDelegate().saveMessages(request, errors);
        }
    }
}
