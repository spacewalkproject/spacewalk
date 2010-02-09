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
package com.redhat.rhn.frontend.action.kickstart;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.rhnset.RhnSetElement;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.kickstart.KickstartCryptoKeyCommand;
import com.redhat.rhn.manager.kickstart.KickstartLister;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;

import org.apache.struts.action.ActionForm;

import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

/**
 * KickstartKeysEditAction - Action to handle associating GPG/SSL keys with a Kickstart
 * @version $Rev: 1 $
 */
public class KickstartCryptoKeysSubmitAction extends BaseKickstartListSubmitAction {
    
    public static final String UPDATE_METHOD = "kickstart.cryptokeys.jsp.submit";

    /**
     * {@inheritDoc}
     */
    protected void operateOnRemovedElements(List elements, 
            HttpServletRequest request) {
        RequestContext rctx = new RequestContext(request);
        KickstartCryptoKeyCommand cmd = new KickstartCryptoKeyCommand(
                rctx.getRequiredParam(RequestContext.KICKSTART_ID), rctx.getCurrentUser());
        List ids = new LinkedList();
        for (int i = 0; i < elements.size(); i++) {
            ids.add(((RhnSetElement) elements.get(i)).getElement());
        }
        cmd.removeKeysById(ids);
        cmd.store();
        
    }

    /**
     * {@inheritDoc}
     */
    protected void operateOnAddedElements(List elements, 
            HttpServletRequest request) {
        RequestContext rctx = new RequestContext(request);
        KickstartCryptoKeyCommand cmd = new KickstartCryptoKeyCommand(
                rctx.getRequiredParam(RequestContext.KICKSTART_ID), rctx.getCurrentUser());
        List ids = new LinkedList();
        for (int i = 0; i < elements.size(); i++) {
            ids.add(((RhnSetElement) elements.get(i)).getElement());
        }
        cmd.addKeysByIds(ids);
        cmd.store();
    }

    /**
     * 
     * {@inheritDoc}
     */
    public RhnSetDecl getSetDecl() {
        return RhnSetDecl.GPGSSL_KEYS;
    }

    protected DataResult getDataResult(User user, 
                                       ActionForm formIn, 
                                       HttpServletRequest request) {
        RequestContext rctx = new RequestContext(request);
        return KickstartLister.getInstance().
            cryptoKeysInOrg(rctx.getCurrentUser().getOrg(), null);
    }

    protected void processMethodKeys(Map map) {
        map.put(UPDATE_METHOD, "operateOnDiff");        
    }

    protected Iterator getCurrentItemsIterator(RequestContext ctx) {
        KickstartCryptoKeyCommand cmd = new KickstartCryptoKeyCommand(
                ctx.getRequiredParam(RequestContext.KICKSTART_ID), ctx.getCurrentUser());
        return cmd.getCryptoKeys().iterator();
        
    }

}
