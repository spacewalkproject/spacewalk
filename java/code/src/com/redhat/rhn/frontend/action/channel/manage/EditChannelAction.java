/**
 * Copyright (c) 2009 Red Hat, Inc.
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
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.ChannelArch;
import com.redhat.rhn.domain.channel.ChannelFactory;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.OrgTrust;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.taglibs.list.helper.ListHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.Listable;
import com.redhat.rhn.frontend.xmlrpc.InvalidChannelLabelException;
import com.redhat.rhn.frontend.xmlrpc.InvalidChannelNameException;
import com.redhat.rhn.frontend.xmlrpc.InvalidGPGKeyException;
import com.redhat.rhn.frontend.xmlrpc.InvalidGPGUrlException;
import com.redhat.rhn.manager.channel.ChannelManager;
import com.redhat.rhn.manager.channel.CreateChannelCommand;
import com.redhat.rhn.manager.channel.InvalidGPGFingerprintException;
import com.redhat.rhn.manager.channel.UpdateChannelCommand;
import com.redhat.rhn.manager.system.SystemManager;

import org.apache.struts.action.ActionErrors;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;
import org.apache.struts.action.DynaActionForm;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


/**
 * EditChannelAction
 * @version $Rev: 1 $
 */
public class EditChannelAction extends RhnAction implements Listable {


    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
                                 ActionForm formIn,
                                 HttpServletRequest request,
                                 HttpServletResponse response) {
    
        ActionErrors errors = new ActionErrors();
        DynaActionForm form = (DynaActionForm)formIn;
        Map params = makeParamMap(request);
        RequestContext ctx = new RequestContext(request);
        
        // keep the cid
        if (ctx.hasParam("cid")) {
            params.put("cid", ctx.getParam("cid", true));
        }

        if (!isSubmitted(form)) {
            setupForm(request, form);
            return getStrutsDelegate().forwardParams(
                    mapping.findForward("default"),
                    request.getParameterMap());
        }

        if (ctx.hasParam("create_button")) {
            Long cid = create(form, errors, ctx);
            params.put("cid", cid);
            if (errors.isEmpty()) {
            createSuccessMessage(request, "message.channelcreated",
                    form.getString("name"));
            }
        }
        else if (ctx.hasParam("edit_button")) {
            //params.put("cid", ctx.getParam("cid", true));
            String sharing = (String) form.get("org_sharing");
            
            if (hasSharingChanged(form, ctx) && ("private".equals(sharing) ||
                    "protected".equals(sharing))) {
                // forward to confirm page
                request.setAttribute("org", ctx.getLoggedInUser().getOrg());
                formToAttributes(request, form);                
                Map urlParams = new HashMap();
                urlParams.put(RequestContext.CID, 
                            ctx.getRequiredParam(RequestContext.CID));
                ListHelper helper = new ListHelper(this, request, urlParams);
                helper.setDataSetName(getDataSetName());
                helper.setListName(getListName());
                // ignore the return
                helper.execute();
                return getStrutsDelegate().forwardParams(
                        mapping.findForward(sharing), params);
            }
            
            edit(form, errors, ctx);
            if (errors.isEmpty()) {
            createSuccessMessage(request, "message.channelupdated",
                    form.getString("name"));
            }
                                     
            //did they enable per user subscriptions?
            String sub = (String)form.get("per_user_subscriptions");            
            if (!sub.equals("all")) {
                 addMessage(request, "message.channelsubscribers");
            }
        }
        // handler for private confirmation page
        else if (ctx.hasParam(RequestContext.DISPATCH)) {
            makePrivate(form, errors, ctx);
        }
        else if (ctx.hasParam("deny")) {
            deny(form, errors, ctx);
        }
        else if (ctx.hasParam("grant")) {
            grant(form, errors, ctx);
        }
        if (!errors.isEmpty()) {
            request.setAttribute("channel_label", (String) form.get("label"));
            request.setAttribute("channel_name", (String) form.get("name"));
            request.setAttribute("channel_arch", (String) form.get("arch_name"));
            request.setAttribute("channel_arch_label", (String) form.get("arch"));
            addErrors(request, errors);
            prepDropdowns(new RequestContext(request));
            return getStrutsDelegate().forwardParams(
                    mapping.findForward("default"), 
                    params);
        }

        return getStrutsDelegate().forwardParams(
                mapping.findForward("success"), params);
    }
    
    /**
     * Return true if the form value of org_sharing is different than the
     * Channel for the given id.
     * @param form contains the user entered values.
     * @param ctx current Request context.
     * @return true if the form value of org_sharing is different than the
     * Channel for the given id.
     */
    private boolean hasSharingChanged(DynaActionForm form, RequestContext ctx) {
        Long cid = ctx.getParamAsLong("cid");
        Channel c = ChannelFactory.lookupByIdAndUser(cid, ctx.getLoggedInUser());
        return !c.getAccess().equals((String) form.get("org_sharing"));
    }
    
    /**
     * Stupid method to copy the contents of the form to the request so that we
     * can perform the confirmation. There's probably a better way, but I've 
     * spent way too long battling Struts.
     * @param request ServletRequest to which the form will be copied as
     * attributes.
     * @param form The DynaActionForm to be copied.
     */
    private void formToAttributes(HttpServletRequest request,
                                  DynaActionForm form) {
        request.setAttribute("name", (String) form.get("name"));
        request.setAttribute("label", (String) form.get("label"));
        request.setAttribute("parent", (String) form.get("parent"));
        request.setAttribute("arch", (String) form.get("arch"));
        request.setAttribute("arch_name", (String) form.get("arch_name"));
        request.setAttribute("summary", (String) form.get("summary"));
        request.setAttribute("description", (String) form.get("description"));
        request.setAttribute("maintainer_name",
                (String) form.get("maintainer_name"));
        request.setAttribute("maintainer_email",
                (String) form.get("maintainer_email"));
        request.setAttribute("maintainer_phone",
                (String) form.get("maintainer_phone"));
        request.setAttribute("support_policy",
                (String) form.get("support_policy"));
        request.setAttribute("per_user_subscriptions",
                (String) form.get("per_user_subscriptions"));
        request.setAttribute("org_sharing", (String) form.get("org_sharing"));
        request.setAttribute("gpg_key_url", (String) form.get("gpg_key_url"));
        request.setAttribute("gpg_key_id", (String) form.get("gpg_key_id"));
        request.setAttribute("gpg_key_fingerprint",
                (String) form.get("gpg_key_fingerprint"));
    }
    
    private Channel deny(DynaActionForm form,
            ActionErrors errors,
            RequestContext ctx) {
        Channel c = edit(form, errors, ctx);
        // now remove all of the orgs to the "rhnchanneltrust"
        c.getTrustedOrgs().clear();
        ChannelFactory.save(c);
        return c;
    }
    
    private Channel grant(DynaActionForm form,
                          ActionErrors errors,
                          RequestContext ctx) {
        Channel c = edit(form, errors, ctx);
        // now add all of the orgs to the "rhnchanneltrust"
        Org org = ctx.getLoggedInUser().getOrg();
        Set<Org> trustedorgs = org.getTrustedOrgs();
        c.setTrustedOrgs(trustedorgs);
        ChannelFactory.save(c);
        return c;
    }

    private Channel makePrivate(DynaActionForm form,
                                ActionErrors errors,
                                RequestContext ctx) {
        // need to unsubscribe all systems from the trusted orgs from this
        // channel
        Long cid = ctx.getParamAsLong("cid");
        Org org = ctx.getLoggedInUser().getOrg();
        Set<Org> trustedorgs = org.getTrustedOrgs();
        for (Org o : trustedorgs) {
            DataResult<Map> dr =
                SystemManager.subscribedInOrgTrust(org.getId(), o.getId());
            for (Map item : dr) {
                Long sid = (Long)item.get("id");
                User user = ctx.getLoggedInUser();
                SystemManager.unsubscribeServerFromChannel(user, sid, cid);
            }
        }
        return edit(form, errors, ctx);
    }

    private Channel edit(DynaActionForm form,
                         ActionErrors errors,
                         RequestContext ctx) {

        User loggedInUser = ctx.getLoggedInUser();
        Channel updated = null;

        // handle submission
        // why can't I just pass in a dictionary? sigh, there are
        // times where python would make this SOOOO much easier.
        UpdateChannelCommand ucc = new UpdateChannelCommand();
        ucc.setArchLabel((String)form.get("arch"));
        ucc.setLabel((String)form.get("label"));
        ucc.setName((String)form.get("name"));
        ucc.setSummary((String)form.get("summary"));
        ucc.setDescription((String)form.get("description"));
        ucc.setUser(loggedInUser);
        ucc.setGpgKeyId((String)form.get("gpg_key_id"));
        ucc.setGpgKeyUrl((String)form.get("gpg_key_url"));
        ucc.setGpgKeyFp((String)form.get("gpg_key_fingerprint"));
        ucc.setMaintainerName((String)form.get("maintainer_name"));
        ucc.setMaintainerEmail((String)form.get("maintainer_email"));
        ucc.setMaintainerPhone((String)form.get("maintainer_phone"));
        ucc.setSupportPolicy((String)form.get("support_policy"));
        ucc.setAccess((String)form.get("org_sharing"));

        String parent = (String)form.get("parent");
        if (parent == null || parent.equals("")) {
            ucc.setParentId(null);
        }
        else {
            ucc.setParentId(Long.valueOf(parent));
        }

        try {
            updated = ucc.update(ctx.getParamAsLong("cid"));
            String sharing = (String)form.get("per_user_subscriptions");
            updated.setGloballySubscribable((sharing != null) &&
                    ("all".equals(sharing)), loggedInUser.getOrg());
            updated = (Channel) ChannelFactory.reload(updated);
        }
        catch (InvalidGPGFingerprintException borg) {
            errors.add(ActionMessages.GLOBAL_MESSAGE,
                    new ActionMessage("edit.channel.invalidgpgfp"));
        }
        catch (InvalidGPGKeyException dukat) {
            errors.add(ActionMessages.GLOBAL_MESSAGE,
                    new ActionMessage("edit.channel.invalidgpgkey"));
        }
        catch (InvalidGPGUrlException khan) {
            errors.add(ActionMessages.GLOBAL_MESSAGE,
                    new ActionMessage("edit.channel.invalidgpgurl"));
        }
        catch (InvalidChannelNameException ferengi) {
            errors.add(ActionMessages.GLOBAL_MESSAGE,
                    new ActionMessage("edit.channel.invalidchannelname"));
        }
        catch (InvalidChannelLabelException q) {
            errors.add(ActionMessages.GLOBAL_MESSAGE,
                    new ActionMessage("edit.channel.invalidchannellabel"));
        }
        catch (IllegalArgumentException iae) {
            errors.add(ActionMessages.GLOBAL_MESSAGE,
                    new ActionMessage("edit.channel.invalidchannelsummary"));
        }
        
        return updated;
    }

    private Long create(DynaActionForm form,
                        ActionErrors errors,
                        RequestContext ctx) {

        User loggedInUser = ctx.getLoggedInUser();
        Long cid = null;

        // handle submission
        // why can't I just pass in a dictionary? sigh, there are
        // times where python would make this SOOOO much easier.
        CreateChannelCommand ccc = new CreateChannelCommand();
        ccc.setArchLabel((String)form.get("arch"));
        ccc.setLabel((String)form.get("label"));
        ccc.setName((String)form.get("name"));
        ccc.setSummary((String)form.get("summary"));
        ccc.setDescription((String)form.get("description"));
        ccc.setParentLabel(null);
        ccc.setUser(loggedInUser);
        ccc.setGpgKeyId((String)form.get("gpg_key_id"));
        ccc.setGpgKeyUrl((String)form.get("gpg_key_url"));
        ccc.setGpgKeyFp((String)form.get("gpg_key_fingerprint"));
        ccc.setMaintainerName((String)form.get("maintainer_name"));
        ccc.setMaintainerEmail((String)form.get("maintainer_email"));
        ccc.setMaintainerPhone((String)form.get("maintainer_phone"));
        ccc.setSupportPolicy((String)form.get("support_policy"));
        ccc.setAccess((String)form.get("org_sharing"));

        String parent = (String)form.get("parent");
        if (parent == null || parent.equals("")) {
            ccc.setParentId(null);
        }
        else {
            ccc.setParentId(Long.valueOf(parent));
        }

        try {
            Channel c = ccc.create();
            String sharing = (String)form.get("per_user_subscriptions");
            c.setGloballySubscribable((sharing != null) &&
                    ("all".equals(sharing)), loggedInUser.getOrg());
            c = (Channel) ChannelFactory.reload(c);
            cid = c.getId();
        }
        catch (InvalidGPGFingerprintException borg) {
            errors.add(ActionMessages.GLOBAL_MESSAGE,
                    new ActionMessage("edit.channel.invalidgpgfp"));
        }
        catch (InvalidGPGKeyException dukat) {
            errors.add(ActionMessages.GLOBAL_MESSAGE,
                    new ActionMessage("edit.channel.invalidgpgkey"));
        }
        catch (InvalidGPGUrlException khan) {
            errors.add(ActionMessages.GLOBAL_MESSAGE,
                    new ActionMessage("edit.channel.invalidgpgurl"));
        }
        catch (InvalidChannelNameException ferengi) {
            errors.add(ActionMessages.GLOBAL_MESSAGE,
                    new ActionMessage("edit.channel.invalidchannelname"));
        }
        catch (InvalidChannelLabelException q) {
            errors.add(ActionMessages.GLOBAL_MESSAGE,
                    new ActionMessage("edit.channel.invalidchannellabel"));
        }
        catch (IllegalArgumentException iae) {
            errors.add(ActionMessages.GLOBAL_MESSAGE,
                    new ActionMessage("edit.channel.invalidchannelsummary"));
        }

        return cid;
    }
    
    private void setupForm(HttpServletRequest request, DynaActionForm form) {
        RequestContext ctx = new RequestContext(request);
        prepDropdowns(ctx);
        Long cid = ctx.getParamAsLong("cid");

        if (cid != null) {
            Channel c = ChannelManager.lookupByIdAndUser(cid,
                                                         ctx.getLoggedInUser());

            form.set("name", c.getName());
            form.set("summary", c.getSummary());
            form.set("description", c.getDescription());
            form.set("org_sharing", c.getAccess());
            form.set("gpg_key_url", c.getGPGKeyUrl());
            form.set("gpg_key_id", c.getGPGKeyId());
            form.set("gpg_key_fingerprint", c.getGPGKeyFp());
            form.set("maintainer_name", c.getMaintainerName());
            form.set("maintainer_phone", c.getMaintainerPhone());
            form.set("maintainer_email", c.getMaintainerEmail());
            form.set("support_policy", c.getSupportPolicy());
            if (c.isGloballySubscribable(ctx.getLoggedInUser().getOrg())) {
                form.set("per_user_subscriptions", "all");
            }
            else {
                form.set("per_user_subscriptions", "selected");
            }

            if (c.getParentChannel() != null) {
                request.setAttribute("parent_name",
                                     c.getParentChannel().getName());
                request.setAttribute("parent_id",
                                     c.getParentChannel().getId());
            }
            else {
                request.setAttribute("parent_name",
                    LocalizationService.getInstance()
                                       .getMessage("generic.jsp.none"));
            }

            request.setAttribute("channel_label", c.getLabel());
            request.setAttribute("channel_name", c.getName());
            request.setAttribute("channel_arch", c.getChannelArch().getName());
            request.setAttribute("channel_arch_label", c.getChannelArch().getLabel());
        }
        else {
            // default settings
            request.setAttribute("channel_name", "");
            form.set("org_sharing", "private");
            form.set("per_user_subscriptions", "all");
        }
    }

    private void prepDropdowns(RequestContext ctx) {
        User loggedInUser = ctx.getLoggedInUser();
        // populate parent base channels
        List baseChannels = new ArrayList();
        List<Channel> bases = ChannelManager.findAllBaseChannelsForOrg(
                        loggedInUser.getOrg());

        LocalizationService ls = LocalizationService.getInstance();
        addOption(baseChannels, ls.getMessage("generic.jsp.none"), "");
        for (Channel c : bases) {
            addOption(baseChannels, c.getName(), c.getId().toString());
        }
        ctx.getRequest().setAttribute("parentChannels", baseChannels);
        
        // base channel arches
        List channelArches = new ArrayList();
        List<ChannelArch> arches = ChannelManager.getChannelArchitectures();
        for (ChannelArch arch : arches) {
            addOption(channelArches, arch.getName(), arch.getLabel());
        }
        ctx.getRequest().setAttribute("channelArches", channelArches);
    }
    
    /**
     * Utility function to create options for the dropdown.
     * @param options list containing all options.
     * @param key resource bundle key used as the display value.
     * @param value value to be submitted with form.
     */
    private void addOption(List options, String key, String value) {
        Map selection = new HashMap();
        selection.put("label", key);
        selection.put("value", value);
        options.add(selection);
    }

    /** {@inheritDoc} */
    public String getDataSetName() {
        return "pageList";
    }

    /** {@inheritDoc} */
    public String getListName() {
        // TODO Auto-generated method stub
        return "trustedOrgList";
    }

    /** {@inheritDoc} */
    public String getParentUrl(RequestContext ctx) {
        return ctx.getRequest().getRequestURI() +
            "?cid=" + ctx.getParamAsLong("cid");
    }

    /** {@inheritDoc} */
    public List getResult(RequestContext ctx) {
        Org org = ctx.getLoggedInUser().getOrg();
        Set<Org> trustedorgs = org.getTrustedOrgs();
        List<OrgTrust> trusts = new ArrayList<OrgTrust>();
        for (Org o : trustedorgs) {
            DataResult<Map> dr =
                SystemManager.subscribedInOrgTrust(org.getId(), o.getId());
            OrgTrust trust = new OrgTrust(o);
            if (!dr.isEmpty()) {
                for (Map m : dr) {
                    Long sid = (Long)m.get("id");
                    trust.getSubscribed().add(sid);
                }
            }
            trusts.add(trust);
        }
        return trusts;
    }

}
