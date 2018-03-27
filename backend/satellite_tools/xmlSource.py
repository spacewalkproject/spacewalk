#
# Decoding data from XML streams
#
# Copyright (c) 2008--2018 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public License,
# version 2 (GPLv2). There is NO WARRANTY for this software, express or
# implied, including the implied warranties of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
# along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
#
# Red Hat trademarks are not licensed under GPLv2. No permission is
# granted to use or replicate Red Hat trademarks that are incorporated
# in this software or its documentation.
#

import sys
import re
from xml.sax import make_parser, SAXParseException, ContentHandler, \
    ErrorHandler

from spacewalk.common import usix
from spacewalk.common import rhnFlags
from spacewalk.common.rhnLog import log_debug
from spacewalk.common.rhnConfig import CFG
from spacewalk.common.rhnTB import Traceback
from spacewalk.server.importlib import importLib, backendLib

RHEL234_REGEX = re.compile("rhel-[^-]*-[aew]s-(4|3|2.1)")

# Terminology used throughout this file:
# Item: an atomic entity from the database's perspective.
#   A channel, or a package, or an erratum is an item.
# Container: a list of items
#   We work under the assumption everything on the second level (i.e. a child
#   of the root element) is a container.

# The way the parser works: get a handler with getHandler() and call process()
# with an XML stream.

# Our parser exceptions


class ParseException(Exception):

    """general parser exception (generated at this level).
    """
    pass


class _EndContainerEvent(Exception):

    def __init__(self, container):
        Exception.__init__(self)
        self.container = container


class IncompatibleVersionError(ParseException):

    def __init__(self, stream_version, parser_version, *args):
        ParseException.__init__(self, *args)
        self.stream_version = stream_version
        self.parser_version = parser_version

# XML parser exception wrappers
# Exposed functionality for the next three include:
#    getColumnNumber(), getLineNumber(), and _msg (or just str(e))


class RecoverableParseException(SAXParseException, Exception):

    """exception wrapper for a critical, but possibly recoverable, XML parser
       error.
    """
    pass


class FatalParseException(SAXParseException, Exception):

    """exception wrapper for a critical XML parser error.
    """
    pass

# XML Node


class Node:

    def __init__(self, name, attributes=None, subelements=None):
        self.name = name
        if attributes is None:
            attributes = {}
        if subelements is None:
            subelements = []
        self.attributes = attributes
        self.subelements = subelements

    def addSubelement(self, e):
        self.subelements.append(e)

    def __repr__(self):
        return "[<Node element: name=%s>]" % self.name


