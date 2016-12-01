/**
 * Copyright (c) 2009--2015 Red Hat, Inc.
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
package com.redhat.rhn.frontend.action.kickstart;

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.security.PermissionException;
import com.redhat.rhn.common.validator.ValidatorException;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.kickstart.KickstartVirtualizationType;
import com.redhat.rhn.domain.kickstart.KickstartableTree;
import com.redhat.rhn.domain.kickstart.builder.KickstartBuilder;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnValidationHelper;
import com.redhat.rhn.frontend.struts.wizard.RhnWizardAction;
import com.redhat.rhn.frontend.struts.wizard.WizardStep;
import com.redhat.rhn.manager.acl.AclManager;
import com.redhat.rhn.manager.kickstart.KickstartWizardHelper;

import org.apache.log4j.Logger;
import org.apache.struts.action.ActionErrors;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;
import org.apache.struts.action.DynaActionForm;

import java.lang.reflect.Method;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Manages the workflow for the Create New Kickstart Profile wizard
 *
 * @version $Rev $
 */
public class CreateProfileWizardAction extends RhnWizardAction {

    private static final String PREV_CHAN_ID = "previousChannelId";
    private static final String CURR_CHAN_ID = "currentChannelId";
    private static final String PREV_STEP_PARAM = "prevStep";
    private static final String NEXT_STEP_PARAM = "nextStep";
    private static final String KICKSTART_LABEL_PARAM = "kickstartLabel";
    private static final String KSTREE_ID_PARAM = "kstreeId";
    private static final String USE_NEWEST_KSTREE_PARAM = "useNewestTree";
    private static final String USE_NEWEST_RH_KSTREE_PARAM = "useNewestRHTree";
    private static final String CURRENT_CHANNEL_ID_PARAM = "currentChannelId";
    private static final String RED_HAT_TREES_AVAILABLE = "redHatTreesAvailable";
    private static final String KSTREE_UPDATE_TYPE = "kstreeUpdateType";

    private static final String DEFAULT_DOWNLOAD_PARAM = "defaultDownload";
    private static final String USER_DOWNLOAD_PARAM = "userDefinedDownload";
    private static final String ROOT_PASSWORD_PARAM = "rootPassword";
    private static final String ROOT_PASSWORD_CONFIRM_PARAM = "rootPasswordConfirm";
    private static final String DEFAULT_DOWNLOAD_LOCN = "defaultDownloadLocation";

    public static final String CHANNELS = "channels";
    public static final String KSTREES_PARAM = "kstrees";
    public static final String NOTREES_PARAM = "notrees";
    public static final String NOCHANNELS_PARAM = "nochannels";
    public static final String VIRTUALIZATION_TYPES_PARAM = "virtualizationTypes";
    public static final String VIRTUALIZATION_TYPE_LABEL_PARAM = "virtualizationTypeLabel";

    private static Logger log = Logger.getLogger(CreateProfileWizardAction.class);

    /**
     *
     * {@inheritDoc}
     */
    @Override
    public ActionForward execute(ActionMapping mapping,
            ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response) throws Exception {

        if (!AclManager.hasAcl("user_role(org_admin) or user_role(config_admin)",
                request, null)) {
            //Throw an exception with a nice error message so the user
            //knows what went wrong.
            LocalizationService ls = LocalizationService.getInstance();
            PermissionException pex = new PermissionException("Only Org Admins or " +
                    "Configuration Admins can modify kickstarts");
            pex.setLocalizedTitle(ls.getMessage("permission.jsp.summary.acl.header"));
            pex.setLocalizedSummary(ls.getMessage("permission.jsp.summary.acl.reason5"));
            throw pex;
        }

        return super.execute(mapping, formIn, request, response);
    }

