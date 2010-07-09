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
package com.redhat.rhn.frontend.action.systems.monitoring;

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.domain.monitoring.MonitoringFactory;
import com.redhat.rhn.domain.monitoring.Probe;
import com.redhat.rhn.domain.monitoring.command.Command;
import com.redhat.rhn.domain.monitoring.command.CommandGroup;
import com.redhat.rhn.domain.monitoring.satcluster.SatClusterFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.monitoring.ModifyProbeCommand;
import com.redhat.rhn.manager.monitoring.MonitoringManager;

import org.apache.commons.collections.CollectionUtils;
import org.apache.commons.collections.Transformer;
import org.apache.commons.lang.StringUtils;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;
import org.apache.struts.util.LabelValueBean;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * BaseProbeCreateAction
 * @version $Rev: 75283 $
 */
public abstract class BaseProbeCreateAction extends BaseProbeAction {

    public static final String COMMAND_GROUP = "command_group";
    public static final String SELECTED_COMMAND_GROUP_SESSION =
                                   "selected_command_group_session";
    public static final String SELECTED_COMMAND_SESSION =
                                    "selected_command_session";
    private static final String COMMAND = "command";
    private static final String OLD_DESCR = "old_description";

    /**
     * {@inheritDoc}
     */
    public final ActionForward execute(ActionMapping mapping, ActionForm formIn,
            HttpServletRequest req, HttpServletResponse resp) {
        DynaActionForm form = (DynaActionForm) formIn;

        RequestContext ctx = new RequestContext(req);
        User user = ctx.getCurrentUser();

        // Process form
        CommandGroup group = lookupCommandGroup(form, req.getSession());
        List commands = listCommands(group);
        Command command = lookupCommand(form, group, commands, req.getSession());
        ModifyProbeCommand cmd = null;
        boolean submitted = isSubmitted(form);
        if (submitted) {
            cmd = makeModifyProbeCommand(ctx, form, command);
            if (editProbe(cmd, form, req)) {
                // ServerProbe created and saved
                createSuccessMessage(req, "probecreate.created",
                        cmd.getProbe().getDescription());
                HashMap params = new HashMap();
                addSuccessParams(ctx, params, cmd.getProbe());
                return getStrutsDelegate().forwardParams(mapping.findForward("success"),
                        params);
            }
        }

        // We only get here  if (a) this is the initial form request
        // or (b) the user submitted a form with validation errors
        form.set(COMMAND_GROUP, group.getGroupName());
        form.set(COMMAND, command.getName());
        setDefault(form, CHECK_INTERVAL_MIN, ModifyProbeCommand.CHECK_INTERVAL_DEFAULT);
        setDefault(form, NOTIFICATION_INTERVAL_MIN,
                ModifyProbeCommand.NOTIF_INTERVAL_DEFAULT);
        // Set up request attributes for display of the form
        if (submitted) {
            setParamValueList(req, cmd.getProbe(), cmd.getProbe().getCommand(), submitted);
        }
        else {
            setParamValueList(req, null, command, submitted);
        }
        // Set the description to the current command's description
        // if they haven't changed it
        String oldDescr = form.getString(OLD_DESCR);
        if (oldDescr == null || oldDescr.equals(form.get(DESCR))) {
            String defaultDesc = description(command, true);
            form.set(DESCR, defaultDesc);
            form.set(OLD_DESCR, defaultDesc);
        }
        else {
            form.set(OLD_DESCR, "[[user-modified]]");
        }

        addAttributes(ctx);
        setSatClusters(ctx);
        setIntervals(req);
        setContactGroups(req, user.getOrg());
        setCommandGroups(req);
        req.setAttribute("commands", toLabelValue(group, commands));
        req.setAttribute(COMMAND, command);

        return mapping.findForward("default");
    }

    /**
     * Add attributes to the request that are needed by the default JSP
     * @param ctx RequestContext
     */
    protected abstract void addAttributes(RequestContext ctx);

    /**
     * Add parameters that are needed by the <tt>created</tt> forward that
     * we send the user to once a probe has been created successfully
     * @param req the current request
     * @param params the map into which the parameters should be put
     */
    protected abstract void addSuccessParams(RequestContext req, Map params, Probe probe);

    /**
     * Create a command that will be used to modify the probe, in particular to
     * set command parameters etc.
     * @param ctx RequestContext
     * @param form the user's input
     * @param command the monitoring command that the new probe should run
     * @return a command that will be used to modify the probe
     */
    protected abstract ModifyProbeCommand makeModifyProbeCommand(
            RequestContext ctx, DynaActionForm form, Command command);

