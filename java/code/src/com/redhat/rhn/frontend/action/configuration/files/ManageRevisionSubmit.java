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
package com.redhat.rhn.frontend.action.configuration.files;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.hibernate.LookupException;
import com.redhat.rhn.common.security.PermissionException;
import com.redhat.rhn.common.validator.ValidatorResult;
import com.redhat.rhn.domain.config.ConfigFile;
import com.redhat.rhn.domain.config.ConfigRevision;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.rhnset.RhnSetElement;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.common.RhnSetAction;
import com.redhat.rhn.frontend.action.configuration.ConfigActionHelper;
import com.redhat.rhn.frontend.action.configuration.ConfigFileForm;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.struts.StrutsDelegate;
import com.redhat.rhn.manager.acl.AclManager;
import com.redhat.rhn.manager.configuration.ConfigurationManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;

import org.apache.commons.lang.StringEscapeUtils;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;
import org.apache.struts.upload.FormFile;

import java.io.IOException;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * ManageRevisionSubmit struts action.
 * @version $Rev: 101893 $
 */
public class ManageRevisionSubmit extends RhnSetAction {

    private static final int SUCCESS = 1;
    private static final int FAILURE = 0;
    private static final int FILE_DELETED = 2;

    /**
     * {@inheritDoc}
     */
    protected DataResult getDataResult(User userIn,
                                       ActionForm formIn,
                                       HttpServletRequest requestIn) {
        ConfigFile file = ConfigActionHelper.getFile(requestIn);
        return ConfigurationManager.getInstance().listRevisionsForFile(userIn, file, null);
    }

    /**
     * {@inheritDoc}
     */
    protected RhnSetDecl getSetDecl() {
        return RhnSetDecl.CONFIG_REVISIONS;
    }

    /**
     * {@inheritDoc}
     */
    protected void processMethodKeys(Map mapIn) {
        mapIn.put("manage.jsp.delete", "delete");
        mapIn.put("manage.jsp.uploadbutton", "upload");
    }

    /**
     * {@inheritDoc}
     */
    protected void processParamMap(ActionForm formIn,
                                   HttpServletRequest requestIn,
                                   Map paramsIn) {
        RequestContext requestContext = new RequestContext(requestIn);

        Long fileId = requestContext.getRequiredParam(ConfigActionHelper.FILE_ID);
        paramsIn.put(ConfigActionHelper.FILE_ID, fileId);
    }

    /**
     * A passthrough for deleting revisions so that affected config sets are also
     * cleared
     * @param mapping struts ActionMapping
     * @param form struts ActionForm
     * @param request HttpServletRequest
     * @param response HttpServletResponse
     * @return A forward to the Manage Revisions page.
     */
    public ActionForward delete(ActionMapping mapping, ActionForm form,
            HttpServletRequest request, HttpServletResponse response) {
        RequestContext requestContext = new RequestContext(request);
        checkAcl(requestContext);

        RhnSet set = updateSet(request);

        //if they chose no config revisions, return to the same page with a message
        if (set.isEmpty()) {
            ActionMessages msg = new ActionMessages();
            msg.add(ActionMessages.GLOBAL_MESSAGE,
                    new ActionMessage("emptyselectionerror"));
            getStrutsDelegate().saveMessages(request, msg);

            Map params = makeParamMap(form, request);
            return getStrutsDelegate().forwardParams(
                    mapping.findForward(RhnHelper.DEFAULT_FORWARD), params);
        }

        ActionForward forward = deleteRevisions(request, form, mapping, set);

        //now some of the sets may be invalid, so delete them.
        ConfigActionHelper.clearRhnSets(requestContext.getLoggedInUser());

        return forward;
    }

    /**
     * Accepts an uploaded file as the new revision for the current config file.
     * @param mapping struts action mapping.
     * @param form struts action form
     * @param request Http Request
     * @param response Http Response
     * @return The ActionForward to the next page.
     * @throws IOException If the file has trouble.
     */
    public ActionForward upload(ActionMapping mapping, ActionForm form,
            HttpServletRequest request, HttpServletResponse response) throws IOException {

        RequestContext requestContext = new RequestContext(request);
        checkAcl(requestContext);

        Long cfid = requestContext.getRequiredParam(ConfigActionHelper.FILE_ID);
        User user = requestContext.getLoggedInUser();

        //get a connection to the file stream
        ConfigFileForm cff = (ConfigFileForm)form;
        ValidatorResult result = cff.validateUpload(request);
        if (!result.isEmpty()) {
            getStrutsDelegate().saveMessages(request, result);
            return getStrutsDelegate().forwardParam(mapping.findForward("default"),
                    ConfigActionHelper.FILE_ID, cfid.toString());
        }

        //The file is there and small enough, make a new revision!
        FormFile file = (FormFile)cff.get(ConfigFileForm.REV_UPLOAD);
        ConfigRevision rev = ConfigurationManager.getInstance()
                .createNewRevision(user, file.getInputStream(),
                                   cfid, new Long(file.getFileSize()));

        //create the success message
        createUploadSuccessMessage(rev, request, cfid);
        return getStrutsDelegate().forwardParam(mapping.findForward("default"),
                ConfigActionHelper.FILE_ID, cfid.toString());
    }