# Base class we use as a SAX parsing handler
class BaseDispatchHandler(ContentHandler, ErrorHandler):

    """ Base class we use as a SAX parsing handler

        We expect the meaningful data to be on the third level.
        The root element defines what the export contains, while the collection
        element defines what this collection contains
    """
    rootElement = None  # non-static
    __stream = None
    container_dispatch = {}

    def __init__(self):
        ContentHandler.__init__(self)
        self.rootAttributes = None
        self.__parser = make_parser()
        # Init the parser's handlers
        self.restoreParser()
        # No container at this time
        self.__container = None
        # Reset all the containers, to make sure previous runs don't leave
        # garbage data
        for container in self.container_dispatch.values():
            container.reset()

    def restoreParser(self):
        # Restore the parser's handlers to self
        self.__parser.setContentHandler(self)
        self.__parser.setErrorHandler(self)

    @staticmethod
    def setStream(stream):
        BaseDispatchHandler.__stream = stream

    # Starts processing the data from the XML stream
    def process(self, stream=None):
        log_debug(6)
        if stream is not None:
            self.setStream(stream)
        try:
            self.__parser.parse(self.__stream)
        except (KeyboardInterrupt, SystemExit):
            raise
        except Exception:  # pylint: disable=E0012, W0703
            Traceback(ostream=sys.stderr, with_locals=1)
            if stream is not None:
                stream.close()
            sys.exit(1)

    def reset(self):
        self.close()
        # Re-init
        self.__init__()

    def close(self):
        # WARNING: better call this function when you're done, or you'll end
        # up with a circular reference
        self.__parser = None

    def clear(self):
        # clear out the current container's parse batch; start afresh
        if self.__container:
            try:
                self.__container.batch = []
            except (KeyboardInterrupt, SystemExit):
                raise
            except Exception:
                e = sys.exc_info()[1]
                log_debug(-1, 'ERROR (odd) upon container.batch=[] cleanup: %s' % e)
                raise

    # Interface with containers
    def set_container(self, obj):
        if not hasattr(obj, "container_name"):
            raise Exception("%s not a container type" % type(obj))

        # reset the container (to clean up garbage from previous parses)
        obj.reset()
        self.container_dispatch[obj.container_name] = obj

    def get_container(self, name):
        if name not in self.container_dispatch:
            # Return a dummy container
            c = ContainerHandler()
            c.container_name = name
            return c

        return self.container_dispatch[name]

    def has_container(self, name):
        return (name in self.container_dispatch)

    # Overwrite the functions required by SAX
    def setDocumentLocator(self, locator):
        ContentHandler.setDocumentLocator(self, locator)

    # def startDocument(self):

    # def endDocument(self):

    def startElement(self, name, attrs):
        log_debug(6, name)
        utf8_attrs = _dict_to_utf8(attrs)
        if self.rootAttributes is None:
            # First time around
            if self.rootElement != name:
                raise Exception("Mismatching elements; root='%s', "
                                "received='%s'" % (self.rootElement, name))
            self.rootAttributes = utf8_attrs
            self._check_version()
            return

        if self.__container is None:
            # This means it's parsing a container element
            self.__container = self.get_container(name)

        self.__container.startElement(name, utf8_attrs)

    def characters(self, content):
        if self.__container:
            self.__container.characters(_stringify(content))

    def endElement(self, name):
        log_debug(6, name)
        if self.__container is None:
            # End of the root attribute
            # We know now the tag stack is empty
            self.rootAttributes = None
            return

        try:
            self.__container.endElement(name)
        except _EndContainerEvent:
            self.__container = None

    #___Error handling methods___

    # pylint: disable=W0212,W0710
    def error(self, exception):
        """Handle a recoverable error.
        """
        log_debug(-1, "ERROR (RECOVERABLE): parse error encountered - line: %s, col: %s, msg: %s"
                  % (exception.getLineNumber(), exception.getColumnNumber(), exception._msg))
        raise RecoverableParseException(exception._msg, exception, exception._locator)

    def fatalError(self, exception):
        """Handle a non-recoverable error.
        """
        log_debug(-1, "ERROR (FATAL): parse error encountered - line: %s, col: %s, msg: %s"
                  % (exception.getLineNumber(), exception.getColumnNumber(), exception._msg))
        raise FatalParseException(exception._msg, exception, exception._locator)

    def warning(self, exception):
        """Handle a warning.
        """
        log_debug(-1, "ERROR (WARNING): parse error encountered - line: %s, col: %s, msg: %s"
                  % (exception.getLineNumber(), exception.getColumnNumber(), exception._msg))

    # To be overridden in subclasses
    def _check_version(self):
        pass

# Particular case: a satellite handler


class SatelliteDispatchHandler(BaseDispatchHandler):
    rootElement = 'rhn-satellite'
    # this is the oldest version of channel dump we support
    version = "3.0"

    # Historical log
    # * Version 2.2 2004-03-02
    #    arch types introduced in all the arch dumps
    # * Version 2.3 2004-09-13
    #    added short package dumps per channel
    # * Version 3.0 2005-01-13
    #    required major version change for channel family merging (#136525)

    def _check_version(self):
        # Check the version
        version = self.rootAttributes.get("version")
        # Entitlement/certificate generation
        generation = self.rootAttributes.get("generation")
        rhnFlags.set("stream-generation", generation)
        if not version:
            version = "0"
        stream_version = list(map(int, version.split('.')))
        allowed_version = list(map(int, self.version.split(".")))
        if (stream_version[0] != allowed_version[0] or
                stream_version[1] < allowed_version[1]):
            raise IncompatibleVersionError(version, self.version,
                                           "Incompatible stream version %s; code supports %s" % (
                                               version, self.version))

# Element handler


