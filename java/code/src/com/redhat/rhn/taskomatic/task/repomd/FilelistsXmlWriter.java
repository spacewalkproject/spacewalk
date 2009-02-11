package com.redhat.rhn.taskomatic.task.repomd;

import java.io.Writer;
import java.util.Iterator;

import org.xml.sax.SAXException;

import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.frontend.dto.PackageDto;
import com.redhat.rhn.taskomatic.task.TaskConstants;

public class FilelistsXmlWriter extends RepomdWriter {

    private PackageCapabilityIterator filelistIterator;
    /**
     * 
     * @param writer The writer object for filelist xml
     */
    public FilelistsXmlWriter(Writer writer) {
        super(writer);
    }
    /**
     * 
     * @param channel channel info
     * @return filelistxml for given channel
     * @throws Exception
     */
    public String getFilelistsXml(Channel channel) throws Exception{
        begin(channel);

        Iterator iter = getChannelPackageDtoIterator(channel);
        while (iter.hasNext()) {
            addPackage((PackageDto) iter.next());
        }

        end();

        return "";

    }
    /**
     * end xml metadata generation
     */
    public void end() {
        try {
            handler.endElement("filelists");
            handler.endDocument();
        } 
        catch (SAXException e) {
            throw new RepomdRuntimeException(e);
        }

    }
    /**
     * Start xml metadata generation
     * @param channel channel info
     */
    public void begin(Channel channel) {
        filelistIterator = new PackageCapabilityIterator(channel,
                               TaskConstants.TASK_QUERY_REPOMD_GENERATOR_CAPABILITY_FILES);
        SimpleAttributesImpl attr = new SimpleAttributesImpl();
        attr.addAttribute("xmlns", "http://linux.duke.edu/metadata/filelists");
        attr.addAttribute("packages", Integer.toString(channel.getPackages().size()));

        try {
            handler.startElement("filelists", attr);
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
            addPackageFiles(pkgDto);
            handler.endElement("package");
        } 
        catch (SAXException e) {
            throw new RepomdRuntimeException(e);
        }

    }

    /**
     * 
     * @param pkgId package Id info
     * @throws SAXException
     */
    private void addPackageFiles(PackageDto pkgDto) throws SAXException {
        long pkgId = pkgDto.getId().longValue();
        while (filelistIterator.hasNextForPackage(pkgId)) {
            handler.addElementWithCharacters("file", sanitize(pkgId, filelistIterator.getString("name")));
        }
    }

}
