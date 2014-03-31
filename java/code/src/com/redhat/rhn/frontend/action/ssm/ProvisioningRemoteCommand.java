/**
 * Copyright (c) 2013 SUSE
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

package com.redhat.rhn.frontend.action.ssm;

import java.text.MessageFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Locale;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.lang.StringEscapeUtils;
import org.apache.struts.action.ActionErrors;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;
import org.apache.struts.action.DynaActionForm;

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.util.DatePicker;
import com.redhat.rhn.common.util.StringUtil;
import com.redhat.rhn.domain.action.ActionChain;
import com.redhat.rhn.domain.action.script.ScriptActionDetails;
import com.redhat.rhn.domain.server.Capability;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.SystemOverview;
import com.redhat.rhn.frontend.struts.ActionChainHelper;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.ListHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.Listable;
import com.redhat.rhn.manager.action.ActionChainManager;
import com.redhat.rhn.manager.action.ActionManager;
import com.redhat.rhn.manager.entitlement.EntitlementManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.system.SystemManager;

import java.util.Iterator;


/**
 * Remote command for the SSM provisioning.
 *
 * @author Bo Maryniuk
 */
public class ProvisioningRemoteCommand extends RhnAction implements Listable {
    private static final String[] FORM_FIELD_IDS = {
        "uid", "gid", "script_body",
    };

    /**
     * Form values bean to keep values if form failed.
     */
    public static class FormValues {
        private String script;
        private String uid;
        private String gid;
        private Long timeout;
        private String label;

        /**
         * Get script body.
         * @return string Contains script body.
         */
        public String getScript() {
            return script;
        }

        /**
         * Set script body.
         * @param formScript Body of the script
         * @return FormValues returns self.
         */
        public FormValues setScript(String formScript) {
            this.script = formScript;
            return this;
        }

        /**
         * Get group id (GID)
         * @return String Returns group ID.
         */
        public String getGid() {
            return gid;
        }

        /**
         * Set group ID (GID)
         * @param formGID GID
         * @return FormValues returns self.
         */
        public FormValues setGid(String formGID) {
            this.gid = formGID;
            return this;
        }

        /**
         * Returns command label.
         * @return String command label.
         */
        public String getLabel() {
            return label;
        }

        /**
         * Set command label.
         * @param formLabel optional label of the command
         * @return FormValues returns self.
         */
        public FormValues setLabel(String formLabel) {
            this.label = formLabel;
            return this;
        }

        /**
         * Get script timeout.
         * @return Long returns script timeout.
         */
        public Long getTimeout() {
            return timeout;
        }

        /**
         * Set script timeout.
         * @param formTimeout timeout in seconds
         * @return FormValues returns self.
         */
        public FormValues setTimeout(Long formTimeout) {
            this.timeout = formTimeout;
            return this;
        }

        /**
         * Get user ID (UID).
         * @return String get user ID.
         */
        public String getUid() {
            return uid;
        }

        /**
         * Set user ID (UID).
         * @param formUID User ID
         * @return FormValues returns self.
         */
        public FormValues setUid(String formUID) {
            this.uid = formUID;
            return this;
        }
    }


