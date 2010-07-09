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

package com.redhat.rhn.frontend.action.kickstart;

import com.redhat.rhn.common.util.StringUtil;
import com.redhat.rhn.common.validator.ValidatorException;
import com.redhat.rhn.common.validator.ValidatorResult;
import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.kickstart.KickstartRawData;
import com.redhat.rhn.domain.kickstart.KickstartVirtualizationType;
import com.redhat.rhn.domain.kickstart.KickstartableTree;
import com.redhat.rhn.domain.kickstart.builder.KickstartBuilder;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.struts.RhnValidationHelper;
import com.redhat.rhn.frontend.struts.StrutsDelegate;
import com.redhat.rhn.manager.kickstart.KickstartFileDownloadCommand;
import com.redhat.rhn.manager.kickstart.KickstartWizardHelper;
import com.redhat.rhn.manager.kickstart.cobbler.CobblerProfileCommand;

import org.apache.log4j.Logger;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;
import org.apache.struts.upload.FormFile;
import org.cobbler.Distro;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


/**
 * @author paji
 * AdvancedModeDetailsAction
 * @version $Rev$
 */
public class AdvancedModeDetailsAction extends RhnAction {
    private static final String KSTREES_PARAM = "kstrees";
    private static final String NOTREES_PARAM = "notrees";
    private static final String KICKSTART_LABEL_PARAM = "kickstartLabel";
    private static final String KSTREE_ID_PARAM = "kstreeId";
    private static final String VIRTUALIZATION_TYPES_PARAM = "virtualizationTypes";
    private static final String VIRTUALIZATION_TYPE_LABEL_PARAM = "virtualizationTypeLabel";
    private static final String CONTENTS = "contents";
    private static final String FILE_UPLOAD = "fileUpload";
    private static final String ORG_DEFAULT = "org_default";
    private static final String ACTIVE = "active";

    private static final String CREATE_MODE = "create";

    private static Logger log = Logger.getLogger(AdvancedModeDetailsAction.class);
    private static final String UPLOAD_KEY = "manage.jsp.uploadbutton";
    private static final String UPLOAD_KEY_LABEL = "uploadKey";
    private static final String VALIDATION_XSD =
        "/com/redhat/rhn/frontend/action/kickstart/validation/kickstartFileForm.xsd";
    /**
     *
     * {@inheritDoc}
     */
    public ActionForward execute(ActionMapping mapping,
            ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response) throws Exception {
        RequestContext context = new RequestContext(request);


        request.setAttribute(UPLOAD_KEY_LABEL, UPLOAD_KEY);
        context.copyParamToAttributes(RequestContext.KICKSTART_ID);
        if (CREATE_MODE.equals(mapping.getParameter())) {
            context.getRequest().setAttribute(CREATE_MODE, Boolean.TRUE);
        }

        DynaActionForm form = (DynaActionForm) formIn;
        if (!context.isSubmitted()) {
            setup(context, form);
        }
        else if (!isCreateMode(request) && !getKsData(context).isValid()) {
            return submitInvalid(context, form, mapping);
        }
        else {
            return submit(context, form, mapping);
        }

        return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
    }
    private ActionForward submitInvalid(RequestContext context,
            DynaActionForm form, ActionMapping mapping) {
        try {
            KickstartData data = getKsData(context);
            User user  = context.getLoggedInUser();
            KickstartBuilder builder = new KickstartBuilder(user);
            KickstartWizardHelper cmd = new KickstartWizardHelper(user);
            KickstartableTree tree = cmd.getKickstartableTree(
                                        (Long)form.get(KSTREE_ID_PARAM));
            builder.update(data, data.getLabel(), tree,
                    data.getKickstartDefaults().getVirtualizationType().getLabel());
            return getStrutsDelegate().forwardParam(mapping.findForward("success"),
                                    RequestContext.KICKSTART_ID, data.getId().toString());
        }
        catch (ValidatorException ve) {
            RhnValidationHelper.setFailedValidation(context.getRequest());
            getStrutsDelegate().saveMessages(context.getRequest(), ve.getResult());
            setup(context, form);
            if (!isCreateMode(context.getRequest())) {
                KickstartRawData ks = getKsData(context);
                return getStrutsDelegate().forwardParam(mapping.
                                    findForward(RhnHelper.DEFAULT_FORWARD),
                        RequestContext.KICKSTART_ID,
                        ks.getId().toString());
            }
            return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
        }
    }

    private ActionForward submit(RequestContext context,
                        DynaActionForm form, ActionMapping mapping) {
        try {
            validateInput(form, context);
            User user  = context.getLoggedInUser();
            KickstartWizardHelper cmd = new KickstartWizardHelper(user);
            KickstartableTree tree = cmd.getKickstartableTree(
                                        (Long)form.get(KSTREE_ID_PARAM));

            String virtType = form.getString(VIRTUALIZATION_TYPE_LABEL_PARAM);
            String label = form.getString(KICKSTART_LABEL_PARAM);

            KickstartBuilder builder = new KickstartBuilder(user);
            KickstartRawData ks;
            String fileData = getData(context, form);
            if (isCreateMode(context.getRequest())) {
                ks = builder.createRawData(label, tree, fileData, virtType);
            }
            else {
                ks = getKsData(context);
                ks.setData(fileData);
                builder.update(ks, label, tree, virtType);
                ks.setActive(Boolean.TRUE.equals(form.get(ACTIVE)));
                ks.setOrgDefault(Boolean.TRUE.equals(form.get(ORG_DEFAULT)));
            }

            KickstartDetailsEditAction.processCobblerFormValues(ks, form,
                    context.getLoggedInUser());

            return getStrutsDelegate().forwardParam(mapping.findForward("success"),
                                                        RequestContext.KICKSTART_ID,
                                                        ks.getId().toString());
        }
        catch (ValidatorException ve) {
            RhnValidationHelper.setFailedValidation(context.getRequest());
            getStrutsDelegate().saveMessages(context.getRequest(), ve.getResult());
            setup(context, form);
            if (!isCreateMode(context.getRequest())) {
                KickstartRawData ks = getKsData(context);
                return getStrutsDelegate().forwardParam(mapping.
                                    findForward(RhnHelper.DEFAULT_FORWARD),
                        RequestContext.KICKSTART_ID,
                        ks.getId().toString());
            }
            return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
        }
    }

