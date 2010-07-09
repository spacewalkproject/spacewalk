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
package com.redhat.rhn.common.db.datasource;

import com.redhat.rhn.common.util.manifestfactory.ManifestFactory;
import com.redhat.rhn.common.util.manifestfactory.ManifestFactoryBuilder;

import org.xml.sax.ContentHandler;
import org.xml.sax.InputSource;
import org.xml.sax.XMLReader;
import org.xml.sax.helpers.XMLReaderFactory;

import java.net.URL;
import java.util.Collection;
import java.util.Map;

/**
 * Class to drive parsing of the DataSource XML files, and return modes
 * as they are requested.
 *
 * @version $Rev$
 */
public class ModeFactory implements ManifestFactoryBuilder {


    private static final String DEFAULT_PARSER_NAME =
                                       "org.apache.xerces.parsers.SAXParser";

    private static ManifestFactory factory = new ManifestFactory(new ModeFactory());

    private static XMLReader parser = null;

    /** {@inheritDoc} */
    public String getManifestFilename() {
        return "xml/file-list.xml";
    }

    /** {@inheritDoc} */
    public Object createObject(Map params) {
        try {
            if (parser == null) {
                parser = XMLReaderFactory.createXMLReader(DEFAULT_PARSER_NAME);

                ContentHandler handler = new DataSourceParserHelper();
                parser.setContentHandler(handler);
            }
            String filename = (String)params.get("filename");
            if (filename == null) {
                throw new NullPointerException("filename is null");
            }

            URL u = this.getClass().getResource(filename);
            DataSourceParserHelper handler =
                          (DataSourceParserHelper)parser.getContentHandler();
            handler.resetModes();
            parser.parse(new InputSource(u.openStream()));
            return handler.getModes();
        }
        catch (Exception e) {
            throw new DataSourceParsingException("Unable to parse file", e);
        }
    }

    private static Mode getModeInternal(String name, String mode) {
        Map modes = (Map)factory.getObject(name);
        Mode ret = (Mode)modes.get(mode);
        if (ret == null) {
            throw new ModeNotFoundException(
                              "Could not find mode " + mode + " in " + name);
        }
        return ret;
    }

    private static SelectMode getSelectMode(String name, String mode) {
        Map modes = (Map) factory.getObject(name);
        SelectMode m = (SelectMode) modes.get(mode);
        if (m == null) {
            throw new ModeNotFoundException(
                              "Could not find mode " + mode + " in " + name);
        }
        SelectMode ret = new SelectMode(m);
        return ret;
    }
    /**
     * Retreive a specific mode from the map of modes already parsed
     * @param name The name of the file to search, this is the name as it is
     *             passed to parseURL.
     * @param mode the mode to retreive
     * @return The requested mode
     */
    public static SelectMode getMode(String name, String mode) {
        return getSelectMode(name, mode);
    }

    /**
     * Retreive a specific mode from the map of modes already parsed.
     * @param name The name of the file to search, this is the name as it is passed
     *             to parseURL.
     * @param mode The mode to retreive
     * @param clazz The class you would like the returned objects to be.
     * @return The requested mode
     */
    public static SelectMode getMode(String name, String mode, Class clazz) {
        SelectMode ret = getSelectMode(name, mode);
        ret.setClassString(clazz.getName());
        return ret;
    }

    /**
     * Retreive a specific mode from the map of modes already parsed
     * @param name The name of the file to search, this is the name as it is
     *             passed to parseURL.
     * @param mode the mode to retreive
     * @return The requested mode
     */
    public static WriteMode getWriteMode(String name, String mode) {
        return (WriteMode)getModeInternal(name, mode);
    }

    /**
     * Retreive a specific mode from the map of modes already parsed
     * @param name The name of the file to search, this is the name as it is
     *             passed to parseURL.
     * @param mode the mode to retreive
     * @return The requested mode
     */
    public static CallableMode getCallableMode(String name, String mode) {
        return (CallableMode)getModeInternal(name, mode);
    }

    /**
     * Retreive the keys
     * @return the fileMap filled out from parsing the files.
     * This function really shouldn't be here, but I need it for the
     * unit tests.
     */
    public static Collection getKeys() {
        return factory.getKeys();
    }

    /**
     * Retrieve the Modes for a given key.
     * @param name of the filemap to retrieve.
     * @return the fileMap filled out from parsing the files.
     * This function really shouldn't be here, but I need it for the
     * unit tests.
     */
    public static Map getFileKeys(String name) {
        return (Map)factory.getObject(name);
    }
}

