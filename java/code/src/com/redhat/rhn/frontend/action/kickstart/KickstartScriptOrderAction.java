/**
 * Copyright (c) 2009--2013 Red Hat, Inc.
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

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.lang.StringUtils;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;
import org.apache.struts.util.LabelValueBean;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.kickstart.KickstartScript;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.struts.RhnLookupDispatchAction;
import com.redhat.rhn.frontend.taglibs.list.ListTagHelper;
import com.redhat.rhn.manager.kickstart.KickstartLister;

/**
 * KickstartScriptCreateAction action for creating a new kickstart script
 * @version $Rev: 1 $
 */
public class KickstartScriptOrderAction extends RhnLookupDispatchAction {

    static final String PRE_SCRIPTS = "preScripts";
    static final String POST_SCRIPTS = "postScripts";
    static final String SELECTED_PRE = "selectedPre";
    static final String SELECTED_POST = "selectedPost";
    static final String RANKED_PRE = "rankedPreValues";
    static final String RANKED_POST = "rankedPostValues";

    /**
     *
     * {@inheritDoc}
     */
    public ActionForward handleNoScript(ActionMapping mapping, ActionForm formIn,
            HttpServletRequest request, HttpServletResponse response) {
        RequestContext rctx = new RequestContext(request);

        if (!rctx.isJavaScriptEnabled()) {
            getStrutsDelegate().saveMessage("common.config.rank.jsp.error.nojavascript",
                    request);
        }

        setup((DynaActionForm) formIn, rctx);

        return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
    }

    protected void setup(DynaActionForm formIn, RequestContext rctx) {
        Org org = rctx.getCurrentUser().getOrg();
        KickstartData ksdata = KickstartFactory.lookupKickstartDataByIdAndOrg(org,
                rctx.getRequiredParam(RequestContext.KICKSTART_ID));
        DataResult<KickstartScript> dataSet = getDataResult(ksdata.getId(), org);

        List<LabelValueBean> preScripts = new ArrayList<LabelValueBean>();
        List<LabelValueBean> postScripts = new ArrayList<LabelValueBean>();
        for (KickstartScript ks : dataSet) {
            if (ks.getScriptType().equals(KickstartScript.TYPE_PRE)) {
                preScripts.add(lv(ks.getScriptName(), ks.getPosition().toString()));
            }
            else {
                postScripts.add(lv(ks.getScriptName(), ks.getPosition().toString()));
            }
        }
        if (!preScripts.isEmpty()) {
            if (StringUtils.isEmpty((String) formIn.get(SELECTED_PRE))) {
                String selected = preScripts.get(0).getLabel();
                formIn.set(SELECTED_PRE, selected);
            }
        }
        if (!postScripts.isEmpty()) {
            if (StringUtils.isEmpty((String) formIn.get(SELECTED_POST))) {
                String selected = postScripts.get(0).getLabel();
                formIn.set(SELECTED_POST, selected);
            }
        }

        rctx.getRequest().setAttribute(ListTagHelper.PARENT_URL,
                rctx.getRequest().getRequestURI());
        formIn.set(PRE_SCRIPTS, preScripts);
        formIn.set(POST_SCRIPTS, postScripts);
        rctx.getRequest().setAttribute(RequestContext.KICKSTART, ksdata);
    }

    /**
     *
     * {@inheritDoc}
     */
    protected DataResult<KickstartScript> getDataResult(Long ksid, Org org) {
        return KickstartLister.getInstance().scriptsInKickstartWithFakeEntry(org, ksid);
    }

    /**
     * {@inheritDoc}
     */
    protected Map<String, String> getKeyMethodMap() {
        Map<String, String> keys = new HashMap<String, String>();
        keys.put("kickstartscript.order.update", "update");
        keys.put("ssm.config.rank.jsp.up", "handleNoScript");
        keys.put("ssm.config.rank.jsp.down", "handleNoScript");
        return keys;
    }

