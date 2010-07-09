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
package com.redhat.rhn.frontend.action.channel;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.ChannelFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.ISOImage;
import com.redhat.rhn.frontend.dto.ISOSet;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnUnpagedListAction;
import com.redhat.rhn.manager.channel.ChannelManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * ISODownloadAction - handle events related to choosing an ISO to download
 * @version $Rev$
 */
public class ISODownloadAction extends RhnUnpagedListAction {

    public static final String  CHANNEL_ID           = "cid";
    public static final String  IMAGE_TYPE           = "iso";
    public static final String  CHANNEL_NAME         = "channel";
    public static final String  LATEST               = "latest";
    public static final String  SET_LIST             = "setList";

    public static final String  BASE_CHANNEL_CONTENT = "baseContent";
    public static final String  INCR_CHANNEL_CONTENT = "incrContent";

    private static final String CHANNEL_DUMP_TYPE    = "channel-xml-dump";
    private static final String BASE                 = "(Base";
    private static final String INCR                 = "(Incremental";

    /**
     * {@inheritDoc}
     */
    public ActionForward execute(ActionMapping mapping, ActionForm form,
            HttpServletRequest request, HttpServletResponse response) {

        RequestContext requestContext = new RequestContext(request);
        User user = requestContext.getLoggedInUser();
        DataResult dr = null;
        Long cid = requestContext.getParamAsLong(CHANNEL_ID);
        Channel ch = ChannelFactory.lookupByIdAndUser(cid, user);
        request.setAttribute(CHANNEL_NAME, ch);

        if (ch != null) {
            dr = ChannelManager.listDownloadImages(user, ch.getLabel(), IMAGE_TYPE, null,
                    false);
            List sets = findISOSets(request, user, dr, false);
            request.setAttribute(SET_LIST, sets);

            dr = ChannelManager.listDownloadImages(user, ch.getLabel(), CHANNEL_DUMP_TYPE,
                    null, true);
            if (dr != null && dr.size() > 0) {
                sets = findISOSets(request, user, dr, true);
                separateContent(request, sets);
            }
        }
        return mapping.findForward("default");
    }

    /*
     * Breaks content-ISOs into Base and Incremental, by category
     */
    protected void separateContent(HttpServletRequest request, List sets) {
        List bases = new ArrayList();
        List incrementals = new ArrayList();
        for (Iterator itr = sets.iterator(); itr.hasNext();) {
            ISOSet aSet = (ISOSet) itr.next();
            if (aSet.getCategory().indexOf(BASE) >= 0) {
                bases.add(aSet);
            }
            else if (aSet.getCategory().indexOf(INCR) >= 0) {
                incrementals.add(aSet);
            }
        }
        request.setAttribute(BASE_CHANNEL_CONTENT, bases);
        request.setAttribute(INCR_CHANNEL_CONTENT, incrementals);
    }

    /*
     * Breaks download-ISOs into latest, binary, and source downloads
     */
    protected List findISOSets(HttpServletRequest request, User user, DataResult dr,
            boolean isSat) {
        List prevSets = new ArrayList(); // ISOSet
        Map categories = new HashMap(); // category, ISOSet

        if (dr != null && dr.size() > 0) {
            int startingImg = 0;
            // Set up first/latest set, if we're not satellite-content
            // (For content, we don't make this distinction, so skip this step)
            if (!isSat) {
                ISOImage latest = (ISOImage) dr.get(startingImg++);
                latest.createDownloadUrl(user);
                ISOSet latestSet = new ISOSet();
                latestSet.add(latest);
                categories.put(latest.getCategory(), latestSet);
                request.setAttribute(LATEST, latestSet);
            }

            // Handle all remaining images
            for (int i = startingImg; i < dr.getTotalSize(); i++) {
                ISOImage img = (ISOImage) dr.get(i);
                img.createDownloadUrl(user);
                ISOSet theSet = (ISOSet) categories.get(img.getCategory());
                if (theSet == null) {
                    theSet = new ISOSet();
                    prevSets.add(theSet);
                    categories.put(img.getCategory(), theSet);
                }
                theSet.add(img);
            }
        }
        return prevSets;
    }
}
