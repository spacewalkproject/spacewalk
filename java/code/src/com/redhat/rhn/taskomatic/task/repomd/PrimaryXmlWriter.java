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

package com.redhat.rhn.taskomatic.task.repomd;

import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.frontend.dto.PackageCapabilityDto;
import com.redhat.rhn.frontend.dto.PackageDto;
import com.redhat.rhn.manager.rhnpackage.PackageManager;
import com.redhat.rhn.manager.task.TaskManager;
import com.redhat.rhn.taskomatic.task.TaskConstants;

import org.apache.commons.lang.StringUtils;
import org.xml.sax.SAXException;

import java.io.ByteArrayOutputStream;
import java.io.Writer;
import java.util.Collection;
import java.util.HashMap;
import java.util.Map;

/**
 * Primary.xml writer class
 * @version $Rev $
 *
 */
public class PrimaryXmlWriter extends RepomdWriter {

    /**
     *
     * @param writer The writer object for primary xml
     */
    public PrimaryXmlWriter(Writer writer) {
        super(writer, false);
    }

    /**
     *
     * @param channel channel info
     * @return primaryXml for the given channel
     * @throws Exception exception
     */
    public String getPrimaryXml(Channel channel) throws Exception {
        begin(channel);

        for (PackageDto pkgDto : TaskManager.getChannelPackageDtos(channel)) {
            addPackage(pkgDto);
        }

        end();

        return "";
    }

    /**
     * end xml metadata generation
     */
    public void end() {
        try {
            handler.endElement("metadata");
            handler.endDocument();
        }
        catch (SAXException e) {
            throw new RepomdRuntimeException(e);
        }
    }

    /**
     * Start xml metadata generation
     * @param channel channel data
     */
    public void begin(Channel channel) {
        SimpleAttributesImpl attr = new SimpleAttributesImpl();
        attr.addAttribute("xmlns", "http://linux.duke.edu/metadata/common");
        attr.addAttribute("xmlns:rpm", "http://linux.duke.edu/metadata/rpm");
        attr.addAttribute("packages", Integer.toString(channel.getPackageCount()));

        try {
            handler.startElement("metadata", attr);
        }
        catch (SAXException e) {
            throw new RepomdRuntimeException(e);
        }
    }

    /**
     *
     * @param pkgDto pkg info to add to xml
     */
    public void addPackage(PackageDto pkgDto) {
        try {
            String xml = pkgDto.getPrimaryXml();
            if (ConfigDefaults.get().useDBRepodata() && !StringUtils.isEmpty(xml)) {

                if (xml != null) {
                    handler.addCharacters(xml);
                    return;
                }
            }

            ByteArrayOutputStream st = new ByteArrayOutputStream();
            SimpleContentHandler tmpHandler = getTemporaryHandler(st);


            SimpleAttributesImpl attr = new SimpleAttributesImpl();
            attr.addAttribute("type", "rpm");
            tmpHandler.startDocument();

            tmpHandler.startElement("package", attr);

            addBasicPackageDetails(pkgDto, tmpHandler);
            addPackageFormatDetails(pkgDto, tmpHandler);
            tmpHandler.endElement("package");
            tmpHandler.endDocument();

            String pkg =  st.toString();
            PackageManager.updateRepoPrimary(pkgDto.getId(), pkg);
            handler.addCharacters(pkg);

        }
        catch (SAXException e) {
            throw new RepomdRuntimeException(e);
        }
    }

    /**
     *
     * @param pkgDto pkg info to add to xml
     * @throws SAXException sax exception
     */
    private void addPackageFormatDetails(PackageDto pkgDto,
            SimpleContentHandler localHandler) throws SAXException {
        long pkgId = pkgDto.getId().longValue();

        localHandler.startElement("format");

        localHandler.addElementWithCharacters("rpm:license", sanitize(pkgId, pkgDto
                .getCopyright()));
        localHandler.addElementWithCharacters("rpm:vendor", sanitize(pkgId, pkgDto
                .getVendor()));
        localHandler.addElementWithCharacters("rpm:group", sanitize(pkgId, pkgDto
                .getPackageGroupName()));
        localHandler.addElementWithCharacters("rpm:buildhost", sanitize(pkgId,
                pkgDto.getBuildHost()));
        localHandler.addElementWithCharacters("rpm:sourcerpm", sanitize(pkgId,
                pkgDto.getSourceRpm()));

        SimpleAttributesImpl attr = new SimpleAttributesImpl();
        attr.addAttribute("start", pkgDto.getHeaderStart().toString());
        attr.addAttribute("end", pkgDto.getHeaderEnd().toString());
        localHandler.startElement("rpm:header-range", attr);
        localHandler.endElement("rpm:header-range");

        addPackagePrcoData(pkgDto, localHandler);
        addEssentialPackageFiles(pkgId, localHandler);
        localHandler.endElement("format");
    }

