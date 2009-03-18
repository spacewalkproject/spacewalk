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
import com.redhat.rhn.common.security.SessionSwap;
import com.redhat.rhn.common.util.FileUtils;
import com.redhat.rhn.common.util.MD5Sum;
import com.redhat.rhn.common.util.download.ByteArrayStreamInfo;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.ChannelFactory;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.kickstart.KickstartSession;
import com.redhat.rhn.domain.kickstart.KickstartSessionState;
import com.redhat.rhn.domain.kickstart.KickstartableTree;
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
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Arrays;
import java.util.Calendar;
import java.util.Date;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.TimeZone;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * ChannelPackagesAction
 * @version $Rev$
 */
public class DownloadFile extends DownloadAction {
   

    private static Logger log = Logger.getLogger(DownloadFile.class);

    private static final String PARAMS = "params";
    private static final String TYPE = "type";
    private static final String HASH = "hash";
    private static final String EXPIRE = "expire";
    private static final String USERID = "userid";
    private static final String FILEID = "fileid";
    private static final String FILENAME = "filename";
    private static final String TREE = "tree";
    private static final String PATH = "path";
    private static final String SESSION = "session";
    
    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
            ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response) throws Exception {
        
        String url = request.getParameter("url");
        if (log.isDebugEnabled()) {
            log.debug("url : " + url);
        }
        if (url.startsWith("/ks/dist")) {
            if (log.isDebugEnabled()) {
                log.debug("URL is ks dist..");
            }
            ActionForward error = handleKickstartDownload(request, response, 
                    url, mapping);
            if (log.isDebugEnabled()) {
                log.debug("Done handling ks download");
            }
            if (error != null) {
                if (log.isDebugEnabled()) {
                    log.debug("returning null");
                }
                return null;
            }
        }
        else {
            ActionForward error = handleUserDownload(request, url, mapping);
            if (error != null) { 
                return error;
            }
        }
        try {
            if (log.isDebugEnabled()) {
                log.debug("Calling super.execute");
            }
            super.execute(mapping, formIn, request, response);
        }
        catch (Exception e) {
            e.printStackTrace();
            log.error("Package retrieval error on file download url: " + url);
            return mapping.findForward("error");
        }
        
        return null;
    }
    
    private ActionForward handleKickstartDownload(HttpServletRequest request, 
            HttpServletResponse response, String url, 
            ActionMapping mapping) throws IOException {
        // /ks/dist/f9-x86_64-distro/images/boot.iso
        
        // we accept two URL forms, for cases when there is a pre-determined
        // session available:
        // /ks/dist/tree-label/path/to/file.rpm
        // /ks/dist/session/HEX/tree-label/path/to/file.rpm

        Map params = new HashMap();
        KickstartSession ksession = null;
        KickstartSessionState newState = null;
        if (log.isDebugEnabled()) {
            log.debug("URL : " + url);
        }
        String[] split = StringUtils.split(url, '/');
        String treeLabel = split[2];
        String path = "";
        for (int i = 3; i < split.length; i++) {
            path = path + "/" + split[i];
        }
        if (treeLabel.equals("session")) {
            if (log.isDebugEnabled()) {
                log.debug("using session: " + treeLabel);
            }
            // ($session_id, $tree_label, $path) = split m(/), $path, 3;
            String sessionId = split[3];
            treeLabel = split[4];
            path = "";
            for (int i = 5; i < split.length; i++) {
                path = path + "/" + split[i];
            }
            sessionId = SessionSwap.extractData(sessionId)[0];
            if (log.isDebugEnabled()) {
                log.debug("SessionId: " + sessionId);
            }
            ksession = KickstartFactory.
                lookupKickstartSessionById(new Long(sessionId));
            if (log.isDebugEnabled()) {
                log.debug("looked up ksession: " + ksession);
            }
        }
        if (log.isDebugEnabled()) {
            log.debug("computed path to just the file: " + path);
            log.debug("Tree label to lookup: " + treeLabel);
        }
        KickstartableTree tree = KickstartFactory.lookupKickstartTreeByLabel(treeLabel);
        if (tree == null) {
            log.error("Tree not found.");
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return mapping.findForward("error");
        }
        
        params.put(TYPE, DownloadManager.DOWNLOAD_TYPE_KICKSTART);
        params.put(TREE, tree);
        params.put(FILENAME, path);
        if (ksession != null) {
            params.put(SESSION, ksession);
        }
        request.setAttribute(PARAMS, params);
        return null;
    }
    
    
    private ActionForward handleUserDownload(HttpServletRequest request, String url, 
            ActionMapping mapping) {
        List<String> split = Arrays.asList(url.split("/"));
        Iterator<String> it = split.iterator();
        Map params = new HashMap();
        
        String type = getNextValue(it);
        String hash = getNextValue(it);
        Long expire = new Long(getNextValue(it));
        Long userId = new Long(getNextValue(it));
        Long fileId = new Long(getNextValue(it));
        String filename = getNextValue(it);
        
        params.put(TYPE, type);
        params.put(HASH, hash);
        params.put(EXPIRE, expire);
        params.put(USERID, userId);
        params.put(FILEID, fileId);
        params.put(FILENAME, filename);
        request.setAttribute(PARAMS, params);
        
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
        
        return null;
    }

    @Override
    protected StreamInfo getStreamInfo(ActionMapping mapping, ActionForm form,
            HttpServletRequest request, HttpServletResponse response)
        throws Exception {
        
        String path = "";
        Map params = (Map) request.getAttribute(PARAMS);
        String type = (String) params.get(TYPE);
        if (type.equals(DownloadManager.DOWNLOAD_TYPE_KICKSTART)) {
            path = (String) params.get(FILENAME);
            if (log.isDebugEnabled()) {
                log.debug("getStreamInfo KICKSTART type, path: " + path);
            }
            String diskPath;
            String kickstartMount = Config.get().getString(Config.MOUNT_POINT);
            String fileName;
            KickstartSession ksession = (KickstartSession) params.get(SESSION);
            KickstartSessionState newState = null;
            KickstartableTree tree = (KickstartableTree) params.get(TREE);
            Package rpmPackage;
            if (tree.getBasePath().indexOf(kickstartMount) == 0) {
                log.debug("Trimming mount because tree is" +
                    " explicitly rooted to the mount point");
                kickstartMount = "";
            }
            // If the tree is rooted somewhere other than 
            // /var/satellite then no need to prepend it.
            if (tree.getBasePath().startsWith("/")) {
                log.debug("Tree isnt rooted at /var/satellite, lets just use basepath");
                kickstartMount = "";
            }

            // Searching for RPM
            if (path.endsWith(".rpm")) {
                String[] split = StringUtils.split(path, '/');
                fileName = split[split.length - 1];
                if (log.isDebugEnabled()) {
                    log.debug("RPM filename: " + fileName);
                }
                Channel channel = tree.getChannel();
                rpmPackage = ChannelFactory.lookupPackageByFilename(channel, fileName); 
                if (rpmPackage != null) {
                    diskPath = Config.get().getString(Config.MOUNT_POINT) + "/" + 
                        rpmPackage.getPath();
                    if (log.isDebugEnabled()) {
                        log.debug("found package :: diskPath path: " + diskPath);
                    }
                }
                else {
                    if (log.isDebugEnabled()) {
                        log.error("RPM not found: " + fileName + 
                            " in channel: " + channel.getLabel());
                    }
                    response.sendError(HttpServletResponse.SC_NOT_FOUND);
                    return getStreamForText("".getBytes());
                }
                newState = KickstartFactory.
                    lookupSessionStateByLabel(KickstartSessionState.IN_PROGRESS);
            }
            // Else it is just a file in the ks tree
            // check for dir pings, virt manager or install, bz #345721
            else {
                // my $dp = File::Spec->catfile($kickstart_mount, $tree->base_path, $path);
                diskPath = kickstartMount + "/" + tree.getBasePath() + path;
                if (log.isDebugEnabled()) {
                    log.debug("DirCheck path: " + diskPath);
                }
                File actualFile = new File(diskPath);
                if (actualFile.exists() && actualFile.isDirectory()) {
                    log.debug("Directory hit.  just return 200");
                    response.setContentLength(0);
                    response.setStatus(HttpServletResponse.SC_OK);
                    return getStreamForText("".getBytes());
                }
                else if (actualFile.exists()) {
                    log.debug("Looks like it is an actual file and it exists.");
                    KickstartFactory.
                        lookupSessionStateByLabel(KickstartSessionState.STARTED);
                    
                }
                else {
                    log.error(diskPath + " Not Found .. 404!");
                    response.sendError(HttpServletResponse.SC_NOT_FOUND);
                    return getStreamForText("".getBytes());
                }
                
            }
            
            // Update kickstart session
            if (ksession != null) {
                ksession.setState(newState);
                if (ksession.getPackageFetchCount() == null) {
                    ksession.setPackageFetchCount(new Long(0));
                }
                if (ksession.getState().getLabel().equals(
                        KickstartSessionState.IN_PROGRESS)) {
                    ksession.setPackageFetchCount(
                            ksession.getPackageFetchCount().longValue() + 1);
                    ksession.setLastFileRequest(path);
                }
                KickstartFactory.saveKickstartSession(ksession);
            }
            log.debug("Final path before returning getStreamForBinary(): " + diskPath);
            
            Enumeration e = request.getHeaderNames();
            while (e.hasMoreElements()) {
                String name = (String) e.nextElement();
                log.debug("header: [" + name + "]: " + request.getHeader(name)); 
            }
            if (request.getMethod().equals("HEAD")) {
                log.debug("Method is HEAD .. serving checksum");
                return manualServeChecksum(response, diskPath);
            }
            
            else if (request.getHeader("Range") != null) {
                log.debug("range detected.  serving chunk of file");
                String range = request.getHeader("Range");
                return manualServeByteRange(request, response, diskPath, range);
            }
            log.debug("returning getStreamForBinary");
            return getStreamForBinary(diskPath);
        }
        else {
            Long fileId = (Long) params.get(FILEID);
            Long userid = (Long) params.get(USERID);
            User user = UserFactory.lookupById(userid);
            if (type.equals(DownloadManager.DOWNLOAD_TYPE_PACKAGE)) {
                Package pack = PackageFactory.lookupByIdAndOrg(fileId, user.getOrg());
                path = Config.get().getString(Config.MOUNT_POINT) + "/" + pack.getPath();
                return getStreamForBinary(path);
            }
            else if (type.equals(DownloadManager.DOWNLOAD_TYPE_SOURCE)) {
                Package pack = PackageFactory.lookupByIdAndOrg(fileId, user.getOrg());
                path = Config.get().getString(Config.MOUNT_POINT) + "/" + 
                    pack.getSourcePath();
                return getStreamForBinary(path);
            }        
            else if (type.equals(DownloadManager.DOWNLOAD_TYPE_PATCH_README)) {
                Patch patch = (Patch) PackageFactory.lookupByIdAndOrg(fileId, 
                        user.getOrg());
                return getStreamForText(patch.getReadme().getBytes(1L, 
                        (int) patch.getReadme().length()));
                
            }     
            else if (type.equals(DownloadManager.DOWNLOAD_TYPE_PATCH_SET_README)) {
                PatchSet patch = (PatchSet) PackageFactory.lookupByIdAndOrg(fileId, 
                        user.getOrg());
                return getStreamForText(patch.getReadme().getBytes(1L, 
                        (int) patch.getReadme().length()));
            }         
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
    
    // Ported from perl - needed for proxy support
    private StreamInfo manualServeChecksum(HttpServletResponse response, 
            String diskPath) throws IOException {

        response.setContentType("application/octet-stream");

        // Obtain the checksum for the file in question and stick it in the 
        // outgoing HTTP headers under "X-RHN-Checksum".
        File f = new File(diskPath);
        if (!f.exists()) {
            log.error("manualServeChecksum :: File not found: " + diskPath);
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return getStreamForText("".getBytes());
        }
        String checksum = MD5Sum.getFileMD5Sum(f);
        // Create some headers.
        response.setContentLength(0);
        response.addHeader("X-RHN-Checksum", checksum);
        response.setStatus(HttpServletResponse.SC_OK);
        return getStreamForText("".getBytes());
    }
    
    // Ported from perl - needed for yum's requests for byte ranges
    private StreamInfo manualServeByteRange(HttpServletRequest request, 
            HttpServletResponse response,
            String diskPath, String range) {

        // bytes=440-25183
        String[] bytesheader = StringUtils.split(range, "=");
        String[] ranges = StringUtils.split(bytesheader[1], "-");
        long start = Long.valueOf(ranges[0]).longValue();
        long end = Long.valueOf(ranges[1]).longValue();
        if (log.isDebugEnabled()) {
            log.debug("manualServeByteRange Start    : " + start);
            log.debug("manualServeByteRange End      : " + end);
        }
        long size = end - start + 1;
        File actualFile = new File(diskPath);
        long totalSize = actualFile.length();
        
        if (log.isDebugEnabled()) {
            log.debug("manualServeByteRange totalsize: " + totalSize);
        }
    
        if (size <= 0) {
            return getStreamForBinary(diskPath);
        }
        response.setContentType("application/octet-stream");
        response.setStatus(HttpServletResponse.SC_PARTIAL_CONTENT);
        Date mtime = new Date(actualFile.lastModified());
        // "EEE, dd MMM yyyy HH:mm:ss zzz";
        SimpleDateFormat formatter = new SimpleDateFormat(
                "EEE, dd MMM yyyy HH:mm:ss zzz", Locale.US);
        formatter.setTimeZone(TimeZone.getTimeZone("GMT"));
        String fdate = formatter.format(mtime);
        response.addHeader("last-modified", fdate);
        response.addHeader("Content-Length", String.valueOf(size));
        response.addHeader("Content-Range", "bytes " + start + "-" + end + 
                "/" + totalSize);
        response.addHeader("Accept-Ranges", "bytes");
        if (log.isDebugEnabled()) {
            log.debug("Added header last-modified: " + fdate);
            log.debug("Added header Content-Length: " + String.valueOf(size));
            log.debug("Added header Content-Range: " + "bytes " + start + 
                    "-" + end + "/" + totalSize);
            log.debug("Added header Accept-Ranges: bytes");
        }
        // gotta make sure it is end + 1
        byte[] chunk = FileUtils.readByteArrayFromFile(actualFile, start, end + 1);
        if (log.isDebugEnabled()) {
            log.debug("chunk size: " + chunk.length);
            log.debug("read chunk into byte array.  returning ByteArrayStreamInfo");
        }
        ByteArrayStreamInfo stream = new 
            ByteArrayStreamInfo("application/octet-stream", chunk);
        return stream;
    }
    
}