class BaseItem:
    item_name = None
    item_class = object
    tagMap = {}

    def __init__(self):
        pass

    def populate(self, attributes, elements):
        item = self.item_class()
        # Populate the item from the attribute data structure
        self.populateFromAttributes(item, attributes)
        # Populate the item from sub-elements
        self.populateFromElements(item, elements)
        return item

    def populateFromAttributes(self, obj, sourceDict):
        # Populates dict with items from sourceDict
        for key, value in sourceDict.items():
            if key not in self.tagMap:
                if key not in obj:
                    # Unsupported key
                    continue
            else:
                # Have to map this key
                key = self.tagMap[key]

            # Finally, update the key
            obj[key] = _normalizeAttribute(obj.attributeTypes.get(key), value)

    def populateFromElements(self, obj, elements):
        # Populates obj with `elements' as subelements
        keys = list(obj.keys())
        keys_len = len(keys)
        for element in elements:
            if _is_string(element):
                if keys_len != 1:
                    if not element.strip():
                        # White space around an element - skip
                        continue
                    # Ambiguity: don't know which attribute to initialize
                    raise Exception("Ambiguity %s" % keys)
                # Init the only attribute we know of
                obj[keys[0]] = element
                continue
            name = element.name
            if name not in obj and name not in self.tagMap:
                # Unsupported key
                continue
            if name in self.tagMap:
                # Have to map this element
                name = self.tagMap[name]
            value = _normalizeSubelements(obj.attributeTypes.get(name),
                                          element.subelements)
            obj[name] = value


def _is_string(obj):
    if isinstance(obj, usix.StringType):
        return 1
    if isinstance(obj, usix.UnicodeType):
        return 1
    return 0


def _stringify(data):
    # Accelerate the most common cases
    if isinstance(data, usix.StringType):
        return data
    elif isinstance(data, usix.UnicodeType):
        return data.encode('UTF8')
    return str(data)


def _dict_to_utf8(d):
    # Convert the dictionary to have non-unocide key-value pairs
    ret = {}
    for k, v in d.items():
        if isinstance(k, usix.UnicodeType):
            k = k.encode('UTF8')
        if isinstance(v, usix.UnicodeType):
            v = v.encode('UTF8')
        ret[k] = v
    return ret


__itemDispatcher = {}


def addItem(classobj):
    __itemDispatcher[classobj.item_name] = classobj


def _createItem(element):
    # Creates an Item object from the specified element
    if element.name not in __itemDispatcher:
        # No item processor
        return None
    item = __itemDispatcher[element.name]()
    return item.populate(element.attributes, element.subelements)

#
# ITEMS:
#


class BaseArchItem(BaseItem):
    pass


class ServerArchItem(BaseArchItem):
    item_name = 'rhn-server-arch'
    item_class = importLib.ServerArch
addItem(ServerArchItem)


class PackageArchItem(BaseArchItem):
    item_name = 'rhn-package-arch'
    item_class = importLib.PackageArch
addItem(PackageArchItem)


class ChannelArchItem(BaseArchItem):
    item_name = 'rhn-channel-arch'
    item_class = importLib.ChannelArch
addItem(ChannelArchItem)


class CPUArchItem(BaseItem):
    item_name = 'rhn-cpu-arch'
    item_class = importLib.CPUArch
addItem(CPUArchItem)


class ServerPackageArchCompatItem(BaseItem):
    item_name = 'rhn-server-package-arch-compat'
    item_class = importLib.ServerPackageArchCompat
addItem(ServerPackageArchCompatItem)


class ServerChannelArchCompatItem(BaseItem):
    item_name = 'rhn-server-channel-arch-compat'
    item_class = importLib.ServerChannelArchCompat
addItem(ServerChannelArchCompatItem)


class ChannelPackageArchCompatItem(BaseItem):
    item_name = 'rhn-channel-package-arch-compat'
    item_class = importLib.ChannelPackageArchCompat
addItem(ChannelPackageArchCompatItem)


class ServerGroupServerArchCompatItem(BaseItem):
    item_name = 'rhn-server-group-server-arch-compat'
    item_class = importLib.ServerGroupServerArchCompat
addItem(ServerGroupServerArchCompatItem)


class ChannelFamilyItem(BaseItem):
    item_name = 'rhn-channel-family'
    item_class = importLib.ChannelFamily
    tagMap = {
        'id': 'channel-family-id',
        # max_members is no longer populated from the xml dump, but from the
        # satellite cert
        'rhn-channel-family-name': 'name',
        'rhn-channel-family-product-url': 'product_url',
        'channel-labels': 'channels',
    }
addItem(ChannelFamilyItem)


