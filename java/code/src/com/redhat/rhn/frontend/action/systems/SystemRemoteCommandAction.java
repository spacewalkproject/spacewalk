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

package com.redhat.rhn.frontend.action.systems;

import java.text.MessageFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

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
import com.redhat.rhn.common.util.StringUtil.ScriptCheckResult;
import com.redhat.rhn.domain.action.Action;
import com.redhat.rhn.domain.action.ActionChain;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.ActionChainHelper;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.manager.action.ActionChainManager;
import com.redhat.rhn.manager.action.ActionManager;
import com.redhat.rhn.manager.system.SystemManager;

/**
 * Action for the single system remote command scheduling.
 *
 * @author Bo Maryniuk <bo@suse.de>
 */
public class SystemRemoteCommandAction extends RhnAction {
    /**
     * Class to retention form data.
     */
    public static final class FormData {
        public static final String UID = "uid";
        public static final String GID = "gid";
        public static final String SCRIPT = "script_body";
        public static final String LABEL = "lbl";
        public static final String TIMEOUT = "timeout";
        public static final Long DEFAULT_TIMEOUT = 600L;

        public static final String[] MANDATORY_FIELDS = {
            FormData.UID,
            FormData.GID,
            FormData.SCRIPT,
        };

        private String uid;
        private String gid;
        private String scriptBody;
        private String label;
        private Long timeout;

        /**
         * Default constructor.
         */
        public FormData() {
            this.uid = "root";
            this.gid = "root";
            this.timeout = FormData.DEFAULT_TIMEOUT;
            this.label = "";
            this.scriptBody = "#!/bin/sh\n# Add your shell script below\n";
        }

        /**
         * Get UID
         * @return the uid
         */
        public String getUid() {
            return uid;
        }

        /**
         * Set UID
         * @param userid the uid to set
         * @return Form data object.
         */
        public FormData setUid(String userid) {
            this.uid = userid;
            return this;
        }

        /**
         * Get GID
         * @return the gid
         */
        public String getGid() {
            return gid;
        }

        /**
         * Set GID
         * @param groupid the gid to set
         * @return Form data object.
         */
        public FormData setGid(String groupid) {
            this.gid = groupid;
            return this;
        }

        /**
         * Get script content.
         * @return the scriptBody
         */
        public String getScriptBody() {
            return scriptBody;
        }

        /**
         * Set script content.
         * @param script the content of the script to set
         * @return Form data object.
         */
        public FormData setScriptBody(String script) {
            this.scriptBody = script;
            return this;
        }

        /**
         * Get label
         * @return the label
         */
        public String getLabel() {
            return label;
        }

        /**
         * Set label
         * @param commandLabel the label to set
         * @return Form data object.
         */
        public FormData setLabel(String commandLabel) {
            this.label = commandLabel;
            return this;
        }

        /**
         * Get timeout
         * @return the timeout
         */
        public Long getTimeout() {
            return timeout;
        }

        /**
         * Set timeout
         * @param commandTimeout the timeout to set
         * @return Form data object.
         */
        public FormData setTimeout(Long commandTimeout) {
            this.timeout = commandTimeout;
            return this;
        }
    }


    /**
     * Validate form has required fields.
     *
     * @param form
     * @param errorMessages
     * @return
     */
    private boolean validate(DynaActionForm form,
                            ActionErrors errorMessages) {
        boolean formValid = true;
        for (String fid : SystemRemoteCommandAction.FormData.MANDATORY_FIELDS) {
            if (StringUtil.nullOrValue(form.getString(fid)) == null) {
                if (formValid) {
                    formValid = false;
                }
                errorMessages.add(ActionMessages.GLOBAL_MESSAGE,
                        new ActionMessage(String.format(
                                "ssm.operations.provisioning." +
                                "remotecommand.form.%s.missing", fid)));
            }
        }

        // Check if Script looks legit :-)
        if (StringUtil.nullOrValue(form.getString(FormData.SCRIPT)) != null) {
            ScriptCheckResult checkResult = StringUtil.scriptPrematureCheck(
                    form.getString(FormData.SCRIPT));
            if (checkResult != null) {
                formValid = false;
                errorMessages.add(ActionMessages.GLOBAL_MESSAGE,
                                  new ActionMessage(checkResult.getMessageKey()));
            }
        }

        return formValid;
    }


