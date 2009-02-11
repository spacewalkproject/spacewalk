package com.redhat.rhn.taskomatic.task.repomd;

import java.io.Writer;
import java.util.Iterator;

import org.apache.log4j.Logger;
import org.xml.sax.SAXException;

import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.frontend.dto.PackageDto;
import com.redhat.rhn.taskomatic.task.TaskConstants;

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
     * @throws Exception
     */
    public String getOtherXml(Channel channel) throws Exception{
        begin(channel);

        Iterator iter = getChannelPackageDtoIterator(channel);
        while (iter.hasNext()) {
            addPackage((PackageDto) iter.next());
        }

        end();

        return "";

    }
    /**
     * Start xml metadata generation
     */
    public void begin(Channel channel) {
                changeLogIterator = new PackageCapabilityIterator(channel,
                                        TaskConstants.TASK_QUERY_REPOMD_GENERATOR_PACKAGE_CHANGELOG);
        SimpleAttributesImpl attr = new SimpleAttributesImpl();
        attr.addAttribute("xmlns", "http://linux.duke.edu/metadata/other");
        attr.addAttribute("packages", Integer.toString(channel.getPackages().size()));

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
            addPackageBoilerplate(handler, pkgDto);
            addPackageChangelog(pkgDto);
            handler.endElement("package");
        } 
        catch (SAXException e) {
            throw new RepomdRuntimeException(e);
        }
    }
    /**
     * 
     * @param pkgDto pkg changelog info to add to xml
     * @throws SAXException
     */
    private void addPackageChangelog(PackageDto pkgDto) throws SAXException {

        long pkgId = pkgDto.getId().longValue();
        while (changeLogIterator.hasNextForPackage(pkgId)) {
            String author = changeLogIterator.getString("author");
            String text = changeLogIterator.getString("text");
            SimpleAttributesImpl attr = new SimpleAttributesImpl();
            attr.addAttribute("author", sanitize(pkgId, author));
            attr.addAttribute("date", Long.toString(changeLogIterator.getDate("time").getTime()/1000));
            handler.startElement("changelog", attr);
            handler.addCharacters(sanitize(pkgId, text));
            handler.endElement("changelog");
        }
    }

}
