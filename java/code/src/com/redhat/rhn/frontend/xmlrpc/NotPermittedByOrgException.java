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
package com.redhat.rhn.frontend.xmlrpc;

import com.redhat.rhn.FaultException;
import com.redhat.rhn.common.localization.LocalizationService;


/**
 * NotPermittedByOrg
 * @version $Rev$
 */
public class NotPermittedByOrgException extends FaultException  {
    
    /**
     * Constructor
     * @param orgId Org ID.
     * @param request The property user is requesting to modify. (e.g. ChannelName)
     * @param targetOrgId The Org ID that the property exists in.
     */
    public NotPermittedByOrgException(String orgId, String request, String targetOrgId) {
        super(1066, "notPermittedByOrg", LocalizationService.getInstance().
                getMessage("api.org.notpermittedbyorg", new Object[] {orgId, request, 
                        targetOrgId}));
    }

    /**
     * Constructor
     * @param orgId Org ID.
     * @param request The property user is requesting to modify. (e.g. ChannelName)
     * @param targetOrgId The Org ID that the property exists in.
     * @param cause the cause (which is saved for later retrieval by the
     * Throwable.getCause() method). (A null value is permitted, and indicates
     * that the cause is nonexistent or unknown.)
     */
    public NotPermittedByOrgException(String orgId, String request, String targetOrgId,
            Throwable cause) {
        super(1066, "notPermittedByOrg", LocalizationService.getInstance().
                getMessage("api.org.notpermittedbyorg", new Object[] {orgId, request, 
                        targetOrgId}), cause);
    }
}
