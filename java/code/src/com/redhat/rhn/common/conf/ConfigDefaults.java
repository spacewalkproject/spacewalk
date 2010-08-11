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
package com.redhat.rhn.common.conf;

import org.apache.commons.lang.StringUtils;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

/**
 * ConfigDefaults is the place to store application specific Config settings
 * and convenience methods.
 *
 * @version $Rev$
 */
public class ConfigDefaults {

    private static ConfigDefaults instance = new ConfigDefaults();

    public static final String SPACEWALK = "Spacewalk";
    //
    // Names of the configuration parameters
    //

    public static final String SSL_AVAILABLE = "ssl_available";

    //TODO: was private.  Made public for AccessTest
    public static final String WEB_SATELLITE = "web.satellite";

    public static final String ENABLE_OAI_SYNC = "enable_oai_sync";
    public static final String SYSTEM_CHECKIN_THRESHOLD = "web.system_checkin_threshold";
    public static final String WEB_ALLOW_PXT_PERSONALITIES = "web.allow_pxt_personalities";
    public static final String WEB_DEFAULT_MAIL_FROM = "web.default_mail_from";
    public static final String WEB_ENCRYPTED_PASSWORDS = "web.encrypted_passwords";
    public static final String WEB_L10N_RESOURCEBUNDLES = "web.l10n_resourcebundles";
    public static final String WEB_PAM_AUTH_SERVICE = "web.pam_auth_service";
    public static final String WEB_SESSION_DATABASE_LIFETIME =
        "web.session_database_lifetime";

    public static final String WEB_SESSION_SECRET_1 = "web.session_secret_1";
    public static final String WEB_SESSION_SECRET_2 = "web.session_secret_2";
    public static final String WEB_SESSION_SECRET_3 = "web.session_secret_3";
    public static final String WEB_SESSION_SECRET_4 = "web.session_secret_4";

    public static final String WEB_SESSION_SWAP_SECRET_1 = "web.session_swap_secret_1";
    public static final String WEB_SESSION_SWAP_SECRET_2 = "web.session_swap_secret_2";
    public static final String WEB_SESSION_SWAP_SECRET_3 = "web.session_swap_secret_3";
    public static final String WEB_SESSION_SWAP_SECRET_4 = "web.session_swap_secret_4";

    public static final String WEB_SMTP_SERVER = "web.smtp_server";
    public static final String TASKOMATIC_TASKS = "taskomatic.tasks";
    public static final String TASKOMATIC_DEFAULT_TASKS = "taskomatic.default_tasks";
    public static final String ERRATA_CACHE_COMPUTE_THRESHOLD
                            = "errata_cache_compute_threshold";

    public static final String DOWNLOAD_URL_LIFETIME = "download_url_lifetime";

    public static final String NON_EXPIRABLE_PACKAGE_URLS = "non_expirable_package_urls";

    public static final String WEB_IS_MONITORING_SCOUT = "web.is_monitoring_scout";

    public static final String WEB_IS_MONITORING_BACKEND = "web.is_monitoring_backend";

    public static final String SATELLITE_PARENT = "server.satellite.rhn_parent";

    public static final String JABBER_SERVER = "server.jabber_server";

    public static final String WEB_SCOUT_SHARED_KEY = "monitoring.scout_shared_key";

    public static final String GPG_KEYRING = "web.gpg_keyring";

    public static final String OVAL_MOUNT_POINT = "web.oval_mount_point";

    public static final String KICKSTART_HOST = "kickstart_host";

    public static final String CONFIG_REVISION_MAX_SIZE = "web.maximum_config_file_size";

    public static final String WEB_EXCLUDED_COUNTRIES = "web.excluded_countries";

    public static final String DISCONNECTED = "disconnected";

    public static final String DEFAULT_SAT_PARENT = "satellite.rhn.redhat.com";

    public static final String TINY_URL_TIMEOUT = "server.satellite.tiny_url_timeout";

    public static final String FORCE_UNENTITLEMENT = "web.force_unentitlement";

    public static final String PRODUCT_NAME = "web.product_name";

    public static final String COBBLER_AUTOMATED_USER = "web.taskomatic_cobbler_user";