class ChannelItem(BaseItem):
    item_name = 'rhn-channel'
    item_class = importLib.Channel
    tagMap = {
        'channel-id': 'string_channel_id',
        'org-id': 'org_id',
        'rhn-channel-parent-channel': 'parent_channel',
        'rhn-channel-families': 'families',
        'channel-arch': 'channel_arch',
        'rhn-channel-basedir': 'basedir',
        'rhn-channel-name': 'name',
        'rhn-channel-summary': 'summary',
        'rhn-channel-description': 'description',
        'rhn-channel-last-modified': 'last_modified',
        'rhn-dists': 'dists',
        'rhn-release': 'release',
        'channel-errata': 'errata',
        'kickstartable-trees': 'kickstartable_trees',
        'rhn-channel-errata': 'errata_timestamps',
        'source-packages': 'source_packages',
        'rhn-channel-gpg-key-url': 'gpg_key_url',
        'rhn-channel-product-name': 'product_name',
        'rhn-channel-product-version': 'product_version',
        'rhn-channel-product-beta': 'product_beta',
        'rhn-channel-receiving-updates': 'receiving_updates',
        'rhn-channel-checksum-type': 'checksum_type',
        'rhn-channel-comps-last-modified': 'comps_last_modified',
        'rhn-channel-modules-last-modified': 'modules_last_modified',
        'sharing': 'channel_access',
        'rhn-channel-trusted-orgs': 'trust_list',
    }

    def populateFromElements(self, obj, elements):
        # bz 808516, to retain compatibility with Satellite <= 5.3 we
        # need to assume sha1 checksum type unless we explicitly see
        # 'rhn-null' in the xml
        checksum_type_really_null = False
        for element in elements:
            if (not _is_string(element)
                    and element.name == 'rhn-channel-checksum-type'):
                for subelement in element.subelements:
                    if (not _is_string(subelement)
                            and subelement.name == 'rhn-null'):
                        checksum_type_really_null = True

        BaseItem.populateFromElements(self, obj, elements)

        if obj['checksum_type'] == 'sha':
            obj['checksum_type'] = 'sha1'
        if not obj['checksum_type'] and not checksum_type_really_null:
            obj['checksum_type'] = 'sha1'

        # if importing from an old export that does not know about
        # channel_access, use the default
        if not obj['channel_access']:
            obj['channel_access'] = 'private'

        # if using versions of rhel that doesn't use yum, set
        # checksum_type to None
        if (RHEL234_REGEX.match(obj['label'])
                or (obj['parent_channel']
                    and RHEL234_REGEX.match(obj['parent_channel']))):
            obj['checksum_type'] = None

addItem(ChannelItem)


class ChannelTrustItem(BaseItem):
    item_name = 'rhn-channel-trusted-org'
    item_class = importLib.ChannelTrust
    tagMap = {
        'org-id': 'org_trust_id',
    }
addItem(ChannelTrustItem)


class OrgTrustItem(BaseItem):
    item_name = 'rhn-org-trust'
    item_class = importLib.OrgTrust
    tagMap = {
        'org-id': 'org_id',
    }
addItem(OrgTrustItem)


class OrgItem(BaseItem):
    item_name = 'rhn-org'
    item_class = importLib.Org
    tagMap = {
        'id': 'id',
        'name': 'name',
        'rhn-org-trusts': 'org_trust_ids',
    }
addItem(OrgItem)


class BaseChecksummedItem(BaseItem):

    def populate(self, attributes, elements):
        item = BaseItem.populate(self, attributes, elements)
        item['checksums'] = {}
        if 'md5sum' in item:
            # xml dumps < 3.6 (aka pre-sha256)
            item['checksums']['md5'] = item['md5sum']
            del(item['md5sum'])
        if 'checksum_list' in item and item['checksum_list']:
            for csum in item['checksum_list']:
                item['checksums'][csum['type']] = csum['value']
            del(item['checksum_list'])
        for ctype in CFG.CHECKSUM_PRIORITY_LIST:
            if ctype in item['checksums']:
                item['checksum_type'] = ctype
                item['checksum'] = item['checksums'][ctype]
                break
        return item
addItem(BaseChecksummedItem)


class IncompletePackageItem(BaseChecksummedItem):
    item_name = 'rhn-package-short'
    item_class = importLib.IncompletePackage
    tagMap = {
        'id': 'package_id',
        'package-size': 'package_size',
        'last-modified': 'last_modified',
        'package-arch': 'arch',
        'org-id': 'org_id',
        'checksums': 'checksum_list',
    }
addItem(IncompletePackageItem)


class ChecksumItem(BaseItem):
    item_name = 'checksum'
    item_class = importLib.Checksum
    tagMap = {
        'checksum-type': 'type',
        'checksum-value': 'value',
    }