    @Override
    protected void generateWizardSteps(Map steps) {
        List methods = findMethods("run");
        for (Iterator iter = methods.iterator(); iter.hasNext();) {
            Method m = (Method) iter.next();
            if (m.getName().startsWith("run")) {
                String stepName = m.getName().substring(3).toLowerCase();
                WizardStep wizStep = new WizardStep();
                wizStep.setWizardMethod(m);
                if (stepName.equals("first")) {
                    wizStep.setNext("second");
                    steps.put(RhnWizardAction.STEP_START, wizStep);
                }
                else if (stepName.equals("second")) {
                    wizStep.setPrevious("first");
                    wizStep.setNext("third");
                }
                else if (stepName.equals("third")) {
                    wizStep.setPrevious("second");
                    wizStep.setNext("complete");
                }
                else if (stepName.equals("complete")) {
                    wizStep.setPrevious("third");
                }
                steps.put(stepName, wizStep);
            }
            else {
                continue;
            }
        }
    }


    private ActionForward runFirst(ActionMapping mapping, DynaActionForm form,
            RequestContext ctx, HttpServletResponse response,
            WizardStep step) throws Exception {
        KickstartWizardHelper cmd = new KickstartWizardHelper(ctx.getCurrentUser());
        List channels = cmd.getAvailableChannels();
        if (channels == null || channels.size() == 0) {
            ctx.getRequest().setAttribute(NOCHANNELS_PARAM, "true");
        }
        form.set(CHANNELS, channels);
        setCurrentChannel(form);
        loadTrees(cmd, form, ctx.getRequest());
        loadVirtualizationTypes(cmd, form, ctx.getRequest());
        form.set(PREV_STEP_PARAM, "");
        form.set(NEXT_STEP_PARAM, "second");

        ActionForward retval = null;
        retval = mapping.findForward("first");
        return retval;
    }

    private ActionForward runSecond(ActionMapping mapping, DynaActionForm form,
            RequestContext ctx, HttpServletResponse response,
            WizardStep step) throws Exception {
        List<String> fields = new LinkedList<String>();
        KickstartTreeUpdateType updateType = null;
        fields.add(KICKSTART_LABEL_PARAM);
        if (form.get(USE_NEWEST_KSTREE_PARAM) != null) {
            updateType = KickstartTreeUpdateType.ALL;
        }
        else if (form.get(USE_NEWEST_RH_KSTREE_PARAM) != null) {
            updateType = KickstartTreeUpdateType.RED_HAT;
        }
        else {
            updateType = KickstartTreeUpdateType.NONE;
            fields.add(KSTREE_ID_PARAM);
        }

        if (!validateInput(form, fields, ctx)) {
            return this.dispatch(step.getPrevious(), mapping, form, ctx, response);
        }
        try {

            String kickstartLabel = form.getString(KICKSTART_LABEL_PARAM);
            KickstartBuilder builder = new KickstartBuilder(ctx.getCurrentUser());

            try {
                builder.validateNewLabel(kickstartLabel);
            }
            catch (ValidatorException ve) {
                getStrutsDelegate().saveMessages(ctx.getRequest(), ve.getResult());
                return this.dispatch(step.getPrevious(), mapping, form, ctx, response);
            }

            Long channelId = (Long) form.get(CURRENT_CHANNEL_ID_PARAM);
            KickstartWizardHelper cmd = new KickstartWizardHelper(ctx.getCurrentUser());
            ActionForward retval = null;
            KickstartableTree tree = null;

            if (updateType == KickstartTreeUpdateType.NONE) {
                tree = cmd.getKickstartableTree((Long) form
                        .get(KSTREE_ID_PARAM));
            }
            else {
                tree = KickstartFactory.getNewestTree(updateType, channelId,
                        ctx.getCurrentUser().getOrg());
                form.set(KSTREE_ID_PARAM, tree.getId());
            }

            form.set(KSTREE_UPDATE_TYPE, updateType.getType());
            form.set(PREV_STEP_PARAM, "first");
            form.set(NEXT_STEP_PARAM, "third");
            form.set(
                    DEFAULT_DOWNLOAD_LOCN,
                    getDefaultDisplayDownloadLocation(tree));

            ctx.getRequest().setAttribute("selectedTree", tree);

            builder.validateTreeVirt(
                    tree, form.getString(VIRTUALIZATION_TYPE_LABEL_PARAM));

            if (form.get(DEFAULT_DOWNLOAD_PARAM) == null) {
                form.set(DEFAULT_DOWNLOAD_PARAM, Boolean.TRUE);
            }
            retval = mapping.findForward("second");
            return retval;
        }
        catch (ValidatorException ve) {
            getStrutsDelegate().saveMessages(ctx.getRequest(), ve.getResult());
            return this.dispatch(step.getPrevious(), mapping, form, ctx, response);
        }

    }

