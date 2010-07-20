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
package com.redhat.rhn.frontend.action.configuration;

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.domain.config.ConfigChannel;
import com.redhat.rhn.domain.config.ConfigFile;
import com.redhat.rhn.domain.config.ConfigFileCount;
import com.redhat.rhn.domain.config.ConfigRevision;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.html.HtmlTag;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.configuration.ConfigurationManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;

import java.util.Map;

import javax.servlet.http.HttpServletRequest;

/**
 * BaseCompareFileAction - A base class for doing typical config file request processing.
 * @version $Rev$
 */
public abstract class ConfigActionHelper {


    // REQUIRED for all cfg-mgt pages
    public static final String REVISION_ID  = "crid";
    public static final String FILE_ID      = "cfid";
    public static final String CHANNEL_ID   = "ccid";

    public static final String FILE         = "file";
    public static final String REVISION     = "revision";
    public static final String CHANNEL      = "channel";

    private static final int NONE = 0;
    private static final int SINGULAR = 1;
    private static final int PLURAL = 2;

    /**
     * Utility classes can't be instantiated.
     */
    private ConfigActionHelper() {
    }

    /**
     * Adds the config revision, config file, and config channel as request attributes
     * using the identifiers of the request parameters.
     * @param rctxIn The request context which has the request.
     */
    public static void processRequestAttributes(RequestContext rctxIn) {
        HttpServletRequest request = rctxIn.getRequest();
        ConfigFile file = getFile(request);
        ConfigRevision cr = getRevision(request, file);
        setupRequestAttributes(rctxIn, file, cr);
    }

    /**
     * Adds the config revision, config file, and config channel as request attributes
     * when we already know the file and rev
     * @param rctxIn The request context which has the request.
     * @param file known config-file
     * @param cr known revision (null if there isn't one)
     */
    public static void setupRequestAttributes(RequestContext rctxIn, ConfigFile file,
            ConfigRevision cr) {
        HttpServletRequest req = rctxIn.getRequest();

        setupRequestAttributes(rctxIn, file.getConfigChannel());

        req.setAttribute(FILE_ID, file.getId());
        req.setAttribute(FILE, file);

        // Sometimes (like, say, when you've just deleted the revision) you may
        // not want to set the revision-info
        if (cr != null) {
            req.setAttribute(REVISION_ID, cr.getId());
            req.setAttribute(REVISION, cr);
        }
    }

    /**
     * Adds the config channel info as request attributes
     * when we know the channel
     * Used by the pages that aren't file- and/or revision-specific
     * @param ctx The request context which has the request.
     * @param channel known channel
     */
    public static void setupRequestAttributes(RequestContext ctx, ConfigChannel channel) {
        HttpServletRequest req = ctx.getRequest();

        req.setAttribute(CHANNEL_ID, channel.getId());
        req.setAttribute(CHANNEL, channel);
    }

    /**
     * Adds the config channel info to the given map
     * using the identifiers of the request parameters.
     * @param cc ConfigChannel of interest
     * @param params The map in which findings should be stored.
     */
    public static void processParamMap(ConfigChannel cc, Map params) {
        params.put(CHANNEL_ID, cc.getId());
    }

    /**
     * Adds the config revision, config file, and config channel to the given map
     * using the identifiers of the request parameters.
     * @param request The HttServletRequest to get identifiers from
     * @param params The map to which findings should be stored.
     */
    public static void processParamMap(HttpServletRequest request, Map params) {
        ConfigFile file = getFile(request);
        ConfigRevision cr = getRevision(request, file);

        params.put(FILE_ID, file.getId());
        params.put(REVISION_ID, cr.getId());

        ConfigActionHelper.processParamMap(file.getConfigChannel(), params);
    }

    /**
     * Finds the config channel with the identifier corresponding with the value
     * of the request parameter with the given name.
     * @param request The request to look in for the id (if we're creating a new channel,
     * it might be null)
     * @param param The name of the id request parameter.
     * @return The sought config channel.
     */
    public static ConfigChannel getChannel(HttpServletRequest request, String param) {
        RequestContext requestContext = new RequestContext(request);
        Long ccid = requestContext.getParamAsLong(param);
        if (ccid == null) {
            return null;
        }

        User user = requestContext.getLoggedInUser();
        return ConfigurationManager.getInstance().lookupConfigChannel(user, ccid);
    }

