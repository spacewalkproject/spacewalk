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
package com.redhat.rhn.frontend.action;


/**
 * SetLabels
 * @version $Rev$
 */
public final class SetLabels {
    public static final String SYSTEM_ENTITLEMENTS = "system_entitlements";
    public static final String AFFECTED_SYSTEMS_LIST = "errata_system_list";
    public static final String SYSTEM_LIST = "system_list";
    public static final String PATCH_INSTALL_SET = "install_patch_list";
    public static final String PATCH_REMOVE_SET  = "removable_patch_list";
    public static final String PACKAGE_UPGRADE_SET = "upgrade_package_list";
}