    /**
     * Updates the set and then applies changes to the server
     * @param mapping struts ActionMapping
     * @param formIn struts ActionForm
     * @param request HttpServletRequest
     * @param response HttpServletResponse
     * @return An action forward to the success page
     */
    public ActionForward update(ActionMapping mapping, ActionForm formIn,
            HttpServletRequest request, HttpServletResponse response) {
        RequestContext context = new RequestContext(request);
        Org org = context.getCurrentUser().getOrg();
        KickstartData ksdata = KickstartFactory.lookupKickstartDataByIdAndOrg(org,
                context.getRequiredParam(RequestContext.KICKSTART_ID));
        DynaActionForm form = (DynaActionForm) formIn;
        // if its not javascript enabled, can't do much report error
        if (!context.isJavaScriptEnabled()) {
            return handleNoScript(mapping, formIn, request, response);
        }

        Set<KickstartScript> scripts = ksdata.getScripts();

        List<String> orderedPrePriorities = getScriptPriority(form, RANKED_PRE);
        List<String> orderedPostPriorities = getScriptPriority(form, RANKED_POST);
        Map<Long, Long> oldToNew = new HashMap<Long, Long>();

        Long nextPosition = 1L;
        Long nextNegativePosition = -1L;
        boolean beforeRedHat = true;

        // map the old priorities to the new updated ones
        for (String pre : orderedPrePriorities) {
            Long oldPriority = Long.parseLong(pre);
            oldToNew.put(oldPriority, nextPosition);
            nextPosition += 1;
        }
        for (String post : orderedPostPriorities) {
            Long oldPriority = Long.parseLong(post);
            if (oldPriority == 0L) {
                beforeRedHat = false;
                continue;
            }
            if (beforeRedHat) {
                oldToNew.put(oldPriority, nextNegativePosition);
                nextNegativePosition -= 1;
            }
            else {
                oldToNew.put(oldPriority, nextPosition);
                nextPosition += 1;
            }
        }

        // in order to avoid a db constraint error about two scripts having the same
        // position, first we'll set them to something huge and then set them to the
        // correct new value.
        Map<Long, Long> fakeToOld = new HashMap<Long, Long>();
        Long next = 10000L;
        for (KickstartScript script : scripts) {
            fakeToOld.put(next, script.getPosition());
            script.setPosition(next);
            next += 1;
            HibernateFactory.getSession().save(script);
        }
        KickstartFactory.saveKickstartData(ksdata);

        // update scripts with the appropriate priorities
        for (KickstartScript script : scripts) {
            script.setPosition(oldToNew.get(fakeToOld.get(script.getPosition())));
            HibernateFactory.getSession().save(script);
        }
        KickstartFactory.saveKickstartData(ksdata);

        getStrutsDelegate().saveMessage("kickstart.script.order.success", request);
        return getStrutsDelegate().forwardParam(mapping.findForward("success"),
                RequestContext.KICKSTART_ID, ksdata.getId().toString());
    }

    /**
     * Returns the position ranking info retrieved after one
     * has clicked Update button.
     * @param form the submitted form.
     * @param preOrPost either
     * @return List containing the channel ids in the order of
     *                   their new  rankings.
     */
    protected List<String> getScriptPriority(DynaActionForm form, String preOrPost) {
        List<String> scripts = new ArrayList<String>();
        String rankedValues = (String) form.get(preOrPost);
        if (StringUtils.isNotBlank(rankedValues)) {
            String[] values = rankedValues.split(",");
            for (String value : values) {
                scripts.add(value);
            }
        }
        return scripts;
    }

    /**
     * {@inheritDoc}
     */
    protected ActionForward unspecified(ActionMapping mapping, ActionForm form,
            HttpServletRequest request, HttpServletResponse response) {
        RequestContext context = new RequestContext(request);
        setup((DynaActionForm) form, context);
        return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
    }

}
