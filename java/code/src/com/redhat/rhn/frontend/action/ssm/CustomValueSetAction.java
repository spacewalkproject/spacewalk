/**
 * Copyright (c) 2014 Red Hat, Inc.
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

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.validator.ValidatorResult;
import com.redhat.rhn.domain.org.CustomDataKey;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.struts.RhnValidationHelper;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.system.SystemManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;
import org.apache.struts.action.DynaActionForm;

import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


/**
 * ListSystemsAction
 * @version $Rev$
 */
public class CustomValueSetAction extends RhnAction {

    private final String CIKID_PARAM = "cikid";
    private final String LABEL_PARAM = "label";
    private final String DESC_PARAM = "description";
    private final String VAL_PARAM = "value";
    private final String REMOVE_BTN = "remove";
    private final String SET_BTN = "set";
    private static final String VALIDATION_XSD = "/com/redhat/rhn/frontend/action/" +
            "systems/sdc/validation/editCustomDataForm.xsd";

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
            ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response) {

        RequestContext context = new RequestContext(request);
        DynaActionForm form = (DynaActionForm)formIn;

        User user = context.getCurrentUser();
        Long cikid = context.getRequiredParam(CIKID_PARAM);

        CustomDataKey key = OrgFactory.lookupKeyById(cikid);

        form.set(LABEL_PARAM, key.getLabel());
        request.setAttribute(CIKID_PARAM, cikid);
        request.setAttribute(LABEL_PARAM, key.getLabel());
        request.setAttribute(DESC_PARAM, key.getDescription());

        if (context.isSubmitted()) {
            String setLabel = RhnSetDecl.SYSTEMS.getLabel();
            ActionMessages msgs = new ActionMessages();

            if (request.getParameter(REMOVE_BTN) != null) {
                int updated = SystemManager.bulkRemoveCustomValue(user, setLabel, cikid);
                msgs.add(ActionMessages.GLOBAL_MESSAGE, new ActionMessage(
                        "message.bulkremovecustomdata", key.getLabel(), LocalizationService
                                .getInstance().formatNumber(updated)));
                getStrutsDelegate().saveMessages(request, msgs);
                return mapping.findForward("updated");
            }
            else if (request.getParameter(SET_BTN) != null) {
                ValidatorResult result = RhnValidationHelper.validate(this.getClass(),
                        makeValidationMap(form), null, VALIDATION_XSD);
                if (!result.isEmpty()) {
                    request.setAttribute(VAL_PARAM, form.getString(VAL_PARAM));
                    getStrutsDelegate().saveMessages(request, result);
                    return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
                }

                String value = form.getString(VAL_PARAM);
                SystemManager.bulkSetCustomValue(user, setLabel, key.getLabel(), value);

                msgs.add(ActionMessages.GLOBAL_MESSAGE, new ActionMessage(
                        "message.bulksetcustomdata", key.getLabel()));
                getStrutsDelegate().saveMessages(request, msgs);
                return mapping.findForward("updated");
            }
        }

        return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
    }

    private Object makeValidationMap(DynaActionForm formIn) {
        Map<String, String> map = new HashMap<String, String>();
        map.put(VAL_PARAM, formIn.getString(VAL_PARAM));
        return map;
    }
}