    private ActionForward runThird(ActionMapping mapping, DynaActionForm form,
            RequestContext ctx, HttpServletResponse response,
            WizardStep step) throws Exception {
        List<String> fields = new LinkedList<String>();
        fields.add(DEFAULT_DOWNLOAD_PARAM);
        if (!validateInput(form, fields, ctx)) {
            return this.dispatch(step.getPrevious(), mapping, form, ctx, response);
        }
        Boolean usingDefaultLocation =
                (Boolean) form.get(DEFAULT_DOWNLOAD_PARAM);
        if (usingDefaultLocation != null && usingDefaultLocation.equals(Boolean.FALSE)) {
            fields.clear();
            fields = new LinkedList();
            fields.add(USER_DOWNLOAD_PARAM);
            if (!validateInput(form, fields, ctx)) {
                form.set(DEFAULT_DOWNLOAD_PARAM, Boolean.FALSE);
                return this.dispatch(step.getPrevious(), mapping, form, ctx, response);
            }
            String userDownload = form.getString(USER_DOWNLOAD_PARAM);
            userDownload = userDownload.toLowerCase();
            if (!userDownload.startsWith("http://") &&
                    !userDownload.startsWith("ftp://")) {
                ActionErrors errs = new ActionErrors();
                errs.add(ActionMessages.GLOBAL_MESSAGE,
                        new ActionMessage("invalidUserDefinedDownload"));
                saveMessages(ctx.getRequest(), errs);
                return this.dispatch(step.getPrevious(), mapping, form, ctx, response);
            }
        }
        form.set(PREV_STEP_PARAM, "second");
        form.set(NEXT_STEP_PARAM, "complete");
        return mapping.findForward("third");
    }

    private ActionForward runComplete(ActionMapping mapping, DynaActionForm form,
            RequestContext ctx, HttpServletResponse response,
            WizardStep step) throws Exception {
        log.debug("CreateProfileWizard.runComplete()");
        KickstartWizardHelper cmd = new KickstartWizardHelper(ctx.getCurrentUser());
        List<String> fields = new LinkedList<String>();
        fields.add(ROOT_PASSWORD_PARAM);
        fields.add(ROOT_PASSWORD_CONFIRM_PARAM);
        if (!validateInput(form, fields, ctx) ||
                !passwdsEqual(form.getString(ROOT_PASSWORD_PARAM),
                        form.getString(ROOT_PASSWORD_CONFIRM_PARAM), ctx)) {
            return this.dispatch(step.getPrevious(), mapping, form, ctx, response);
        }
        KickstartableTree tree = cmd.getKickstartableTree((Long) form
                .get(KSTREE_ID_PARAM));
        KickstartTreeUpdateType updateType = KickstartTreeUpdateType
                .find((String) form.get(KSTREE_UPDATE_TYPE));
        Boolean useDefault = (Boolean) form.get(DEFAULT_DOWNLOAD_PARAM);
        String downloadUrl = null;
        if (useDefault != null && Boolean.TRUE.equals(useDefault)) {
            downloadUrl = tree.getDefaultDownloadLocation();
        }
        else {
            downloadUrl = form.getString(USER_DOWNLOAD_PARAM);
        }
        log.debug("Using download location: " + downloadUrl);
        String ksLabel = form.getString(KICKSTART_LABEL_PARAM);
        String rootPass = form.getString(ROOT_PASSWORD_PARAM);
        String virtType = form.getString(VIRTUALIZATION_TYPE_LABEL_PARAM);
        KickstartBuilder builder = new KickstartBuilder(ctx.getCurrentUser());
        KickstartData ksdata = builder.create(ksLabel, tree, virtType,
                downloadUrl, rootPass, updateType);

        String url = ctx.getRequest().getContextPath() + "/kickstart/" +
                "KickstartDetailsEdit.do?ksid=" + ksdata.getId();
        response.sendRedirect(url);
        return null;
    }

