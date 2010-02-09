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

import com.redhat.rhn.frontend.xmlrpc.NoSuchPackageException;

import org.apache.log4j.Logger;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ExceptionHandler;

import javax.servlet.http.HttpServletRequest;

/**
 * UnknownPackageExceptionHandler
 * @version $Rev$
 */
public class NoSuchPackageExceptionHandler extends ExceptionHandler {
    private NoSuchPackageException exception;

    @Override
    protected void storeException(HttpServletRequest request, String property,
                     ActionMessage error, ActionForward forward, String scope) {
        request.setAttribute("error", exception);
    }

    @Override
    protected void logException(Exception ex) {
        Logger log = Logger.getLogger(NoSuchPackageExceptionHandler.class);
        log.error("Missing Parameter Error", ex);
        exception = (NoSuchPackageException) ex;
    }
}
