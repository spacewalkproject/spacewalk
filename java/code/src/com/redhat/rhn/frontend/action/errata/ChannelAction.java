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
package com.redhat.rhn.frontend.action.errata;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.ChannelFactory;
import com.redhat.rhn.domain.errata.Errata;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.rhnset.RhnSetElement;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.common.RhnSetAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.StrutsDelegate;
import com.redhat.rhn.manager.channel.ChannelManager;
import com.redhat.rhn.manager.errata.ErrataManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;

import org.apache.log4j.Logger;
import org.apache.struts.action.ActionErrors;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * ChannelAction
 * @version $Rev$
 */
public class ChannelAction extends RhnSetAction {
    

    private static Logger log = Logger.getLogger(ChannelAction.class);


    /**
     * Publishes an unpublished errata (with id = eid) and adds the errata to the 
     * channels selected on the confirmation page.
     * @param mapping ActionMapping for this action
     * @param formIn The form
     * @param request The request
     * @param response The response
     * @return Returns to the publish mapping if publish was executed successfully, to 
     * the failure mapping otherwise.
     */
    public ActionForward publish(ActionMapping mapping,
                                 ActionForm formIn,
                                 HttpServletRequest request,
                                 HttpServletResponse response) {
        log.debug("Publish");
        StrutsDelegate strutsDelegate = getStrutsDelegate();
 
        RequestContext requestContext = new RequestContext(request);
        //Get the logged in user
        User user = requestContext.getLoggedInUser();
        
        //Get the errata object
        Errata errata = requestContext.lookupErratum();
        
        //Update the set with items on the page the user has selected
        RhnSet set = updateSet(request);
        
        //Make sure the user has selected something
        if (set.isEmpty()) {
            return failNoChannelsSelected(request, mapping, errata.getId());
        }
        
        //publish the errata
        errata = ErrataManager.publish(errata, getChannelIdsFromRhnSet(set), user);
        
        return strutsDelegate.forwardParam(mapping.findForward("publish"),
                "eid",
                errata.getId().toString());
    }
    
    /**
     * Updates the channels associated with this errata
     * @param mapping ActionMapping for this action
     * @param formIn The form
     * @param request The request
     * @param response The response
     * @return Returns to the publish mapping if publish was executed successfully, to 
     * the failure mapping otherwise.
     */
    public ActionForward updateChannels(ActionMapping mapping,
                                        ActionForm formIn,
                                        HttpServletRequest request,
                                        HttpServletResponse response) {
        log.debug("updateChannels called.");
        RequestContext requestContext = new RequestContext(request); 
        User user = requestContext.getLoggedInUser();
        
        //Get the errata object
        Errata errata = requestContext.lookupErratum();
        
        //Update the set with items on the page the user has selected
        RhnSet set = updateSet(request);
        //Make sure the user has selected something
        if (set.isEmpty()) {
            return failNoChannelsSelected(request, mapping, errata.getId());
        }
        
        // Save off original channel ids so we can update caches
        Set<Channel> originalChannels = new HashSet<Channel>(errata.getChannels());
        Set<Long> newChannels = getChannelIdsFromRhnSet(set);
        //Otherwise, add each channel to errata
        //The easiest way to do this is to clear the errata's channels and add back the 
        //channels that are in the user's current set
        errata.clearChannels(); //clear the channels associated with errata.
        //add the channels from the set back to the errata

        errata = ErrataManager.addChannelsToErrata(errata, 
                newChannels, user);

        //Update Errata Cache
        if (errata.isPublished()) {          
            
            log.debug("updateChannels - isPublished");
            // Compute list of old and NEW channels so we can 
            // refresh both of their caches.
            List<Channel> channelsToRemove = new LinkedList<Channel>();
            List<Long> channelsToAdd = new LinkedList<Long>();
            for (Channel c : originalChannels) {
                if (!newChannels.contains(c.getId())) {
                    //We are removing the errata from the channel
                    log.debug("updateChannels.Adding1: " + c.getId());
                    channelsToRemove.add(c);                    
                }
            }
            
            for (Long cid : newChannels) {
                Channel newChan = ChannelFactory.lookupById(cid);
                if (!originalChannels.contains(newChan)) {
                    channelsToAdd.add(newChan.getId());
                }
            }
            log.debug("updateChannels() - channels to remove errata: " + channelsToRemove);
            
            //If the errata was removed from any channels lets remove it.
            List<Long> eList = new ArrayList<Long>();
            eList.add(errata.getId());
            for (Channel toRemove : channelsToRemove) {
                ErrataManager.removeErratumFromChannel(errata, toRemove, user);
            }
            
            
            
        }
       StrutsDelegate strutsDelegate = getStrutsDelegate();
       strutsDelegate.saveMessages(request, getMessages(errata));
        
        //Store a success message and forward to default mapping
        //ActionMessages msgs = getMessages(errata);
        //strutsDelegate.saveMessages(request, msgs);
        return strutsDelegate.forwardParam(mapping.findForward("push"),
                                      "eid",
                                      errata.getId().toString());
    }
    
