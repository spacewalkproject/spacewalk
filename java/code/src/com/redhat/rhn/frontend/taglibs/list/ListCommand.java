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
    RENDER ("__render__"),
    TBL_HEADER ("__tbl_header__"),
    TBL_FOOTER ("__tbl__footer__"),
    COL_HEADER ("__col_header__"),
    ENUMERATE ("__enum__");

    private String _cmd;

    private ListCommand(String cmd) {
        _cmd = cmd;
    }

    /**
     * ${@inheritDoc}
     */
    public String toString() {
        return _cmd;
    }
}
