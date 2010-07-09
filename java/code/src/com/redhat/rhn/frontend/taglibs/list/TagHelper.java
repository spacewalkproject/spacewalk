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
package com.redhat.rhn.frontend.taglibs.list;

import com.redhat.rhn.common.db.datasource.Elaborator;

import java.util.zip.CRC32;

import javax.servlet.ServletRequest;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

/**
 * general tag helper for common functionality shared between tags
 * TagHelper
 * @version $Rev$
 */
public class TagHelper {

    public static final String ELAB_TAG = "_elaborator_lab";

    private TagHelper() {
    }


    /**
     * Stores the declaration information of an rhnSet
     * so as to be used by the list tag while
     * rendering a set.
     * @param listName name of list
     * @param elab the elaboratable object to bind to bind
     * @param request current HttpServletRequest
     */
    public static void bindElaboratorTo(String listName, Elaborator elab,
                                ServletRequest request) {
        String uniqueName = TagHelper.generateUniqueName(listName);
        String selectedName = "list_" + uniqueName + ELAB_TAG;
        HttpSession session = ((HttpServletRequest)request).getSession(true);
        session.setAttribute(selectedName, elab);
    }


    /**
     * Returns an Elaborator associated to this list
     * if it was previously bound.
     * @param listName the name of the list to who holds the set.
     *                  Note: this must be a Unique Name ..
     *                  See bindElaboratorTo method for more info.
     * @param request the servlet request object
     * @return returns the elaborator associated to the list.
     */
    public static Elaborator lookupElaboratorFor(String listName,
                                                ServletRequest request) {
        HttpSession session = ((HttpServletRequest)request).getSession(false);
        if (null == session) {
            return null;
        }
        String selectedName = "list_" + listName + ELAB_TAG;
        return (Elaborator) session.getAttribute(selectedName);
    }


    /**
     * Generates the unique name for a list
     * @param name list name
     * @return "uniquified" name
     */
    public static String generateUniqueName(String name) {
        CRC32 crc = new CRC32();
        crc.update(name.getBytes());
        return String.valueOf(crc.getValue());
    }

}