    /**
     * Takes an RhnSet object with ids and gets all the channelIds from the set.
     * @param set The RhnSet object containing channel ids
     * @retval Set of channelIds
     */
    private Set getChannelIdsFromRhnSet(RhnSet set) {
        Set retval = new HashSet();
        Iterator itr = set.getElements().iterator();

        while (itr.hasNext()) {
            RhnSetElement element = (RhnSetElement) itr.next();
            retval.add(element.getElement());
        }
        if (log.isDebugEnabled()) {
            log.debug("channel ids from rhnSet: " + retval);
        }
        return retval;
    }
    
    /**
     * Private helper method to setup a no channels selected failure ActionForward
     * @param request The request to save the errors to
     * @param mapping The mapping that contains the failure forward
     * @param eid The errata id of the errata we're working on
     * @return Returns a failure ActionForward with the errors saved to the request.
     */
    private ActionForward failNoChannelsSelected(HttpServletRequest request,
                                                 ActionMapping mapping,
                                                 Long eid) {
        ActionErrors errors =  new ActionErrors();
        //Get the error message
        errors.add(ActionMessages.GLOBAL_MESSAGE,
                   new ActionMessage("errata.publish.nochannelsselected"));
        //store the errors object to the request
        addErrors(request, errors);
        //return to the failure mapping
        return getStrutsDelegate().forwardParam(mapping.findForward("failure"),
                                      "eid", 
                                      eid.toString());
    }
    
    /**
     * {@inheritDoc}
     */
    public DataResult getDataResult(User user, 
                                    ActionForm formIn, 
                                    HttpServletRequest request) {
        //returns *all* items for the select all list function
        return ChannelManager.channelsOwnedByOrg(user.getOrg().getId(), null);
    }
    
    /**
     * {@inheritDoc}
     * Add publish method to our map of dispatch methods
     */
    protected void processMethodKeys(Map map) {
        map.put("errata.publish.publisherrata", "publish");
        map.put("errata.channels.updatechannels", "updateChannels");
    }
    
    /**
     * {@inheritDoc}
     * Add eid to our parameter map
     */
    protected void processParamMap(ActionForm formIn, 
                                   HttpServletRequest request, 
                                   Map params) {
        //keep eid in params
        Long eid = new RequestContext(request).getRequiredParam("eid");
        //keep track of return visit
        String rv = request.getParameter("returnvisit");
        if (rv != null) {
            params.put("returnvisit", "true");
        }
        params.put("eid", eid);
        
    }

    protected RhnSetDecl getSetDecl() {
        return RhnSetDecl.CHANNELS_FOR_ERRATA;
    }
    
    
    /**
     * Determines whether the success message should be plural or not and fills 
     * out the ActionMessages object appropriately.
     * @param errata The Errata we're working on.
     * @return Returns an ActionMessages object with the correct pluralization.
     */
    private ActionMessages getMessages(Errata errata) {
        ActionMessages msgs = new ActionMessages();
        //get the size of the channels set into a string
        String size = new Long(errata.getChannels().size()).toString();
        if (errata.getChannels().size() == 1) { //singular version '1 channel'
            msgs.add(ActionMessages.GLOBAL_MESSAGE,
                     new ActionMessage("errata.channels.updated.singular",
                                       errata.getAdvisoryName(), size));
        }
        else { //plural version '4 channels'
            msgs.add(ActionMessages.GLOBAL_MESSAGE,
                     new ActionMessage("errata.channels.updated.plural",
                                       errata.getAdvisoryName(), size));    
        }
        return msgs;
    }    
    
    
    
    
}
