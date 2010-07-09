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
package com.redhat.rhn.frontend.action.systems.provisioning;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.common.CommonFactory;
import com.redhat.rhn.domain.common.FileList;
import com.redhat.rhn.domain.rhnset.RhnSetElement;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.common.BaseSetOperateOnSelectedItemsAction;
import com.redhat.rhn.manager.kickstart.KickstartLister;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;

import org.apache.struts.action.ActionForm;

import java.util.Map;

import javax.servlet.http.HttpServletRequest;

/**
 *
 * PreservationListDeletionAction - for deleting FileList objects
 * @version $Rev$
 */
public class PreservationListDeleteAction extends
                                    BaseSetOperateOnSelectedItemsAction {

    /**
     * {@inheritDoc}
     */
    public Boolean operateOnElement(ActionForm form,
                                    HttpServletRequest request,
                                    RhnSetElement elementIn,
                                    User userIn) {
        FileList fl = CommonFactory.lookupFileList(elementIn.getElement(),
                                                   userIn.getOrg());
        if (fl != null) {
            CommonFactory.removeFileList(fl);
        }
        return Boolean.TRUE;
    }

    /**
     * {@inheritDoc}
     */
    protected void processMethodKeys(Map map) {
        map.put("preservation_list.jsp.deletelist", "operateOnSelectedSet");
    }

    /**
     * {@inheritDoc}
     */
    protected RhnSetDecl getSetDecl() {
        return RhnSetDecl.FILE_LISTS;
    }

    /**
     * {@inheritDoc}
     */
    protected DataResult getDataResult(User user,
                                       ActionForm formIn,
                                       HttpServletRequest request) {
        return KickstartLister.getInstance().preservationListsInOrg(
                                                        user.getOrg(), null);
    }

    protected void processParamMap(ActionForm formIn,
                                   HttpServletRequest request,
                                   Map params) {
        // no op
    }

}
