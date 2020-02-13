/**
 * Copyright (c) 2009--2017 Red Hat, Inc.
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
package com.redhat.rhn.frontend.action.channel.manage.repo;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.redhat.rhn.domain.channel.ContentSourceType;
import com.redhat.rhn.frontend.xmlrpc.channel.repo.InvalidRepoTypeException;
import org.apache.commons.lang.StringUtils;
import org.apache.struts.action.ActionErrors;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;
import org.apache.struts.action.DynaActionForm;
import org.apache.struts.util.LabelValueBean;

import com.redhat.rhn.common.client.InvalidCertificateException;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.validator.ValidatorException;
import com.redhat.rhn.common.validator.ValidatorResult;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.ChannelFactory;
import com.redhat.rhn.domain.channel.ContentSource;
import com.redhat.rhn.domain.channel.ContentSourceFilter;
import com.redhat.rhn.domain.channel.SslContentSource;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.kickstart.crypto.SslCryptoKey;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.struts.RhnValidationHelper;
import com.redhat.rhn.frontend.xmlrpc.InvalidParameterException;
import com.redhat.rhn.frontend.xmlrpc.channel.repo.InvalidRepoLabelException;
import com.redhat.rhn.frontend.xmlrpc.channel.repo.InvalidRepoUrlException;
import com.redhat.rhn.manager.channel.repo.BaseRepoCommand;
import com.redhat.rhn.manager.channel.repo.CreateRepoCommand;
import com.redhat.rhn.manager.channel.repo.EditRepoCommand;


/**
 * CobblerSnippetDetailsAction
 * @version $Rev$
 */
public class RepoDetailsAction extends RhnAction {

    public static final String CREATE_MODE = "create_mode";
    public static final String REPO = "repo";
    public static final String URL = "url";
    public static final String LABEL = "label";
    public static final String TYPE = "contenttype";
    public static final String SSL_CA_CERT = "sslcacert";
    public static final String SSL_CLIENT_CERT = "sslclientcert";
    public static final String SSL_CLIENT_KEY = "sslclientkey";
    public static final String SOURCEID = "sourceid";
    public static final String FILTERS = "filters";