    /**
     *
     * @param pkgDto pkg info to add to xml
     * @throws SAXException sax exception
     */
    private void addBasicPackageDetails(PackageDto pkgDto,
            SimpleContentHandler localHandler) throws SAXException {
        long pkgId = pkgDto.getId().longValue();

        localHandler.addElementWithCharacters("name", sanitize(pkgId, pkgDto
                .getName()));
        localHandler.addElementWithCharacters("arch", sanitize(pkgId, pkgDto
                .getArchLabel()));

        SimpleAttributesImpl attr = new SimpleAttributesImpl();
        attr.addAttribute("ver", sanitize(pkgId, pkgDto.getVersion()));
        attr.addAttribute("rel", sanitize(pkgId, pkgDto.getRelease()));
        attr.addAttribute("epoch", sanitize(pkgId, getPackageEpoch(pkgDto
                .getEpoch())));
        localHandler.startElement("version", attr);
        localHandler.endElement("version");

        attr.clear();
        attr.addAttribute("type", sanitize(pkgId, pkgDto.getChecksumType()));
        attr.addAttribute("pkgid", "YES");
        localHandler.startElement("checksum", attr);
        localHandler.addCharacters(sanitize(pkgId, pkgDto.getChecksum()));
        localHandler.endElement("checksum");

        localHandler.addElementWithCharacters("summary", sanitize(pkgId, pkgDto
                .getSummary()));
        localHandler.addElementWithCharacters("description", sanitize(pkgId, pkgDto
                .getDescription()));

        localHandler.addEmptyElement("packager");
        localHandler.addEmptyElement("url");

        attr.clear();
        attr.addAttribute("file", Long
                .toString(pkgDto.getBuildTime().getTime() / 1000));
        attr.addAttribute("build", Long.toString(pkgDto.getBuildTime()
                .getTime() / 1000));
        localHandler.startElement("time", attr);
        localHandler.endElement("time");

        attr.clear();
        attr.addAttribute("package", pkgDto.getPackageSize().toString());
        attr.addAttribute("archive", pkgDto.getPayloadSize().toString());
        if (pkgDto.getInstalledSize() != null) {
            attr.addAttribute("installed", pkgDto.getInstalledSize().toString());
        }
        else {
            /* set something for "installed" so anaconda doesn't die */
            attr.addAttribute("installed", pkgDto.getPayloadSize().toString());
        }
        localHandler.startElement("size", attr);
        localHandler.endElement("size");

        String pkgFile = sanitize(pkgId, getProxyFriendlyFilename(pkgDto));

        attr.clear();
        attr.addAttribute("href", "getPackage/" + pkgFile);
        localHandler.startElement("location", attr);
        localHandler.endElement("location");
    }

    /**
     *
     * @param pkgDto pkg info to add to xml
     * @throws SAXException
     */
    private void addPackagePrcoData(PackageDto pkgDto,
            SimpleContentHandler localHandler) throws SAXException {
        addPackageDepData(
                TaskConstants.TASK_QUERY_REPOMD_GENERATOR_CAPABILITY_PROVIDES,
                pkgDto.getId(), "provides", localHandler);
        addPackageDepData(
                TaskConstants.TASK_QUERY_REPOMD_GENERATOR_CAPABILITY_REQUIRES,
                pkgDto.getId(), "requires", localHandler);
        addPackageDepData(
                TaskConstants.TASK_QUERY_REPOMD_GENERATOR_CAPABILITY_CONFLICTS,
                pkgDto.getId(), "conflicts", localHandler);
        addPackageDepData(
                TaskConstants.TASK_QUERY_REPOMD_GENERATOR_CAPABILITY_OBSOLETES,
                pkgDto.getId(), "obsoletes", localHandler);
        addPackageDepData(
                TaskConstants.TASK_QUERY_REPOMD_GENERATOR_CAPABILITY_RECOMMENDS,
                pkgDto.getId(), "recommends", localHandler);
        addPackageDepData(
                TaskConstants.TASK_QUERY_REPOMD_GENERATOR_CAPABILITY_SUGGESTS,
                pkgDto.getId(), "suggests", localHandler);
        addPackageDepData(
                TaskConstants.TASK_QUERY_REPOMD_GENERATOR_CAPABILITY_SUPPLEMENTS,
                pkgDto.getId(), "supplements", localHandler);
        addPackageDepData(
                TaskConstants.TASK_QUERY_REPOMD_GENERATOR_CAPABILITY_ENHANCES,
                pkgDto.getId(), "enhances", localHandler);
    }

