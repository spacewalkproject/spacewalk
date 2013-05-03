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
package com.redhat.rhn.common.errors;

import com.redhat.rhn.common.messaging.MessageQueue;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.common.BadParameterException;
import com.redhat.rhn.frontend.events.TraceBackEvent;
import com.redhat.rhn.frontend.struts.RequestContext;

import org.apache.log4j.Logger;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ExceptionHandler;
import org.apache.struts.config.ExceptionConfig;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * BadParameterExceptionHandler
 * @version $Rev$
 */
public class BadParameterExceptionHandler extends ExceptionHandler {

    private BadParameterException exception;

    /**
     * {@inheritDoc}
     */
    @Override
    public ActionForward execute(Exception exIn, ExceptionConfig aeIn,
            ActionMapping mappingIn, ActionForm formInstanceIn,
            HttpServletRequest requestIn, HttpServletResponse responseIn)
        throws ServletException {
        exception = (BadParameterException) exIn;
        requestIn.setAttribute("error", exception);
        responseIn.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        return super.execute(exception, aeIn, mappingIn, formInstanceIn, requestIn,
                responseIn);
    }

    /**
     * {@inheritDoc}
     */
    protected void logException(Exception ex) {
        Logger log = Logger.getLogger(BadParameterExceptionHandler.class);
        log.error("Missing Parameter Error", ex);
    }

    protected void storeException(HttpServletRequest request, String property,
            ActionMessage msg, ActionForward forward, String scope) {
        TraceBackEvent evt = new TraceBackEvent();
        User usr = new RequestContext(request).getLoggedInUser();
        evt.setUser(usr);
        evt.setRequest(request);
        evt.setException(exception);
        MessageQueue.publish(evt);
    }
}
