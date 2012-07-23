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
except ImportError:
    pycurl = None

from iniparse import INIConfig

import gettext
t = gettext.translation('yum-rhn-plugin', fallback=True)
_ = t.ugettext

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
cachedRHNReposFile = 'rhnplugin.repos'

rhn_enabled = True

COMMUNICATION_ERROR = _("There was an error communicating with RHN.")

from M2Crypto.SSL import SSLError

def init_hook(conduit):
    """
    Plugin initialization hook. We setup the RHN channels here.

    We get a list of RHN channels from the server, then make a repo object for
    each one. This list of repos is then added to yum's list of repos via the 
    conduit.
    """

    global rhn_enabled
   
    RHN_DISABLED = _("RHN Satellite or RHN Classic support will be disabled.")
    
    if not os.geteuid()==0:
        # If non-root notify user RHN repo not accessible
        conduit.error(0, _("*Note* Red Hat Network repositories are not listed below. You must run this command as root to access RHN repositories."))
        rhn_enabled = False
        return

    up2date_cfg = config.initUp2dateConfig()
    proxy_dict = {}
    try:
        proxy_url = get_proxy_url(up2date_cfg)
        if proxy_url:
            if up2date_cfg['useNoSSLForPackages']:
                proxy_dict = {'HTTP' : proxy_url}
            else:
                proxy_dict = {'HTTPS' : proxy_url}
    except BadProxyConfig:
        rhn_enabled = False
        PROXY_ERROR =  _("There was an error parsing the RHN proxy settings.") 
        conduit.error(0, PROXY_ERROR + "\n" + RHN_DISABLED)
        return 

    # check commands and options which don't need network communication
    prog_name = os.path.basename(sys.argv[0])
    if prog_name == 'yum':
        cmd_args = sys.argv[1:]
        if ('--help' in cmd_args
            or '--version' in cmd_args
            or cmd_args == []):
            rhn_enabled = False
            conduit.info(10, _("Either --version, --help or no commands entered") +
                     "\n" + RHN_DISABLED)
            return
        if 'clean' in cmd_args:
            addCachedRepos(conduit)
            conduit.info(10, _("Cleaning") + "\n" + RHN_DISABLED)
            # cleanup cached login info
            if os.path.exists(pcklAuthFileName):
                os.unlink(pcklAuthFileName)
            return
        if ('-C' in cmd_args
            or '--cacheonly' in cmd_args):
            rhn_enabled = False
            addCachedRepos(conduit)
            conduit.info(10, _("Using list of RHN repos from cache") +
                     "\n" + RHN_DISABLED)
            return

    try:
        login_info = up2dateAuth.getLoginInfo()
    except up2dateErrors.RhnServerException, e:
        rewordError(e)
        conduit.error(0, COMMUNICATION_ERROR + "\n" + RHN_DISABLED + "\n" +
            unicode(e))
        rhn_enabled = False
        return

    if not login_info:
        conduit.error(0, _("This system is not registered with RHN Classic or RHN Satellite.") +
                "\n" + _("You can use rhn_register to register.") +
                "\n" + RHN_DISABLED)
        rhn_enabled = False
        truncateRHNReposCache(conduit)
        return 

    CHANNELS_DISABLED = _("RHN channel support will be disabled.")
    try:
        svrChannels = rhnChannel.getChannelDetails()
    except up2dateErrors.NoChannelsError:
        conduit.error(0, _("This system is not subscribed to any channels.") + 
            "\n" + CHANNELS_DISABLED)
        truncateRHNReposCache(conduit)
        return
    except up2dateErrors.NoSystemIdError:
        conduit.error(0, _("This system may not be a registered to RHN Classic or RHN Satellite. SystemId could not be acquired.") +
                "\n" + _("You can use rhn_register to register.") +
                "\n" + RHN_DISABLED)
        rhn_enabled = False
        return
    except up2dateErrors.RhnServerException, e:
        conduit.error(0, COMMUNICATION_ERROR + "\n" + CHANNELS_DISABLED + 
            "\n" + unicode(e))
        return

    if rhn_enabled:
        conduit.info(2, _("This system is receiving updates from RHN Classic or RHN Satellite."))

    repos = conduit.getRepos()
    conduit_conf = conduit.getConf()
    timeout = conduit_conf.timeout
    cachedir = conduit_conf.cachedir
    sslcacert = get_ssl_ca_cert(up2date_cfg)
    pluginOptions = getRHNRepoOptions(conduit, 'main')

    cachefile = openRHNReposCache(conduit)
    for channel in svrChannels:
        if channel['version']:
            repo = RhnRepo(channel)
            repo.basecachedir = cachedir
            repo.gpgcheck = conduit_conf.gpgcheck
            repo.proxy = proxy_url
            repo.sslcacert = sslcacert
            repo.enablegroups = conduit_conf.enablegroups
            repo.metadata_expire = conduit_conf.metadata_expire
            repo.exclude = conduit_conf.exclude
            repo._proxy_dict = proxy_dict
            if repo.timeout < timeout:
                repo.timeout = timeout
            if hasattr(conduit_conf, '_repos_persistdir'):
                repo.base_persistdir = conduit_conf._repos_persistdir
            repoOptions = getRHNRepoOptions(conduit, repo.id)
            for options in [pluginOptions, repoOptions]:
                if options:
                    for o in options:
                        if o[0] == 'exclude': # extend current list
                            setattr(repo, o[0], ",".join(repo.exclude) + ',' + o[1])
                        else: # replace option
                            setattr(repo, o[0], o[1])
                        conduit.info(5, "Repo '%s' setting option '%s' = '%s'" %
                            (repo.id, o[0], o[1]))
            repos.add(repo)
            if cachefile:
                cachefile.write("%s %s\n" % (repo.id, repo.name))
    if cachefile:
        cachefile.close()

