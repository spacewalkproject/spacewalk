/**
 * Copyright (c) 2009--2014 Red Hat, Inc.
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

import com.redhat.rhn.domain.kickstart.KickstartData;

import java.io.File;

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

    public static final String SYSTEM_CHECKIN_THRESHOLD = "web.system_checkin_threshold";
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
    public static final String ERRATA_CACHE_COMPUTE_THRESHOLD
    = "errata_cache_compute_threshold";

    public static final String DOWNLOAD_URL_LIFETIME = "download_url_lifetime";

    public static final String NON_EXPIRABLE_PACKAGE_URLS = "non_expirable_package_urls";

    public static final String WEB_IS_MONITORING_SCOUT = "web.is_monitoring_scout";

    public static final String WEB_IS_MONITORING_BACKEND = "web.is_monitoring_backend";

    public static final String SATELLITE_PARENT = "server.satellite.rhn_parent";

    public static final String JABBER_SERVER = "server.jabber_server";

    public static final String WEB_SCOUT_SHARED_KEY = "monitoring.scout_shared_key";

    public static final String KICKSTART_HOST = "kickstart_host";

    public static final String CONFIG_REVISION_MAX_SIZE = "web.maximum_config_file_size";

    public static final String WEB_EXCLUDED_COUNTRIES = "java.excluded_countries";

    public static final String DISCONNECTED = "disconnected";

    public static final String DEFAULT_SAT_PARENT = "satellite.rhn.redhat.com";

    public static final String FORCE_UNENTITLEMENT = "web.force_unentitlement";

    public static final String PRODUCT_NAME = "web.product_name";

    public static final String COBBLER_AUTOMATED_USER = "java.taskomatic_cobbler_user";

    public static final String DOC_REFERENCE_GUIDE = "docs.reference_guide";
    public static final String DOC_INSTALL_GUIDE = "docs.install_guide";
    public static final String DOC_PROXY_GUIDE = "docs.proxy_guide";
    public static final String DOC_CLIENT_CONFIG_GUIDE = "docs.client_config_guide";
    public static final String DOC_USER_GUIDE = "docs.user_guide";
    public static final String DOC_GETTING_STARTED_GUIDE = "docs.getting_started_guide";
    public static final String DOC_RELEASE_NOTES = "docs.release_notes";

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
    public static final String USE_DB_REPODATA = "user_db_repodata";
    public static final String CONFIG_MACRO_ARGUMENT_REGEX = "config_macro_argument_regex";

    public static final String DB_BACKEND = "db_backend";
    public static final String DB_BACKEND_ORACLE = "oracle";
    public static final String DB_BACKEND_POSTGRESQL = "postgresql";
    public static final String DB_USER = "db_user";
    public static final String DB_PASSWORD = "db_password";
    public static final String DB_NAME = "db_name";
    public static final String DB_HOST = "db_host";
    public static final String DB_PORT = "db_port";
    public static final String DB_SSL_ENABLED = "db_ssl_enabled";
    public static final String DB_PROTO = "hibernate.connection.driver_proto";
    public static final String DB_CLASS = "hibernate.connection.driver_class";

    public static final String SSL_TRUSTSTORE = "java.ssl_truststore";

    public static final String LOOKUP_EXCEPT_SEND_EMAIL = "lookup_exception_email";

    public static final String KS_PARTITION_DEFAULT = "kickstart.partition.default";
    public static final String IPA_DEFAULT_USER_ORG = "java.ipa.default_user_org";

    /**
     * System Currency defaults
     */
    public static final String SYSTEM_CURRENCY_CRIT = "java.sc_crit";
    public static final String SYSTEM_CURRENCY_IMP  = "java.sc_imp";
    public static final String SYSTEM_CURRENCY_MOD  = "java.sc_mod";
    public static final String SYSTEM_CURRENCY_LOW  = "java.sc_low";
    public static final String SYSTEM_CURRENCY_BUG  = "java.sc_bug";
    public static final String SYSTEM_CURRENCY_ENH  = "java.sc_enh";

    /**
     * Taskomatic defaults
     */
    public static final String TASKOMATIC_CHANNEL_REPODATA_WORKERS
        = "java.taskomatic_channel_repodata_workers";

    private ConfigDefaults() {
    }

    /**
     * Returns the System Currency multiplier for critical security errata
     * @return the System Currency multiplier for critical security errata
     */
    public Integer getSCCrit() {
        return Config.get().getInt(SYSTEM_CURRENCY_CRIT, 32);
    }

    /**
     * Returns the System Currency multiplier for important security errata
     * @return the System Currency multiplier for important security errata
     */
    public Integer getSCImp() {
        return Config.get().getInt(SYSTEM_CURRENCY_IMP, 16);
    }

    /**
     * Returns the System Currency multiplier for moderate security errata
     * @return the System Currency multiplier for moderate security errata
     */
    public Integer getSCMod() {
        return Config.get().getInt(SYSTEM_CURRENCY_MOD, 8);
    }

    /**
     * Returns the System Currency multiplier for low security errata
     * @return the System Currency multiplier for low security errata
     */
    public Integer getSCLow() {
        return Config.get().getInt(SYSTEM_CURRENCY_LOW, 4);
    }

    /**
     * Returns the System Currency multiplier for bug fix errata
     * @return the System Currency multiplier for bug fix errata
     */
    public Integer getSCBug() {
        return Config.get().getInt(SYSTEM_CURRENCY_BUG, 2);
    }

    /**
     * Returns the System Currency multiplier for enhancement errata
     * @return the System Currency multiplier for enhancement errata
     */
    public Integer getSCEnh() {
        return Config.get().getInt(SYSTEM_CURRENCY_ENH, 1);
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
     * Returns the default VirtMemory Size in MBs
     * @param data the kickstart data, so we can tell if it's RHEL 7
     * @return the memory size
     */
    public int getDefaultVirtMemorySize(KickstartData data) {
        // RHEL 7 requires at least 768 MB of ram to install
        if (data.isRhel7OrGreater()) {
            return Config.get().getInt(VIRT_MEM, 768);
        }
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

    /**
     * is the server configured to use oracle
     * @return true if so
     */
    public boolean isPostgresql() {
        return DB_BACKEND_POSTGRESQL.equals(Config.get().getString(DB_BACKEND));
    }

    private void setSslTrustStore() throws ConfigException {
        String trustStore = Config.get().getString(SSL_TRUSTSTORE);
        if (trustStore == null || !new File(trustStore).isFile()) {
            throw new ConfigException("Can not find java truststore at " +
                trustStore + ". Path can be changed with " +
                SSL_TRUSTSTORE + " option.");
        }
        System.setProperty("javax.net.ssl.trustStore", trustStore);
    }

    /**
     * Constructs JDBC connection string based on configuration, checks for
     * some basic sanity.
     * @return JDBC connection string
     * @throws ConfigException if unknown database backend is set,
     */
    public String getJdbcConnectionString() throws ConfigException {
        String dbName = Config.get().getString(DB_NAME);
        String dbHost = Config.get().getString(DB_HOST);
        String dbPort = Config.get().getString(DB_PORT);
        String dbProto = Config.get().getString(DB_PROTO);
        boolean dbSslEnabled = Config.get().getBoolean(DB_SSL_ENABLED);

        String connectionUrl;

        if (isOracle()) {
            connectionUrl = dbProto + ":@";
            if (dbProto.contains("thin")) {
                connectionUrl += dbHost + ":" + dbPort + ":";
            }
            connectionUrl += dbName;

            if (dbSslEnabled) {
                throw new ConfigException(
                    "SSL is not supported for Oracle database backend");
            }
        }
        else if (isPostgresql()) {
            connectionUrl = dbProto + ":";
            if (dbHost != null && dbHost.length() > 0) {
                connectionUrl += "//" + dbHost;
                if (dbPort != null && dbPort.length() > 0) {
                    connectionUrl += ":" + dbPort;
                }
                connectionUrl += "/";
            }
            connectionUrl += dbName;

            if (dbSslEnabled) {
                connectionUrl += "?ssl=true";
                setSslTrustStore();
            }
        }
        else {
            throw new ConfigException(
                "Unknown db backend set, expecting oracle or postgresql");
        }
        return connectionUrl;
    }

    /**
     * is documentation available
     * @return true if so
     */
    public boolean isDocAvailable() {
        return !isSpacewalk();
    }

    /**
     * Returns Max taskomatic channel repodata workers
     * @return Max taskomatic channel repodata workers
     */
    public int getTaskoChannelRepodataWorkers() {
        return Config.get().getInt(TASKOMATIC_CHANNEL_REPODATA_WORKERS, 1);
    }

    /**
     * Returns Max taskomatic channel repodata workers
     * @return Max taskomatic channel repodata workers
     */
    public Long getIpaDefaultUserOrgId() {
        Integer ipaDefaultUserOrg = Config.get().getInteger(IPA_DEFAULT_USER_ORG);
        if (ipaDefaultUserOrg != null) {
            return ipaDefaultUserOrg.longValue();
        }
        throw new ConfigException(IPA_DEFAULT_USER_ORG + " not set!");
    }
}