    private void setSatClusters(RequestContext ctx) {
        //We want all sat clusters regardless of org since they are a "Shared resource"
        ctx.getRequest().setAttribute("satClusters", SatClusterFactory.findSatClusters());

    }

    private Command lookupCommand(DynaActionForm form, CommandGroup group,
                                  List commands, HttpSession session) {
        assert (group != null);
        assert commands != null && commands.size() > 0;
        Command result = null;
        String name = form.getString(COMMAND);
        if (StringUtils.isBlank(name)) {
            name = (String) session.getAttribute(SELECTED_COMMAND_SESSION);
            if (StringUtils.isBlank(name)) {
                name = ModifyProbeCommand.COMMAND_DEFAULT;
            }
        }
        result = MonitoringManager.getInstance().lookupCommand(name);
        if (!group.contains(result)) {
            result = (Command) commands.get(0);
        }
        session.setAttribute(SELECTED_COMMAND_SESSION, result.getName());
        assert result != null;
        return result;
    }

    private static CommandGroup lookupCommandGroup(DynaActionForm form,
            HttpSession session) {
        CommandGroup result = null;
        String name = form.getString(COMMAND_GROUP);
        if (StringUtils.isBlank(name)) {
            name = (String) session.getAttribute(SELECTED_COMMAND_GROUP_SESSION);
            if (StringUtils.isBlank(name)) {
                name = ModifyProbeCommand.COMMAND_GROUP_DEFAULT;
            }
        }
        session.setAttribute(SELECTED_COMMAND_GROUP_SESSION, name);
        result = MonitoringManager.getInstance().lookupCommandGroup(name);
        assert result != null;
        return result;
    }

    private static void setCommandGroups(HttpServletRequest req) {
        List groups = MonitoringFactory.loadAllCommandGroups();
        ArrayList lv = new ArrayList();
        CollectionUtils.collect(groups, new CommandGroupToLVBean(), lv);
        Collections.sort(lv, LabelValueBean.CASE_INSENSITIVE_ORDER);
        req.setAttribute("commandGroups", lv);
    }

    private static List listCommands(CommandGroup group) {
        assert group != null;
        LinkedList commands = new LinkedList();
        Iterator i = MonitoringManager.
            getInstance().listCommands(group).iterator();
        while (i.hasNext()) {
            Command c = (Command) i.next();
            if (c.isEnabled()) {
                commands.add(c);
            }
        }
        Collections.sort(commands, new CommandComparator());
        return commands;
    }

    private static void setDefault(DynaActionForm form, String prop, Object value) {
        if (form.get(prop) == null) {
            form.set(prop, value);
        }
    }

    private static String description(Command command, boolean qualify) {
        LocalizationService ls = LocalizationService.getInstance();
        if (qualify) {
            return ls.getMessage(command.getCommandGroup().getDescription()) +
                   ls.getMessage("punctuation.colonwithspace") +
                   ls.getMessage(command.getDescription());
        }
        else {
            return ls.getMessage(command.getDescription());
        }
    }

    private ArrayList toLabelValue(CommandGroup group, List commands) {
        CommandToLVBean t = new CommandToLVBean(group.getGroupName());
        ArrayList result = new ArrayList();
        CollectionUtils.collect(commands, t, result);
        Collections.sort(result, LabelValueBean.CASE_INSENSITIVE_ORDER);
        return result;
    }

    private static final class CommandComparator implements Comparator {

        /**
         * {@inheritDoc}
         */
        public int compare(Object o1, Object o2) {
            Command c1 = (Command) o1;
            Command c2 = (Command) o2;
            return c1.getDescription().compareTo(c2.getDescription());
        }

    }

    private static final class CommandToLVBean implements Transformer {

        private boolean qualify;

        public CommandToLVBean(String group) {
            qualify = CommandGroup.ALL_GROUP_NAME.equals(group);
        }

        public Object transform(Object input) {
            Command c = (Command) input;
            String d = description(c, qualify);
            return new LabelValueBean(d, c.getName());
        }

    }

    private static final class CommandGroupToLVBean implements Transformer {

        public Object transform(Object input) {
            CommandGroup c = (CommandGroup) input;
            String d = LocalizationService.getInstance().getMessage(c.getDescription());
            return new LabelValueBean(d, c.getGroupName());
        }

    }
}