    /**
     * Finds the config channel with the identifier corresponding with the value
     * of the ccid request parameter.
     * @param request The request to look in for the id
     * @return The sought config channel.
     */
    public static ConfigChannel getChannel(HttpServletRequest request) {
        return getChannel(request, CHANNEL_ID);
    }

    /**
     * Finds the config file from the cfid request parameter.
     * @param request The HttpServletRequest with a cfid
     * @return The found file
     */
    public static ConfigFile getFile(HttpServletRequest request) {
        RequestContext requestContext = new RequestContext(request);
        User user = requestContext.getLoggedInUser();
        Long cfid = requestContext.getParamAsLong(FILE_ID);
        if (cfid != null) {
            return ConfigurationManager.getInstance().lookupConfigFile(user, cfid);
        }
        else {
            Long crid = requestContext.getParamAsLong(REVISION_ID);
            if (crid != null) {
                ConfigRevision cr = ConfigurationManager.getInstance().
                    lookupConfigRevision(user, crid);
                return cr.getConfigFile();
            }
            else {
                return null;
            }
        }
    }

    /**
     * Tries to find the revision using a request parameter.  Defaults to the newest
     * revision of the given file if it is not found.
     * @param request The HttpServletRequest which has a crid parameter
     * @param file The file this revision should belong to.
     * @return The found revision
     */
    public static ConfigRevision getRevision(HttpServletRequest request, ConfigFile file) {
        RequestContext requestContext = new RequestContext(request);

        User user = requestContext.getLoggedInUser();
        Long crid = requestContext.getParamAsLong(REVISION_ID);
        if (crid != null) {
            return ConfigurationManager.getInstance().lookupConfigRevision(user, crid);
        }
        else {
            return file.getLatestConfigRevision();
        }
    }

    /**
     * Find the requested REVISION.  We have a revision-id as "crid" - but sometimes, we
     * only have a file-id as "cfid".  If the latter, find the ConfigFile's latest revision.
     * @param req incoming request
     * @return a ConfigRevision, or NULL if we couldn't find one
     */
    public static ConfigRevision findRevision(HttpServletRequest req) {
        RequestContext requestContext = new RequestContext(req);

        User user = requestContext.getLoggedInUser();
        Long crid = requestContext.getParamAsLong(REVISION_ID);

        ConfigRevision cr = null;

        if (crid != null) {
            cr = ConfigurationManager.getInstance().lookupConfigRevision(user, crid);
        }
        else {
            ConfigFile cf = getFile(req);
            if (cf != null) {
                cr = cf.getLatestConfigRevision();
            }
        }
        return cr;
    }

    /**
     * Clears all of the configuration management sets.
     * @param user The user for which to clear the sets.
     */
    public static void clearRhnSets(User user) {
        RhnSetDecl.CONFIG_CHANNELS.clear(user);
        RhnSetDecl.CONFIG_ENABLE_SYSTEMS.clear(user);
        RhnSetDecl.CONFIG_FILE_NAMES.clear(user);
        RhnSetDecl.CONFIG_FILES.clear(user);
        RhnSetDecl.CONFIG_REVISIONS.clear(user);
        RhnSetDecl.CONFIG_SYSTEMS.clear(user);
        RhnSetDecl.CONFIG_TARGET_SYSTEMS.clear(user);
        RhnSetDecl.CONFIG_FILE_DEPLOY_SYSTEMS.clear(user);
        RhnSetDecl.CONFIG_CHANNEL_DEPLOY_SYSTEMS.clear(user);
        RhnSetDecl.CONFIG_CHANNEL_DEPLOY_REVISIONS.clear(user);
    }


