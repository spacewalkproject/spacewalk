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

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.config.ConfigChannel;
import com.redhat.rhn.domain.config.ConfigChannelType;
import com.redhat.rhn.domain.config.ConfigFile;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.configuration.ConfigActionHelper;
import com.redhat.rhn.manager.configuration.ConfigurationManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;

import org.apache.struts.action.ActionForm;

import javax.servlet.http.HttpServletRequest;

/**
 * CopyFileCentralSubmitAction
 * @version $Rev$
 */
public class CopyFileCentralSubmitAction extends BaseCopyFileSubmitAction {

    /**
     * {@inheritDoc}
     */
    protected DataResult getDataResult(User userIn,
                                       ActionForm formIn,
                                       HttpServletRequest requestIn) {
        ConfigFile file = ConfigActionHelper.getFile(requestIn);
        ConfigurationManager cm = ConfigurationManager.getInstance();
        return cm.listChannelsForFileCopy(userIn, file, getLabel(), null);
    }

    /**
     * {@inheritDoc}
     */
    protected RhnSetDecl getSetDecl() {
        return RhnSetDecl.CONFIG_CHANNELS;
    }

    protected String getLabel() {
        return ConfigChannelType.global().getLabel();
    }

    protected ConfigChannel getChannelFromElement(User usr, Long anId) {
        return ConfigurationManager.getInstance()
            .lookupConfigChannel(usr, anId);
    }
}
