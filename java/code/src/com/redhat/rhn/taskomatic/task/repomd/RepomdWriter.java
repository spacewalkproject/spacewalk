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

import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.rhnpackage.Package;
import com.redhat.rhn.frontend.dto.PackageDto;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.apache.xml.serialize.OutputFormat;
import org.apache.xml.serialize.XMLSerializer;
import org.xml.sax.SAXException;

import java.io.IOException;
import java.io.OutputStream;
import java.io.Writer;

/**
 * 
 * @version $Rev $
 * 
 */
public abstract class RepomdWriter {

    protected SimpleContentHandler handler;

    private static final String CONTROL_CHARS;
    private static final String CONTROL_CHARS_REPLACEMENT;

    static {
        CONTROL_CHARS = "\u0000\u0001\u0002\u0003\u0004\u0005\u0006\u0007\u0008" +
                 "\u000B\u000C\u000E\u000F\u0010\u0011\u0012\u0013\u0014\u0015" +
                 "\u0016\u0017\u0018\u0019\u001A\u001B\u001C\u001D\u001E\u001F";
        CONTROL_CHARS_REPLACEMENT = StringUtils.repeat(" ", CONTROL_CHARS.length());
    }

    private static Logger log = Logger.getLogger(RepomdWriter.class);

    /**
     * Constructor takes in a writer
     * @param writer content writer
     */
    public RepomdWriter(Writer writer) {

        OutputFormat of = new OutputFormat();
        of.setPreserveSpace(true);
        
        //We use an unescaping serializer because we'll be appending xml
        XMLSerializer serializer = new UnescapingXmlSerializer(writer, of);
        
        
        try {
            handler = new SimpleContentHandler(serializer.asContentHandler());
        }
        catch (IOException e) {
            // XXX fatal error
        }
        try {
            handler.startDocument();
        }
        catch (SAXException e) {
            // XXX fatal error
        }
    }


    protected SimpleContentHandler getTemporaryHandler(OutputStream st) {
        OutputFormat of = new OutputFormat();
        of.setPreserveSpace(true);
        of.setOmitXMLDeclaration(true);
        XMLSerializer tmpSerial = new XMLSerializer(st, of);
        SimpleContentHandler tmpHandler = new SimpleContentHandler(tmpSerial);
        return tmpHandler;        
    }
    
    

    /**
     * 
     * @param handler content handler
     * @param pkgDto package info dto object
     * @throws SAXException
     */
    protected static void addPackageBoilerplate(SimpleContentHandler handler,
            PackageDto pkgDto) throws SAXException {
        long pkgId = pkgDto.getId().longValue();
        SimpleAttributesImpl attr = new SimpleAttributesImpl();
        attr.addAttribute("pkgid", sanitize(pkgId, pkgDto.getChecksum()));
        attr.addAttribute("name", sanitize(pkgId, pkgDto.getName()));
        attr.addAttribute("arch", sanitize(pkgId, pkgDto.getArchLabel()));
        handler.startElement("package", attr);

        attr.clear();
        attr.addAttribute("ver", sanitize(pkgId, pkgDto.getVersion()));
        attr.addAttribute("rel", sanitize(pkgId, pkgDto.getRelease()));
        attr.addAttribute("epoch", sanitize(pkgId,
                getPackageEpoch(pkgDto.getEpoch())));
        handler.startElement("version", attr);
        handler.endElement("version");
    }

    /**
     * 
     * @param pkg package object
     * @return package epoch string
     */
    protected static String getPackageEpoch(Package pkg) {
        return getPackageEpoch(pkg.getPackageEvr().getEpoch());
    }

    /**
     * 
     * @param epoch package epoch string
     * @return modified epoch string
     */
    protected static String getPackageEpoch(String epoch) {
        if (epoch == null || epoch.length() == 0) {
            epoch = "0";
        }
        return epoch;
    }

    /**
     * Removes all control characters from passed in String.
     * @param pkgId package id
     * @param input char input
     */
    protected static String sanitize(long pkgId, String input) {
        if (StringUtils.containsNone(input, CONTROL_CHARS)) {
            return input;
        }
        if (log.isDebugEnabled()) {
            log.debug("Package " + pkgId +
                    " metadata contains control chars, cleanup required: " + input);
        }
        return StringUtils.replaceChars(input, CONTROL_CHARS, CONTROL_CHARS_REPLACEMENT);
    }
    

    /**
     * 
     * @param channel channel info
     */
    public abstract void begin(Channel channel);

    /**
     * writer end call
     */
    public abstract void end();

}
