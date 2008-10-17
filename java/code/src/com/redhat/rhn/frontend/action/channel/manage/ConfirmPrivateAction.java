/**
 * Copyright (c) 2008 Red Hat, Inc.
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
package com.redhat.rhn.frontend.action.channel.manage;

import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.taglibs.list.Listable;

import java.util.List;

/**
 * ConfirmPrivateAction handles the channel set access to private, confirmation
 * page.
 * @version $Rev$
 */
public class ConfirmPrivateAction extends RhnAction implements Listable {

    /** ${@inheritDoc} */
    public String getDataSetName() {
        return "pageList";
    }

    /** ${@inheritDoc} */
    public String getListName() {
        return null;
    }

    /** ${@inheritDoc} */
    public String getParentUrl(RequestContext context) {
        return context.getRequest().getRequestURI();
    }

    /** ${@inheritDoc} */
    public List getResult(RequestContext context) {
        // TODO Auto-generated method stub
        return null;
    }

}
