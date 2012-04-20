/**
 * Copyright (c) 2012 Red Hat, Inc.
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
package com.redhat.rhn.frontend.action.audit.ssm;

import java.util.List;

import javax.servlet.http.HttpServletRequest;

import org.apache.struts.action.DynaActionForm;

import com.redhat.rhn.common.util.DatePicker;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.taglibs.list.ListTagHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.ListHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.Listable;
import com.redhat.rhn.manager.audit.ScapManager;

/**
 * SSM OpenSCAP XCCDF scanning.
 * @version $Rev$
 */
public abstract class BaseSsmScheduleXccdfAction
        extends RhnAction implements Listable {

    protected static final String DATE = "date";
    protected static final String PATH = "path";
    protected static final String PARAMS = "params";
    protected static final String LOCALIZED_DATE = "localizedDate";
    protected static final String READONLY = "readonly";
    protected static final String TRUE = "true";
    protected static final String ERROR = "error";

    /**
     * {@inheritDoc}
     */
    public List getResult(RequestContext context) {
        return ScapManager.systemsInSsmAndScapCapability(context.getLoggedInUser());
    }

    protected void setupListHelper(HttpServletRequest request) {
        ListHelper helper = new ListHelper(this, request);
        helper.execute();
        request.setAttribute(ListTagHelper.PARENT_URL, request.getRequestURI());
    }

    protected void setupDatePicker(HttpServletRequest request, DynaActionForm form) {
        getStrutsDelegate().prepopulateDatePicker(request,
                form, DATE, DatePicker.YEAR_RANGE_POSITIVE);
    }
}