    public static final String DOC_REFERENCE_GUIDE = "docs.reference_guide";
    public static final String DOC_INSTALL_GUIDE = "docs.install_guide";
    public static final String DOC_PROXY_GUIDE = "docs.proxy_guide";
    public static final String DOC_CLIENT_CONFIG_GUIDE = "docs.client_config_guide";
    public static final String DOC_CHANNEL_MGMT_GUIDE = "docs.channel_mgmt_guide";
    public static final String DOC_RELEASE_NOTES = "docs.release_notes";
    public static final String DOC_PROXY_RELEASE_NOTES = "docs.proxy_release_notes";

    public static final String WEB_SUBSCRIBE_PROXY_CHANNEL = "web.subscribe_proxy_channel";

    public static final String TAKE_SNAPSHOTS = "enable_snapshots";

    /**
     * The default maximum size for config revisions,  (128 K)
     */
    public static final int DEFAULT_CONFIG_REVISION_MAX_SIZE = 131072;

    public static final String REPOMD_PATH_PREFIX = "taskomatic.repomd_path_prefix";

    public static final String REPOMD_CACHE_MOUNT_POINT = "repomd_cache_mount_point";


    public static final String DEFAULT_KICKSTART_PACKAGE_NAME = "spacewalk-koan";
    public static final String KICKSTART_PACKAGE_NAME = "kickstart_package";

    public static final String MOUNT_POINT = "mount_point";
    public static final String KICKSTART_MOUNT_POINT = "kickstart_mount_point";

    public static final String PAGE_SIZES = "web.page_sizes";
    public static final String DEFAULT_PAGE_SIZE = "web.default_page_size";

    public static final String KICKSTART_COBBLER_DIR = "kickstart.cobbler.dir";
    public static final String COBBLER_SNIPPETS_DIR = "cobbler.snippets.dir";
    private static final String DEFAULT_COBBLER_SNIPPET_DIR = "/var/lib/cobbler/snippets";
    private static final String COBBLER_NAME_SEPARATOR = "cobbler.name.separator";

    public static final String KVM_VIRT_PATH_DIR = "kickstart.virt_storage_path_kvm";
    public static final String XEN_VIRT_PATH_DIR = "kickstart.virt_storage_path_xen";
    private static final String DEFAULT_XEN_VIRT_PATH = "/var/lib/xen/images";
    private static final String DEFAULT_KVM_VIRT_PATH = "/var/lib/libvirt/images";
    public static final String VIRT_BRIDGE = "kickstart.virt_bridge";
    public static final String VIRT_MEM = "kickstart.virt_mem_size_mb";
    public static final String VIRT_CPU = "kickstart.virt_cpus";
    public static final String VIRT_DISK = "kickstart.virt_disk_size_gb";
    public static final String KICKSTART_NETWORK_INTERFACE = "kickstart.default_interface";

    public static final String SPACEWALK_REPOSYNC_PATH = "spacewalk_reposync_path";
    public static final String SPACEWALK_REPOSYNC_LOG_PATH = "spacewalk_reposync_logpath";
    public static final String NON_REFERER_URLS = "non_referer_urls";
    public static final String USE_DB_REPODATA = "user_db_repodata";
    public static final String CONFIG_MACRO_ARGUMENT_REGEX = "config_macro_argument_regex";

    public static final String DB_BACKEND = "db_backend";
    public static final String DB_BACKEND_ORACLE = "oracle";
    public static final String DB_USER = "db_user";
    public static final String DB_PASSWORD = "db_password";
    public static final String DB_NAME = "db_name";
    public static final String DB_HOST = "db_host";
    public static final String DB_PORT = "db_port";
    public static final String DB_PROTO = "hibernate.connection.driver_proto";

    public static final String LOOKUP_EXCEPT_SEND_EMAIL = "lookup_exception_email";


    private ConfigDefaults() {
    }

    /**
     * Get instance of ConfigDefaults.
     * @return ConfigDefaults instance.
     */
    public static ConfigDefaults get() {
        return instance;
    }

    /**
     * Return the kickstart mount point directory
     * Note the mount point is guaranteed to have a
     * '/' at the end of the string so you can use it
     * for appending sub directories.
     * @return the ks mount point directory.
     */
    public String getKickstartMountPoint() {
        String mount =  StringUtils.defaultIfEmpty(
                Config.get().getString(KICKSTART_MOUNT_POINT),
                Config.get().getString(MOUNT_POINT)).trim();
        if (!mount.endsWith("/")) {
            mount = mount + "/";
        }
        return mount;
    }