addItem(ChecksumItem)


class PackageItem(IncompletePackageItem):
    item_name = 'rhn-package'
    item_class = importLib.Package
    tagMap = {
        # Stuff coming through as attributes
        'package-group': 'package_group',
        'rpm-version': 'rpm_version',
        'payload-size': 'payload_size',
        'build-host': 'build_host',
        'build-time': 'build_time',
        'source-rpm': 'source_rpm',
        'payload-format': 'payload_format',
        # Stuff coming through as subelements
        'rhn-package-summary': 'summary',
        'rhn-package-description': 'description',
        'rhn-package-vendor': 'vendor',
        'rhn-package-copyright': 'license',
        'rhn-package-header-sig': 'header_sig',
        # These are duplicated as attributes, should go away eventually
        'rhn-package-package-group': 'package_group',
        'rhn-package-rpm-version': 'rpm_version',
        'rhn-package-payload-size': 'payload_size',
        'rhn-package-header-start': 'header_start',
        'rhn-package-header-end': 'header_end',
        'rhn-package-build-host': 'build_host',
        'rhn-package-build-time': 'build_time',
        'rhn-package-source-rpm': 'source_rpm',
        'rhn-package-payload-format': 'payload_format',
        'rhn-package-cookie': 'cookie',
        #
        'rhn-package-files': 'files',
        'rhn-package-requires': 'requires',
        'rhn-package-provides': 'provides',
        'rhn-package-conflicts': 'conflicts',
        'rhn-package-obsoletes': 'obsoletes',
        'rhn-package-recommends': 'recommends',
        'rhn-package-suggests': 'suggests',
        'rhn-package-supplements': 'supplements',
        'rhn-package-enhances': 'enhances',
        'rhn-package-changelog': 'changelog',
    }
    tagMap.update(IncompletePackageItem.tagMap)

    def populate(self, attributes, elements):
        item = IncompletePackageItem.populate(self, attributes, elements)
        # find out "primary" checksum
        # pylint: disable=bad-option-value,unsubscriptable-object,unsupported-assignment-operation
        have_filedigests = len([1 for i in item['requires'] if i['name'] == 'rpmlib(FileDigests)'])
        if not have_filedigests:
            item['checksum_type'] = 'md5'
            item['checksum'] = item['checksums']['md5']
        return item
addItem(PackageItem)


class IncompleteSourcePackageItem(BaseItem):
    item_name = 'source-package'
    item_class = importLib.IncompleteSourcePackage
    tagMap = {
        'last-modified': 'last_modified',
        'source-rpm': 'source_rpm',
    }
addItem(IncompleteSourcePackageItem)


class SourcePackageItem(BaseItem):
    item_name = 'rhn-source-package'
    item_class = importLib.SourcePackage
    tagMap = {
        'id': 'package_id',
        'source-rpm': 'source_rpm',
        'package-group': 'package_group',
        'rpm-version': 'rpm_version',
        'payload-size': 'payload_size',
        'build-host': 'build_host',
        'build-time': 'build_time',
        'package-size': 'package_size',
        'last-modified': 'last_modified',
    }
addItem(SourcePackageItem)


class ChangelogItem(BaseItem):
    item_name = 'rhn-package-changelog-entry'
    item_class = importLib.ChangeLog
    tagMap = {
        'rhn-package-changelog-entry-name': 'name',
        'rhn-package-changelog-entry-text': 'text',
        'rhn-package-changelog-entry-time': 'time',
    }
addItem(ChangelogItem)


class DependencyItem(BaseItem):

    """virtual class - common settings for dependency items"""
    item_class = importLib.Dependency
    tagMap = {
        'sense': 'flags',
    }


class ProvidesItem(DependencyItem):
    item_name = 'rhn-package-provides-entry'
addItem(ProvidesItem)


class RequiresItem(DependencyItem):
    item_name = 'rhn-package-requires-entry'
addItem(RequiresItem)


class ConflictsItem(DependencyItem):
    item_name = 'rhn-package-conflicts-entry'
addItem(ConflictsItem)


class ObsoletesItem(DependencyItem):
    item_name = 'rhn-package-obsoletes-entry'
addItem(ObsoletesItem)


class RecommendsItem(DependencyItem):
    item_name = 'rhn-package-recommends-entry'
addItem(RecommendsItem)


class SuggestsItem(DependencyItem):
    item_name = 'rhn-package-suggests-entry'