    /**
     *
     * @param pkgCapIter pkg capability info
     * @param pkgId package Id to set
     * @param dep dependency info
     * @throws SAXException sax exception
     */
    private void addPackageDepData(String query, Long pkgId,
            String dep, SimpleContentHandler localHandler) throws SAXException {
        Collection<PackageCapabilityDto> capabilities = TaskManager
                .getPackageCapabilityDtos(pkgId, query);
        localHandler.startElement("rpm:" + dep);
        for (PackageCapabilityDto capability : capabilities) {
            SimpleAttributesImpl attr = new SimpleAttributesImpl();
            attr.addAttribute("name", sanitize(pkgId, capability.getName()));
            Map<String, String> evrMap = parseEvr(sanitize(pkgId,
                    capability.getVersion()));

            if (evrMap.get("epoch") != null || evrMap.get("version") != null ||
                    evrMap.get("release") != null) {
                attr.addAttribute("flags",
                        getSenseAsString(capability.getSense()));
            }

            if (evrMap.get("epoch") != null) {
                attr.addAttribute("epoch", evrMap.get("epoch"));
            }
            else if (evrMap.get("version") != null) {
                attr.addAttribute("epoch", "0");
            }

            if (evrMap.get("version") != null) {
                attr.addAttribute("ver", evrMap.get("version"));
            }
            if (evrMap.get("release") != null) {
                attr.addAttribute("rel", evrMap.get("release"));
            }

            if (hasPreFlag(capability.getSense())) {
                attr.addAttribute("pre", "1");
            }

            localHandler.startElement("rpm:entry", attr);
            localHandler.endElement("rpm:entry");
        }
        localHandler.endElement("rpm:" + dep);
    }

    /**
     *
     * @param evr package evr info
     * @return package evr object
     */
    private static Map<String, String> parseEvr(String evr) {
        Map<String, String> map = new HashMap<String, String>();
        map.put("epoch", null);
        map.put("version", null);
        map.put("release", null);

        if (evr != null) {
            String[] parts = evr.split(":");
            String vr;
            if (parts.length != 1) {
                map.put("epoch", parts[0]);
                vr = parts[1];
            }
            else {
                vr = parts[0];
            }

            int dash = vr.lastIndexOf('-');

            if (dash == -1) {
                map.put("version", vr);
            }
            else {
                map.put("version", vr.substring(0, dash));
                map.put("release", vr.substring(dash + 1));
            }
        }

        return map;
    }

    /**
     *
     * @param pkgId package Id info
     * @throws SAXException sax exception
     */
    private void addEssentialPackageFiles(long pkgId,
            SimpleContentHandler hndlr) throws SAXException {
        String regex = ".*bin/.*|^/etc/.*|^/usr/lib.sendmail$";
        Collection<PackageCapabilityDto> files = TaskManager
                .getPackageCapabilityDtos(
                        pkgId,
                        TaskConstants.TASK_QUERY_REPOMD_GENERATOR_CAPABILITY_FILES);
        for (PackageCapabilityDto file : files) {
            String path = sanitize(pkgId, file.getName());
            if (path.matches(regex)) {
                hndlr.addElementWithCharacters("file", path);
            }
        }
    }

    /**
     *
     * @param pkgDto package info
     * @return package filename
     */
    private String getProxyFriendlyFilename(PackageDto pkgDto) {
        String[] parts = StringUtils.split(pkgDto.getPath(), '/');
        if (parts != null && parts.length > 0) {
            return parts[parts.length - 1];
        }
        return pkgDto.getName() + "-" + pkgDto.getVersion() +
                "-" + pkgDto.getRelease() + "." +
                pkgDto.getArchLabel() + ".rpm";
    }

    /**
     * @param senseIn package sense
     * @return a human readable representation of the sense
     */
    private String getSenseAsString(long senseIn) {
        long sense = senseIn & 0xf;
        if (sense == 2) {
            return "LT";
        }
        else if (sense == 4) {
            return "GT";
        }
        else if (sense == 8) {
            return "EQ";
        }
        else if (sense == 10) {
            return "LE";
        }
        else { // 12
            return "GE";
        }
    }

    /**
     * @param senseIn package sense
     * @return true in case the pre flag is set, otherwise false
     */
    private boolean hasPreFlag(long senseIn) {
        return ((senseIn & (1 << 6)) > 0) ? true : false;
    }
}
