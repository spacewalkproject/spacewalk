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

import com.redhat.rhn.common.hibernate.LookupException;
import com.redhat.rhn.domain.config.ConfigChannel;
import com.redhat.rhn.domain.config.ConfigRevision;
import com.redhat.rhn.domain.rhnset.RhnSetElement;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.common.BaseSetOperateOnSelectedItemsAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.configuration.ConfigurationManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;

import java.util.Map;

import javax.servlet.http.HttpServletRequest;

/**
 * BaseCopyFileSubmitAction
 * This is the submit action for all three 'copy config file' pages, because
 * the actual work for copying a config file is the same no matter what type of
 * channel you are copying from or to.
 * @version $Rev$
 */
public abstract class BaseCopyFileSubmitAction extends BaseSetOperateOnSelectedItemsAction {

    /**
     * {@inheritDoc}
     */
    protected void processMethodKeys(Map mapIn) {
        mapIn.put("copycentral.jsp.copy", "operateOnSelectedSet");
    }

    /**
     * {@inheritDoc}
     */
    protected void processParamMap(ActionForm formIn,
                                   HttpServletRequest requestIn,
                                   Map paramsIn) {
        RequestContext requestContext = new RequestContext(requestIn);

        Long cfid = requestContext.getRequiredParam("cfid");
        Long crid = requestContext.getParamAsLong("crid");
        paramsIn.put("cfid", cfid);
        if (crid != null) {
            paramsIn.put("crid", crid);
        }
    }

    /**
     * {@inheritDoc}
     */
    public Boolean operateOnElement(ActionForm formIn, HttpServletRequest requestIn,
            RhnSetElement elementIn, User user) {

        RequestContext requestContext = new RequestContext(requestIn);

        Long crid = requestContext.getRequiredParam("crid");

        //Lookup the pieces
        ConfigRevision revision;
        ConfigChannel channel;
        try {
            revision = ConfigurationManager.getInstance().lookupConfigRevision(user, crid);
            channel = getChannelFromElement(user, elementIn.getElement());
        }
        //make sure both are there
        catch (LookupException e) {
            return Boolean.FALSE;
        }

        //Now start copying
        try {
            ConfigurationManager.getInstance().copyConfigFile(revision, channel, user);
            return Boolean.TRUE;
        }
        catch (IllegalArgumentException e) {
            log.error("Error copying config revision " + revision.getId() + " to channel " +
                    channel.getId(), e);
        }

        return Boolean.FALSE;
    }

    protected void addToMessage(ActionMessages msg,
            String methodName,
            boolean success,
            long count) {
        if (count > 0) {
            String key = "";
            if (success) {
                if (count == 1) {
                    key = "copyfile.jsp.success";
                }
                else {
                    key += "copyfile.jsp.successes";
                }
            }
            else {
                if (count == 1) {
                    key += "copyfile.jsp.failure";
                }
                else {
                    key += "copyfile.jsp.failures";
                }
            }

            Object[] args = new Object[]{String.valueOf(count)};
            ActionMessage temp =  new ActionMessage(key, args);
            msg.add(ActionMessages.GLOBAL_MESSAGE, temp);
         }
    }

    protected abstract String getLabel();

    protected abstract ConfigChannel getChannelFromElement(User usr, Long anId);
}