addItem(SuggestsItem)


class SupplementsItem(DependencyItem):
    item_name = 'rhn-package-supplements-entry'
addItem(SupplementsItem)


class EnhancesItem(DependencyItem):
    item_name = 'rhn-package-enhances-entry'
addItem(EnhancesItem)


class FileItem(BaseChecksummedItem):
    item_name = 'rhn-package-file'
    item_class = importLib.File
    tagMap = {
        'checksum-type': 'checksum_type',
    }

    def populate(self, attributes, elements):
        if 'md5' in attributes and 'checksum-type' not in attributes:
            attributes['checksum-type'] = 'md5'
            attributes['checksum'] = attributes['md5']
        item = BaseChecksummedItem.populate(self, attributes, elements)
        return item
addItem(FileItem)


class DistItem(BaseItem):
    item_name = 'rhn-dist'
    item_class = importLib.DistChannelMap
    tagMap = {
        'channel-arch': 'channel_arch',
    }
addItem(DistItem)


class ChannelErratumItem(BaseItem):
    item_name = 'erratum'
    item_class = importLib.ChannelErratum
    tagMap = {
        'last-modified': 'last_modified',
        'advisory-name': 'advisory_name',
    }
addItem(ChannelErratumItem)


class ReleaseItem(BaseItem):
    item_name = 'rhn-release'
    item_class = importLib.ReleaseChannelMap
    tagMap = {
        'channel-arch': 'channel_arch'
    }
addItem(ReleaseItem)


class BugItem(BaseItem):
    item_name = 'rhn-erratum-bug'
    item_class = importLib.Bug
    tagMap = {
        'rhn-erratum-bug-id': 'bug_id',
        'rhn-erratum-bug-summary': 'summary',
        'rhn-erratum-bug-href': 'href',
    }
addItem(BugItem)


class KeywordItem(BaseItem):
    item_name = 'rhn-erratum-keyword'
    item_class = importLib.Keyword
    tagMap = {
    }
addItem(KeywordItem)


class ErratumItem(BaseItem):
    item_name = 'rhn-erratum'
    item_class = importLib.Erratum
    tagMap = {
        'id': 'erratum_id',
        'org-id': 'org_id',
        'rhn-erratum-advisory-name': 'advisory_name',
        'rhn-erratum-advisory-rel': 'advisory_rel',
        'rhn-erratum-advisory-type': 'advisory_type',
        'rhn-erratum-product': 'product',
        'rhn-erratum-description': 'description',
        'rhn-erratum-synopsis': 'synopsis',
        'rhn-erratum-topic': 'topic',
        'rhn-erratum-solution': 'solution',
        'rhn-erratum-issue-date': 'issue_date',
        'rhn-erratum-update-date': 'update_date',
        'rhn-erratum-notes': 'notes',
        'rhn-erratum-org-id': 'org_id',
        'rhn-erratum-refers-to': 'refers_to',
        'rhn-erratum-channels': 'channels',
        'rhn-erratum-keywords': 'keywords',
        'rhn-erratum-checksums': 'checksums',
        'rhn-erratum-bugs': 'bugs',
        'rhn-erratum-cve': 'cve',
        'rhn-erratum-last-modified': 'last_modified',
        'rhn-erratum-files': 'files',
        'rhn-erratum-errata-from': 'errata_from',
        'rhn-erratum-severity': 'severity_id',
        'cve-names': 'cve',
    }
addItem(ErratumItem)


class ErrorItem(BaseItem):
    item_name = 'rhn-error'
    item_class = importLib.Error
addItem(ErrorItem)


class ErrataFileItem(BaseChecksummedItem):
    item_name = 'rhn-erratum-file'
    item_class = importLib.ErrataFile
    tagMap = {
        'type': 'file_type',
        'channels': 'channel_list',
        # Specific to XML
        'package': 'package',
        'source-package': 'source-package',
        'checksum-type': 'checksum_type',
    }
addItem(ErrataFileItem)


class ProductNamesItem(BaseItem):
    item_name = 'rhn-product-name'
    item_class = importLib.ProductName
addItem(ProductNamesItem)


class KickstartableTreeItem(BaseItem):
    item_name = 'rhn-kickstartable-tree'
    item_class = importLib.KickstartableTree
    tagMap = {
        'rhn-kickstart-files': 'files',
        'base-path': 'base_path',
        'boot-image': 'boot_image',
        'kstree-type-label': 'kstree_type_label',
        'install-type-label': 'install_type_label',
        'kstree-type-name': 'kstree_type_name',
        'install-type-name': 'install_type_name',
        'last-modified': 'last_modified',
    }