    /**
     * Returns the default kickstart package name
     * @return the default kickstart package name
     */
    public String getKickstartPackageName() {
        return StringUtils.defaultIfEmpty(Config.get().getString(KICKSTART_PACKAGE_NAME),
                DEFAULT_KICKSTART_PACKAGE_NAME).trim();
    }

    /**
     * Get the user string for use with authorization between Spacewalk
     * and Cobbler if there is no actual user in context.
     *
     * @return String from our config
     */
    public String getCobblerAutomatedUser() {
        return Config.get().getString(COBBLER_AUTOMATED_USER, "taskomatic_user");
    }

    /**
     * Returns all the available page sizes.
     * Note this is only meant to check
     * if the web.page_sizes config entry is set
     * you might want to use PageSizeDecorator.getPageSizes instead.
     * @see com.redhat.rhn.frontend.taglibs.list.decorators.PageSizeDecorator
     * for more info.
     * @return the comma separated list of page sizes or "".
     */
    public String getPageSizes() {
        return Config.get().getString(PAGE_SIZES, "");
    }

    /**
     * Returns the default page size config entry.
     * Note this is only meant to check
     * if the web.default_page_size config entry is set
     * you might want to use PageSizeDecorator.getDefaultPageSize instead.
     * @see com.redhat.rhn.frontend.taglibs.list.decorators.PageSizeDecorator
     * for more info.
     * @return the default page size config entry or "".
     */
    public String getDefaultPageSize() {
        return Config.get().getString(DEFAULT_PAGE_SIZE, "");
    }

    /**
     * Returns the directory which hosts all the
     * cobbler kickstart .cfg files..
     * All the .cfg files that have been generated
     * by spacewalk will be either at
     * ${kickstart.cobbler.dir}/wizard or
     * ${kickstart.cobbler.dir}/upload
     * @return the dir which has the kickstarts
     */
    public String getKickstartConfigDir() {
        return Config.get().getString(KICKSTART_COBBLER_DIR, "/var/lib/rhn/kickstarts/");
    }

    /**
     * Returns the directory which hosts all the
     * org specific cobbler snippets files..
     * All the snippet files that have been generated
     * by spacewalk will be at
     * /var/lib/cobbler/snippets
     *
     * @return the dir which has the kickstarts cobbler snippets
     */
    public String getCobblerSnippetsDir() {
        return Config.get().getString(COBBLER_SNIPPETS_DIR, DEFAULT_COBBLER_SNIPPET_DIR);
    }

    /**
     * Returns the base directory where the virt artifacts will be stored.
     * This information is used while setting up system records and so on..
     * @param xen true if the virt path required is for a xen virt type.
     * @return the virt path..
     */
    public File getVirtPath(boolean xen) {
        String virtPath = xen ? XEN_VIRT_PATH_DIR : KVM_VIRT_PATH_DIR;
        String defaultVirtPath = xen ? DEFAULT_XEN_VIRT_PATH : DEFAULT_KVM_VIRT_PATH;
        return new File(Config.get().getString(virtPath, defaultVirtPath));
    }

    /**
     * Returns the default value for the xen virt bridge
     * @return  the value for virt bridge.
     */
    public String getDefaultXenVirtBridge() {
        return Config.get().getString(VIRT_BRIDGE, "xenbr0");
    }

    /**
     * Returns the default value for the xen virt bridge
     * @return  the value for virt bridge.
     */
    public String getDefaultKVMVirtBridge() {
        return Config.get().getString(VIRT_BRIDGE, "virbr0");
    }


    /**
     * Returns the default virt disk size in GBs
     * @return the virt disk size
     */
    public int getDefaultVirtDiskSize() {
        return Config.get().getInt(VIRT_DISK, 3);
    }

    /**
     * Returns the defualt VirtMemory Size in MBs
     * @return the memory size
     */
    public int getDefaultVirtMemorySize() {
        return Config.get().getInt(VIRT_MEM, 512);
    }

    /**
     * Returns the default number of virt cpus
     * @return the number of virt cpus
     */
    public int getDefaultVirtCpus() {
        return Config.get().getInt(VIRT_CPU, 1);
    }


    /**
     * Check to see if monitoring scout functionality is enabled
     *
     * @return true if scout is enabled
     */
    public boolean isMonitoringScout() {
        return Config.get().getBoolean(WEB_IS_MONITORING_SCOUT);
    }

