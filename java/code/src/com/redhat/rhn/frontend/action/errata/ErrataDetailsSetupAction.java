/**
 * Copyright (c) 2009--2014 Red Hat, Inc.
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
package com.redhat.rhn.frontend.action.errata;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.util.StringUtil;
import com.redhat.rhn.domain.errata.Errata;
import com.redhat.rhn.domain.errata.ErrataFactory;
import com.redhat.rhn.domain.errata.ErrataFile;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.manager.errata.ErrataManager;

import org.apache.commons.collections.CollectionUtils;
import org.apache.commons.collections.IteratorUtils;
import org.apache.commons.collections.Transformer;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * DetailsSetupAction
 * @version $Rev$
 */
public class ErrataDetailsSetupAction extends RhnAction {
    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
                                 ActionForm formIn,
                                 HttpServletRequest request,
                                 HttpServletResponse response) {

        RequestContext requestContext = new RequestContext(request);

        Long eid = requestContext.getRequiredParam("eid");

        User user = requestContext.getCurrentUser();
        Errata errata = ErrataManager.lookupErrata(eid, user);
        String ovalFile = findOvalFile(errata.getId());
        DataResult channels = ErrataManager.affectedChannels(user, eid);
        DataResult fixed = ErrataManager.bugsFixed(eid);
        DataResult cve = ErrataManager.errataCVEs(eid);
        DataResult keywords = ErrataManager.keywords(eid);

        //create the display for keywords
        //example: "/var/tmp, current, directory, expect"
        String keywordsDisplay = null;
        if (keywords != null) {
            keywordsDisplay = StringUtil.join(
                LocalizationService.getInstance().getMessage("list delimiter"),
                IteratorUtils.getIterator(CollectionUtils.collect(keywords,
                        new Transformer() {
                            public Object transform(Object o) {
                                return o.toString();
                            }
                        })));
        }

        request.setAttribute("errata", errata);
        request.setAttribute("issued", LocalizationService.getInstance()
                                           .formatShortDate(errata.getIssueDate()));
        request.setAttribute("updated", LocalizationService.getInstance()
                                           .formatShortDate(errata.getUpdateDate()));
        request.setAttribute("topic", StringUtil.htmlifyText(errata.getTopic()));
        request.setAttribute("description", StringUtil.htmlifyText(
                                            errata.getDescription()));
        request.setAttribute("solution", StringUtil.htmlifyText(errata.getSolution()));
        request.setAttribute("notes", StringUtil.htmlifyText(errata.getNotes()));
        request.setAttribute("references", StringUtil.htmlifyText(errata.getRefersTo()));
        request.setAttribute("channels", channels);
        request.setAttribute("fixed", fixed);
        request.setAttribute("cve", cve);
        request.setAttribute("keywords", keywordsDisplay);
        request.setAttribute("ovalFile", ovalFile);
        request.setAttribute("errataFrom", errata.getErrataFrom());

        return getStrutsDelegate().forwardParams(
                mapping.findForward(RhnHelper.DEFAULT_FORWARD),
                request.getParameterMap());
    }

    private String findOvalFile(Long errataId) {
        String retval = null;
        List files =
            ErrataFactory.lookupErrataFilesByErrataAndFileType(errataId, "oval");
        if (files == null || files.size() == 0) {
            return null;
        }
        ErrataFile ef = (ErrataFile) files.get(0);
        StringBuilder buf = new StringBuilder();
        buf.append("<a href=\"/rhn/oval?errata=").append(errataId).append("\">");
        String name = ef.getErrata().getAdvisoryName().toLowerCase();
        name = name.replaceAll(":", "");
        buf.append("com.redhat.").append(name).append(".xml");
        buf.append("</a>");
        retval = buf.toString();
        return retval;
    }
}
