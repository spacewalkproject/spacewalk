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
package com.redhat.rhn.taskomatic.task.repomd;

import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.errata.Bug;
import com.redhat.rhn.domain.errata.Cve;
import com.redhat.rhn.domain.errata.Errata;
import com.redhat.rhn.domain.rhnpackage.Package;

import org.xml.sax.SAXException;

import java.io.Writer;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Iterator;

/**
 * UpdateInfo.xml writer class
 * 
 * @version $Rev $
 * 
 */
public class UpdateInfoWriter extends RepomdWriter {

    /**
     * Constructor takes in writer.
     * @param writer xml writer object
     */
    public UpdateInfoWriter(Writer writer) {
        super(writer);
    }

    /**
     * Get the updateInfo for given channel
     * @param channel channel info
     * @return updateInfo
     */
    public String getUpdateInfo(Channel channel) {
        begin(channel);

        Iterator iter = channel.getErratas().iterator();

        while (iter.hasNext()) {
            try {
                addErratum((Errata) iter.next(), channel);
            }
            catch (SAXException e) {
                throw new RepomdRuntimeException(e);
            }
        }

        end();

        return "";

    }

    /**
     * Ends the xml creation
     */
    public void end() {
        try {
            handler.endElement("updates");
            handler.endDocument();
        }
        catch (SAXException e) {
            throw new RepomdRuntimeException(e);
        }
    }

    /**
     * Starts xml creation
     * @param channel channel info
     */
    public void begin(Channel channel) {
        try {
            handler.startElement("updates");
        }
        catch (SAXException e) {
            throw new RepomdRuntimeException(e);
        }
    }

    /**
     * Add erratum to repodata for given channel
     * @param erratum erratum to be added
     * @param channel channel info
     * @throws SAXException
     */
    private void addErratum(Errata erratum, Channel channel)
        throws SAXException {
        SimpleAttributesImpl attr = new SimpleAttributesImpl();
        attr.addAttribute("from", "security@redhat.com");
        attr.addAttribute("status", "final");
        attr.addAttribute("type", mapAdvisoryType(erratum.getAdvisoryType()));
        attr.addAttribute("version", Long.toString(erratum.getAdvisoryRel()));
        handler.startElement("update", attr);

        handler.addElementWithCharacters("id", sanitize(0, erratum
                .getAdvisoryName()));
        handler.addElementWithCharacters("title", sanitize(0, erratum
                .getSynopsis()));

        DateFormat df = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");

        attr.clear();
        attr.addAttribute("date", df.format(erratum.getIssueDate()));
        handler.startElement("issued", attr);
        handler.endElement("issued");

        attr.clear();
        attr.addAttribute("date", df.format(erratum.getUpdateDate()));
        handler.startElement("updated", attr);
        handler.endElement("updated");

        handler.addElementWithCharacters("description", sanitize(0, erratum
                .getDescription()));

        addErratumReferences(erratum);
        addErratumPkgList(erratum, channel);

        handler.endElement("update");
    }

    /**
     * Adds packages associated to the errata
     * @param erratum erratum to be added
     * @param channel channel info
     * @throws SAXException
     */
    private void addErratumPkgList(Errata erratum, Channel channel)
        throws SAXException {
        handler.startElement("pkglist");

        SimpleAttributesImpl attr = new SimpleAttributesImpl();
        attr.addAttribute("short", channel.getLabel());
        handler.startElement("collection", attr);

        handler.addElementWithCharacters("name", channel.getName());

        Iterator iter = erratum.getPackages().iterator();

        while (iter.hasNext()) {
            Package pkg = (Package) iter.next();
            if (channel.getPackages().contains(pkg)) {
                long pkgId = pkg.getId();
                String epoch = pkg.getPackageEvr().getEpoch();
                if (epoch == null || epoch.length() == 0) {
                    epoch = "0";
                }
                attr.clear();
                attr.addAttribute("name", sanitize(pkgId, pkg.getPackageName()
                        .getName()));
                attr.addAttribute("version", sanitize(pkgId, pkg
                        .getPackageEvr().getVersion()));
                attr.addAttribute("release", sanitize(pkgId, pkg
                        .getPackageEvr().getRelease()));
                attr.addAttribute("epoch", sanitize(pkgId, epoch));
                attr.addAttribute("arch", sanitize(pkgId, pkg.getPackageArch()
                        .getLabel()));
                attr.addAttribute("src", sanitize(pkgId, pkg.getSourceRpm()
                        .getName()));
                handler.startElement("package", attr);

                handler.addElementWithCharacters("filename", sanitize(pkgId,
                        pkg.getFilename()));

                attr.clear();
                attr.addAttribute("type", 
                    sanitize(pkgId, pkg.getChecksum().getChecksumType().getLabel()));
                handler.startElement("sum", attr);
                handler.addCharacters(sanitize(pkgId, pkg.getChecksum().getChecksum()));
                handler.endElement("sum");

                handler.endElement("package");
            }
        }

        handler.endElement("collection");

        handler.endElement("pkglist");

    }

    /**
     * Adds references info from the errata
     * @param erratum erratum to be added
     * @throws SAXException
     */
    private void addErratumReferences(Errata erratum) throws SAXException {
        handler.startElement("references");

        Iterator iter = erratum.getBugs().iterator();
        while (iter.hasNext()) {
            Bug bug = (Bug) iter.next();

            SimpleAttributesImpl attr = new SimpleAttributesImpl();
            attr.addAttribute("href",
                    "http://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=" +
                            bug.getId());
            attr.addAttribute("id", Long.toString(bug.getId()));
            attr.addAttribute("type", "bugzilla");
            handler.startElement("reference", attr);
            handler.addCharacters(bug.getSummary());
            handler.endElement("reference");
        }

        iter = erratum.getCves().iterator();
        while (iter.hasNext()) {
            Cve cve = (Cve) iter.next();

            SimpleAttributesImpl attr = new SimpleAttributesImpl();
            attr.addAttribute("href",
                    "http://www.cve.mitre.org/cgi-bin/cvename.cgi?name=" + cve);
            attr.addAttribute("id", sanitize(0, cve.getName()));
            attr.addAttribute("type", "cve");
            handler.startElement("reference", attr);
            handler.endElement("reference");
        }

        handler.endElement("references");
    }

    /**
     * Maps the Errata advisory type info
     * @param advisoryType Errata advisory type
     * @return advisory as a string
     */
    private static String mapAdvisoryType(String advisoryType) {
        if (advisoryType.equals("Bug Fix Advisory")) {
            return "bugfix";
        }
        else if (advisoryType.equals("Product Enhancement Advisory")) {
            return "enhancement";
        }
        else if (advisoryType.equals("Security Advisory")) {
            return "security";
        }
        else {
            return "errata";
        }
    }
}
