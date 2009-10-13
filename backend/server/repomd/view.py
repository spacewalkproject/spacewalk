#
# Copyright (c) 2008 Red Hat, Inc.
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
import re

XML_ENCODING = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"

class RepoView:

    def __init__(self, primary, filelists, other, updateinfo, groups, fileobj):
        self.primary = primary
        self.filelists = filelists
        self.other = other
        self.updateinfo = updateinfo
        self.groups = groups

        self.fileobj = fileobj

    def _get_data(self, data_type, data_obj):
        output = []
        output.append("  <data type=\"%s\">" % (data_type))
        output.append("    <location href=\"repodata/%s.xml.gz\"/>"
            % (data_type))
        output.append("    <checksum type=\"sha\">%s</checksum>"
            % (data_obj['gzip_checksum']))
        output.append("    <timestamp>%d</timestamp>" % (data_obj['timestamp']))
        output.append("    <open-checksum type=\"sha\">%s</open-checksum>"
            % (data_obj['open_checksum']))
        output.append("  </data>")
        return output

    def _get_comps_data(self):
        output = []
        if self.groups:
            output.append("  <data type=\"group\">")
            output.append("    <location href=\"repodata/comps.xml\"/>")
            output.append("    <checksum type=\"sha\">%s</checksum>"
                % (self.groups['open_checksum']))
            output.append("    <timestamp>%d</timestamp>" 
                % (self.groups['timestamp']))
            output.append("  </data>")

        return output

    def write_repomd(self):
        output = []
        output.append(XML_ENCODING)
        output.append("<repomd xmlns=\"http://linux.duke.edu/metadata/repo\">")
        output.extend(self._get_data('primary', self.primary))
        output.extend(self._get_data('filelists', self.filelists))
        output.extend(self._get_data('other', self.other))
        output.extend(self._get_data('updateinfo', self.updateinfo))
        output.extend(self._get_comps_data())
        output.append("</repomd>")
        self.fileobj.write('\n'.join(output))


class PrimaryView(object):

    def __init__(self, channel, fileobj):
        self.channel = channel
        self.fileobj = fileobj

    def _get_deps(self, deps):
        output = []
        for dep in deps:
            if dep['flag']:
                line = "        <rpm:entry name=\"%s\" flags=\"%s\" \
                        epoch=\"%s\" ver=\"%s\" " % (dep['name'], dep['flag'],
                                dep['epoch'], dep['version'])
                if dep['release']:
                   line += "rel=\"%s\" " % dep['release']
                line += "/>"
                output.append(line)
            else:
                output.append("         <rpm:entry name=\"%s\" />"
                    % (text_filter(dep['name'])))
        return output

    def _get_files(self, files):
        output = []
        filere = re.compile('.*bin\/.*|^\/etc\/.*|^\/usr\/lib\.sendmail$')
        for pkg_file in files:
            if filere.match(pkg_file):
                output.append("      <file>%s</file>"
                        % (text_filter(pkg_file)))
        return output

    def _get_package(self, package):
        output = []
        output.append("  <package type=\"rpm\">")
        output.append("    <name>%s</name>" % (package.name))
        output.append("    <arch>%s</arch>" % (package.arch))
        output.append("    <version epoch=\"%s\" ver=\"%s\" rel=\"%s\" />"
            % (package.epoch, package.version, package.release))
        output.append("    <checksum type=\"md5\" pkgid=\"YES\">%s</checksum>"
            % (package.checksum))
        output.append("    <summary>%s</summary>"
            % (text_filter(package.summary)))
        output.append("    <description>%s</description>"
            % (text_filter(package.description)))
        output.append("    <packager></packager>")
        output.append("    <url></url>")
        output.append("    <time file=\"%d\" build=\"%d\" />"
            % (package.build_time, package.build_time))
        output.append("    <size package=\"%d\" installed=\"\" "
            "archive=\"%d\" />"
            % (package.package_size, package.payload_size))
        output.append("    <location href=\"getPackage/%s\" />"
            % (package.filename))
        output.append("    <format>")
        output.append("      <rpm:license>%s</rpm:license>"
            % (text_filter(package.copyright)))
        output.append("      <rpm:vendor>%s</rpm:vendor>"
            % (text_filter(package.vendor)))
        output.append("      <rpm:group>%s</rpm:group>"
            % (text_filter(package.package_group)))
        output.append("      <rpm:buildhost>%s</rpm:buildhost>"
            % (text_filter(package.build_host)))
        output.append("      <rpm:sourcerpm>%s</rpm:sourcerpm>"
            % (text_filter(package.source_rpm)))
        output.append("      <rpm:header-range start=\"%d\" end=\"%d\" />"
            % (package.header_start, package.header_end))

        output.append("      <rpm:provides>")
        output.extend(self._get_deps(package.provides))
        output.append("      </rpm:provides>")

        output.append("      <rpm:requires>")
        output.extend(self._get_deps(package.requires))
        output.append("      </rpm:requires>")
  
        output.append("      <rpm:conflicts>")
        output.extend(self._get_deps(package.conflicts))
        output.append("      </rpm:conflicts>")

        output.append("      <rpm:obsoletes>")
        output.extend(self._get_deps(package.obsoletes))
        output.append("      </rpm:obsoletes>")

        output.extend(self._get_files(package.files))

        output.append("    </format>")
        output.append("  </package>")

        return output

    def write_start(self):
        output = XML_ENCODING + "\n" + \
        "<metadata xmlns=\"http://linux.duke.edu/metadata/common\" " + \
        "xmlns:rpm=\"http://linux.duke.edu/metadata/rpm\" " + \
        "packages=\"%d\">" % self.channel.num_packages

        self.fileobj.write(output)
       
    def write_package(self, package):
        self.fileobj.write('\n'.join(self._get_package(package)))

    def write_end(self):
        self.fileobj.write("</metadata>")