    private void setup(RequestContext context, DynaActionForm form) {
        User user  = context.getLoggedInUser();
        KickstartWizardHelper cmd = new KickstartWizardHelper(user);
        loadTrees(cmd, form, context);
        loadVirtualizationTypes(cmd, form, context);
        if (!isCreateMode(context.getRequest())) {
            KickstartRawData data = getKsData(context);
            if (!data.isValid()) {
                context.getRequest().setAttribute(KickstartDetailsEditAction.INVALID,
                                                                            Boolean.TRUE);
                return;
            }
            form.set(KICKSTART_LABEL_PARAM, data.getLabel());
            form.set(CONTENTS, data.getData());
            KickstartFileDownloadCommand dcmd = new KickstartFileDownloadCommand(
                    data.getId(),
                    user,
                    context.getRequest());
            context.getRequest().setAttribute(KickstartFileDownloadAction.KSURL,
                    dcmd.getOrgDefaultUrl());

            KickstartDetailsEditAction.setupCobblerFormValues(context, form, data);

            form.set(ORG_DEFAULT, data.isOrgDefault());
            form.set(ACTIVE, data.isActive());
            KickstartDetailsEditAction.checkKickstartFile(context, getStrutsDelegate());
         }
    }


    private void loadVirtualizationTypes(KickstartWizardHelper cmd, DynaActionForm form,
            RequestContext context) {

        List types = cmd.getVirtualizationTypes();
        form.set(VIRTUALIZATION_TYPES_PARAM, types);

        if (isCreateMode(context.getRequest())) {
            form.set(VIRTUALIZATION_TYPE_LABEL_PARAM,
                    KickstartVirtualizationType.NONE);
        }
        else {
            KickstartRawData data = getKsData(context);
            form.set(VIRTUALIZATION_TYPE_LABEL_PARAM, data.getKickstartDefaults().
                                                getVirtualizationType().getLabel());
        }
    }

    private void loadTrees(KickstartWizardHelper cmd, DynaActionForm form,
                                                RequestContext context) {

        List <KickstartableTree> trees = cmd.getKickstartableTrees();
        if (trees == null || trees.size() == 0) {
            context.getRequest().setAttribute(NOTREES_PARAM, Boolean.TRUE);
              form.set(KSTREE_ID_PARAM, null);
        }
        else {
            form.set(KSTREES_PARAM, trees);

            if (isCreateMode(context.getRequest())) {
                form.set(KSTREE_ID_PARAM, null);
            }
            else {
                KickstartRawData data = getKsData(context);
                KickstartableTree tree = data.getTree();
                if (tree == null) {
                    form.set(KSTREE_ID_PARAM, null);
                }
                else {
                    form.set(KSTREE_ID_PARAM, tree.getId());
                }
            }
        }
    }

    private boolean isCreateMode(HttpServletRequest request) {
        return Boolean.TRUE.equals(request.getAttribute(CREATE_MODE));
    }

    private void validateInput(DynaActionForm form,
                                    RequestContext context) {
        String label = form.getString(KICKSTART_LABEL_PARAM);
        KickstartBuilder builder = new KickstartBuilder(context.getLoggedInUser());
        if (isCreateMode(context.getRequest())) {
            builder.validateNewLabel(label);
        }
        else {
            KickstartRawData data = getKsData(context);
            if (!data.getLabel().equals(label)) {
                builder.validateNewLabel(label);
            }
        }
        ValidatorResult result = RhnValidationHelper.validate(this.getClass(),
                                            makeValidationMap(form), null,
                                            VALIDATION_XSD);
         if (!result.isEmpty()) {
             throw new ValidatorException(result);
         }


         KickstartableTree tree =  KickstartFactory.lookupKickstartTreeByIdAndOrg(
                 (Long) form.get(KSTREE_ID_PARAM),
                 context.getLoggedInUser().getOrg());
         KickstartVirtualizationType vType =
             KickstartFactory.lookupKickstartVirtualizationTypeByLabel(
                 form.getString(VIRTUALIZATION_TYPE_LABEL_PARAM));

         Distro distro = CobblerProfileCommand.getCobblerDistroForVirtType(tree, vType,
                 context.getLoggedInUser());
         if (distro == null) {
             ValidatorException.raiseException("kickstart.cobbler.profile.invalidvirt");
         }
   }

    private String getData(RequestContext context, DynaActionForm form) {
        if (context.wasDispatched(UPLOAD_KEY)) {
            StrutsDelegate delegate = getStrutsDelegate();
            FormFile file = (FormFile) form.get(FILE_UPLOAD);
            return delegate.extractString(file);
        }
        return StringUtil.webToLinux(form.getString(CONTENTS));
    }

    private KickstartRawData getKsData(RequestContext context) {
        return (KickstartRawData) context.lookupAndBindKickstartData();
    }

    private Map makeValidationMap(DynaActionForm form) {
        Map map = new HashMap();
        map.put(KSTREE_ID_PARAM, form.get(KSTREE_ID_PARAM));
        map.put(KICKSTART_LABEL_PARAM, form.get(KICKSTART_LABEL_PARAM));
        return map;
    }

    private String getSuccessKey() {
        return "kickstart.details.success";
    }
}
