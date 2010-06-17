"""
Yum plugin for RHN access.

This plugin provides access to Red Hat Network to yum via up2date modules
and XMLRPC calls.
"""

import os
import sys
import urllib

from yum.plugins import TYPE_CORE
from yum.yumRepo import YumRepository

import yum.Errors

from urlgrabber.grabber import URLGrabber
from urlgrabber.grabber import URLGrabError
try:
    from urlgrabber.grabber import pycurl
except:
    pycurl = None

from iniparse import INIConfig
import gettext
_ = gettext.gettext

# TODO: Get the up2date stuff that we need in a better place,
# so we don't have to do path magic.
sys.path.append("/usr/share/rhn/")

import up2date_client.up2dateAuth as up2dateAuth
from up2date_client import config
from up2date_client import rhnChannel
from up2date_client import rhnPackageInfo
from up2date_client import up2dateErrors
import rhn.transports

__revision__ = "$Rev$"

requires_api_version = '2.5'
plugin_type = TYPE_CORE
pcklAuthFileName = "/var/spool/up2date/loginAuth.pkl"

rhn_enabled = True

COMMUNICATION_ERROR = _("There was an error communicating with RHN.")

from M2Crypto.SSL import SSLError, Connection

def bypass_m2crypto_ssl_connection_check(*args, **kw):
    """This needs to return True, it's used to bypass a check in 
    M2Crypto.SSL.Connection
    """
    return True


def init_hook(conduit):
    """ 
    Plugin initialization hook. We setup the RHN channels here. 
    
    We get a list of RHN channels from the server, then make a repo object for
    each one. This list of repos is then added to yum's list of repos via the 
    conduit.
    """

    global rhn_enabled
   
    RHN_DISABLED = _("RHN support will be disabled.")
    
    #####bz 332011 
    #This will bypass a check in M2Crypto.SSL.Connection.
    #The check we are bypassing, was causing an exception on multi-homed machines
    #when the SSL Cert "commonName" did not match the name used to connect to the host.
    #This functionality was different than RHEL4, desire was to bypass the check to 
    #maintain the functionality in RHEL4 
    setattr(Connection, "clientPostConnectionCheck", bypass_m2crypto_ssl_connection_check)

    if not os.geteuid()==0:
        # If non-root notify user RHN repo not accessible
        conduit.error(0, _("*Note* Red Hat Network repositories are not listed below. You must run this command as root to access RHN repositories."))
        rhn_enabled = False
        return

    up2date_cfg = config.initUp2dateConfig()
    try:
        proxy_url = get_proxy_url(up2date_cfg)
        proxy_dict = {}
        if up2date_cfg['useNoSSLForPackages']:
            proxy_dict = {'HTTP' : proxy_url}
        else:
            proxy_dict = {'HTTPS' : proxy_url}
    except BadProxyConfig:
        rhn_enabled = False
        PROXY_ERROR =  _("There was an error parsing the RHN proxy settings.") 
        conduit.error(0, PROXY_ERROR + "\n" + RHN_DISABLED)
        return 

    # We might not have an opt parser (ie in pirut)
    opt_parser = conduit.getOptParser()
    if opt_parser:
        (opts, commands) = opt_parser.parse_args()

        if len(commands) > 0 and commands[0] == 'clean':
            formReposForClean(conduit)
            conduit.info(10, _("Cleaning") +
                "\n" + RHN_DISABLED)
            return

        if  (hasattr(opts,'version') and opts.version) or (len(commands) == 0):
            rhn_enabled = False
            conduit.info(10, _("Either --version, or no commands entered") +
                "\n" + RHN_DISABLED)
            return

    try:
        login_info = up2dateAuth.getLoginInfo()
    except up2dateErrors.RhnServerException, e:
        rewordError(e)
        conduit.error(0, COMMUNICATION_ERROR + "\n" + RHN_DISABLED + "\n" +
            str(e))
        rhn_enabled = False
        return

    if not login_info:
        conduit.error(0, _("This system is not registered with RHN.") + "\n" +
            RHN_DISABLED)
        rhn_enabled = False
        return 

    CHANNELS_DISABLED = _("RHN channel support will be disabled.")
    try:
        svrChannels = rhnChannel.getChannelDetails()
    except up2dateErrors.NoChannelsError:
        conduit.error(0, _("This system is not subscribed to any channels.") + 
            "\n" + CHANNELS_DISABLED)
        return
    except up2dateErrors.NoSystemIdError:
        conduit.error(0, _("This system may not be a registered to RHN. SystemId could not be acquired.\n") +
                          RHN_DISABLED)
        rhn_enabled = False
        return
    except up2dateErrors.RhnServerException, e:
        conduit.error(0, COMMUNICATION_ERROR + "\n" + CHANNELS_DISABLED + 
            "\n" + str(e))
        return

    repos = conduit.getRepos()
    cachedir = conduit.getConf().cachedir
    default_gpgcheck = conduit.getConf().gpgcheck
    gpgcheck = conduit.confBool('main', 'gpgcheck', default_gpgcheck)
    sslcacert = get_ssl_ca_cert(up2date_cfg)
    enablegroups = conduit.getConf().enablegroups

    for channel in svrChannels:
        if channel['version']:
            repo = RhnRepo(channel)
            repo.basecachedir = cachedir
            repo.gpgcheck = gpgcheck
            repo.proxy = proxy_url
            repo.sslcacert = sslcacert
            repo.enablegroups = enablegroups
            repoOptions = getRHNRepoOptions(conduit, repo.id)
            if repoOptions:
                for o in repoOptions:
                    setattr(repo, o[0], o[1])
                    conduit.info(5, "Repo '%s' setting option '%s' = '%s'" %
                            (repo.id, o[0], o[1]))
            repos.add(repo)


