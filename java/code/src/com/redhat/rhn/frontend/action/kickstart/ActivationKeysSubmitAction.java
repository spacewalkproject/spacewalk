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
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.rhnset.RhnSetElement;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.kickstart.KickstartActivationKeysCommand;
import com.redhat.rhn.manager.kickstart.KickstartLister;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;

import org.apache.log4j.Logger;
import org.apache.struts.action.ActionForm;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

/**
 * ActivationKeysSubmitAction.
 * @version $Rev$
 */
public class ActivationKeysSubmitAction extends BaseKickstartListSubmitAction {

    public static final String UPDATE_METHOD = "kickstart.activationkeys.jsp.submit";
    private static Logger log = Logger.getLogger(ActivationKeysSubmitAction.class);
    
    /**
     * {@inheritDoc}
     */
    protected DataResult getDataResult(User userIn, 
                                       ActionForm formIn, 
                                       HttpServletRequest request) {
        RequestContext rctx = new RequestContext(request);
        Org org = rctx.getCurrentUser().getOrg();
        return KickstartLister.getInstance().getActivationKeysInOrg(org, null);
    }

    /**
     * 
     * {@inheritDoc}
     */
    protected void operateOnRemovedElements(List elements,
                                            HttpServletRequest request) {
        RequestContext ctx = new RequestContext(request);

        KickstartActivationKeysCommand cmd =
            new KickstartActivationKeysCommand(
                    ctx.getRequiredParam(RequestContext.KICKSTART_ID),
                    ctx.getCurrentUser());

        // my @ids = map { $_->id() } @elements;

        ArrayList ids = new ArrayList();
        Iterator i = elements.iterator();

        while (i.hasNext()) {
            ids.add(((RhnSetElement) i.next()).getElement());
        }
        
        if (log.isDebugEnabled()) {
            log.debug("ids to remove: " + ids);
        }
        
        cmd.removeTokensByIds(ids);
        cmd.store();

        return;
    }

    /**
     * 
     * {@inheritDoc}
     */
    protected void operateOnAddedElements(List elements, HttpServletRequest request) {
        RequestContext ctx = new RequestContext(request);

        KickstartActivationKeysCommand cmd =
            new KickstartActivationKeysCommand(
                    ctx.getRequiredParam(RequestContext.KICKSTART_ID), 
                    ctx.getCurrentUser());

        // my @ids = map { $_->id() } @elements;

        ArrayList ids = new ArrayList();
        Iterator i = elements.iterator();

        while (i.hasNext()) {
            ids.add(((RhnSetElement) i.next()).getElement());
        }

        if (log.isDebugEnabled()) {
            log.debug("ids to add: " + ids);
        }
        
        cmd.addTokensByIds(ids);
        cmd.store();

        return;
    }

    /**
     * 
     * @return security label for activation keys
     */
    public RhnSetDecl getSetDecl() {
        return RhnSetDecl.KICKSTART_ACTIVATION_KEYS;
    }

    /**
     * {@inheritDoc}
     */
    protected void processMethodKeys(Map map) {
        map.put(UPDATE_METHOD, "operateOnDiff");        
    }

    protected Iterator getCurrentItemsIterator(RequestContext ctx) {
        KickstartActivationKeysCommand cmd =
            new KickstartActivationKeysCommand(
                    ctx.getRequiredParam(RequestContext.KICKSTART_ID), 
                    ctx.getCurrentUser());
        return cmd.getDefaultRegTokens().iterator();
    }

}