    /**
     * {@inheritDoc}
     */
    @Override
    public ActionForward execute(ActionMapping mapping,
                                 ActionForm actionForm,
                                 HttpServletRequest request,
                                 HttpServletResponse response)
        throws Exception {
        RequestContext context = new RequestContext(request);
        DynaActionForm form = (DynaActionForm) actionForm;
        ActionErrors errorMessages = new ActionErrors();
        ActionMessages infoMessages = new ActionMessages();
        FormValues formValues = new FormValues();

        if (form.get("submitted") != null) {
            User user = new RequestContext(request).getCurrentUser();
            Date scheduleDate = this.getStrutsDelegate()
                    .readDatePicker(form, "date", DatePicker.YEAR_RANGE_POSITIVE);
            ActionChain actionChain = ActionChainHelper.readActionChain(form, user);

            boolean formValid = true;
            for (String fid : ProvisioningRemoteCommand.FORM_FIELD_IDS) {
                if (form.getString(fid) == null || form.getString(fid).isEmpty()) {
                    if (formValid) {
                        formValid = false;
                    }

                    errorMessages.add(ActionMessages.GLOBAL_MESSAGE,
                            new ActionMessage(String.format(
                                "ssm.operations.provisioning.remotecommand.form.%s.missing",
                                fid)));
                }
            }

            // Check if script seems legit :)
            if (formValid) {
                StringUtil.ScriptCheckResult result = StringUtil.scriptPrematureCheck(
                        form.getString("script_body"));
                if (result != null) {
                    formValid = false;
                    errorMessages.add(ActionMessages.GLOBAL_MESSAGE,
                                      new ActionMessage(result.getMessageKey()));
                }
            }

            if (formValid) {
                ScriptActionDetails scriptActionDetails = ActionManager.createScript(
                        form.getString("uid"),
                        form.getString("gid"),
                        form.get("timeout") == null ? 300 : (Long) form.get("timeout"),
                        form.getString("script_body").trim());

                List<SystemOverview> systems = this.getResult(context);
                List<Server> servers = new ArrayList<Server>();
                List<Long> serverIds = new ArrayList<Long>();

                for (int i = 0; i < systems.size(); i++) {
                    servers.add(SystemManager.lookupByIdAndUser(
                            systems.get(i).getId(), user));
                    serverIds.add(systems.get(i).getId());
                }

                String label = StringUtil.nullIfEmpty(form.getString("lbl"));
                label = label != null ?
                        label.trim() :
                        this.generateLabel(servers,
                                           request.getLocale(),
                                           form.getString("script_body"));

                ActionChainManager.scheduleScriptRuns(user, serverIds, label,
                    scriptActionDetails, scheduleDate, actionChain);

                if (actionChain == null) {
                    infoMessages.add(ActionMessages.GLOBAL_MESSAGE, new ActionMessage(
                        "ssm.operations.provisioning.remotecommand.form.schedule.succeed",
                        label, LocalizationService.getInstance().formatDate(scheduleDate)));
                }
                else {
                    infoMessages.add(ActionMessages.GLOBAL_MESSAGE, new ActionMessage(
                        "ssm.operations.provisioning.remotecommand.form.queue.succeed",
                        label, actionChain.getLabel()));
                }
            }
            else {
                formValues.setUid(form.getString("uid"))
                          .setGid(form.getString("gid"))
                          .setTimeout((Long) form.get("timeout"))
                          .setLabel(form.getString("lbl"))
                          .setScript(form.getString("script_body"));
            }

            form.getMap().clear();
        }

        request.setAttribute("fv", formValues);
        request.setAttribute(
                "date", this.getStrutsDelegate().prepopulateDatePicker(
                                request, form, "date", DatePicker.YEAR_RANGE_POSITIVE));
        ActionChainHelper.prepopulateActionChains(request);

        ListHelper helper = new ListHelper(this, request);
        helper.setListName("systemList");
        helper.setDataSetName(RequestContext.PAGE_LIST);
        helper.execute();

        // Add messages to the screen
        this.getStrutsDelegate().saveMessages(request, errorMessages);
        this.getStrutsDelegate().saveMessages(request, infoMessages);

        return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
    }

    /**
     * Generate label for the task.
     *
     * @param servers
     * @param locale
     * @return
     */
    private String generateLabel(List<Server> servers, Locale locale, String script) {
        // Spacewalk developers are still sitting in front of 80x25 TTY terminals. :-(
        String body = LocalizationService.getInstance().getMessage(
                "ssm.operations.provisioning.remotecommand" +
                ".form.script_label.title.default.body");
        String sngl = LocalizationService.getInstance().getMessage(
                "ssm.operations.provisioning.remotecommand" +
                ".form.script_label.title.default.client_single");
        String plrl = LocalizationService.getInstance().getMessage(
                "ssm.operations.provisioning.remotecommand" +
                ".form.script_label.title.default.client_plural");

        String[] scriptShellTokens = script.trim().split("\n").clone()[0].split("/");
        String scriptType = scriptShellTokens[scriptShellTokens.length - 1];
        scriptType = scriptType.length() > 1 ?
                     (scriptType.substring(0, 1).toUpperCase() +
                      scriptType.substring(1).toLowerCase()) :
                      scriptType.toUpperCase();

        StringBuilder summary = new StringBuilder();
        for (int i = 0; i < servers.size(); i++) {
            if (i > 0) {
                summary.append(" ");
            }

            if (i < 4) {
                summary.append(servers.get(i).getName());
            }
            else {
                break;
            }
        }

        if (servers.size() > 3) {
            summary.append("...");
        }

        return MessageFormat.format(body,
                scriptType, servers.size(), servers.size() > 1 ? plrl : sngl,
                StringEscapeUtils.escapeXml(summary.toString()));
    }


    /**
     * {@inheritDoc}
     */
    public List<SystemOverview> getResult(RequestContext context) {
        List<SystemOverview> dataset = new ArrayList<SystemOverview>();
        List<SystemOverview> sysOvr = SystemManager.inSet(context.getCurrentUser(),
            RhnSetDecl.SYSTEMS.getLabel(), true);
        for (int i = 0; i < sysOvr.size(); i++) {
            Server server = SystemManager.lookupByIdAndUser(sysOvr.get(i).getId(),
                                                            context.getCurrentUser());
            if (server != null &&
                server.hasEntitlement(EntitlementManager.PROVISIONING) &&
                server.getCapabilities() != null) {
                    Iterator<Capability> citer = server.getCapabilities().iterator();
                    while (citer.hasNext()) {
                        if (citer.next().getName().equals("script.run")) {
                            dataset.add(sysOvr.get(i));
                            break;
                        }
                    }
            }
        }

        context.getRequest().setAttribute("affectedSystemsCount", dataset.size());
        return dataset;
    }
}