addItem(KickstartableTreeItem)


class KickstartFileItem(BaseChecksummedItem):
    item_name = 'rhn-kickstart-file'
    item_class = importLib.KickstartFile
    tagMap = {
        'relative-path': 'relative_path',
        'file-size': 'file_size',
        'last-modified': 'last_modified',
        'checksums': 'checksum_list',
    }
addItem(KickstartFileItem)

#
# Container handler and containers:
#


class ContainerHandler:
    container_name = None

    def __init__(self):
        # The tag stack; each item is an array [element, attributes]
        self.tagStack = []
        # The object stack; each item is an array
        # [element, attributes, content]
        self.objStack = []
        # Collects the elements in a batch
        self.batch = []

    def reset(self):
        # Make sure the batch is preserved
        batch = self.batch
        # Re-init the object: cleans up the stacks and such
        self.__init__()
        # And restore the batch
        self.batch = batch

    def startElement(self, element, attrs):
        # log_debug(6, element) --duplicate logging.
        if not self.tagStack and element != self.container_name:
            # Strange; this element is called to parse stuff when it's not
            # supposed to
            raise Exception('This object should not have been used')
        self.tagStack.append(Node(element, attrs))
        self.objStack.append([])

    def characters(self, data):
        log_debug(6, data)
        if data == '':
            # Nothing to do
            return
        # If the thing in front is a string, append to it
        lastObj = self.objStack[-1]
        if lastObj and _is_string(lastObj[-1]):
            lastObj[-1] = '%s%s' % (lastObj[-1], data)
        else:
            lastObj.append(data)

    def endElement(self, element):
        # log_debug(6, element) --duplicate logging.
        tagobj = self.tagStack[-1]
        # Remove the previous tag
        del self.tagStack[-1]
        # Decode the tag object
        name = tagobj.name
        if name != element:
            raise ParseException(
                "incorrect XML data: closing tag %s, opening tag %s" % (
                    element, name))
        # Append the content of the object to the tag object
        for obj in self.objStack[-1]:
            tagobj.addSubelement(obj)

        # Remove the subelements from the stack
        del self.objStack[-1]

        if not self.objStack:
            # End element for this container
            self.endContainerCallback()
            raise _EndContainerEvent(tagobj)

        # Regular element; append the current object as a subelement to the
        # previous object
        self.objStack[-1].append(tagobj)
        if len(self.tagStack) == 1:
            # Finished parsing an item; let the parent know
            self.endItemCallback()

    def getLastItem(self):
        return self.objStack[-1][-1]

    def clearLastItem(self):
        del self.objStack[-1][-1]

    def endItemCallback(self):
        # Grab the latest object we've parsed
        obj = self.getLastItem()
        # And remove it since we don't need it
        self.clearLastItem()
        # Instantiate the object
        item = _createItem(obj)

        if item is None:
            # Nothing to do with this object
            return

        if 'error' in item:
            # Special case errors
            log_debug(0, 'XML parser error: found "rhn-error" item: %s' %
                      item['error'])
            raise ParseException(item['error'])

        self.postprocessItem(item)
        # Add it to the items list
        self.batch.append(item)

    def endContainerCallback(self):
        pass

    def postprocessItem(self, item):
        # Do nothing
        pass