    /**
     * Schedule remote action script.
     *
     * @param form
     * @param user
     * @param server
     * @return Script action details.
     */
    private Set<Action> scheduleScript(DynaActionForm form,
                                User user,
                                Server server) {
        Date scheduleDate = getStrutsDelegate().readDatePicker(
                form, "date", DatePicker.YEAR_RANGE_POSITIVE);
        ActionChain actionChain = ActionChainHelper.readActionChain(form, user);
        List<Long> servers = new ArrayList<Long>();
        servers.add(server.getId());
        String label = StringUtil.nullIfEmpty(form.getString("lbl"));
        String msg = LocalizationService
                         .getInstance()
                         .getMessage("ssm.overview.provisioning.remotecommand.staticname");

        return ActionChainManager.scheduleScriptRuns(
                user,
                servers,
                (label != null ? label : MessageFormat.format(msg, server.getName())),
                ActionManager.createScript(form.getString(FormData.UID),
                        form.getString(FormData.GID),
                        form.get(FormData.TIMEOUT) == null ?
                                 FormData.DEFAULT_TIMEOUT :
                                 (Long) form.get(FormData.TIMEOUT),
                        form.getString(FormData.SCRIPT)), scheduleDate, actionChain);
    }


    /**
     * Get form into the bean.
     *
     * @param form
     * @return FormData object.
     */
    private FormData getFormData(DynaActionForm form) {
        FormData data = new FormData();
        data.setUid(form.getString(FormData.UID));
        data.setGid(form.getString(FormData.GID));
        data.setLabel(form.getString(FormData.LABEL));
        data.setScriptBody(form.getString(FormData.SCRIPT));
        data.setTimeout((Long) form.get(FormData.TIMEOUT));

        return data;
    }


    /**
    * {@inheritDoc}
    */
    public ActionForward execute(ActionMapping mapping,
                                 ActionForm actionForm,
                                 HttpServletRequest request,
                                 HttpServletResponse response)
            throws Exception {
        // Prepare
        DynaActionForm form = (DynaActionForm) actionForm;
        RequestContext context = new RequestContext(request);
        User user = context.getCurrentUser();
        Server server = SystemManager.lookupByIdAndUser(
                context.getRequiredParam(RequestContext.SID), user);
        ActionErrors errorMessages = new ActionErrors();
        ActionMessages infoMessages = new ActionMessages();

        // Default form values
        request.setAttribute("formData", new SystemRemoteCommandAction.FormData());

        // Process submit
        if (form.get(RhnAction.SUBMITTED) != null) {
            if (this.validate(form, errorMessages)) {
                try {
                    Action action = this.scheduleScript(form, user, server).iterator()
                        .next();
                    infoMessages.add(ActionMessages.GLOBAL_MESSAGE,
                                 new ActionMessage("ssm.overview.provisioning" +
                                                   ".remotecommand.succeed",
                                 server.getId().toString(),
                                 action.getId().toString(),
                                 LocalizationService
                                     .getInstance()
                                     .formatDate(action.getEarliestAction())));
                }
                catch (Exception ex) {
                    errorMessages.add(ActionMessages.GLOBAL_MESSAGE,
                                  new ActionMessage("ssm.operations.actionchaindetails." +
                                                    "scheduleerror.general.param",
                                                    ex.getLocalizedMessage()));
                }
            }
            else {
                request.setAttribute("formData", this.getFormData(form));
            }
        }

        // End the page
        request.setAttribute("date", this.getStrutsDelegate().prepopulateDatePicker(
                request, form, "date", DatePicker.YEAR_RANGE_POSITIVE));
        ActionChainHelper.prepopulateActionChains(request);
        request.setAttribute("system", server);

        this.getStrutsDelegate().saveMessages(request, errorMessages);
        this.getStrutsDelegate().saveMessages(request, infoMessages);

        form.getMap().clear();

        return getStrutsDelegate().forwardParam(
                mapping.findForward(RhnHelper.DEFAULT_FORWARD),
                RequestContext.SID, server.getId().toString()
                );
    }
}
