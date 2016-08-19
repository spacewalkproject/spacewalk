/**
 * Copyright (c) 2016 Red Hat, Inc.
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

package com.redhat.rhn.frontend.servlets;

import javax.servlet.ServletOutputStream;
import javax.servlet.WriteListener;

/**
 * Wrapper class implementing new methods introduced in Servlet API 3.1 in Tomcat 8.
 * This is intended for async write support but we don't use it currently.
 * Since we need javax.servlet.WriteListener interface not present in Servlet API < 3.1,
 * we create dummy version this interface in our code.
 * So we are able to compile with older Servlet API too.
 *
 * @version $Rev $
 */
public abstract class LegacyServletOutputStream extends ServletOutputStream {

    /**
     * Check if async support is ready.
     * @return we do not support this, return false
     */
    public boolean isReady() {
        return false;
    }

    /**
     * Set listener for async support.
     * @param listener listener matching our dummy interface
     */
    public void setWriteListener(WriteListener listener) {
        // DO NOTHING
    }
}