#bz226151,441265
#Allows a "yum clean all" to succeed without communicating
#to backend.  Creating a set of dummy repos which mimic the dirs stored locally
#This gives yum the dir info it needs to peform a clean
#
def formReposForClean(conduit):
    repos = conduit.getRepos()
    cachedir = conduit.getConf().cachedir
    try:
        dir_list = os.listdir(cachedir)
    except Exception, e:
        raise yum.Errors.RepoError(str(e))
    urls = ["http://dummyvalue"]
    for dir in dir_list:
        if dir[0] == ".":
            continue
        if os.path.isdir(os.path.join(cachedir,dir)):
            repo = YumRepository(dir)
            repo.basecachedir = cachedir
            repo.baseurl = urls 
            repo.urls = repo.baseurl
            repo.enable()
            if not repos.findRepos(repo.id):
                repos.add(repo)
   # cleanup cached login info
    if os.path.exists(pcklAuthFileName):
        os.unlink(pcklAuthFileName)

def posttrans_hook(conduit):
    """ Post rpm transaction hook. We update the RHN profile here. """
    global rhn_enabled
    if rhn_enabled:
        up2date_cfg = config.initUp2dateConfig()
        if up2date_cfg.has_key('writeChangesToLog') and up2date_cfg['writeChangesToLog'] == 1:
            ts_info = conduit.getTsInfo()
            delta = make_package_delta(ts_info)
            rhnPackageInfo.logDeltaPackages(delta)
        try:
            rhnPackageInfo.updatePackageProfile()
        except up2dateErrors.RhnServerException, e:
            conduit.error(0, COMMUNICATION_ERROR + "\n" +
                _("Package profile information could not be sent.") + "\n" + 
                str(e))

def rewordError(e):
    #This is compensating for hosted/satellite returning back an error
    #message instructing RHEL5 clients to run "up2date --register"
    #bz: 438175
    replacedText = _("Error Message:") + "\n\t" + \
        _("Please run rhn_register as root on this client")
    index = e.errmsg.find(": 9\n")
    if index == -1:
        return
    if e.errmsg.find("up2date", 0, index) == -1:
        return
    #Find where the "Error Class Code" text begins, to account
    #for different languages, looking for new line character
    #preceeding the Error Class Code
    indexB = e.errmsg.rfind("\n", 0, index)
    e.errmsg = "\n" + replacedText + e.errmsg[indexB:]
                
            