    /**
     * Check to see if monitoring backend functionality is enabled
     *
     * @return true if backend is enabled
     */
    public boolean isMonitoringBackend() {
        return Config.get().getBoolean(WEB_IS_MONITORING_BACKEND);
    }

    /**
     * Return <code>true</code> if SSL is available for web traffic.
     *
     * @return <code>true</code> if SSL is available for web traffic.
     */
    public boolean isSSLAvailable() {
        return Config.get().getBoolean(SSL_AVAILABLE);
    }

    /**
     *
     * @return if we should force unentitlement of systems
     * when setting entitlements below current usage for multiorg
     */
    public boolean forceUnentitlement() {
        return Config.get().getBoolean(FORCE_UNENTITLEMENT);
    }

    /**
     * Check if this Sat is disconnected or not
     * @return boolean if this sat is disconnected or not
     */
    public boolean isDisconnected() {
        return (Config.get().getBoolean(DISCONNECTED));
    }

    /**
     * Get the configured hostname for this RHN Server.
     * @return String hostname
     */
    public String getHostname() {
        return Config.get().getString(JABBER_SERVER);
    }

    /**
     * Returns the URL for the search server, if not defined returns
     * http://localhost:2828/RPC2
     * @return the URL for the search server.
     */
    public String getSearchServerUrl() {
        String searchServerHost =
            Config.get().getString("search_server.host", "localhost");
        int searchServerPort = Config.get().getInt("search_server.port", 2828);
        return "http://" + searchServerHost + ":" + searchServerPort + "/RPC2";
    }

    /**
     * Returns the URL for the tasko server, if not defined returns
     * http://localhost:2829/RPC2
     * @return the URL for the search server.
     */
    public String getTaskoServerUrl() {
        String taskoServerHost =
            Config.get().getString("tasko_server.host", "localhost");
        int taskoServerPort = Config.get().getInt("tasko_server.port", 2829);
        return "http://" + taskoServerHost + ":" + taskoServerPort + "/RPC2";
    }

    /**
     * Get the URL to the cobbler server
     * @return http url
     */
    public String getCobblerServerUrl() {
        String cobblerServer = getCobblerHost();
        int cobblerServerPort = Config.get().getInt("cobbler.port", 80);
        return "http://" + cobblerServer + ":" + cobblerServerPort;
    }


    /**
     * Get just the cobbler hostname
     * @return the cobbler hostname
     */
    public String getCobblerHost() {
        return Config.get().getString("cobbler.host", "localhost");
    }

    /**
     * get the text to print at the top of a kickstart template
     * @return the header
     */
    public String getKickstartTemplateHeader() {
        return Config.get().getString("kickstart.header", "#errorCatcher ListErrors");
    }


    /**
     * Returns the default network interface for a kickstart profile
     * @return the network interface
     */
    public String getDefaultKickstartNetworkInterface() {
        return Config.get().getString(KICKSTART_NETWORK_INTERFACE, "eth0");
    }

    /**
     * Get the list of Url paths that we don't do the referer check on
     * @return The list of strings
     */
    public List<String> getNonRefererUrls() {
        List<String> toRet = Config.get().getList(NON_REFERER_URLS);
        if (toRet == null) {
            toRet = new ArrayList<String>();
        }
        toRet.add("/Login.do");
        toRet.add("/ReLogin.do");
        toRet.add("/index.jsp");
        toRet.add("/YourRhn.do");
        return toRet;
    }

    /**
     * Return true if this is a Spacewalk instance. (as opposed to Satellite)
     * @return true is this is a Spacewalk instance.
     */
    public boolean isSpacewalk() {
        if (Config.get().getString(PRODUCT_NAME).equals(SPACEWALK)) {
            return true;
        }
        return false;
    }

    /**
     * Return true if you are to use/save repodata into the DB
     * @return true or false
     */
    public boolean useDBRepodata() {
        if (Config.get().getString(USE_DB_REPODATA) == null) {
            return true;
        }
        return Config.get().getBoolean(USE_DB_REPODATA);
    }

    /**
     * Get the seperator to use when creating cobbler namse
     *  defaults to ':'
     * @return the seperator
     */
    public String getCobblerNameSeparator() {
        return Config.get().getString(COBBLER_NAME_SEPARATOR, ":");

    }

    /**
     * is the server configured to use oracle
     * @return true if so
     */
    public boolean isOracle() {
        return DB_BACKEND_ORACLE.equals(Config.get().getString(DB_BACKEND));
    }

}
