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

package com.redhat.rhn.frontend.taglibs.list.helper;

import com.redhat.rhn.frontend.struts.RequestContext;

import java.util.List;

/**
 * Interface used to tie an action into ListTag 3.0 (known for a while as "new List Tag").
 * This interface allows the List*Helper classes to interact with the action to retrieve
 * the data to show on the page.
 * <p/>
 * See the Spacewalk wiki for more information on how to work with ListTag 3.0.
 * @version $Rev$
 */
public interface Listable {

    /**
     * Returns the data to display on the web page.
     *
     * @param context the request context; will not be <code>null</code>
     * @return a List of {@link com.redhat.rhn.frontend.struts.Selectable} or
     *         {@link com.redhat.rhn.domain.Identifiable} objects.
     */
    List getResult(RequestContext context);
}