class RhnRepo(YumRepository):

    """
    Repository object for Red Hat Network.

    This, along with the RhnPackageSack, adapts up2date for use with
    yum.
    """
    rhn_needed_headers = ['X-RHN-Server-Id',
                          'X-RHN-Auth-User-Id',
                          'X-RHN-Auth',
                          'X-RHN-Auth-Server-Time',
                          'X-RHN-Auth-Expire-Offset']
    
    def __init__(self, channel):
        YumRepository.__init__(self, channel['label'])
        self.name = channel['name']
        self.label = channel['label']
        self._callbacks_changed = False

        # support failover urls, #232567
        urls = []
        if type(channel['url']) == list:
          for url in channel['url']:
            urls.append(url + '/GET-REQ/' + self.id)
        else:
          urls.append(channel['url'] + '/GET-REQ/' + self.id)

        self.baseurl = urls 
        self.urls = self.baseurl
        self.failovermethod = 'priority'
        self.keepalive = 0
        self.bandwidth = 0
        self.retries = 1
        self.throttle = 0
        self.timeout = 60.0

        self.http_caching = True

        self.gpgkey = []
        self.gpgcheck = False
    
        try:
            self.gpgkey = get_gpg_key_urls(channel['gpg_key_url'])
        except InvalidGpgKeyLocation:
            #TODO: Warn about this or log it
            pass

        self.enable()

    def setupRhnHttpHeaders(self):
        """ Set up self.http_headers with needed RHN X-RHN-blah headers """
        
        try:
            li = up2dateAuth.getLoginInfo()
        except up2dateErrors.RhnServerException, e:
            raise yum.Errors.RepoError(str(e))

        # TODO:  do evalution on li auth times to see if we need to obtain a
        # new session...

        for header in RhnRepo.rhn_needed_headers:
            if not li.has_key(header):
                error = _("Missing required login information for RHN: %s") \
                    % header
                raise yum.Errors.RepoError(error)
            
            self.http_headers[header] = li[header]
        # Set the redirect flag
        self.http_headers['X-RHN-Transport-Capability'] = "follow-redirects=3"

    # Override the 'private' __get method so we can do our auth stuff.
    def _getFile(self, url=None, relative=None, local=None,
        start=None, end=None, copy_local=0, checkfunc=None, text=None,
        reget='simple', cache=True, size=None):
        try:
            try:
                return self._noExceptionWrappingGet(url, relative, local,
                    start, end, copy_local, checkfunc, text, reget, cache, size)
            except URLGrabError, e:
                try:
                    up2dateAuth.updateLoginInfo()
                except up2dateErrors.RhnServerException, e:
                    raise yum.Errors.RepoError(str(e))

                return self._noExceptionWrappingGet(url, relative, local,
                    start, end, copy_local, checkfunc, text, reget, cache, size)

        except URLGrabError, e:
            raise yum.Errors.RepoError, \
                "failed to retrieve %s from %s\nerror was %s" % (relative,
                self.id, e)
        except SSLError, e:
            raise yum.Errors.RepoError(str(e))
        except up2dateErrors.InvalidRedirectionError, e:
            raise up2dateErrors.InvalidRedirectionError(e)
    _YumRepository__get = _getFile

    # This code is copied from yum, we should get the original code to
    # provide more detail in its exception, so we don't have to cut n' paste
    def _noExceptionWrappingGet(self, url=None, relative=None, local=None,
        start=None, end=None, copy_local=0, checkfunc=None, text=None,
        reget='simple', cache=True, size=None):
        """retrieve file from the mirrorgroup for the repo
           relative to local, optionally get range from
           start to end, also optionally retrieve from a specific baseurl"""

        # if local or relative is None: raise an exception b/c that shouldn't happen
        # return the path to the local file

        self.setupRhnHttpHeaders()
        if pycurl:
            # pycurl/libcurl workaround: in libcurl setting an empty HTTP header means
            # remove that header from the list
            # but we have to send and empty X-RHN-Auth-User-Id ...
            AuthUserH = 'X-RHN-Auth-User-Id'
            if (AuthUserH in self.http_headers and not self.http_headers[AuthUserH]):
                self.http_headers[AuthUserH] = "\nX-libcurl-Empty-Header-Workaround: *"

        # Turn our dict into a list of 2-tuples
        headers = YumRepository._YumRepository__headersListFromDict(self)

        # We will always prefer to send no-cache.
        if not (cache or self.http_headers.has_key('Pragma')):
            headers.append(('Pragma', 'no-cache'))

        headers = tuple(headers)

        if local is None or relative is None:
            raise yum.Errors.RepoError, \
                  "get request for Repo %s, gave no source or dest" % self.id

        if self.failure_obj:
            (f_func, f_args, f_kwargs) = self.failure_obj
            self.failure_obj = (f_func, f_args, f_kwargs)

        if self.cache == 1:
            if os.path.exists(local): # FIXME - we should figure out a way
                return local          # to run the checkfunc from here

            else: # ain't there - raise
                raise yum.Errors.RepoError, \
                    "Caching enabled but no local cache of %s from %s" % (local,
                           self)

        if url is not None:
            remote = url + '/' + relative
            result = self.grab.urlgrab(remote, local,
                                      text = text,
                                      range = (start, end),
                                      copy_local=copy_local,
                                      reget = reget,
                                      checkfunc=checkfunc,
                                      http_headers=headers,
                                      ssl_ca_cert = self.sslcacert,
                                      timeout=self.timeout,
                                      size = size
                                      )
            return result

        result = None
        urlException = None
        for server in self.baseurl:
            #force to http if configured
            up2date_cfg = config.initUp2dateConfig()
            if up2date_cfg['useNoSSLForPackages'] == 1:
                server = force_http(server)
            #Sanity check the url
            check_url(server)
            # Construct the full url string
            remote = server + '/' + relative
            try:
                result = self.grab.urlgrab(remote, local,
                                          text = text,
                                          range = (start, end),
                                          copy_local=copy_local,
                                          reget = reget,
                                          checkfunc=checkfunc,
                                          http_headers=headers,
                                          ssl_ca_cert = self.sslcacert,
                                          timeout=self.timeout,
                                          size = size
                                          )
                return result
            except URLGrabError, e:
                urlException = e
                continue
            
        if result == None:
            raise urlException
        return result

    def _setupGrab(self):
        """sets up the grabber functions. We don't want to use mirrors."""

        headers = tuple(YumRepository._YumRepository__headersListFromDict(self))

        self._grabfunc = URLGrabber(keepalive=self.keepalive,
                                   bandwidth=self.bandwidth,
                                   retry=self.retries,
                                   throttle=self.throttle,
                                   progress_obj=self.callback,
                                   proxies = self.proxy_dict,
                                   interrupt_callback=self.interrupt_callback,
                                   timeout=self.timeout,
                                   http_headers=headers,
                                   reget='simple')
        #bz453690 ensure that user-agent header matches for communication from
        #up2date library calls, as well as yum-rhn-plugin calls
        self._grabfunc.opts.user_agent = rhn.transports.Transport.user_agent
        self._grab = self._grabfunc
    setupGrab = _setupGrab

    def _getgrabfunc(self):
        if not self._grabfunc or self._callbacks_changed:
            self._setupGrab()
            self._callbacks_changed = False
        return self._grabfunc
    def _getgrab(self):
        if not self._grab or self._callbacks_changed:
            self._setupGrab()
            self._callbacks_changed = False
        return self._grab

    grabfunc = property(lambda self: self._getgrabfunc())
    grab = property(lambda self: self._getgrab())

    def _setChannelEnable(self, value=1):
        """ Enable or disable channel in file rhnplugin.conf.
            channel is label of channel and value should be 1 or 0.
        """
        cfg = INIConfig(file('/etc/yum/pluginconf.d/rhnplugin.conf'))
        # we cannot use directly cfg[channel].['enabled'], because
        # if that section do not exist it raise error
        func=getattr(cfg, self.label)
        func.enabled=value
        f=open('/etc/yum/pluginconf.d/rhnplugin.conf', 'w')
        print >>f, cfg
        f.close()

    def enablePersistent(self):
        """
        Persistently enable channel in rhnplugin.conf
        """
        self._setChannelEnable(1)
        self.enable()

    def disablePersistent(self):
        """
        Persistently disable channel in rhnplugin.conf
        """
        self._setChannelEnable(0)
        self.disable()

    def _getRepoXML(self):
        import yum.Errors
        try:
            return YumRepository._getRepoXML(self)
        except yum.Errors.RepoError, e:
            # Refresh our loginInfo then try again
            # possibly it's out of date
            up2dateAuth.updateLoginInfo()
            return YumRepository._getRepoXML(self)

