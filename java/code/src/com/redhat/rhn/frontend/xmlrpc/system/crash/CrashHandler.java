/**
 * Copyright (c) 2013--2014 Red Hat, Inc.
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

package com.redhat.rhn.frontend.xmlrpc.system.crash;

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.domain.rhnpackage.PackageArch;
import com.redhat.rhn.domain.rhnpackage.PackageEvr;
import com.redhat.rhn.domain.rhnpackage.PackageEvrFactory;
import com.redhat.rhn.domain.rhnpackage.PackageFactory;
import com.redhat.rhn.domain.rhnpackage.PackageName;
import com.redhat.rhn.domain.server.Crash;
import com.redhat.rhn.domain.server.CrashCount;
import com.redhat.rhn.domain.server.CrashFactory;
import com.redhat.rhn.domain.server.CrashFile;
import com.redhat.rhn.domain.server.CrashNote;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.xmlrpc.BaseHandler;
import com.redhat.rhn.frontend.xmlrpc.NoCrashesFoundException;
import com.redhat.rhn.frontend.xmlrpc.CrashFileDownloadException;
import com.redhat.rhn.frontend.xmlrpc.RhnXmlRpcServer;
import com.redhat.rhn.frontend.dto.CrashSystemsDto;
import com.redhat.rhn.frontend.dto.IdenticalCrashesDto;
import com.redhat.rhn.frontend.xmlrpc.system.XmlRpcSystemHelper;
import com.redhat.rhn.manager.download.DownloadManager;
import com.redhat.rhn.manager.system.CrashManager;

import org.apache.commons.codec.binary.Base64;
import org.apache.commons.lang.StringUtils;

import java.io.BufferedInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * CrashHandler
 * @version $Rev$
 * @xmlrpc.namespace system.crash
 * @xmlrpc.doc Provides methods to access and modify software crash information.
 */
public class CrashHandler extends BaseHandler {

    private static float freeMemCoeff = 0.9f;

    private CrashCount getCrashCount(Server serverIn) {
        CrashCount crashCount = serverIn.getCrashCount();
        if (crashCount == null) {
            throw new NoCrashesFoundException();
        }
        return crashCount;
    }

    /**
     * Return crash count information
     * @param sessionKey Session key
     * @param serverId Server ID
     * @return Return crash count information
     *
     * @xmlrpc.doc Return date of last software crashes report for given system
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "serverId")
     * @xmlrpc.returntype
     *     #struct("Crash Count Information")
     *         #prop_desc("int", "total_count",
     *                    "Total number of software crashes for a system")
     *         #prop_desc("int", "unique_count",
     *                    "Number of unique software crashes for a system")
     *         #prop_desc("dateTime.iso8601", "last_report",
     *                    "Date of the last software crash report")
     *     #struct_end()
     */
    public Map getCrashCountInfo(String sessionKey, Integer serverId) {
        User loggedInUser = getLoggedInUser(sessionKey);
        XmlRpcSystemHelper sysHelper = XmlRpcSystemHelper.getInstance();
        Server server = sysHelper.lookupServer(loggedInUser, serverId);

        Map returnMap = new HashMap();
        CrashCount crashCount = null;

        try {
            crashCount = getCrashCount(server);
        }
        catch (NoCrashesFoundException e) {
            returnMap.put("total_count", 0);
            returnMap.put("unique_count", 0);
            return returnMap;
        }

        returnMap.put("total_count", crashCount.getTotalCrashCount());
        returnMap.put("unique_count", crashCount.getUniqueCrashCount());
        returnMap.put("last_report", crashCount.getLastReport());

        return returnMap;
    }

