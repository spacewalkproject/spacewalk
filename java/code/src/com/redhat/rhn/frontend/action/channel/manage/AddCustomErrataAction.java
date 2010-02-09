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
package com.redhat.rhn.frontend.action.channel.manage;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.ChannelFactory;
import com.redhat.rhn.domain.channel.SelectableChannel;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnListAction;
import com.redhat.rhn.frontend.struts.RhnListSetHelper;
import com.redhat.rhn.frontend.taglibs.list.ListTagHelper;
import com.redhat.rhn.frontend.taglibs.list.TagHelper;
import com.redhat.rhn.manager.channel.ChannelManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * 
 * AddCustomErrataAction
 * @version $Rev$
 */
public class AddCustomErrataAction extends RhnListAction {

    
    private static final String CID = "cid";
    private static final String SELECTED_CHANNEL = "selected_channel";
    private static final String SELECTED_CHANNEL_OLD = "selected_channel_old";
   
    
    private static final String CHANNEL_LIST = "channel_list";
    
    private static final String CHANNEL_SUBMIT = "frontend.actions.channels.manager." +
            "add.viewErrata";
    private static final String NULL = "null";
    private static final String CHECKED = "assoc_checked";
    
    private static final String SUBMITTED = "frontend.actions.channels.manager.add." +
            "submit";    
    
    private static final String LIST_NAME = "errata";
    
    /**
     * {@inheritDoc}
     */
    public ActionForward execute(ActionMapping mapping,
            ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response) {
        
        RequestContext requestContext = new RequestContext(request);
        User user =  requestContext.getLoggedInUser();
        Long cid = Long.parseLong(request.getParameter(CID));
        Channel currentChan = ChannelFactory.lookupByIdAndUser(cid, user);
        Channel selectedChannel = null;
        
                
        PublishErrataHelper.checkPermissions(user);
        
        request.setAttribute(CID, cid);
        request.setAttribute("user", user);
        request.setAttribute("channel_name", currentChan.getName());
        request.setAttribute(ListTagHelper.PARENT_URL, request.getRequestURI());
        
        
        List<SelectableChannel> channelList = null;

        

        String selectedChannelStr = null;
        Boolean checked = true;
        
        
        //Set initail strings
        selectedChannelStr = request.getParameter(SELECTED_CHANNEL_OLD);
  
        //If the channel submit button was clicked
        if (requestContext.wasDispatched(CHANNEL_SUBMIT)) {
          selectedChannelStr = request.getParameter(SELECTED_CHANNEL);
          if (selectedChannelStr.equals(NULL)) {
              selectedChannelStr = null;
          }          
        }

        //If this is a clone, go ahead and pre-select the original Channel
        Channel original = ChannelFactory.lookupOriginalChannel(currentChan);
        if (!requestContext.isSubmitted() && selectedChannel == null && 
                original != null) {
            selectedChannel = original;
            selectedChannelStr = selectedChannel.getId().toString();
        }
        
        request.setAttribute(SELECTED_CHANNEL, selectedChannelStr);
        
        
        if (requestContext.isSubmitted() && request.getParameter(CHECKED) == null)  {
            checked = false;
        }
        
        
        request.setAttribute(CHECKED, checked);
        
        //if we submitted, go to confirm page
        if (requestContext.wasDispatched(SUBMITTED)) {
            Map params = new HashMap();
            params.put(CID, request.getParameter(CID));
            params.put(CHECKED, request.getParameter(CHECKED));
            params.put(SELECTED_CHANNEL,
                    selectedChannelStr == null ? "" : selectedChannelStr);
            return getStrutsDelegate().forwardParams(mapping.findForward("submit"), 
                    params); 
        }

        
        
            
        List<Channel> channelSet = ChannelFactory.listCustomBaseChannels(user);
        
        channelList = new ArrayList();
        sortChannelsAndChildify(channelSet, channelList, user, selectedChannelStr);
        request.setAttribute(CHANNEL_LIST, channelList);
           
        
        //If we clicked on the channel selection, clear the set
        if (requestContext.wasDispatched(CHANNEL_SUBMIT) ||
                !requestContext.isSubmitted()) {
            RhnSet set =  getSetDecl(currentChan).get(user);
            set.clear();
            RhnSetManager.store(set);             
        }
        
        
        if (selectedChannelStr != null) {
            selectedChannel = ChannelFactory.lookupByIdAndUser(Long.parseLong(
                    selectedChannelStr), user);   
        }                

            
        RhnListSetHelper helper = new RhnListSetHelper(request);        
        RhnSet set =  getSetDecl(currentChan).get(user);
        

        DataResult dr = getData(request, selectedChannel, currentChan, null, 
                checked, user);        
        request.setAttribute("pageList", dr);
        
        if (ListTagHelper.getListAction(LIST_NAME, request) != null) {
            helper.execute(set, LIST_NAME, dr);
        }    
        if (!set.isEmpty()) {
            helper.syncSelections(set, dr);
            ListTagHelper.setSelectedAmount(LIST_NAME, set.size(), request);            
        }
        
        TagHelper.bindElaboratorTo(LIST_NAME, dr.getElaborator(), request);
        ListTagHelper.bindSetDeclTo(LIST_NAME, getSetDecl(currentChan), request);
        
        
        
        return mapping.findForward("default");
    }
    
    
    private void sortChannelsAndChildify(List<Channel> listToSort, 
            List<SelectableChannel> resultList, 
            User user, String selectedId) {
        
        Long cid = null;
        if (selectedId != null) {
            cid = Long.parseLong(selectedId);
        }
        
        Collections.sort(listToSort);
        for (Channel chan : listToSort) {
            List<Channel> children = chan.getAccessibleChildrenFor(user);
            Collections.sort(children);
            resultList.add(new SelectableChannel(chan));
            if (cid != null && chan.getId().equals(cid)) {
                resultList.get(resultList.size() - 1).setSelected(true);
            }
            for (Channel childChan : children)  {
                resultList.add(new SelectableChannel(childChan));
                if (cid != null && childChan.getId().equals(cid)) {
                    resultList.get(resultList.size() - 1).setSelected(true);
                }
            }
        }
    }
    
    
    
    protected RhnSetDecl getSetDecl(Channel chan) {
        return RhnSetDecl.setForChannelErrata(chan);
    }
    
    
    protected DataResult getData(HttpServletRequest request, 
            Channel selectedChan, 
            Channel currentChan, 
            List<SelectableChannel> selChannelList,
            boolean packageAssoc,
            User user) {
        
        if (selectedChan != null) {
            RhnSet set = RhnSetDecl.CHANNELS_FOR_ERRATA.get(user);
            set.clear();   
            set.addElement(selectedChan.getId());
            RhnSetManager.store(set);
            return ChannelManager.findErrataFromRhnSetForTarget(currentChan, 
                    packageAssoc, user);     
        }
        else if (selChannelList != null) {
                RhnSet set = RhnSetDecl.CHANNELS_FOR_ERRATA.get(user);
                set.clear();
                for (SelectableChannel chan : selChannelList) {
                    set.addElement(chan.getId());
                }
                RhnSetManager.store(set);
                return ChannelManager.findErrataFromRhnSetForTarget(currentChan, 
                        packageAssoc, user);
        }
        else {
                return ChannelManager.findCustomErrataForTarget(currentChan, 
                        packageAssoc);       
        }
    }
    
}