def openRHNReposCache(conduit):
    cachedir = conduit.getConf().cachedir
    cachefilename = os.path.join(cachedir, cachedRHNReposFile)
    try:
        if not os.path.exists(cachedir):
            os.makedirs(cachedir, 0755)
        cachefile = open(cachefilename, 'w')
    except:
        cachefile = None
    return cachefile

def truncateRHNReposCache(conduit):
    cachefile = openRHNReposCache(conduit)
    if cachefile:
        cachefile.truncate()
        cachefile.close()

def addCachedRepos(conduit):
    """
    Add list of repos we've seen last time (from cache file)
    """
    repos = conduit.getRepos()
    cachedir = conduit.getConf().cachedir
    cachefilename = os.path.join(cachedir, cachedRHNReposFile)
    if not os.access(cachefilename, os.R_OK):
        return
    cachefile = open(cachefilename, 'r')
    repolist = [ line.rstrip().split(' ', 1) for line in cachefile.readlines()]
    cachefile.close()
    urls = ["http://dummyvalue"]
    for repo_item in repolist:
        if len(repo_item) == 1:
            repo_item.append('')
        (repoid, reponame) = repo_item
        repodir = os.path.join(cachedir, repoid)
        if os.path.isdir(repodir):
            repo = YumRepository(repoid)
            repo.basecachedir = cachedir
            repo.baseurl = urls
            repo.urls = repo.baseurl
            repo.name = reponame
            if hasattr(conduit.getConf(), '_repos_persistdir'):
                repo.base_persistdir = conduit.getConf()._repos_persistdir
            repo.enable()
            if not repos.findRepos(repo.id):
                repos.add(repo)

def posttrans_hook(conduit):
    """ Post rpm transaction hook. We update the RHN profile here. """
    global rhn_enabled
    if rhn_enabled:
        up2date_cfg = config.initUp2dateConfig()
        if up2date_cfg.has_key('writeChangesToLog') and up2date_cfg['writeChangesToLog'] == 1:
            ts_info = conduit.getTsInfo()
            delta = make_package_delta(ts_info)
            rhnPackageInfo.logDeltaPackages(delta)
        if up2dateAuth.getSystemId(): # are we registred?
            try:
                rhnPackageInfo.updatePackageProfile()
            except up2dateErrors.RhnServerException, e:
                conduit.error(0, COMMUNICATION_ERROR + "\n" +
                    _("Package profile information could not be sent.") + "\n" + 
                    unicode(e))