    /**
     * Returns list of software crashes for a system.
     * @param sessionKey Session key
     * @param serverId Server ID
     * @return Returns list of software crashes for given system id.
     *
     * @xmlrpc.doc Return list of software crashes for a system.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "serverId")
     * @xmlrpc.returntype
     *     #array()
     *         #struct("crash")
     *             #prop("int", "id")
     *             #prop("string", "crash")
     *             #prop("string", "path")
     *             #prop("int", "count")
     *             #prop("string", "uuid")
     *             #prop("string", "analyzer")
     *             #prop("string", "architecture")
     *             #prop("string", "cmdline")
     *             #prop("string", "component")
     *             #prop("string", "executable")
     *             #prop("string", "kernel")
     *             #prop("string", "reason")
     *             #prop("string", "username")
     *             #prop("date", "created")
     *             #prop("date", "modified")
     *         #struct_end()
     *     #array_end()
     */
    public List listSystemCrashes(String sessionKey, Integer serverId) {
        User loggedInUser = getLoggedInUser(sessionKey);
        XmlRpcSystemHelper sysHelper = XmlRpcSystemHelper.getInstance();
        Server server = sysHelper.lookupServer(loggedInUser, serverId);

        List returnList = new ArrayList();

        for (Crash crash : server.getCrashes()) {
            Map crashMap = new HashMap();
            crashMap.put("id", crash.getId());
            crashMap.put("crash", crash.getCrash());
            crashMap.put("path", crash.getPath());
            crashMap.put("count", crash.getCount());
            crashMap.put("uuid",
                StringUtils.defaultString(crash.getUuid()));
            crashMap.put("analyzer",
                StringUtils.defaultString(crash.getAnalyzer()));
            crashMap.put("architecture",
                StringUtils.defaultString(crash.getArchitecture()));
            crashMap.put("cmdline",
                StringUtils.defaultString(crash.getCmdline()));
            crashMap.put("component",
                StringUtils.defaultString(crash.getComponent()));
            crashMap.put("executable",
                StringUtils.defaultString(crash.getExecutable()));
            crashMap.put("kernel",
                StringUtils.defaultString(crash.getKernel()));
            crashMap.put("reason",
                StringUtils.defaultString(crash.getReason()));
            crashMap.put("username",
                StringUtils.defaultString(crash.getUsername()));
            crashMap.put("created", crash.getCreated());
            crashMap.put("modified", crash.getModified());

            if (crash.getPackageNameId() != null) {
                PackageName pname = PackageFactory.lookupPackageName(
                    crash.getPackageNameId());
                crashMap.put("package_name", pname.getName());
            }

            if (crash.getPackageEvrId() != null) {
                PackageEvr pevr = PackageEvrFactory.lookupPackageEvrById(
                    crash.getPackageEvrId());
                crashMap.put("package_epoch", pevr.getEpoch());
                crashMap.put("package_version", pevr.getVersion());
                crashMap.put("package_release", pevr.getRelease());
            }

            if (crash.getPackageArchId() != null) {
                PackageArch parch = PackageFactory.lookupPackageArchById(
                    crash.getPackageArchId());
                crashMap.put("package_arch", parch.getLabel());
            }

            returnList.add(crashMap);
        }

        return returnList;
    }

    /**
     * Returns list of crash files for a given crash id.
     * @param sessionKey Session key
     * @param crashId Crash ID
     * @return Returns list of crash files.
     *
     * @xmlrpc.doc Return list of crash files for given crash id.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "crashId")
     * @xmlrpc.returntype
     *     #array()
     *         #struct("crashFile")
     *             #prop("int", "id")
     *             #prop("string", "filename")
     *             #prop("string", "path")
     *             #prop("int", "filesize")
     *             #prop("boolean", "is_uploaded")
     *             #prop("date", "created")
     *             #prop("date", "modified")
     *         #struct_end()
     *     #array_end()
     */
    public List listSystemCrashFiles(String sessionKey, Integer crashId) {
        User loggedInUser = getLoggedInUser(sessionKey);
        Crash crash = CrashManager.lookupCrashByUserAndId(loggedInUser,
                      new Long(crashId.longValue()));

        List returnList = new ArrayList();

        for (CrashFile crashFile : crash.getCrashFiles()) {
            Map crashMap = new HashMap();
            crashMap.put("id", crashFile.getId());
            crashMap.put("filename", crashFile.getFilename());
            crashMap.put("path", crashFile.getPath());
            crashMap.put("filesize", crashFile.getFilesize());
            crashMap.put("is_uploaded", crashFile.getIsUploaded());
            crashMap.put("created", crashFile.getCreated());
            crashMap.put("modified", crashFile.getModified());
            returnList.add(crashMap);
        }

        return returnList;
    }

