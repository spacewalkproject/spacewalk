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
package com.redhat.rhn.frontend.action.configuration.ssm;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.util.DatePicker;
import com.redhat.rhn.domain.action.ActionFactory;
import com.redhat.rhn.domain.action.ActionType;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.ConfigSystemDto;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnListDispatchAction;
import com.redhat.rhn.manager.action.ActionManager;
import com.redhat.rhn.manager.configuration.ConfigurationManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;
import org.apache.struts.action.DynaActionForm;

import java.util.Collection;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * DiffConfirmSubmitAction
 * @version $Rev$
 */
public class ConfigConfirmSubmitAction extends RhnListDispatchAction {

    /**
     * {@inheritDoc}
     */
    protected void processMethodKeys(Map map) {
        map.put("diffconfirm.jsp.confirm", "diff");
        map.put("deployconfirm.jsp.confirm", "deploy");
    }

    /**
     * {@inheritDoc}
     */
    protected void processParamMap(ActionForm form,
            HttpServletRequest requestIn, Map params) {
        //no-op for diff
        if (form != null) {
            getStrutsDelegate().rememberDatePicker(params, (DynaActionForm)form,
                    "date", DatePicker.YEAR_RANGE_POSITIVE);
        }
    }

    /**
     * Schedules diff config actions
     * @param mapping struts ActionMapping
     * @param form struts ActionForm
     * @param request HttpServletRequest
     * @param response HttpServletResponse
     * @return forward to the starting Diff page.
     */
    public ActionForward diff(ActionMapping mapping, ActionForm form,
            HttpServletRequest request, HttpServletResponse response) {
        return confirm(mapping, request, form, "schedulediff",
                ActionFactory.TYPE_CONFIGFILES_DIFF);
    }

    /**
     * Schedules deploy config actions
     * @param mapping struts ActionMapping
     * @param form struts ActionForm
     * @param request HttpServletRequest
     * @param response HttpServletResponse
     * @return forward to the starting Deploy page.
     */
    public ActionForward deploy(ActionMapping mapping, ActionForm form,
            HttpServletRequest request, HttpServletResponse response) {
        return confirm(mapping, request, form, "scheduledeploy",
                ActionFactory.TYPE_CONFIGFILES_DEPLOY);
    }

    /**
     * Schedules a config action for the systems in the system set for the
     * config file names in the config file name set.
     * @param mapping struts ActionMapping
     * @param request HttpServletRequest
     * @param form struts ActionForm
     * @param msgPrefix A prefix for success and failure message keys.
     * @param type The exact type of config action to schedule.
     * @return forward to the next page.
     */
    public ActionForward confirm(ActionMapping mapping, HttpServletRequest request,
            ActionForm form, String msgPrefix, ActionType type) {

        RequestContext requestContext = new RequestContext(request);

        //schedule diff actions
        User user = requestContext.getLoggedInUser();
        ConfigurationManager cm = ConfigurationManager.getInstance();

        DataResult<ConfigSystemDto> systems = cm.listSystemsForConfigAction(user, null,
                type.getLabel());
        RhnSet fileNames = RhnSetDecl.CONFIG_FILE_NAMES.get(user);
        int successes = systems.size();

        Date earliest = getEarliestAction(form);


        Map<Long, Collection<Long>> serverConfigMap =
            new HashMap<Long, Collection<Long>>();
        for (ConfigSystemDto system : systems) {
            Long sid = system.getId();
            Set<Long> revisions = new HashSet<Long>();
            for (Long cfnid : fileNames.getElementValues()) {
                Long crid = cm.getDeployableRevisionForFileName(cfnid, sid);
                //add to the set if this system has a deployable revision of this
                //file name
                if (crid != null) {
                    revisions.add(crid);
                }
            }
            serverConfigMap.put(sid, revisions);
        }
        ActionManager.createConfigActionForServers(user, serverConfigMap, type, earliest);

        //create the message
        if (successes > 0) {
            RhnSetManager.remove(fileNames);
            createSuccessMessage(successes, request, msgPrefix);
        }
        else {
            createFailureMessage(request, msgPrefix);
        }

        //go back to the beginning
        return mapping.findForward("success");
    }

    private void createSuccessMessage(int successes, HttpServletRequest request,
            String prefix) {
        ActionMessages msg = new ActionMessages();
        if (successes == 1) {
            msg.add(ActionMessages.GLOBAL_MESSAGE,
                    new ActionMessage(prefix + ".ssm.success"));
        }
        else {
            msg.add(ActionMessages.GLOBAL_MESSAGE,
                new ActionMessage(prefix + ".ssm.successes", new Integer(successes)));
        }
        getStrutsDelegate().saveMessages(request, msg);
    }

    private void createFailureMessage(HttpServletRequest request, String prefix) {
        ActionMessages msg = new ActionMessages();
        msg.add(ActionMessages.GLOBAL_MESSAGE,
                new ActionMessage(prefix + ".ssm.failure"));
        getStrutsDelegate().saveMessages(request, msg);
    }

    private Date getEarliestAction(ActionForm formIn) {
        if (formIn == null) {
            return new Date();
        }
        DynaActionForm form = (DynaActionForm) formIn;
        return getStrutsDelegate().readDatePicker(form, "date",
                DatePicker.YEAR_RANGE_POSITIVE);
    }
}