    /**
     * Makes messages that look like
     * 1 file and 5 directories and 0 symlinks
     * 2 files and 1 directory and 0 symlinks
     * No files or directories or symlinks
     * Very standard i18nized counts messages
     * used in various places in config management.
     * @param count the ConfigFileCount object,
     *          that stores info on the number of files and directories
     * @param url the url to wrap the messages if so desired
     * @param includeAddUrlForEmpty include "Add" section for empty
     * @return the properly formatted File & Directories helper messages ..
     */
    public static String makeFileCountsMessage(ConfigFileCount count,
                                               String url,
                                               boolean includeAddUrlForEmpty) {
        return makeFileCountsMessage(count, url, false, includeAddUrlForEmpty);
    }

    /**
     * Makes messages that look like
     * 1 file and 5 directories and 0 symlinks
     * 2 files and 1 directory and 0 symlinks
     * No files or directories and 0 symlinks
     * Very standard i18nized counts messages
     * used in various places in config management.
     * @param count the ConfigFileCount object,
     *          that stores info on the number of files and directories
     * @param url the url to wrap the messages if so desired
     * @param includeEmptyFilesAndDirs force the inclusion of both
     *                             the file and directory information
     *                             even if their count is 0.
     *                         for example:
     *                         if  this param == true
     *                              return "0 files and 1 directory and 0 symlinks"
     *                         else
     *                              return "1 directory"
     * @param includeAddUrlForEmpty include "Add" section for empty
     * @return the properly formatted File & Directories helper messages ..
     */
    public static String makeFileCountsMessage(ConfigFileCount count,
                                               String url,
                                               boolean includeEmptyFilesAndDirs,
                                               boolean includeAddUrlForEmpty) {
        long fileCount = count.getFiles(), dirCount = count.getDirectories(),
                symlinkCount = count.getSymlinks();
        int fileSuffix = getSuffix(fileCount);
        int dirSuffix = getSuffix(dirCount);
        int symlinkSuffix = getSuffix(symlinkCount);

        LocalizationService service  = LocalizationService.getInstance();
        String key = "config." + "files_" + fileSuffix + "_dirs_" + dirSuffix +
                "_symlinks_" + symlinkSuffix;

        if (fileSuffix == NONE && dirSuffix == NONE && symlinkSuffix == NONE) {
            if (includeAddUrlForEmpty && url != null) {
                key += "_url";
                return service.getMessage(key, new Object[] {url});
            }
            return service.getMessage(key);
        }

        /* now we know there is at least one file/dir/symlink
         * so all we need to do is make all NONEs into PLURALs
         */
        if (includeEmptyFilesAndDirs) {
            if (fileSuffix == NONE) {
                fileSuffix = PLURAL;
            }
            if (symlinkSuffix == NONE) {
                symlinkSuffix = PLURAL;
            }
            if (dirSuffix == NONE) {
                dirSuffix = PLURAL;
            }
        }

        String message = service.getMessage(key, new Object[] {
            String.valueOf(fileCount),
            String.valueOf(dirCount),
            String.valueOf(symlinkCount)
        });
        if (url != null) {
            HtmlTag a = new HtmlTag("a");
            a.setAttribute("href", url);
            a.addBody(message);
            message = a.render();
        }
        return message;
    }

    private static int getSuffix(long i) {
        if (i == 1) {
            return SINGULAR;
        }
        if (i > 1) {
            return PLURAL;
        }

        return NONE;
    }

    /**
     * Makes messages that look like
     * 1 channel
     * 2 channels
     * None
     * Very standard i18nized counts messages
     * used in various places in config management.
     * @param count the number of config channels
     * @param url the url to wrap the messages if so desired
     * @return the properly formatted config channel messages
     */
    public static String makeChannelCountsMessage(long count,
                                                  String url) {
        LocalizationService service  = LocalizationService.getInstance();
        int suffix = getSuffix(count);
        String key = "config.channels_" + suffix;
        String message;
        if (suffix == PLURAL) {
            message = service.getMessage(key, new Object[] {new Long(count)});
        }
        else {
            message = service.getMessage(key);
        }

        if (suffix != NONE && url != null && !"".equals(url)) {
            HtmlTag a = new HtmlTag("a");
            a.setAttribute("href", url);
            a.addBody(message);
            message = a.render();
        }
        return message;
    }
}