    /**
     * Delete a crash with given crash id.
     * @param sessionKey Session key
     * @param crashId Crash ID
     * @return 1 In case of success, exception otherwise.
     *
     * @xmlrpc.doc Delete a crash with given crash id.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "crashId")
     * @xmlrpc.returntype #return_int_success()
     */
    public Integer deleteCrash(String sessionKey, Integer crashId) {
        User loggedInUser = getLoggedInUser(sessionKey);
        CrashManager.deleteCrash(loggedInUser, new Long(crashId.longValue()));
        return 1;
    }

    /**
     * Get a crash file download url
     * @param sessionKey Session key
     * @param crashFileId Crash File ID
     * @return Return a download url string.
     *
     * @xmlrpc.doc Get a crash file download url.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "crashFileId")
     * @xmlrpc.returntype string - The crash file download url
     */
    public String getCrashFileUrl(String sessionKey, Integer crashFileId) {
        User loggedInUser = getLoggedInUser(sessionKey);
        CrashFile crashFile = CrashManager.lookupCrashFileByUserAndId(loggedInUser,
                              new Long(crashFileId.longValue()));

       return RhnXmlRpcServer.getProtocol() + "://" +
            RhnXmlRpcServer.getServerName() +
            DownloadManager.getCrashFileDownloadPath(crashFile, loggedInUser);
    }

    /**
     * Download a base64 encoded crash file.
     * @param sessionKey Session key
     * @param crashFileId Crash File ID
     * @return Return a byte array of the crash file.
     * @throws IOException if there is an exception
     *
     * @xmlrpc.doc Download a crash file.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "crashFileId")
     * @xmlrpc.returntype base64 - base64 encoded crash file.
     */
    public byte[] getCrashFile(String sessionKey, Integer crashFileId) throws IOException {
        User loggedInUser = getLoggedInUser(sessionKey);
        CrashFile crashFile = CrashManager.lookupCrashFileByUserAndId(loggedInUser,
                              new Long(crashFileId.longValue()));
        String path = Config.get().getString(ConfigDefaults.MOUNT_POINT) + "/" +
                      crashFile.getCrash().getStoragePath() + "/" +
                      crashFile.getFilename();
        File file = new File(path);

        if (file.length() > freeMemCoeff * Runtime.getRuntime().freeMemory()) {
            throw new CrashFileDownloadException("api.crashfile.download.toolarge");
        }

        byte[] plainFile = new byte[(int) file.length()];
        BufferedInputStream br = new BufferedInputStream(new FileInputStream(file));
        if (br.read(plainFile) != file.length()) {
            throw new CrashFileDownloadException("api.package.download.ioerror");
        }

        return Base64.encodeBase64(plainFile);
    }

    /**
     * @param sessionKey Session key
     * @param crashId Crash ID
     * @param subject Crash note subject
     * @param details Crash note details
     * @return 1 on success
     *
     * @xmlrpc.doc Create a crash note
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "crashId")
     * @xmlrpc.param #param("string", "subject")
     * @xmlrpc.param #param("string", "details")
     * @xmlrpc.returntype #return_int_success()
     */
    public int createCrashNote(String sessionKey, Integer crashId,
            String subject, String details) {
        User loggedInUser = getLoggedInUser(sessionKey);
        if (StringUtils.isBlank(subject)) {
            throw new IllegalArgumentException("Crash note subject is required");
        }
        CrashNote cn = new CrashNote();
        cn.setSubject(subject);
        cn.setNote(details);
        cn.setCreator(loggedInUser);
        cn.setCrash(CrashManager.lookupCrashByUserAndId(loggedInUser,
                crashId.longValue()));
        CrashFactory.save(cn);
        return 1;
    }

    /**
     * @param sessionKey Session ID
     * @param crashNoteId Crash note ID
     * @return 1 on success
     *
     * @xmlrpc.doc Delete a crash note
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "crashNoteId")
     * @xmlrpc.returntype #return_int_success()
     */
    public int deleteCrashNote(String sessionKey, Integer crashNoteId) {
        User loggedInUser = getLoggedInUser(sessionKey);
        CrashNote cn = CrashManager.lookupCrashNoteByUserAndId(loggedInUser,
                crashNoteId.longValue());
        CrashFactory.delete(cn);
        return 1;
    }

