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
package com.redhat.rhn.testing;

import com.mockobjects.servlet.MockPageContext;

import javax.servlet.ServletResponse;

/**
 * RhnMockPageContext
 * @version $Rev$
 */
public class RhnMockPageContext extends MockPageContext {
    
    private ServletResponse response;

    
    /**
     * @return Returns the response.
     */
    public ServletResponse getResponse() {
        return response;
    }

    
    /**
     * @param responseIn The response to set.
     */
    public void setResponse(ServletResponse responseIn) {
        this.response = responseIn;
    }
    
}
