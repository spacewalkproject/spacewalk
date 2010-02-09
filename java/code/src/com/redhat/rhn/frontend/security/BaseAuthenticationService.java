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
package com.redhat.rhn.frontend.security;

import org.apache.commons.collections.CollectionUtils;
import org.apache.commons.collections.Predicate;

import java.util.Set;

import javax.servlet.http.HttpServletRequest;

/**
 * BaseAuthenticationService
 * @version $Rev$
 */
public abstract class BaseAuthenticationService implements AuthenticationService {

    protected boolean requestURIRequiresAuthentication(final HttpServletRequest request) {
        return !CollectionUtils.exists(getUnprotectedURIs(), new Predicate() {
            public boolean evaluate(Object uri) {
                return request.getRequestURI().startsWith(uri.toString());
            }
        });
    }
    
    protected abstract Set getUnprotectedURIs();

}
