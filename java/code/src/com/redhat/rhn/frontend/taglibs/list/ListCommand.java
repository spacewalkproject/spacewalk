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

/**
 * Describes the various states the ListTag moves thru as it renders a list
 * @version $Rev $
 */

public enum ListCommand {
    ENUMERATE("__enum__"),
    TBL_HEADING("__tbl_heading__"),
    TBL_ADDONS("__tbl_addons__"),
    COL_HEADER("__col_header__"),
    BEFORE_RENDER("__tbl__before_render__"),
    RENDER("__render__"),
    AFTER_RENDER("__tbl__after_render__"),
    TBL_FOOTER("__tbl_footer__");

    private String _cmd;

    ListCommand(String cmd) {
        _cmd = cmd;
    }

    /**
     * ${@inheritDoc}
     */
    @Override
    public String toString() {
        return _cmd;
    }
}
