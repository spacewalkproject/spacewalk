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
package com.redhat.rhn.frontend.action.configuration.channel;

import com.redhat.rhn.domain.config.ConfigChannel;
import com.redhat.rhn.domain.config.ConfigFile;
import com.redhat.rhn.domain.config.ConfigRevision;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.rhnset.RhnSetElement;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.configuration.ConfigActionHelper;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.struts.RhnListSetHelper;
import com.redhat.rhn.frontend.taglibs.list.ListTagHelper;
import com.redhat.rhn.manager.configuration.ConfigurationManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;

import java.util.Iterator;
import java.util.List;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * BaseCopyToAction
 *
 * Copying, whether to local or global channels, looks pretty much the same.
 * This class handles all the common code
 * @version $Rev$
 */
public abstract class BaseCopyToAction extends RhnAction {

    /**
     * On dispatch, do the copy - otherwise, we're just displaying/handling set updates
     * {@inheritDoc}
     */
    public ActionForward execute(ActionMapping mapping,
            ActionForm form,
            HttpServletRequest req,
            HttpServletResponse resp) throws Exception {

        RequestContext ctx = new RequestContext(req);
        User user = ctx.getLoggedInUser();
        //if its not submitted
        // ==> this is the first visit to this page
        // clear the 'dirty set'
        if (req.getParameter(SUBMITTED) == null) {
            RhnSet set = getSetDecl().get(user);
            set.clear();
            RhnSetManager.store(set);
        }

        // If the page is dispatched - do the copy and report back
        if (req.getParameter(RequestContext.DISPATCH) != null) {

            return doCopy(mapping, req, user);
        }
        else { // not dispatched
            return doDisplay(mapping, req, user);
        }
    }

    protected ActionForward doDisplay(ActionMapping mapping,
                                            HttpServletRequest req,
                                              User user) {
        RhnListSetHelper helper = new RhnListSetHelper(req);
        setupRequest(req);
        List result = getData(req);

        if (ListTagHelper.getListAction(getJspLabel(), req) != null) {
            helper.execute(getSetDecl().get(user), getJspLabel(), result);
        }

        req.setAttribute("pageList", result);


        RhnSet destSet = getSetDecl().lookup(user);
        if (destSet != null && !destSet.isEmpty()) {
            helper.syncSelections(destSet, result);
            ListTagHelper.setSelectedAmount(getJspLabel(), destSet.size(), req);
        }
        return mapping.findForward("default");
    }

    protected void setupRequest(HttpServletRequest req) {
        RequestContext ctx = new RequestContext(req);
        ConfigChannel cc = ConfigActionHelper.getChannel(req);
        ConfigActionHelper.setupRequestAttributes(ctx, cc);
        req.setAttribute("parentUrl",  req.getRequestURI() + "?ccid=" + cc.getId());
    }

    protected ActionForward doCopy(ActionMapping mapping,
                            HttpServletRequest req, User user) {
        RhnListSetHelper helper = new RhnListSetHelper(req);
        ConfigurationManager cm = ConfigurationManager.getInstance();
        RhnSet set = getSetDecl().get(user);
        helper.updateSet(set, getJspLabel());
        if (set.isEmpty()) {
            RhnHelper.handleEmptySelection(req);
            return doDisplay(mapping, req, user);
        }
        Set destSet = set.getElements();
        RhnSet fileSet = getFileSetDecl().lookup(user);

        if (fileSet == null || fileSet.isEmpty()) {
            RhnHelper.handleEmptySelection(req);
            return doDisplay(mapping, req, user);
        }
        Set files = fileSet.getElements();

        // for each destination
        //   find the dest-channel
        //   for each file
        //      cm.copyConfigFile(file.latest.revision, dest-chan, usr);
        //
        for (Iterator destItr = destSet.iterator(); destItr.hasNext();) {
            Long destid = ((RhnSetElement)destItr.next()).getElement();
            ConfigChannel cc = getDestinationFromId(destid);
            for (Iterator fileItr = files.iterator(); fileItr.hasNext();) {
                Long fileId = ((RhnSetElement)fileItr.next()).getElement();
                ConfigFile cf = cm.lookupConfigFile(user, fileId);
                ConfigRevision cr = cf.getLatestConfigRevision();
                cm.copyConfigFile(cr, cc, user);
            }
        }

        ActionMessages msg = new ActionMessages();
        Object[] args = new Object[2];
        args[0] = "" + files.size();
        args[1] = "" + destSet.size();
        msg.add(ActionMessages.GLOBAL_MESSAGE,
                new ActionMessage(getSuccessKey(files.size(), destSet.size()), args));
        saveMessages(req, msg);

        getFileSetDecl().clear(user);
        getSetDecl().clear(user);
        return mapping.findForward("success");
    }

    /**
     * returns the set that stores the original config files
     * that are to be copied.
     * @return RhnSetDecl of the appropriate Config Files
     */
    protected RhnSetDecl getFileSetDecl() {
        return RhnSetDecl.CONFIG_FILES;
    }


    /**
     * What set should we be using?
     * @return RhnSetDecl of the appropriate CONFIG_CHANNEL* set
     */
    public abstract RhnSetDecl getSetDecl();

    /**
     * What data set are we showing?
     * @param req incoming HttpServletRequest
     * @return List of Dtos to drive the JSP list
     */
    public abstract List getData(HttpServletRequest req);

    /**
     * What does the JSP expect the list-set to be called?
     * @return label used in the JSP
     */
    public abstract String getJspLabel();

    /**
     * When we tell the user things worked, what's the bean-key?
     * @param numFiles TODO
     * @param numChannels TODO
     * @return key into I18N system
     */
    public abstract String getSuccessKey(int numFiles, int numChannels);

    /**
     * Where are we copying to?
     * Based on an Id, return a channel - what the "id" means is determined by the subclass,
     * which knows what getData().get(n).getId() means...
     * @param destId ID of destination-entity
     * @return config-channel files should be copied into
     */
    public abstract ConfigChannel getDestinationFromId(Long destId);
}
