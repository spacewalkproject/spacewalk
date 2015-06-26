/**
 * Copyright (c) 2009--2015 Red Hat, Inc.
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
import com.redhat.rhn.common.security.PermissionException;
import com.redhat.rhn.common.util.StringUtil;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.ChannelArch;
import com.redhat.rhn.domain.channel.ChannelFactory;
import com.redhat.rhn.domain.common.ChecksumType;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.OrgTrust;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.ListHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.Listable;
import com.redhat.rhn.frontend.xmlrpc.InvalidChannelLabelException;
import com.redhat.rhn.frontend.xmlrpc.InvalidChannelNameException;
import com.redhat.rhn.frontend.xmlrpc.InvalidGPGKeyException;
import com.redhat.rhn.frontend.xmlrpc.InvalidGPGUrlException;
import com.redhat.rhn.manager.channel.ChannelManager;
import com.redhat.rhn.manager.channel.CloneChannelCommand;
import com.redhat.rhn.manager.channel.CreateChannelCommand;
import com.redhat.rhn.manager.channel.InvalidGPGFingerprintException;
import com.redhat.rhn.manager.channel.UpdateChannelCommand;
import com.redhat.rhn.manager.download.DownloadManager;
import com.redhat.rhn.manager.system.SystemManager;
import com.redhat.rhn.manager.user.UserManager;

import org.apache.commons.lang.StringUtils;
import org.apache.struts.action.ActionErrors;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;
import org.apache.struts.action.DynaActionForm;
import org.stringtree.json.JSONWriter;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


/**
 * EditChannelAction
 * @version $Rev: 1 $
 */
public class EditChannelAction extends RhnAction implements Listable<OrgTrust> {
    public static final String GPG_FINGERPRINT = "gpg_key_fingerprint";
    public static final String GPG_KEY = "gpg_key_id";
    public static final String GPG_URL = "gpg_key_url";
    public static final String SUPPORT_POLICY = "support_policy";
    public static final String ORG_SHARING = "org_sharing";
    public static final String MAINT_PHONE = "maintainer_phone";
    public static final String MAINT_EMAIL = "maintainer_email";
    public static final String MAINT_NAME = "maintainer_name";
    public static final String SUBSCRIPTIONS = "per_user_subscriptions";
    public static final String NAME = "name";
    public static final String LABEL = "label";
    public static final String PARENT = "parent";
    public static final String ARCH = "arch";
    public static final String ARCH_NAME = "arch_name";
    public static final String CHECKSUM = "checksum";
    public static final String SUMMARY = "summary";
    public static final String DESCRIPTION = "description";
    public static final String CLONE_TYPE = "clone_type";
    public static final String ORIGINAL_ID = "original_id";
    public static final String ORIGINAL_NAME = "original_name";
    public static final String CHANNEL_NAME = "channel_name";
    public static final String CHANNEL_LABEL = "channel_label";
    public static final String CHANNEL_ARCH = "channel_arch";
    public static final String CHANNEL_ARCH_LABEL = "channel_arch_label";