def _normalizeSubelements(objtype, subelements):
    # pylint: disable=R0911
    # Deal with simple cases first
    if objtype is None:
        # Don't know how to handle it
        return _stringify(subelements)

    if not subelements:
        # No subelements available
        if isinstance(objtype, usix.ListType):
            # Expect a list of things - return the empty list
            return []
        # Expected a scalar type
        return None

    # We do have subelements
    # Extract all the non-string subelements
    _s = []
    _strings_only = 1
    for subel in subelements:
        if _is_string(subel) and not subel.strip():
            # Ignore it for now
            continue
        _s.append(subel)
        if not _is_string(subel):
            _strings_only = 0

    if _strings_only:
        # Multiple strings - contactenate into one
        subelements = [''.join(subelements)]
    else:
        # Ignore whitespaces around elements
        subelements = _s

    if not isinstance(objtype, usix.ListType):
        if len(subelements) > 1:
            raise Exception("Expected a scalar, got back a list")
        subelement = subelements[0]
        # NULL?
        if isinstance(subelement, Node):
            if subelement.name == 'rhn-null':
                return None
            raise Exception("Expected a scalar, got back an element '%s'" % subelement.name)

        if objtype is usix.StringType:
            return _stringify(subelement)

        if objtype is usix.IntType:
            if subelement == '':
                # Treat it as NULL
                return None
            return int(subelement)

        if objtype is importLib.DateType:
            return _normalizeDateType(subelement)
        raise Exception("Unhandled type %s for subelement %s" % (objtype,
                                                                 subelement))

    # Expecting a list of things
    expectedType = objtype[0]
    if expectedType is usix.StringType:
        # List of strings
        return list(map(_stringify, subelements))

    if expectedType is usix.IntType:
        # list of ints
        return list(map(int, subelements))

    if expectedType is importLib.DateType:
        return list(map(_normalizeDateType, subelements))

    # A subelement
    result = []
    for subelement in subelements:
        item = _createItem(subelement)
        if item is None:
            # Item processor not found
            continue
        if not isinstance(item, expectedType):
            raise Exception("Expected type %s, got back %s %s" % (expectedType,
                                                                  type(item), item))
        result.append(item)

    return result


def _normalizeAttribute(objtype, attribute):
    # Deal with simple cases first
    if (objtype is None) or (objtype is usix.StringType):
        # (Don't know how to handle it) or (Expecting a scalar)
        return attribute
    elif objtype is usix.IntType:
        if attribute == '' or attribute == 'None':
            # Treat it as NULL
            return None
        else:
            return int(attribute)
    elif objtype is importLib.DateType:
        return _normalizeDateType(attribute)
    elif isinstance(objtype, usix.ListType):
        # List type - split stuff
        return attribute.split()
    else:
        raise Exception("Unhandled attribute data type %s" % objtype)


def _normalizeDateType(value):
    try:
        value = int(value)
    except ValueError:
        # string
        return value
    # Timestamp
    return backendLib.localtime(value)


#
# Containers:
#
# XXX: we'll need an ErrorContainer eventually
#      (we do not handle <rhn-error> properly if it is
#       a "root" element).
# class ErrorContainer(ContainerHandler):
#    container_name = 'rhn-error'
#    def endContainerCallback(self):
#        lastObj = self.getLastItem()
#        raise ParseException(lastObj)


class ChannelFamilyContainer(ContainerHandler):
    container_name = 'rhn-channel-families'


class ChannelContainer(ContainerHandler):
    container_name = 'rhn-channels'


class IncompletePackageContainer(ContainerHandler):
    container_name = 'rhn-packages-short'

    def postprocessItem(self, item):
        channels = []
        for channel in item['channels'] or []:
            c = importLib.Channel()
            c['label'] = channel
            channels.append(c)
        item['channels'] = channels


class PackageContainer(IncompletePackageContainer):

    """Inherits from IncompletePackageContainer, since we need to postprocess the
       channel information
    """
    container_name = 'rhn-packages'


class SourcePackageContainer(ContainerHandler):
    container_name = 'rhn-source-packages'


class ErrataContainer(IncompletePackageContainer):
    container_name = 'rhn-errata'


class ServerArchContainer(ContainerHandler):
    container_name = 'rhn-server-arches'


class PackageArchContainer(ContainerHandler):
    container_name = 'rhn-package-arches'


class ChannelArchContainer(ContainerHandler):
    container_name = 'rhn-channel-arches'


class CPUArchContainer(ContainerHandler):
    container_name = 'rhn-cpu-arches'


class ServerPackageArchCompatContainer(ContainerHandler):
    container_name = 'rhn-server-package-arch-compatibility-map'


class ServerChannelArchCompatContainer(ContainerHandler):
    container_name = 'rhn-server-channel-arch-compatibility-map'


class ChannelPackageArchCompatContainer(ContainerHandler):
    container_name = 'rhn-channel-package-arch-compatibility-map'


class ServerGroupServerArchCompatContainer(ContainerHandler):
    container_name = 'rhn-server-group-server-arch-compatibility-map'


class ProductNamesContainer(ContainerHandler):
    container_name = 'rhn-product-names'


class KickstartableTreesContainer(ContainerHandler):
    container_name = 'rhn-kickstartable-trees'


class OrgContainer(ContainerHandler):
    container_name = 'rhn-orgs'