def make_package_delta(ts_info):
    """
    Construct an RHN style package delta from a yum TransactionData object.

    Return a hash containing two keys: added and removed.
    Each key's value is a list of RHN style package tuples.
    """

    delta = {}
    delta["added"] = []
    delta["removed"] = []

    # Make sure the transaction data has the packages in nice lists.
    ts_info.makelists()

    for ts_member in ts_info.installed:
        package = ts_member.po
        pkgtup = __rhn_pkg_tup_from_po(package)
        delta["added"].append(pkgtup)

    for ts_member in ts_info.depinstalled:
        package = ts_member.po
        pkgtup = __rhn_pkg_tup_from_po(package)
        delta["added"].append(pkgtup)

    for ts_member in ts_info.updated:
        package = ts_member.po
        pkgtup = __rhn_pkg_tup_from_po(package)
        delta["added"].append(pkgtup)

    for ts_member in ts_info.depupdated:
        package = ts_member.po
        pkgtup = __rhn_pkg_tup_from_po(package)
        delta["added"].append(pkgtup)

    for ts_member in ts_info.removed:
        package = ts_member.po
        pkgtup = __rhn_pkg_tup_from_po(package)
        delta["removed"].append(pkgtup)

    for ts_member in ts_info.depremoved:
        package = ts_member.po
        pkgtup = __rhn_pkg_tup_from_po(package)
        delta["removed"].append(pkgtup)

    return delta

