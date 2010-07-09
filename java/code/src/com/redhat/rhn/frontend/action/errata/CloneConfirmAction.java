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
package com.redhat.rhn.frontend.action.errata;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.errata.Errata;
import com.redhat.rhn.domain.errata.ErrataFactory;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.ErrataOverview;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.manager.errata.ErrataManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.util.Iterator;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * CloneConfirmAction
 * @version $Rev$
 */
public class CloneConfirmAction extends RhnAction {

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
                                 ActionForm formIn,
                                 HttpServletRequest request,
                                 HttpServletResponse response) {

        RequestContext rctx = new RequestContext(request);
        User user = rctx.getLoggedInUser();

        DataResult dr = ErrataManager.selectedForCloning(user, null);

        cloneDataResult(user, dr);

        RhnSet set = RhnSetDecl.ERRATA_CLONE.get(user);
        set.clear();
        RhnSetManager.store(set);

        return mapping.findForward("default");
    }

    /**
     * clones the dataresult
     * @param user user the errata is being cloned for
     * @param dr list of Errata to be cloned
     */
    protected void cloneDataResult(User user, DataResult dr) {
        Iterator i = dr.iterator();

        while (i.hasNext()) {
            ErrataOverview eo = (ErrataOverview) i.next();

            Errata e = ErrataFactory.lookupById(new Long(eo.getId().longValue()));
            ErrataManager.createClone(user, e);

        }
    }
}
