/**
 * Copyright (c) 2008 Red Hat, Inc.
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
package com.redhat.rhn.frontend.action.rhnpackage;

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.util.MD5CryptException;
import com.redhat.rhn.common.util.StringUtil;
import com.redhat.rhn.domain.rhnpackage.Package;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.SetLabels;
import com.redhat.rhn.frontend.dto.PackageListItem;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.StrutsDelegate;
import com.redhat.rhn.frontend.struts.StrutsDelegateFactory;
import com.redhat.rhn.manager.rhnpackage.PackageManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.actions.LookupDispatchAction;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * DownloadConfirmAction
 * @version $Rev$
 */
public class DownloadConfirmAction extends LookupDispatchAction {
    
    private StrutsDelegate getStrutsDelegate() {
        StrutsDelegateFactory factory = StrutsDelegateFactory.getInstance();
        return factory.getStrutsDelegate();
    }
    
    /**
     * Sends a redirect to a cgi script for downloading
     * with specific download security form vars. 
     * @param mapping ActionMapping
     * @param formIn ActionForm
     * @param request HttpServletRequest
     * @param response HttpServletResponse
     * @return null because we are sending a redirect
     */
    public ActionForward download(ActionMapping mapping,
                                  ActionForm formIn,
                                  HttpServletRequest request,
                                  HttpServletResponse response) {
        
        RequestContext requestContext = new RequestContext(request);
        
        User user = requestContext.getLoggedInUser();
        Long sid = requestContext.getRequiredParam("sid");
        DataResult packages = PackageManager.downloadableInSet(SetLabels.
                PACKAGE_UPGRADE_SET, user, sid, null);
        
        Config c = Config.get();
        
        StringBuffer uri = new StringBuffer();
        String downloadUrl = c.getString("download_url",
                "/cgi-bin/download.pl/rhn-packages.tar");
        uri.append(downloadUrl);
        uri.append("?");
        String prefix = c.getString("web.mount_point");

        /*
         * Now we start creating parameters to send in the request.
         * There are five steps
         * Step 1:
         *   We get all of the filenames along with the appropriate mount
         *   Directory, shove them together into a string, concatenated
         *   with colons and md5sum it.
         * Step 2:
         *   We get some secret stuff, add in the unix time, bring back the
         *   md5sum from the previous step, concatenate all of them together
         *   and md5sum that result.
         * Step 3:
         *   We make a token string by putting together the unix time, the
         *   md5sum from the first step, and the md5sum from the second step.
         * Step 4:
         *   We add the token string to the uri along with the names of all the
         *   files.  There are two filename parameters here, filename_full and
         *   filename.  filename_full used to be the complete list of all the
         *   files possibly downloadable.  filename is all of the files intended
         *   for download.  I saw no reason to have filename_full, but as it is
         *   expected, send the same list for both.
         * Step 5:
         *   We send the redirect in the response and return null for this method.
         */
        
        //Step 1:
        List sortMe = new ArrayList(); 
        Iterator i = packages.iterator();
        StringBuffer temp;
        //Add each complete filename to a list, sort the list, then md5sum it
        while (i.hasNext()) {
            PackageListItem next = (PackageListItem)i.next();
            Package p = PackageManager.lookupByIdAndUser(new Long(next.getId()
                    .longValue()), user);
            temp = new StringBuffer("");
            temp.append(prefix);
            temp.append(p.getPath());
            sortMe.add(temp.toString());
        }
        //sort the list of filenames
        Collections.sort(sortMe);
        //"fn:fn:fn:fn" where fn=filename
        String compMD5 = md5sum(StringUtil.join(":", sortMe));
        
        //Step 2:
        String unixTime = "" + (System.currentTimeMillis() / 1000);
        temp = new StringBuffer("");
        temp.append(c.getString("web.session_swap_secret_1"));
        temp.append(":");
        temp.append(c.getString("web.session_swap_secret_2"));
        temp.append(":");
        temp.append(unixTime);
        temp.append(":");
        temp.append(compMD5);
        temp.append(":");
        temp.append(c.getString("web.session_swap_secret_3"));
        temp.append(":");
        temp.append(c.getString("web.session_swap_secret_4"));
        String secretMD5 = md5sum(temp.toString());
        
        //Step 3:
        temp = new StringBuffer(unixTime);
        temp.append(":");
        temp.append(compMD5);
        temp.append("x");
        temp.append(secretMD5);
        String token = temp.toString();
        
        //Step 4:
        uri.append("token=");
        uri.append(token);
        i = packages.iterator();
        while (i.hasNext()) {
            PackageListItem next = (PackageListItem)i.next();
            Package p = PackageManager.lookupByIdAndUser(new Long(next.getId()
                    .longValue()), user);
            uri.append("&filename=");
            uri.append(prefix);
            uri.append(p.getPath());
            uri.append("&filename_full=");
            uri.append(prefix);
            uri.append(p.getPath());
        }
        
        //Step 5:
        try {
            response.sendRedirect(uri.toString());
        } 
        catch (IOException exc) {
            log.error("IOException when trying to redirect to " +
                    uri.toString(), exc);
        }
        
        return null;
    }
    
    private String hex(byte[] array) {
        StringBuffer sb = new StringBuffer();
        for (int i = 0; i < array.length; ++i) {
            sb.append(Integer.toHexString((array[i] & 0xFF) | 0x100).substring(1, 3));
        }
        return sb.toString();
    }
    
    private String md5sum(String message) { 
        try { 
            MessageDigest md = MessageDigest.getInstance("MD5"); 
            return hex(md.digest(message.getBytes("CP1252"))); 
        } 
        catch (NoSuchAlgorithmException e) {
            throw new MD5CryptException("Problem getting MD5 message digest " +
            "(NoSuchAlgorithm Exception).");
        } 
        catch (UnsupportedEncodingException e) {
            throw new MD5CryptException("Problem getting MD5 message " +
            "(UnsupportedEncodingException).");
        } 
    }
    
    /**
     * Default action to execute if dispatch parameter is missing
     * or isn't in map
     * @param mapping ActionMapping
     * @param formIn ActionForm
     * @param request ServletRequest
     * @param response ServletResponse
     * @return The ActionForward to go to next.
     */
    public ActionForward unspecified(ActionMapping mapping,
                                     ActionForm formIn,
                                     HttpServletRequest request,
                                     HttpServletResponse response) {
        Map params = makeParamMap(request);
        return getStrutsDelegate().forwardParams(mapping.findForward("default"), params);
    }
    
    /**
     * Makes a parameter map containing request params that need to
     * be forwarded on to the success mapping.
     * @param request HttpServletRequest containing request vars
     * @return Returns Map of parameters
     */
    protected Map makeParamMap(HttpServletRequest request) {
        RequestContext requestContext = new RequestContext(request);
        
        Map params = requestContext.makeParamMapWithPagination();
        Long sid = requestContext.getRequiredParam("sid");
        
        if (sid != null) {
            params.put("sid", sid);
        }
        
        return params;
    }
    
    /**
     * {@inheritDoc}
     */
    protected Map getKeyMethodMap() {
        HashMap map = new HashMap();
        map.put("download.jsp.download", "download");
        return map;
    }

}
