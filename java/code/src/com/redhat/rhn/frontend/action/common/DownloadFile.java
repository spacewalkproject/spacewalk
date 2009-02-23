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
package com.redhat.rhn.frontend.action.common;

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.common.util.download.ByteArrayStreamInfo;
import com.redhat.rhn.domain.rhnpackage.Package;
import com.redhat.rhn.domain.rhnpackage.PackageFactory;
import com.redhat.rhn.domain.rhnpackage.Patch;
import com.redhat.rhn.domain.rhnpackage.PatchSet;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.domain.user.UserFactory;
import com.redhat.rhn.manager.download.DownloadManager;
import com.redhat.rhn.manager.download.UnknownDownloadTypeException;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.actions.DownloadAction;

import java.io.File;
import java.util.Arrays;
import java.util.Calendar;
import java.util.Iterator;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * ChannelPackagesAction
 * @version $Rev$
 */
public class DownloadFile extends DownloadAction {
   
    

    
    private String type;
    private String hash;
    private long expire;
    private long userId;
    private long fileId;
    private String filename;
    
    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
            ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response) {
        
        String url = request.getParameter("url");
         
        List<String> split = Arrays.asList(url.split("/"));
        Iterator<String> it = split.iterator();
        type = getNextValue(it);
        hash = getNextValue(it);
        expire = Long.parseLong(getNextValue(it));
        userId = Long.parseLong(getNextValue(it));
        fileId = Long.parseLong(getNextValue(it));
        filename = getNextValue(it);
        
        
        Logger log = Logger.getLogger(DownloadFile.class);
        if (Calendar.getInstance().getTimeInMillis() > expire) {
            log.error("File download url has expired: " + url); 
            return mapping.findForward("error");
        }
        
        User user = UserFactory.lookupById(userId);
        
        
        if (!hash.equals(DownloadManager.getFileSHA1Token(fileId, 
                filename, user, expire, type))) {
            log.error("Invalid hash on file download url: " + url);
            return mapping.findForward("error");
        }
        
        try {
            super.execute(mapping, formIn, request, response);
        }
        catch (Exception e) {
            e.printStackTrace();
            log.error("Package retrieval error on file download url: " + url);
            return mapping.findForward("error");
        }
        
        return null;
    }

    @Override
    protected StreamInfo getStreamInfo(ActionMapping mapping, ActionForm form,
            HttpServletRequest request, HttpServletResponse response)
        throws Exception {
        
        String path = "";
        User user = UserFactory.lookupById(userId);
        if (type.equals(DownloadManager.DOWNLOAD_TYPE_PACKAGE)) {
            Package pack = PackageFactory.lookupByIdAndOrg(fileId, user.getOrg());
            path = Config.get().getString(Config.MOUNT_POINT) + "/" + pack.getPath();
            return getStreamForBinary(path);
        }
        else if (type.equals(DownloadManager.DOWNLOAD_TYPE_SOURCE)) {
            Package pack = PackageFactory.lookupByIdAndOrg(fileId, user.getOrg());
            path = Config.get().getString(Config.MOUNT_POINT) + "/" + pack.getSourcePath();
            return getStreamForBinary(path);
        }        
        else if (type.equals(DownloadManager.DOWNLOAD_TYPE_PATCH_README)) {
            Patch patch = (Patch) PackageFactory.lookupByIdAndOrg(fileId, user.getOrg());
            return getStreamForText(patch.getReadme().getBytes(1L, 
                    (int) patch.getReadme().length()));
            
        }     
        else if (type.equals(DownloadManager.DOWNLOAD_TYPE_PATCH_SET_README)) {
            PatchSet patch = (PatchSet) PackageFactory.lookupByIdAndOrg(fileId, 
                    user.getOrg());
            return getStreamForText(patch.getReadme().getBytes(1L, 
                    (int) patch.getReadme().length()));
        }         
        
        throw new UnknownDownloadTypeException("The specified download type " + type + 
                " is not currently supported");
        
    }
    
    private StreamInfo getStreamForText(byte[] text) {
        ByteArrayStreamInfo stream = new ByteArrayStreamInfo("text/plain", text);
        return stream;
    }
    
    private StreamInfo getStreamForBinary(String path) {
        File file = new File(path);
        FileStreamInfo stream = new FileStreamInfo("application/octet-stream", file);
        return stream;
    }
    

    private String getNextValue(Iterator<String> it) {
        while (it.hasNext()) {
            String next = it.next();
            if (!StringUtils.isEmpty(next)) {
                return next;
            }
        }
        return null;
    }
    
}
