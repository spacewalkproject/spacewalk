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
package com.redhat.rhn.frontend.action.configuration.files;

import com.redhat.rhn.frontend.action.configuration.ConfigActionHelper;
import com.redhat.rhn.frontend.listview.PageControl;
import com.redhat.rhn.frontend.struts.BaseSetListAction;
import com.redhat.rhn.frontend.struts.RequestContext;

/**
 * CopyFilesCentralAction
 * @version $Rev$
 */
public abstract class BaseCopyConfigFileAction extends BaseSetListAction {

    public static final String CENTRAL_TYPE = "central";
    public static final String LOCAL_TYPE = "local";
    public static final String SANDBOX_TYPE = "sandbox";

    public static final String CHANNEL_FILTER = "nameDisplay";
    public static final String SYSTEM_FILTER = "name";

    public static final String TYPE_ATTR = "type";

    protected void processPageControl(PageControl pc) {
        pc.setFilterColumn(getFilterAttr());
        pc.setFilter(true);
    }

    protected void processRequestAttributes(RequestContext rctxIn) {
        ConfigActionHelper.processRequestAttributes(rctxIn);
        rctxIn.getRequest().setAttribute(TYPE_ATTR, getType());
        super.processRequestAttributes(rctxIn);
        if (!rctxIn.isSubmitted()) {
            getSetDecl().clear(rctxIn.getLoggedInUser());
        }
    }

    /**
     * @return the config-channel-type that the subclass knows how to handle
     */
    protected abstract String getType();

    /**
     * @return The DB label for the desired config channel type.
     */
    protected abstract String getLabel();

    /**
     * @return The attr of ConfigSystemDto top be used for filtering
     */
    protected abstract String getFilterAttr();
}