    private void loadTrees(KickstartWizardHelper cmd, DynaActionForm form,
            HttpServletRequest request) {
        Long currentChanId = (Long) form.get(CURR_CHAN_ID);
        Long prevChanId = (Long) form.get(PREV_CHAN_ID);
        if (currentChanId != null && prevChanId != null) {
            List<KickstartableTree> trees = cmd.getTrees(currentChanId);
            for (KickstartableTree tree : trees) {
                if (tree.getOrg() == null) {
                    request.setAttribute(RED_HAT_TREES_AVAILABLE, "true");
                    break;
                }
            }
            if (trees == null || trees.size() == 0) {
                request.setAttribute(NOTREES_PARAM, "true");
            }
            else {
                form.set(KSTREES_PARAM, trees);
                if (!currentChanId.equals(prevChanId)) {
                    form.set(PREV_CHAN_ID, currentChanId);
                    KickstartableTree tree = trees.get(trees.size() - 1);
                    form.set(KSTREE_ID_PARAM, tree.getId());
                }
            }
        }
        else {
            request.setAttribute(NOTREES_PARAM, "true");
        }
    }

    private void loadVirtualizationTypes(KickstartWizardHelper cmd, DynaActionForm form,
            HttpServletRequest request) {
        List types = cmd.getVirtualizationTypes();
        form.set(VIRTUALIZATION_TYPES_PARAM, types);
        form.set(VIRTUALIZATION_TYPE_LABEL_PARAM,
                KickstartVirtualizationType.NONE);
    }

    private void setCurrentChannel(DynaActionForm form) {
        Long currentChanId = (Long) form.get(CURR_CHAN_ID);
        Long prevChanId = (Long) form.get(PREV_CHAN_ID);
        if (currentChanId == null && prevChanId != null) {
            form.set(CURR_CHAN_ID, prevChanId);
        }
        else if (currentChanId == null || prevChanId == null) {
            List channels = (List) form.get(CHANNELS);
            if (channels != null && channels.size() > 0) {
                Channel channel = (Channel) channels.get(0);
                form.set(CURR_CHAN_ID, channel.getId());
                form.set(PREV_CHAN_ID, channel.getId());
            }
        }
    }

    private boolean validateInput(DynaActionForm form, List fieldNames,
            RequestContext ctx) {
        ActionErrors errs =
                RhnValidationHelper.validateDynaActionForm(this, form, fieldNames);
        boolean retval = errs.size() == 0;

        if (!retval) {
            saveMessages(ctx.getRequest(), errs);
        }
        return retval;
    }

    private boolean passwdsEqual(String root, String confirm, RequestContext rctx) {
        if (!root.equals(confirm)) {
            ActionMessages msg = new ActionMessages();
            msg.add(ActionMessages.GLOBAL_MESSAGE,
                    new ActionMessage("root_confirm_passwds.mismatch"));
            getStrutsDelegate().saveMessages(rctx.getRequest(), msg);
            return false;
        }

        return true;
    }

    /**
     * Display the default download location including a hostname. This hostname will be
     * either the hostname of the proxy the user is
     * hitting, or the hostname of the satellite. (depending on availablity, in that
     * order)
     */
    private String getDefaultDisplayDownloadLocation(KickstartableTree tree) {

        if (tree != null) {
            return tree.getDefaultDownloadLocation();
        }
        return "";
    }

}