    /**
     * @param sessionKey Session ID
     * @param crashId Crash ID
     * @return Crash notes for crash
     *
     * @xmlrpc.doc List crash notes for crash
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "crashId")
     * @xmlrpc.returntype
     *     #array()
     *         #struct("crashNote")
     *             #prop("int", "id")
     *             #prop("string", "subject")
     *             #prop("string", "details")
     *             #prop("string", "updated")
     *         #struct_end()
     *     #array_end()
     */
    public List getCrashNotesForCrash(String sessionKey, Integer crashId) {
        User loggedInUser = getLoggedInUser(sessionKey);
        Crash c = CrashManager.lookupCrashByUserAndId(loggedInUser,
                crashId.longValue());
        List returnList = new ArrayList();
        for (CrashNote cn : c.getCrashNotes()) {
            Map crashNotesMap = new HashMap();
            crashNotesMap.put("id", cn.getId());
            crashNotesMap.put("subject", cn.getSubject());
            crashNotesMap.put("details", cn.getNote() == null ? "" : cn.getNote());
            crashNotesMap.put("updated", cn.getModifiedString());
            returnList.add(crashNotesMap);
        }
        return returnList;
    }

    /**
     * @param sessionKey Session ID
     * @return Software Crash Overview
     *
     * @xmlrpc.doc Get Software Crash Overview
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.returntype
     *     #array()
     *         #struct("crash")
     *             #prop_desc("string", "uuid", "Crash UUID")
     *             #prop_desc("string", "component",
     *                        "Package component (set if unique and non empty)")
     *             #prop_desc("int", "crash_count", "Number of crashes occurred")
     *             #prop_desc("int", "system_count", "Number of systems affected")
     *             #prop_desc("dateTime.iso8601", "last_report", "Last crash occurence")
     *         #struct_end()
     *     #array_end()
     */
    public List getCrashOverview(String sessionKey) {
        User user = getLoggedInUser(sessionKey);
        List returnList = new ArrayList();
        for (IdenticalCrashesDto ic : CrashFactory.listIdenticalCrashesForOrg(user,
            user.getOrg())) {
            Map crashMap = new HashMap();
            crashMap.put("uuid", ic.getUuid());
            String component = ic.getComponent();
            if (component != null) {
                crashMap.put("component", component);
            }
            crashMap.put("crash_count", ic.getTotalCrashCount());
            crashMap.put("system_count", ic.getSystemCount());
            crashMap.put("last_report", ic.getLastCrashReport());
            returnList.add(crashMap);
        }
        return returnList;
    }

    /**
     * @param sessionKey Session ID
     * @param uuid Crash UUID to search for
     * @return List of crashes with given UUID
     *
     * @xmlrpc.doc List software crashes with given UUID
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("string", "uuid")
     * @xmlrpc.returntype
     *     #array()
     *         #struct("crash")
     *             #prop_desc("int", "server_id",
     *                        "ID of the server the crash occurred on")
     *             #prop_desc("string", "server_name",
     *                       "Name of the server the crash occurred on")
     *             #prop_desc("int", "crash_id", "ID of the crash with given UUID")
     *             #prop_desc("int", "crash_count",
     *                        "Number of times the crash with given UUID occurred")
     *             #prop_desc("string", "crash_component", "Crash component")
     *             #prop_desc("dateTime.iso8601", "last_report", "Last crash occurence")
     *         #struct_end()
     *     #array_end()
     */
    public List getCrashesByUuid(String sessionKey, String uuid) {
        User user = getLoggedInUser(sessionKey);
        List returnList = new ArrayList();
        for (CrashSystemsDto cs : CrashFactory.listCrashSystems(user,
            user.getOrg(), uuid)) {
            Map crashMap = new HashMap();
            crashMap.put("server_id", cs.getServerId());
            crashMap.put("server_name", cs.getServerName());
            crashMap.put("crash_id", cs.getCrashId());
            crashMap.put("crash_count", cs.getCrashCount());
            crashMap.put("crash_component", cs.getCrashComponent());
            crashMap.put("last_report", cs.getLastReport());
            returnList.add(crashMap);
        }
        return returnList;
    }
}