    private void createUploadSuccessMessage(ConfigRevision revision,
            HttpServletRequest request, Long cfid) {
        ActionMessages msg = new ActionMessages();
        Object[] args = new Object[2];
        StringBuffer buffy = new StringBuffer();
        buffy.append("/rhn/configuration/file/FileDetails.do?" +
                ConfigActionHelper.FILE_ID + "=");
        buffy.append(cfid);
        buffy.append("&amp;" + ConfigActionHelper.REVISION_ID + "=");
        buffy.append(revision.getId());
        args[0] = StringEscapeUtils.escapeHtml(buffy.toString());
        args[1] = revision.getRevision().toString();

        msg.add(ActionMessages.GLOBAL_MESSAGE,
                new ActionMessage("manage.jsp.success", args));
        getStrutsDelegate().saveMessages(request, msg);
    }

    private ActionForward deleteRevisions(HttpServletRequest request,
            ActionForm form, ActionMapping mapping, RhnSet set) {
        //We need to lookup the file before deleting revisions so that
        //if it gets deleted, we can still go to the right config channel
        //and refer to the correct file path.
        ConfigFile file = ConfigActionHelper.getFile(request);
        User user = new RequestContext(request).getLoggedInUser();

        Map params = makeParamMap(form, request);
        StrutsDelegate strutsDelegate = getStrutsDelegate();

        int successCount = 0;
        int failureCount = 0;
        boolean fileDeleted = false;
        for (Iterator i = set.getElements().iterator(); i.hasNext();) {
            RhnSetElement element = (RhnSetElement) i.next();
            //Delete individual revisions
            int code = deleteRevision(element, user);
            switch (code) {
            case SUCCESS:
                successCount++;
                break;
            case FAILURE:
                failureCount++;
                break;
            case FILE_DELETED:
                fileDeleted = true;
                break;
            default:
                //This should never happen
                break;
            }
        }

        //If the file was deleted, we can't go to the file details page
        if (fileDeleted) {
            getStrutsDelegate().saveMessage("deleterev.jsp.deletedfile",
                    new String[] {file.getConfigFileName().getPath()}, request);
            return getStrutsDelegate().forwardParam(mapping.findForward("deletedfile"),
                    "ccid", file.getConfigChannel().getId().toString());
        }
        else {
            //create messages
            ActionMessages msg = new ActionMessages();
            addIntMessage(successCount, "config_revisions.success", msg);
            addIntMessage(failureCount, "config_revisions.failure", msg);
            //save messages
            strutsDelegate.saveMessages(request, msg);
            //go to the next page
            return strutsDelegate.forwardParams(
                    mapping.findForward(RhnHelper.DEFAULT_FORWARD), params);
        }
    }

    private void addIntMessage(int number, String key, ActionMessages msgs) {
        if (number > 0) {
            if (number == 1) {
                key = key + ".singular";
            }
            ActionMessage message = new ActionMessage(key, String.valueOf(number));
            msgs.add(ActionMessages.GLOBAL_MESSAGE, message);
        }
    }

    /**
     * Attempts to delete the config revision with an id equal to the first element of
     * the RhnSetElement.  Uses the userIn to check for permission errors.
     * @param elementIn The RhnSetElement that contains the soon to be deleted config
     *                  revision's id.
     * @param userIn The user requesting to delete config revisions.
     * @return Whether or not the current revision was deleted successfully.
     */
    public int deleteRevision(RhnSetElement elementIn, User userIn) {
        ConfigRevision revision;
        try {
            revision = ConfigurationManager.getInstance()
                .lookupConfigRevision(userIn, elementIn.getElement());
        }
        //couldn't find it, skip over this element.
        catch (LookupException e) {
            return FAILURE;
        }

        //try to delete the revision
        try {
            boolean fileDeleted = ConfigurationManager.getInstance()
                    .deleteConfigRevision(userIn, revision);
            //This was the last revision, so the file was deleted too.
            if (fileDeleted) {
                return FILE_DELETED;
            }
        }
        catch (IllegalArgumentException e) {
            //Log the error and go on with life.
            log.error("IllegalArgumentException deleting config revision " +
                    revision.getId(), e);
            return FAILURE;
        }
        //yay, it is deleted.
        return SUCCESS;
    }

    private void checkAcl(RequestContext requestContext) {
        //Throws an exception if the user does not have permission to edit the channel.
        User user = requestContext.getLoggedInUser();
        ConfigFile configFile = ConfigActionHelper.getFile(requestContext.getRequest());
        boolean acl = AclManager.hasAcl("config_channel_editable(" +
                configFile.getConfigChannel().getId() + ")", user,
                "com.redhat.rhn.common.security.acl.ConfigAclHandler",
                new HashMap());
        if (!acl) {
            throw new PermissionException("Can not edit Config Channel.");
        }
    }
}