def rewordError(e):
    """ This is compensating for hosted/satellite returning back an error
        message instructing RHEL5 clients to run "rhn_register"
        bz: 438175
    """
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
        else: # type will be always list since Spacewalk 1.4, in future this will be dead coed
            urls.append(channel['url'] + '/GET-REQ/' + self.id)

        self.baseurl = urls 
        self.urls = self.baseurl
        self.failovermethod = 'priority'
        self.keepalive = 0
        self.bandwidth = 0
        self.retries = 1
        self.throttle = 0
        self.timeout = 60.0
        self.metadata_expire = 21700

        self.http_caching = True

        self.gpgkey = []
        self.gpgcheck = False
        self.up2date_cfg = config.initUp2dateConfig()
    
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
            raise yum.Errors.RepoError(unicode(e)), None, sys.exc_info()[2]
        except e:
            raise yum.Errors.RepoError(unicode(e)), None, sys.exc_info()[2]

        # TODO:  do evalution on li auth times to see if we need to obtain a
        # new session...

        for header in RhnRepo.rhn_needed_headers:
            if not li.has_key(header):
                error = _("Missing required login information for RHN: %s") \
                    % header
                raise yum.Errors.RepoError(error)
            
            self.http_headers[header] = li[header]
        if not self.up2date_cfg['useNoSSLForPackages']:
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
                    raise yum.Errors.RepoError(unicode(e)), None, sys.exc_info()[2]

                return self._noExceptionWrappingGet(url, relative, local,
                    start, end, copy_local, checkfunc, text, reget, cache, size)

        except URLGrabError, e:
            raise yum.Errors.RepoError, \
                "failed to retrieve %s from %s\nerror was %s" % (relative,
                self.id, e), sys.exc_info()[2]
        except SSLError, e:
            raise yum.Errors.RepoError(unicode(e)), None, sys.exc_info()[2]
        except up2dateErrors.InvalidRedirectionError, e:
            raise up2dateErrors.InvalidRedirectionError(e), None, sys.exc_info()[2]
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
        headers = YumRepository._YumRepository__headersListFromDict(self)   # pylint: disable-msg=E1101

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
                                      ssl_ca_cert = self.sslcacert.encode('utf-8'),
                                      timeout=self.timeout,
                                      size = size
                                      )
            return result

        result = None
        urlException = None
        for server in self.baseurl:
            #force to http if configured
            if self.up2date_cfg['useNoSSLForPackages'] == 1:
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
                                          ssl_ca_cert = self.sslcacert.encode('utf-8'),
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

        try:
            ugopts = self._default_grabopts()
            if "http_headers" in ugopts:
                del(ugopts["http_headers"])
        except AttributeError: # this method does not exist on RHEL5
            ugopts = { 'keepalive': self.keepalive,
                'bandwidth': self.bandwidth,
                'retry': self.retries,
                'throttle': self.throttle,
                'proxies': self.proxy_dict,
                'timeout': self.timeout,
            }
        headers = tuple(YumRepository._YumRepository__headersListFromDict(self)) # pylint: disable-msg=E1101

        self._grabfunc = URLGrabber(
                                   progress_obj=self.callback,
                                   interrupt_callback=self.interrupt_callback,
                                   copy_local=self.copy_local,
                                   http_headers=headers,
                                   reget='simple',
                                   **ugopts)
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
        func = getattr(cfg, self.label)
        func.enabled = value
        f = open('/etc/yum/pluginconf.d/rhnplugin.conf', 'w')
        print >> f, cfg
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
        try:
            return YumRepository._getRepoXML(self)
        except yum.Errors.RepoError:
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
   
    netloc = config.getProxySetting()
    if netloc == '':
        raise BadProxyConfig
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
    except NoSectionError:
        pass
    return None



