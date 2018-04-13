/**
 * Copyright (c) 2009--2012 Red Hat, Inc.
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
/*
 * Copyright (c) 2010 SUSE LLC
 */
package com.redhat.rhn.taskomatic.task.repomd;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.frontend.dto.Bug;
import com.redhat.rhn.frontend.dto.CVE;
import com.redhat.rhn.frontend.dto.ErrataOverview;
import com.redhat.rhn.frontend.dto.PackageDto;
import com.redhat.rhn.manager.channel.ChannelManager;
import com.redhat.rhn.manager.errata.ErrataManager;

import org.xml.sax.SAXException;

import java.io.Writer;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.List;

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
        super(writer, true);
    }

    /**
     * Get the updateInfo for given channel
     * @param channel channel info
     * @return updateInfo
     */
    public String getUpdateInfo(Channel channel) {
        begin(channel);

        DataResult<ErrataOverview> errata = ChannelManager
                .listErrataSimple(channel.getId());
        final int batchSize = 500;
        for (int i = 0; i < errata.size(); i += batchSize) {
            DataResult<ErrataOverview> errataBatch = errata.subList(i, i + batchSize);
            errataBatch.elaborate();
            for (ErrataOverview erratum : errataBatch) {
                try {
                    addErratum(erratum, channel);
                }
                catch (SAXException e) {
                    throw new RepomdRuntimeException(e);
                }
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
    private void addErratum(ErrataOverview erratum, Channel channel)
            throws SAXException {
        SimpleAttributesImpl attr = new SimpleAttributesImpl();
        attr.addAttribute("from", erratum.getErrataFrom());
        attr.addAttribute("status", "final");
        attr.addAttribute("type", mapAdvisoryType(erratum.getAdvisoryType()));
        attr.addAttribute("version", Long.toString(erratum.getAdvisoryRel()));
        handler.startElement("update", attr);

        handler.addElementWithCharacters("id",
                sanitize(0L, erratum
                .getAdvisoryName()));
        handler.addElementWithCharacters("title", sanitize(0L, erratum
                .getAdvisorySynopsis()));

        DateFormat df = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");

        attr.clear();
        attr.addAttribute("date", df.format(erratum.getIssueDateObj()));
        handler.startElement("issued", attr);
        handler.endElement("issued");

        attr.clear();
        attr.addAttribute("date", df.format(erratum.getUpdateDateObj()));
        handler.startElement("updated", attr);
        handler.endElement("updated");

        handler.addElementWithCharacters("description",
                sanitize(0L, erratum
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
    private void addErratumPkgList(ErrataOverview erratum, Channel channel)
            throws SAXException {
        handler.startElement("pkglist");

        SimpleAttributesImpl attr = new SimpleAttributesImpl();
        attr.addAttribute("short", channel.getLabel());
        handler.startElement("collection", attr);

        handler.addElementWithCharacters("name", channel.getName());

        for (PackageDto pkg : ErrataManager.lookupPacksFromErrataForChannel(
                channel.getId(), erratum.getId())) {
            long pkgId = pkg.getId();
            String epoch = pkg.getEpoch();
            if (epoch == null || epoch.length() == 0) {
                epoch = "0";
            }
            attr.clear();
            attr.addAttribute("name", sanitize(pkgId, pkg.getName()));
            attr.addAttribute("version", sanitize(pkgId, pkg.getVersion()));
            attr.addAttribute("release", sanitize(pkgId, pkg.getRelease()));
            attr.addAttribute("epoch", sanitize(pkgId, epoch));
            attr.addAttribute("arch", sanitize(pkgId, pkg.getArchLabel()));
            attr.addAttribute("src", sanitize(pkgId, pkg.getSourceRpm()));
            handler.startElement("package", attr);
            handler.addElementWithCharacters("filename", sanitize(pkgId, pkg.getFile()));

            List<String> keywords = ErrataManager.lookupKeywordsForErratum(erratum.getId());
            if (keywords.contains("reboot_suggested")) {
                handler.addElementWithCharacters("reboot_suggested", "1");
            }
            else if (keywords.contains("restart_suggested")) {
                handler.addElementWithCharacters("restart_suggested", "1");
            }

            attr.clear();
            attr.addAttribute("type", sanitize(pkgId, pkg.getChecksumType()));
            handler.startElement("sum", attr);
            handler.addCharacters(sanitize(pkgId, pkg.getChecksum()));
            handler.endElement("sum");

            handler.endElement("package");
        }

        handler.endElement("collection");

        handler.endElement("pkglist");

    }

    /**
     * Adds references info from the errata
     * @param erratum erratum to be added
     * @throws SAXException
     */
    private void addErratumReferences(ErrataOverview erratum) throws SAXException {
        handler.startElement("references");

        for (Bug bug : ErrataManager.lookupBugsForErratum(erratum.getId())) {
            SimpleAttributesImpl attr = new SimpleAttributesImpl();
            if (bug.getHref() != null && !bug.getHref().equals("")) {
                attr.addAttribute("href", bug.getHref());
            }
            else {
                attr.addAttribute("href",
                        "http://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=" +
                                bug.getBugId());
            }
            attr.addAttribute("id", Long.toString(bug.getBugId()));
            attr.addAttribute("type", "bugzilla");
            handler.startElement("reference", attr);
            if (bug.getSummary() != null) {
                handler.addCharacters(bug.getSummary());
            }
            handler.endElement("reference");
        }

        for (CVE cve : ErrataManager.lookupCvesForErratum(erratum.getId())) {
            String cveid = sanitize(0L, cve.getName());

            SimpleAttributesImpl attr = new SimpleAttributesImpl();
            attr.addAttribute("href",
                    "http://cve.mitre.org/cgi-bin/cvename.cgi?name=" + cveid);
            attr.addAttribute("id", cveid);
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