def __rhn_pkg_tup_from_po(package):
    """ Construct an rhn-style package tuple from a yum package object. """

    name = package.returnSimple('name')
    epoch = package.returnSimple('epoch')
    version = package.returnSimple('version')
    release = package.returnSimple('release')
    arch = package.returnSimple('arch')

    return (name, version, release, epoch, arch)


class BadConfig(Exception):
    pass

class BadProxyConfig(BadConfig):
    pass

class BadSslCaCertConfig(BadConfig):
    pass

def get_proxy_url(up2date_cfg):
    if not up2date_cfg['enableProxy']:
        return None

    proxy_url = ""
    if up2date_cfg['useNoSSLForPackages']:
        proxy_url = 'http://'
    else:
        proxy_url = 'https://'
    if up2date_cfg['enableProxyAuth']:
        if not up2date_cfg.has_key('proxyUser') or \
            up2date_cfg['proxyUser'] == '':
            raise BadProxyConfig
        if not up2date_cfg.has_key('proxyPassword') or \
            up2date_cfg['proxyPassword'] == '':
            raise BadProxyConfig
        proxy_url = proxy_url + up2date_cfg['proxyUser']
        proxy_url = proxy_url + ':'
        proxy_url = proxy_url + urllib.quote(up2date_cfg['proxyPassword'])
        proxy_url = proxy_url + '@'
   
    netloc = up2date_cfg['httpProxy']
    if netloc == '':
        raise BadProxyConfig

    # Check if a protocol is supplied. We'll ignore it.
    proto_split = netloc.split('://')
    if len(proto_split) > 1:
       netloc = proto_split[1]

    return proxy_url + netloc


class InvalidGpgKeyLocation(Exception):
    pass

def is_valid_gpg_key_url(key_url):
    proto_split = key_url.split('://')
    if len(proto_split) != 2:
        return False
    
    proto, path = proto_split
    if proto.lower() != 'file':
        return False

    path = os.path.normpath(path)
    if not path.startswith('/etc/pki/rpm-gpg/'):
        return False
    return True

def get_gpg_key_urls(key_url_string):
    """
    Parse the key urls and validate them.

    key_url_string is a space seperated list of gpg key urls that must be
    located in /etc/pkg/rpm-gpg/.
    Return a list of strings containing the key urls.
    Raises InvalidGpgKeyLocation if any of the key urls are invalid.
    """
    key_urls = key_url_string.split()
    for key_url in key_urls:
        if not is_valid_gpg_key_url(key_url):
            raise InvalidGpgKeyLocation
    return key_urls

def get_ssl_ca_cert(up2date_cfg):
    if not (up2date_cfg.has_key('sslCACert') and up2date_cfg['sslCACert']):
        raise BadSslCaCertConfig

    ca_certs = up2date_cfg['sslCACert']
    if type(ca_certs) == list:
        return ca_certs[0]

    return ca_certs

def check_url(serverurl):
    typ, uri = urllib.splittype(serverurl)
    if typ != None:
        typ = typ.lower()
    up2date_cfg = config.initUp2dateConfig()
    if up2date_cfg['useNoSSLForPackages']:
        if typ.strip() not in ("http"):
            raise up2dateErrors.InvalidProtocolError("You specified an invalid "
                    "protocol.  Option useNoSSLServerForPackages requires http")
    elif typ.strip() not in ("http", "https"):
        raise up2dateErrors.InvalidProtocolError("You specified an invalid "
                                                 "protocol. Only https and "
                                                 "http are allowed.")

def force_http(serverurl):
    """
    Returns a url using http
    """
    httpUrl = serverurl
    typ, uri = urllib.splittype(serverurl)
    if typ != None:
        typ = typ.lower().strip()
    if typ not in ("http"):
        httpUrl = "http:" + uri
    return httpUrl

def getRHNRepoOptions(conduit, repoid):
    from ConfigParser import NoSectionError
    conduit.info(5, "Looking for repo options for [%s]" % (repoid))
    try:
        if conduit:
            if hasattr(conduit, "_conf") and hasattr(conduit._conf, "items"):
                return conduit._conf.items(repoid)
    except NoSectionError, e:
        pass
    return None



