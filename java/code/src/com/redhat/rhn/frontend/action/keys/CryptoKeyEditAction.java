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
package com.redhat.rhn.frontend.action.keys;

import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.kickstart.crypto.BaseCryptoKeyCommand;
import com.redhat.rhn.manager.kickstart.crypto.EditCryptoKeyCommand;

/**
 * CryptoKeyCreateAction
 * @version $Rev: 1 $
 */
public class CryptoKeyEditAction extends BaseCryptoKeyEditAction {

    protected BaseCryptoKeyCommand getCommand(RequestContext ctx) {
        return new EditCryptoKeyCommand(ctx.getCurrentUser(),
                ctx.getRequiredParam(RequestContext.KEY_ID));
    }

}