class FilelistsView(object):

    def __init__(self, channel, fileobj):
        self.channel = channel
        self.fileobj = fileobj

    def _get_package(self, package):
        output = []
        output.append("  <package pkgid=\"%s\" name=\"%s\" arch=\"%s\">"
            % (package.checksum, package.name, package.arch))
        output.append("    <version epoch=\"%s\" ver=\"%s\" rel=\"%s\" />"
            % (package.epoch, package.version, package.release))

        for file_name in package.files:
            output.append("    <file>%s</file>" % (text_filter(file_name)))
        output.append("  </package>")
        return output

    def write_start(self):
        output = XML_ENCODING + "\n" + \
        "<filelists xmlns=\"http://linux.duke.edu/metadata/filelists\" " + \
        "packages=\"%d\">" % self.channel.num_packages

        self.fileobj.write(output)
       
    def write_package(self, package):
        self.fileobj.write('\n'.join(self._get_package(package)))

    def write_end(self):
        self.fileobj.write("</filelists>")


class OtherView(object):

    def __init__(self, channel, fileobj):
        self.channel = channel
        self.fileobj = fileobj

    def _get_package(self, package):
        output = []
        output.append("  <package pkgid=\"%s\" name=\"%s\" arch=\"%s\">"
            % (package.checksum, package.name, package.arch))
        output.append("    <version epoch=\"%s\" ver=\"%s\" rel=\"%s\" />"
            % (package.epoch, package.version, package.release))

        for changelog in package.changelog:
            output.append("    <changelog author=\"%s\" date=\"%d\">"
                % (text_filter_attribute(changelog['author']),
                    changelog['date']))
            output.append("      " + text_filter(changelog['text']))
            output.append("    </changelog>")
        output.append("  </package>")
        return output

    def write_start(self):
        output = XML_ENCODING + "\n" + \
        "<otherdata xmlns=\"http://linux.duke.edu/metadata/other\" " + \
        "packages=\"%d\">" % self.channel.num_packages
      
        self.fileobj.write(output)

    def write_package(self, package):
        self.fileobj.write('\n'.join(self._get_package(package)))

    def write_end(self):
        self.fileobj.write("</otherdata>")


class UpdateinfoView(object):

    def __init__(self, channel, fileobj):
        self.channel = channel
        self.fileobj = fileobj

    def _get_references(self, erratum):
        output = []
        output.append("    <references>")
       
        ref_string = "       <reference href=\"%s%s\" id=\"%s\" type=\"%s\">"
        for cve_ref in erratum.cve_references:
            output.append(ref_string
                % ("http://www.cve.mitre.org/cgi-bin/cvename.cgi?name=",
                cve_ref, cve_ref, "cve"))
            output.append("      </reference>")

        for bz_ref in erratum.bz_references:
            output.append(ref_string
                % ("http://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=",
                bz_ref['bug_id'], bz_ref['bug_id'], "bugzilla"))
            output.append("        " + text_filter(bz_ref['summary']))
            output.append("      </reference>")

        output.append("    </references>")
        return output

    def _get_packages(self, erratum):
        output = []

        output.append("    <pkglist>")
        output.append("      <collection short=\"%s\">"
                % text_filter_attribute(self.channel.label))
        output.append("        <name>%s</name>"
                % text_filter(self.channel.name))

        for package in erratum.packages:
            output.append("          <package name=\"%s\" version=\"%s\" "
                "release=\"%s\" epoch=\"%s\" arch=\"%s\" src=\"%s\">"
                % (package.name, package.version, package.release,
                package.epoch, package.arch, text_filter(package.source_rpm)))
            output.append("            <filename>%s</filename>"
                % text_filter(package.filename))
            output.append("            <sum type=\"md5\">%s</sum>"
                % package.checksum)
            output.append("          </package>")

        output.append("      </collection>")
        output.append("    </pkglist>")
        return output

    def _get_erratum(self, erratum):
        output = []

        output.append("  <update from=\"security@redhat.com\" " + 
            "status=\"final\" type=\"%s\" version=\"%s\">"
            % (erratum.advisory_type, erratum.version))
        output.append("    <id>%s</id>" % erratum.readable_id)
        output.append("    <title>%s</title>" % text_filter(erratum.title))
        output.append("    <issued date=\"%s\"/>" % erratum.issued)
        output.append("    <updated date=\"%s\"/>" % erratum.updated)
        output.append("    <description>%s</description>"
            % text_filter("%s\n\n\%s" % (erratum.synopsis,  erratum.description)))

        output.extend(self._get_references(erratum))
        output.extend(self._get_packages(erratum))       

        output.append("  </update>")

        return output

    def write_updateinfo(self):
        output = XML_ENCODING + "\n" + "<updates>\n"

        self.fileobj.write(output)

        for erratum in self.channel.errata:
            self.fileobj.write('\n'.join(self._get_erratum(erratum)))

        self.fileobj.write("\n</updates>")


class CompsView(object):

    def __init__(self, comps):
        self.comps = comps

    def get_file(self):
        comps_file = open(self.comps.filename)
        return comps_file


def text_filter(text):
    # do & first
    s = text.replace('&', '&amp;') 
    s = s.replace('<', '&lt;')
    s = s.replace('>', '&gt;')
    return s

def text_filter_attribute(text):
    s = text_filter(text)
    s = s.replace('"', '&quot;')
    return s