    private static final String VALIDATION_XSD =
                "/com/redhat/rhn/frontend/action/channel/" +
                        "manage/repo/validation/repoForm.xsd";
    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
                                  ActionForm formIn,
                                  HttpServletRequest request,
                                  HttpServletResponse response) {
        DynaActionForm form = (DynaActionForm) formIn;
        RequestContext ctx = new RequestContext(request);
        Map<String, Object> params = makeParamMap(request);
        String cid = null;
        request.setAttribute(mapping.getParameter(), Boolean.TRUE);
        if (ctx.hasParam("cid")) {
            cid = ctx.getParam("cid", false);
            request.setAttribute("cid", cid);
        }
        if (ctx.isSubmitted()) {

            ValidatorResult result = RhnValidationHelper.validate(this.getClass(),
                            makeValidationMap(form), null,
                                VALIDATION_XSD);
            if (!result.isEmpty()) {
                getStrutsDelegate().saveMessages(request, result);
                RhnValidationHelper.setFailedValidation(request);
            }
            else {
                try {
                    ActionErrors errors = new ActionErrors();
                    ContentSource repo = submit(request, errors, form);
                    if (!errors.isEmpty()) {
                        addErrors(request, errors);
                        setupContentTypes(ctx);
                        setupCryptoKeys(ctx);
                        bindRepo(request, repo);
                        return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
                    }
                    if (isCreateMode(request)) {
                        createSuccessMessage(request,
                                "repos.jsp.create.success", repo.getLabel());
                    }
                    else {
                        createSuccessMessage(request,
                                "repos.jsp.update.success", repo.getLabel());
                    }
                    request.removeAttribute(CREATE_MODE);
                    /*
                    If cid isn't specified, repo will be created as usual. Otherwise repo
                     will be created and will be automatically assigned to channel cid
                     with redirection to channel repo page
                     */
                    if (cid != null) {
                        params.put("cid", cid);
                        Channel chan = ChannelFactory.lookupById(Long.parseLong(cid));
                        Set<ContentSource> sources = chan.getSources();
                        sources.add(repo);
                        ChannelFactory.save(chan);
                        createSuccessMessage(request,
                                "channel.edit.repo.updated", chan.getLabel());
                        return getStrutsDelegate().forwardParams(
                                mapping.findForward("channelSub"), params);
                    }
                    setupRepo(request, form, repo);
                    params.put("id", repo.getId());
                    return getStrutsDelegate().forwardParams(
                            mapping.findForward("success"), params);
                }
                catch (ValidatorException ve) {
                    getStrutsDelegate().saveMessages(request, ve.getResult());
                    RhnValidationHelper.setFailedValidation(request);
                }
            }
        }

        setup(request, form, isCreateMode(request));

        return getStrutsDelegate().forwardParams(mapping.findForward(RhnHelper
                .DEFAULT_FORWARD), params);
    }

    private Map<String, String> makeValidationMap(DynaActionForm form) {
        Map<String, String> map = new HashMap<String, String>();
        map.put(LABEL, form.getString(LABEL));
        map.put(URL, form.getString(URL));
        return map;
    }

    private boolean isCreateMode(HttpServletRequest request) {
        return Boolean.TRUE.equals(request.getAttribute(CREATE_MODE));
    }

    private void setup(HttpServletRequest request, DynaActionForm form,
            boolean createMode) {
        RequestContext context = new RequestContext(request);
        setupContentTypes(context);
        setupCryptoKeys(context);
        if (!createMode) {
            request.setAttribute("id", context.getParamAsLong("id"));
            setupRepo(request, form, ChannelFactory.lookupContentSource(
                    context.getParamAsLong("id"), context.getCurrentUser().getOrg()));
        }
    }

    private void setupContentTypes(RequestContext context) {
        List<LabelValueBean> contentTypes = new ArrayList<LabelValueBean>();
        for (ContentSourceType ct : ChannelFactory.listContentSourceTypes()) {
            contentTypes.add(lv(ct.getLabel(), ct.getLabel()));
        }
        context.getRequest().setAttribute("contenttypes", contentTypes);
    }

    private void setupCryptoKeys(RequestContext context) {
        List<LabelValueBean> sslCrytpoKeyOptions = new ArrayList<LabelValueBean>();
        sslCrytpoKeyOptions.add(lv(LocalizationService.getInstance().
                getMessage("generic.jsp.none"), ""));
        for (Iterator<SslCryptoKey> iter = KickstartFactory.lookupSslCryptoKeys(
                context.getCurrentUser().getOrg()).iterator(); iter.hasNext();) {
            SslCryptoKey sck = iter.next();
            sslCrytpoKeyOptions.add(lv(sck.getDescription(), sck.getId().toString()));
        }
        context.getRequest().setAttribute("sslcryptokeys", sslCrytpoKeyOptions);
    }

    private void setupRepo(HttpServletRequest request, DynaActionForm form,
            ContentSource repo) {

        form.set(LABEL, repo.getLabel());
        form.set(URL, repo.getSourceUrl());
        form.set(SOURCEID, repo.getId());
        form.set(TYPE, repo.getType().getLabel());
        Set<SslContentSource> repoSslSets = repo.getSslSets();
        if (!repoSslSets.isEmpty()) {
            SslContentSource sslRepo = repoSslSets.iterator().next();
            form.set(SSL_CA_CERT, getStringId(sslRepo.getCaCert()));
            form.set(SSL_CLIENT_CERT, getStringId(sslRepo.getClientCert()));
            form.set(SSL_CLIENT_KEY, getStringId(sslRepo.getClientKey()));
        }
        // Filters
        // The goal here is to transform the db filter representation to
        // something user-friendly.
        String currentFlag = "";
        String filterGroup = "";
        List<ContentSourceFilter> filters = ChannelFactory
                .lookupContentSourceFiltersById(repo.getId());
        List<String> filterGroups = new ArrayList<String>();

        for (ContentSourceFilter filter : filters) {
            String flag = filter.getFlag();
            if (currentFlag.equals(flag)) {
                filterGroup = filterGroup + "," + filter.getFilter();
            }
            else {
                if (!filterGroup.isEmpty()) {
                    filterGroups.add(filterGroup);
                }
                filterGroup = flag + filter.getFilter();
                currentFlag = flag;
            }
        }
        // finally add the last one
        filterGroups.add(filterGroup);

        form.set(FILTERS, StringUtils.join(filterGroups.toArray(), ' '));
        bindRepo(request, repo);
    }

    /**
     * Method to bind the repo to a request
     * @param request the servlet request
     * @param repo content source
     */
    public static void bindRepo(HttpServletRequest request, ContentSource repo) {
        request.setAttribute(REPO, repo);
    }

    private List<ContentSourceFilter> processFilters(String formFilters)
            throws InvalidParameterException {
        List<ContentSourceFilter> ret = new ArrayList<ContentSourceFilter>();
        if (!formFilters.isEmpty()) {
            // split on whitespace
            String[] filters = formFilters.split("\\s+");
            String flag = "";
            int order = 0;
            for (String filter : filters) {
                if (filter.isEmpty()) {
                    continue; // ignore whitespace at beginning of field
                }

                if (filter.startsWith("+") || filter.startsWith("-")) {
                    flag = filter.substring(0, 1);
                    filter = filter.substring(1);
                }
                else if (flag.equals("")) {
                    // the first filter must have a flag
                    throw new InvalidParameterException("repos.jsp.filters.error");
                }
                // else assume the flag has not changed

                String[] rpms = filter.split(",");
                for (String rpm : rpms) {
                    if (rpm.isEmpty()) {
                        continue; // ignore extra commas or whitespace around commas
                    }
                    ContentSourceFilter f = new ContentSourceFilter();
                    f.setFlag(flag);
                    f.setFilter(rpm);
                    f.setSortOrder(order);
                    ret.add(f);
                    order++;
                }
            }
        }
        return ret;
    }

    private ContentSource submit(HttpServletRequest request, ActionErrors errors,
            DynaActionForm form) {
        RequestContext context = new RequestContext(request);
        String url = form.getString(URL);
        String label = form.getString(LABEL);
        String type = form.getString(TYPE);
        String sfilters = form.getString(FILTERS);
        Org org = context.getCurrentUser().getOrg();
        BaseRepoCommand repoCmd = null;
        if (isCreateMode(request)) {
           repoCmd = new CreateRepoCommand(org);
        }
        else {
            repoCmd = new EditRepoCommand(context.getCurrentUser(),
                    context.getParamAsLong(SOURCEID));
        }

        repoCmd.setLabel(label);
        repoCmd.setUrl(url);
        repoCmd.setType(type);

        try {
            // Add SSL
            // FIXME: Allow to set multiple SSL sets per custom repo - new page?
            repoCmd.deleteAllSslSets();
            repoCmd.addSslSet(parseIdFromForm(form, SSL_CA_CERT),
                    parseIdFromForm(form, SSL_CLIENT_CERT),
                    parseIdFromForm(form, SSL_CLIENT_KEY));
            // Process filters
            List<ContentSourceFilter> lresult = processFilters(sfilters);

            // Store Repo
            repoCmd.store();

            // Store Filters
            Long repoid = repoCmd.getRepo().getId();
            ChannelFactory.clearContentSourceFilters(repoid);

            for (ContentSourceFilter filter : lresult) {
                filter.setSourceId(repoid);
                ChannelFactory.save(filter);
            }
        }
        catch (InvalidRepoUrlException e) {
            errors.add(ActionMessages.GLOBAL_MESSAGE, new ActionMessage(
                    "edit.channel.repo.repourlinuse", null));
        }
        catch (InvalidRepoLabelException e) {
            errors.add(ActionMessages.GLOBAL_MESSAGE, new ActionMessage(
                    "edit.channel.repo.repolabelinuse", repoCmd.getLabel()));
        }
        catch (InvalidCertificateException e) {
            errors.add(ActionMessages.GLOBAL_MESSAGE, new ActionMessage(
                    "edit.channel.repo.clientcertmissing"));
        }
        catch (InvalidRepoTypeException e) {
            errors.add(ActionMessages.GLOBAL_MESSAGE, new ActionMessage(
                    "edit.channel.repo.invalidrepotype", repoCmd.getType()));
        }
        catch (InvalidParameterException e) {
            errors.add(ActionMessages.GLOBAL_MESSAGE,
            new ActionMessage(e.getMessage()));
        }

        return repoCmd.getRepo();
    }

    private Long parseIdFromForm(DynaActionForm form, String stringName) {
        Long id = null;
        try {
            id = Long.parseLong(form.getString(stringName));
        }
        catch (NumberFormatException nfe) {
            // empty
        }
        return id;
    }

    private String getStringId(SslCryptoKey sck) {
        String strId = "";
        if (sck != null) {
            Long id = sck.getId();
            if (id != null) {
                strId = id.toString();
            }
        }
        return strId;
    }
}
