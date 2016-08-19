/**
 * Copyright (c) 2009--2016 Red Hat, Inc.
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

package com.redhat.rhn.frontend.action.renderers.io;

import com.redhat.rhn.frontend.servlets.LegacyServletOutputStream;

import java.io.ByteArrayOutputStream;
import java.io.IOException;

/**
 * Caches all content written to it to be retrieved
 * later
 * @version $Rev$
 */
public class CachingOutputStream extends LegacyServletOutputStream {

    private ByteArrayOutputStream buffer = new ByteArrayOutputStream();

    /**
     * {@inheritDoc}
     */
    public void write(int c) throws IOException {
        buffer.write(c);
    }

    /**
     * returns the cached content
     * @return returns the cached content
     */
    public String getCachedContent() {
        return buffer.toString();
    }
}
