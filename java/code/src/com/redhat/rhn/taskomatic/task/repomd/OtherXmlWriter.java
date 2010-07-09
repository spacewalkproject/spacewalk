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
package com.redhat.rhn.taskomatic.task.repomd;

import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.frontend.dto.PackageDto;
import com.redhat.rhn.manager.rhnpackage.PackageManager;
import com.redhat.rhn.manager.task.TaskManager;
import com.redhat.rhn.taskomatic.task.TaskConstants;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.xml.sax.SAXException;

import java.io.ByteArrayOutputStream;
import java.io.OutputStream;
import java.io.Writer;
import java.util.Iterator;

/**
 *
 * @version $Rev $
 *
 */
public class OtherXmlWriter extends RepomdWriter {

    private PackageCapabilityIterator changeLogIterator;
    private Logger log = Logger.getLogger(OtherXmlWriter.class);

    /**
     *
     * @param writer The writer object for other.xml
     */
    public OtherXmlWriter(Writer writer) {
        super(writer);
    }

    /**
     *
     * @param channel channel info
     * @return other.xml for given channel
     * @throws Exception exception
     */
    public String getOtherXml(Channel channel) throws Exception {
        begin(channel);

        Iterator iter = TaskManager.getChannelPackageDtoIterator(channel);
        while (iter.hasNext()) {
            addPackage((PackageDto) iter.next());
        }

        end();

        return "";

    }

    /**
     * Start xml metadata generation
     * @param channel channel info
     */
    public void begin(Channel channel) {
        changeLogIterator = new PackageCapabilityIterator(channel,
                TaskConstants.TASK_QUERY_REPOMD_GENERATOR_PACKAGE_CHANGELOG);
        SimpleAttributesImpl attr = new SimpleAttributesImpl();
        attr.addAttribute("xmlns", "http://linux.duke.edu/metadata/other");
        attr.addAttribute("packages", Integer.toString(channel.getPackageCount()));

        try {
            handler.startElement("otherdata", attr);
        }
        catch (SAXException e) {
            throw new RepomdRuntimeException(e);
        }
    }

    /**
     * end xml metadata generation
     */
    public void end() {
        try {
            handler.endElement("otherdata");
            handler.endDocument();
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
            String xml = pkgDto.getOtherXml();
            if (ConfigDefaults.get().useDBRepodata() && !StringUtils.isEmpty(xml)) {
                if (xml != null) {
                    handler.addCharacters(xml);
                    return;
                }
            }

            OutputStream st = new ByteArrayOutputStream();
            SimpleContentHandler tmpHandler = getTemporaryHandler(st);
            tmpHandler.startDocument();

            addPackageBoilerplate(tmpHandler, pkgDto);
            addPackageChangelog(pkgDto, tmpHandler);
            tmpHandler.endElement("package");
            tmpHandler.endDocument();

            String pkg =  st.toString();
            PackageManager.updateRepoOther(pkgDto.getId(), pkg);
            handler.addCharacters(pkg);

        }
        catch (SAXException e) {
            throw new RepomdRuntimeException(e);
        }
    }

    /**
     *
     * @param pkgDto pkg changelog info to add to xml
     * @throws SAXException sax exception
     */
    private void addPackageChangelog(PackageDto pkgDto,
            SimpleContentHandler tmpHandler) throws SAXException {

        long pkgId = pkgDto.getId().longValue();
        while (changeLogIterator.hasNextForPackage(pkgId)) {
            String author = changeLogIterator.getString("author");
            String text = changeLogIterator.getString("text");
            SimpleAttributesImpl attr = new SimpleAttributesImpl();
            attr.addAttribute("author", sanitize(pkgId, author));
            attr.addAttribute("date", Long.toString(changeLogIterator.getDate(
                    "time").getTime() / 1000));
            tmpHandler.startElement("changelog", attr);
            tmpHandler.addCharacters(sanitize(pkgId, text));
            tmpHandler.endElement("changelog");
        }
    }

}