    public static final String DEFAULT_ARCH = "channel-x86_64";
    public static final String DEFAULT_CHECKSUM = "sha1";
    public static final String DEFAULT_ORG_SHARING = "private";
    public static final String DEFAULT_SUBSCRIPTIONS = "all";

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
                                 ActionForm formIn,
                                 HttpServletRequest request,
                                 HttpServletResponse response) {

        ActionErrors errors = new ActionErrors();
        DynaActionForm form = (DynaActionForm)formIn;
        Map<String, Object> params = makeParamMap(request);
        RequestContext ctx = new RequestContext(request);
        boolean cloneSelect = false;

        // keep the cid
        if (ctx.hasParam("cid")) {
            params.put("cid", ctx.getParam("cid", true));
        }

        if (!isSubmitted(form)) {
            setupForm(request, form);
            return getStrutsDelegate().forwardParams(
                    mapping.findForward(RhnHelper.DEFAULT_FORWARD),
                    request.getParameterMap());
        }

        if (ctx.hasParam("clone_button")) {
            Long cid = clone(form, errors, ctx);
            params.put("cid", cid);
            if (errors.isEmpty()) {
                String[] msgParams = new String[2];
                msgParams[0] = form.getString(NAME);
                msgParams[1] = form.getString(ORIGINAL_NAME);
                createMessage(request, "message.channelcloned", msgParams);
                if (form.getString(CLONE_TYPE).equals("select")) {
                    cloneSelect = true;
                    createSuccessMessage(request, "message.cloneselect", form
                            .getString(ORIGINAL_NAME));
                }
            }
        }
        else if (ctx.hasParam("create_button")) {
            Long cid = create(form, errors, ctx);
            params.put("cid", cid);
            if (errors.isEmpty()) {
                createSuccessMessage(request, "message.channelcreated", form
                        .getString(NAME));
            }
        }
        else if (ctx.hasParam("edit_button")) {
            String sharing = (String) form.get(ORG_SHARING);

            if (hasSharingChanged(form, ctx) && ("private".equals(sharing) ||
                    "protected".equals(sharing))) {
                // forward to confirm page
                request.setAttribute("org", ctx.getCurrentUser().getOrg());
                formToAttributes(request, form);
                Map urlParams = new HashMap();
                urlParams.put(RequestContext.CID,
                            ctx.getRequiredParam(RequestContext.CID));
                ListHelper helper = new ListHelper(this, request, urlParams);
                helper.setDataSetName(getDataSetName());
                helper.setListName(getListName());
                // ignore the return
                helper.execute();
                request.setAttribute(CHANNEL_NAME, form.getString(NAME));
                return getStrutsDelegate().forwardParams(
                        mapping.findForward(sharing), params);
            }

            edit(form, errors, ctx);
            if (errors.isEmpty()) {
                createSuccessMessage(request, "message.channelupdated", form
                        .getString(NAME));
            }


            //did they enable per user subscriptions?
            String sub = (String) form.get(SUBSCRIPTIONS);
            if (!sub.equals("all")) {
                 addMessage(request, "message.channelsubscribers");
            }
        }
        // handler for private confirmation page
        else if (ctx.hasParam(RequestContext.DISPATCH)) {
            makePrivate(form, errors, ctx);
            if (errors.isEmpty()) {
                createSuccessMessage(request, "message.channelupdated", form
                        .getString(NAME));
            }
        }
        else if (ctx.hasParam("deny")) {
            deny(form, errors, ctx);
            if (errors.isEmpty()) {
                createSuccessMessage(request, "message.channelupdated", form
                        .getString(NAME));
            }
        }
        else if (ctx.hasParam("grant")) {
            grant(form, errors, ctx);
            if (errors.isEmpty()) {
                createSuccessMessage(request, "message.channelupdated", form
                        .getString(NAME));
            }
        }
        if (!errors.isEmpty()) {
            request.setAttribute(CHANNEL_LABEL, form.get(LABEL));
            request.setAttribute(CHANNEL_NAME, form.getString(NAME));
            request.setAttribute(CHANNEL_ARCH, form.get(ARCH_NAME));
            request.setAttribute(CHANNEL_ARCH_LABEL, form.get(ARCH));
            request.setAttribute(CHECKSUM, form.get(CHECKSUM));
            addErrors(request, errors);
            prepDropdowns(new RequestContext(request), null);
            return getStrutsDelegate().forwardParams(
                    mapping.findForward(RhnHelper.DEFAULT_FORWARD),
                    params);
        }

        if (cloneSelect) {
            return getStrutsDelegate().forwardParams(mapping.findForward("select"), params);
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
        Channel c = ChannelFactory.lookupByIdAndUser(cid, ctx.getCurrentUser());
        return !c.getAccess().equals(form.get(ORG_SHARING));
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
        request.setAttribute(NAME, form.get(NAME));
        request.setAttribute(LABEL, form.get(LABEL));
        request.setAttribute(PARENT, form.get(PARENT));
        request.setAttribute(ARCH, form.get(ARCH));
        request.setAttribute(CHECKSUM, form.get(CHECKSUM));
        request.setAttribute(ARCH_NAME, form.get(ARCH_NAME));
        request.setAttribute(SUMMARY, form.get(SUMMARY));
        request.setAttribute(DESCRIPTION, form.get(DESCRIPTION));
        request.setAttribute(MAINT_NAME, form.get(MAINT_NAME));
        request.setAttribute(MAINT_EMAIL, form.get(MAINT_EMAIL));
        request.setAttribute(MAINT_PHONE, form.get(MAINT_PHONE));
        request.setAttribute(SUPPORT_POLICY, form.get(SUPPORT_POLICY));
        request.setAttribute(SUBSCRIPTIONS, form.get(SUBSCRIPTIONS));
        request.setAttribute(ORG_SHARING, form.get(ORG_SHARING));
        request.setAttribute(GPG_URL, form.get(GPG_URL));
        request.setAttribute(GPG_KEY, form.get(GPG_KEY));
        request.setAttribute(GPG_FINGERPRINT, form.get(GPG_FINGERPRINT));
    }

    /**
     *
     * @param form form to check
     * @param errors errors to report
     * @param ctx context
     * @return Channel
     */
    private Channel deny(DynaActionForm form, ActionErrors errors,
            RequestContext ctx) {

        Channel c = edit(form, errors, ctx);
        User user = ctx.getCurrentUser();

        unsubscribeOrgsFromChannel(user, c, Channel.PROTECTED);

        c.getTrustedOrgs().clear();
        ChannelFactory.save(c);
        return c;
    }

    /**
     *
     * @param user User that owns parent channel
     * @param channelIn base channel to unsubscribe from.
     */
    private void unsubscribeOrgsFromChannel(User user, Channel channelIn, String accessIn) {
        Org org = channelIn.getOrg();

        // find trusted orgs
        Set<Org> trustedOrgs = org.getTrustedOrgs();
        for (Org o : trustedOrgs) {
            // find systems subscribed in org Trust
            DataResult<Map<String, Object>> dr =
                    SystemManager.sidsInOrgTrust(
                    org.getId(), o.getId());

            for (Map<String, Object> item : dr) {
                Long sid = (Long) item.get("id");
                Server s = ServerFactory.lookupById(sid);
                if (s.isSubscribed(channelIn)) {
                    // check if this is a base custom channel
                    if (channelIn.getParentChannel() == null) {
                        // unsubscribe children first if subscribed
                        List<Channel> children = channelIn
                                .getAccessibleChildrenFor(user);
                        Iterator<Channel> i = children.iterator();
                        while (i.hasNext()) {
                            Channel child = i.next();
                            if (s.isSubscribed(child)) {
                                // unsubscribe server from child channel

                                child.getTrustedOrgs().remove(o);
                                child.setAccess(accessIn);
                                ChannelFactory.save(child);
                                s = SystemManager.
                                unsubscribeServerFromChannel(s, child);
                            }
                        }
                    }
                    // unsubscribe server from channel
                    ChannelFactory.save(channelIn);
                    s = SystemManager.unsubscribeServerFromChannel(s, channelIn);
                }
            }
        }
    }

    private void grant(DynaActionForm form,
                          ActionErrors errors,
                          RequestContext ctx) {
        Channel c = edit(form, errors, ctx);
        // if there was no exception during the above edit
        // add all of the orgs to the "rhnchanneltrust"
        if (c != null) {
            Org org = ctx.getCurrentUser().getOrg();
            Set<Org> trustedorgs = org.getTrustedOrgs();
            c.setTrustedOrgs(trustedorgs);
            ChannelFactory.save(c);
        }
    }

    private Channel makePrivate(DynaActionForm form,
                                ActionErrors errors,
                                RequestContext ctx) {

        User user = ctx.getCurrentUser();
        Long cid = ctx.getParamAsLong("cid");
        Channel channel = ChannelFactory.lookupById(cid);
        unsubscribeOrgsFromChannel(user, channel, Channel.PRIVATE);
        return edit(form, errors, ctx);
    }

    private Channel edit(DynaActionForm form,
                         ActionErrors errors,
                         RequestContext ctx) {

        User loggedInUser = ctx.getCurrentUser();
        Channel updated = null;

        // handle submission
        // why can't I just pass in a dictionary? sigh, there are
        // times where python would make this SOOOO much easier.
        UpdateChannelCommand ucc = new UpdateChannelCommand();
        ucc.setArchLabel((String) form.get(ARCH));
        ucc.setChecksumLabel((String) form.get(CHECKSUM));
        ucc.setLabel((String) form.get(LABEL));
        ucc.setName((String) form.get(NAME));
        ucc.setSummary((String) form.get(SUMMARY));
        ucc.setDescription((String) form.get(DESCRIPTION));
        ucc.setUser(loggedInUser);
        ucc.setGpgKeyId((String) form.get(GPG_KEY));
        ucc.setGpgKeyUrl((String) form.get(GPG_URL));
        ucc.setGpgKeyFp((String) form.get(GPG_FINGERPRINT));
        ucc.setMaintainerName((String) form.get(MAINT_NAME));
        ucc.setMaintainerEmail((String) form.get(MAINT_EMAIL));
        ucc.setMaintainerPhone((String) form.get(MAINT_PHONE));
        ucc.setSupportPolicy((String) form.get(SUPPORT_POLICY));
        ucc.setAccess((String) form.get(ORG_SHARING));

        String parent = (String) form.get(PARENT);
        if (parent == null || parent.equals("")) {
            ucc.setParentId(null);
        }
        else {
            ucc.setParentId(Long.valueOf(parent));
        }

        try {
            updated = ucc.update(ctx.getParamAsLong("cid"));
            String sharing = (String) form.get(SUBSCRIPTIONS);
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
            handleChannelNameException(errors, ferengi);

        }
        catch (InvalidChannelLabelException q) {
            handleChannelLabelException(errors, q);

        }
        catch (IllegalArgumentException iae) {
            errors.add(ActionMessages.GLOBAL_MESSAGE,
                    new ActionMessage(iae.getMessage()));
        }

        return updated;
    }

    private Long createChannelHelper(CreateChannelCommand command, DynaActionForm form,
            ActionErrors errors, RequestContext ctx) {
        User user = ctx.getCurrentUser();
        String parentString = form.getString(PARENT);
        Long parentId = null;
        if (parentString != null && !StringUtils.isEmpty(parentString)) {
            parentId = Long.valueOf(parentString);
        }

        command.setName(form.getString(NAME));
        command.setLabel(form.getString(LABEL));
        command.setSummary(form.getString(SUMMARY));
        command.setDescription(StringUtil.nullIfEmpty(form.getString(DESCRIPTION)));
        command.setArchLabel(form.getString(ARCH));
        command.setChecksumLabel(form.getString(CHECKSUM));
        command.setGpgKeyFp(StringUtil.nullIfEmpty(form.getString(GPG_FINGERPRINT)));
        command.setGpgKeyId(StringUtil.nullIfEmpty(form.getString(GPG_KEY)));
        command.setGpgKeyUrl(StringUtil.nullIfEmpty(form.getString(GPG_URL)));
        command.setParentId(parentId);
        command.setUser(user);
        command.setMaintainerName(StringUtil.nullIfEmpty(form.getString(MAINT_NAME)));
        command.setMaintainerEmail(StringUtil.nullIfEmpty(form.getString(MAINT_EMAIL)));
        command.setMaintainerPhone(StringUtil.nullIfEmpty(form.getString(MAINT_PHONE)));
        command.setSupportPolicy(StringUtil.nullIfEmpty(form.getString(SUPPORT_POLICY)));
        command.setAccess(form.getString(ORG_SHARING));
        String sharing = form.getString(SUBSCRIPTIONS);
        command.setGloballySubscribable((sharing != null) && ("all".equals(sharing)));


        try {
            Channel c = command.create();
            return c.getId();
        }
        catch (InvalidGPGFingerprintException borg) {
            errors.add(ActionMessages.GLOBAL_MESSAGE, new ActionMessage(
                    "edit.channel.invalidgpgfp"));
        }
        catch (InvalidGPGKeyException dukat) {
            errors.add(ActionMessages.GLOBAL_MESSAGE, new ActionMessage(
                    "edit.channel.invalidgpgkey"));
        }
        catch (InvalidGPGUrlException khan) {
            errors.add(ActionMessages.GLOBAL_MESSAGE, new ActionMessage(
                    "edit.channel.invalidgpgurl"));
        }
        catch (InvalidChannelNameException ferengi) {
            handleChannelNameException(errors, ferengi);
        }
        catch (InvalidChannelLabelException q) {
            handleChannelLabelException(errors, q);
        }
        catch (IllegalArgumentException iae) {
            errors.add(ActionMessages.GLOBAL_MESSAGE, new ActionMessage(iae.getMessage()));
        }
        return null;
    }

    private Long clone(DynaActionForm form, ActionErrors errors, RequestContext ctx) {
        User user = ctx.getCurrentUser();
        Channel original = ChannelManager.lookupByIdAndUser((Long) form.get(ORIGINAL_ID),
                user);

        boolean originalState = true;
        if (form.getString(CLONE_TYPE).equals("current")) {
            originalState = false;
        }

        CloneChannelCommand command = new CloneChannelCommand(originalState, original);
        return createChannelHelper(command, form, errors, ctx);
    }

    private Long create(DynaActionForm form,
                        ActionErrors errors,
                        RequestContext ctx) {
        CreateChannelCommand ccc = new CreateChannelCommand();
        return createChannelHelper(ccc, form, errors, ctx);
    }

    private void handleChannelNameException(ActionErrors errors,
                                            InvalidChannelNameException ferengi) {
        switch (ferengi.getReason()) {
            case IS_MISSING:
                errors.add(ActionMessages.GLOBAL_MESSAGE,
                        new ActionMessage("edit.channel.invalidchannelname.missing"));
                break;

            case REGEX_FAILS:
                errors.add(ActionMessages.GLOBAL_MESSAGE,
                        new ActionMessage("edit.channel.invalidchannelname.regex"));
                break;

            case REDHAT_REGEX_FAILS:
                errors.add(ActionMessages.GLOBAL_MESSAGE,
                        new ActionMessage("edit.channel.invalidchannelname.redhat",
                                ferengi.getArgs()));
                break;

            case TOO_SHORT:
                errors.add(ActionMessages.GLOBAL_MESSAGE,
                        new ActionMessage("edit.channel.invalidchannelname.minlength",
                            CreateChannelCommand.CHANNEL_NAME_MIN_LENGTH));
                break;

            case TOO_LONG:
                errors.add(ActionMessages.GLOBAL_MESSAGE,
                        new ActionMessage("edit.channel.invalidchannelname.maxlength",
                            CreateChannelCommand.CHANNEL_NAME_MAX_LENGTH));
                break;

            case NAME_IN_USE:
                errors.add(ActionMessages.GLOBAL_MESSAGE,
                        new ActionMessage("edit.channel.invalidchannelname.nameinuse",
                            ferengi.getName()));
                break;

            default:
                errors.add(ActionMessages.GLOBAL_MESSAGE,
                        new ActionMessage("edit.channel.invalidchannelname"));
        }
    }

    private void handleChannelLabelException(ActionErrors errors,
                                             InvalidChannelLabelException q) {
        switch (q.getReason()) {
            case IS_MISSING:
                errors.add(ActionMessages.GLOBAL_MESSAGE,
                    new ActionMessage("edit.channel.invalidchannellabel.missing"));
                break;

            case REGEX_FAILS:
                errors.add(ActionMessages.GLOBAL_MESSAGE,
                    new ActionMessage("edit.channel.invalidchannellabel.regex"));
                break;

            case REDHAT_REGEX_FAILS:
                errors.add(ActionMessages.GLOBAL_MESSAGE,
                    new ActionMessage("edit.channel.invalidchannellabel.redhat",
                            q.getArgs()));
                break;

            case TOO_SHORT:
                errors.add(ActionMessages.GLOBAL_MESSAGE,
                    new ActionMessage("edit.channel.invalidchannellabel.minlength",
                        CreateChannelCommand.CHANNEL_LABEL_MIN_LENGTH));
                break;

            case LABEL_IN_USE:
                errors.add(ActionMessages.GLOBAL_MESSAGE,
                    new ActionMessage("edit.channel.invalidchannellabel.labelinuse",
                        q.getLabel()));
                break;

            default:
                errors.add(ActionMessages.GLOBAL_MESSAGE,
                    new ActionMessage("edit.channel.invalidchannellabel"));
        }
    }

    /**
     * Set up things required for edit.jsp to render correctly
     * @param request the request
     * @param form the form
     * @param c the channel
     */
    public static void setupFormHelper(HttpServletRequest request, DynaActionForm form,
            Channel c) {
        form.set(SUMMARY, c.getSummary());
        form.set(DESCRIPTION, c.getDescription());
        form.set(ORG_SHARING, c.getAccess());
        form.set(GPG_URL, c.getGPGKeyUrl());
        form.set(GPG_KEY, c.getGPGKeyId());
        form.set(GPG_FINGERPRINT, c.getGPGKeyFp());
        form.set(MAINT_NAME, c.getMaintainerName());
        form.set(MAINT_PHONE, c.getMaintainerPhone());
        form.set(MAINT_EMAIL, c.getMaintainerEmail());
        form.set(SUPPORT_POLICY, c.getSupportPolicy());
        if (c.getChecksumTypeLabel() == null) {
            form.set(CHECKSUM, null);
        }
        else {
            form.set(CHECKSUM, c.getChecksumTypeLabel());
        }

        if (c.getParentChannel() != null) {
            request.setAttribute("parent_name", c.getParentChannel().getName());
            request.setAttribute("parent_id", c.getParentChannel().getId());
        }
        else {
            request.setAttribute("parent_name", LocalizationService.getInstance()
                    .getMessage("generic.jsp.none"));
        }

        request.setAttribute(CHANNEL_ARCH, c.getChannelArch().getName());
        request.setAttribute(CHANNEL_ARCH_LABEL, c.getChannelArch().getLabel());
    }

    private static void setupForm(HttpServletRequest request, DynaActionForm form) {
        RequestContext ctx = new RequestContext(request);
        prepDropdowns(ctx, null);
        Long cid = ctx.getParamAsLong("cid");

        if (cid != null) {
            Channel c = ChannelManager.lookupByIdAndUser(cid,
                                                         ctx.getCurrentUser());
            if (!UserManager.verifyChannelAdmin(ctx.getCurrentUser(), c)) {
                throw new PermissionException(RoleFactory.CHANNEL_ADMIN);
            }

            form.set(NAME, c.getName());
            request.setAttribute(CHANNEL_LABEL, c.getLabel());
            request.setAttribute(CHANNEL_NAME, c.getName());

            if (c.getSources().isEmpty()) {
                request.setAttribute("last_sync", "");
            }
            else {
                String lastSync = LocalizationService.getInstance().getMessage(
                        "channel.edit.repo.neversynced");
                if (c.getLastSynced() != null) {
                    lastSync = LocalizationService.getInstance().formatCustomDate(
                            c.getLastSynced());
                }
                request.setAttribute("last_sync", lastSync);
                if (!ChannelManager.getLatestSyncLogFiles(c).isEmpty()) {
                    request.setAttribute("log_url",
                            DownloadManager.getChannelSyncLogDownloadPath(c,
                                    ctx.getCurrentUser()));
                }

            }
            if (c.isGloballySubscribable(ctx.getCurrentUser().getOrg())) {
                form.set(SUBSCRIPTIONS, "all");
            }
            else {
                form.set(SUBSCRIPTIONS, "selected");
            }

            setupFormHelper(request, form, c);

        }
        else {
            // default settings
            String channelName = LocalizationService.getInstance()
              .getMessage("frontend.actions.channels.manager.create");
            request.setAttribute(CHANNEL_NAME, channelName);
            form.set(ORG_SHARING, DEFAULT_ORG_SHARING);
            form.set(SUBSCRIPTIONS, DEFAULT_SUBSCRIPTIONS);
            form.set(CHECKSUM, DEFAULT_CHECKSUM);
            request.setAttribute(CHANNEL_ARCH_LABEL, DEFAULT_ARCH);
        }
    }

    /**
     * prep the dropdown menues for the edit page
     * @param ctx request context for this request
     * @param original original channel if cloning, null otherwise
     */
    public static void prepDropdowns(RequestContext ctx, Channel original) {
        User loggedInUser = ctx.getCurrentUser();
        // populate parent base channels
        List<Map<String, String>> baseChannels = new ArrayList<Map<String, String>>();
        List<Channel> bases = ChannelManager.findAllBaseChannelsForOrg(
                        loggedInUser);

        LocalizationService ls = LocalizationService.getInstance();

        // if cloning a base channel "None" should be the only option for parents
        // if cloning a child channel "None" should not be an option
        // if not cloning everything should be an option
        if (original == null || original.isBaseChannel()) {
            addOption(baseChannels, ls.getMessage("generic.jsp.none"), "");
        }
        if (original == null || !original.isBaseChannel()) {
            for (Channel c : bases) {
                addOption(baseChannels, c.getName(), c.getId().toString());
            }
            // if cloning a child channel, make a guess as to who the parent should be
            if (original != null) {
                ctx.getRequest().setAttribute("defaultParent",
                        ChannelManager.likelyParentId(original, loggedInUser.getOrg()));
            }
        }
        ctx.getRequest().setAttribute("parentChannels", baseChannels);

        Map<Long, String> parentChannelArches = new HashMap<Long, String>();
        for (Channel c : bases) {
            parentChannelArches.put(c.getId(), c.getChannelArch().getLabel());
        }
        ctx.getRequest().setAttribute("parentChannelArches", parentChannelArches);

        Map<Long, String> parentChannelChecksums = new HashMap<Long, String>();
        for (Channel c : bases) {
            parentChannelChecksums.put(c.getId(), c.getChecksumTypeLabel());
        }
        ctx.getRequest().setAttribute("parentChannelChecksums", parentChannelChecksums);

        JSONWriter json = new JSONWriter();

        // base channel arches
        List<Map<String, String>> channelArches = new ArrayList<Map<String, String>>();
        List<ChannelArch> arches = ChannelManager.getChannelArchitectures();
        List<Map<String, String>> allArchConstruct = new ArrayList<Map<String, String>>();
        for (ChannelArch arch : arches) {
            addOption(channelArches, arch.getName(), arch.getLabel());
            Map<String, String> archAttrs = new HashMap<String, String>();
            archAttrs.put(NAME, arch.getName());
            archAttrs.put(LABEL, arch.getLabel());
            allArchConstruct.add(archAttrs);
        }
        ctx.getRequest().setAttribute("channelArches", channelArches);

        Map<String, String> archCompatMap = new HashMap<String, String>();
        Set<String> uniqueParentChannelArches = new HashSet<String>(parentChannelArches
                .values());
        for (String arch : uniqueParentChannelArches) {
            archCompatMap.put(
                    arch, json.write(ChannelManager.compatibleChildChannelArches(arch)));
        }
        // empty string for when there is no parent, all arches are available
        archCompatMap.put("", json.write(allArchConstruct));
        ctx.getRequest().setAttribute("archCompatMap", archCompatMap);

        // set the list of yum supported checksums
        List<Map<String, String>> checksums = new ArrayList<Map<String, String>>();
        for (ChecksumType chType : ChannelFactory.listYumSupportedChecksums()) {
            addOption(checksums, chType.getLabel(), chType.getLabel());
        }
        ctx.getRequest().setAttribute("checksums", checksums);
    }

    /**
     * Utility function to create options for the dropdown.
     * @param options list containing all options.
     * @param key resource bundle key used as the display value.
     * @param value value to be submitted with form.
     */
    private static void addOption(List<Map<String, String>> options, String key,
            String value) {
        Map<String, String> selection = new HashMap<String, String>();
        selection.put(LABEL, key);
        selection.put("value", value);
        options.add(selection);
    }

    /** {@inheritDoc} */
    public String getDataSetName() {
        return RequestContext.PAGE_LIST;
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
    public List<OrgTrust> getResult(RequestContext ctx) {
        Org org = ctx.getCurrentUser().getOrg();
        Set<Org> trustedorgs = org.getTrustedOrgs();
        List<OrgTrust> trusts = new ArrayList<OrgTrust>();
        for (Org o : trustedorgs) {
            DataResult<Map<String, Object>> dr =
                SystemManager.sidsInOrgTrust(org.getId(), o.getId());
            OrgTrust trust = new OrgTrust(o);
            if (!dr.isEmpty()) {
                for (Map<String, Object> m : dr) {
                    Long sid = (Long)m.get("id");
                    trust.getSubscribed().add(sid);
                }
            }
            trusts.add(trust);
        }
        return trusts;
    }

}
