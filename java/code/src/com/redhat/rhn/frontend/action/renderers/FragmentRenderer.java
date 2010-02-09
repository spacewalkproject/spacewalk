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

package com.redhat.rhn.frontend.action.renderers;

import java.io.IOException;

import javax.servlet.ServletException;

/**
 * Interface for rendering fragments asynchronously
 * 
 * @version $Rev$
 */
public interface FragmentRenderer {
    
    String NEXT_TABLE_STYLE = "next-table-style";
    
    /**
     * Render content, please
     * @return generated content
     * @throws ServletException sometimes things just don't work out
     * @throws IOException      but we can still be friends, m'kay?
     */
    String renderAsync() throws ServletException, IOException;
}
