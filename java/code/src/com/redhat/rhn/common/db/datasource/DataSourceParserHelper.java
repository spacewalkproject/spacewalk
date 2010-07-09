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

import org.xml.sax.Attributes;
import org.xml.sax.ContentHandler;
import org.xml.sax.Locator;
import org.xml.sax.SAXException;

import java.util.HashMap;
import java.util.Iterator;
import java.util.ListIterator;

/**
 * A contentHandler that knows how to parse the DataSource XML files.
 *
 * @version $Rev$
 */
class DataSourceParserHelper implements ContentHandler {

    private static final int TOP_LEVEL = 0;
    private static final int IN_MODE = 1;
    private static final int IN_QUERY = 2;
    private static final int QUERY_THROUGH_MODE = 3;
    private static final int MODE_AFTER_QUERY = 4;
    private static final int IN_ELABORATOR = 5;

    private HashMap internal_queries;
    private HashMap modes;
    private Mode m;
    private CachedStatement q;
    private int state;
    private StringBuffer query;

    /**
     * Create a new DataSourceParserHelper
     */
    public DataSourceParserHelper() {
        internal_queries = new HashMap();
        modes = new HashMap();
        state = TOP_LEVEL;
    }

    /**
     * Get the modes Map
     * @return the modes map.
     */
    public HashMap getModes() {
        return modes;
    }

    /**
     * Reset the mode to an empty map.
     */
    public void resetModes() {
        modes = new HashMap();
    }

    /** {@inheritDoc} */
    public void characters(char[] text, int start, int length)
        throws SAXException {

        if (state == IN_QUERY || state == QUERY_THROUGH_MODE) {
            query.append(new String(text, start, length));
        }
    }

    /** {@inheritDoc} */
    public void startElement(String namespaceURI, String localName,
            String qualifiedName, Attributes atts) {

        query = new StringBuffer();
        if (localName.equals("mode")) {
            state = IN_MODE;
            m = new SelectMode();
            String name = atts.getValue("name");
            String clazz = atts.getValue("class");
            m.setName(name);
            ((SelectMode)m).setClassString(clazz);
        }
        else if (localName.equals("callable-mode")) {
            state = IN_MODE;
            m = new CallableMode();
            String name = atts.getValue("name");
            m.setName(name);
        }
        else if (localName.equals("write-mode")) {
            state = IN_MODE;
            m = new WriteMode();
            String name = atts.getValue("name");
            m.setName(name);
        }
        else if (localName.equals("query") || localName.equals("elaborator")) {
            String alias = atts.getValue("alias");
            if (alias == null) {
                alias = "";
            }
            String name = atts.getValue("name");
            if (name == null) {
                name = "";
            }
            q = new CachedStatement(name, alias);
            if (state == IN_MODE || state == MODE_AFTER_QUERY) {
                state = QUERY_THROUGH_MODE;
                if (localName.equals("query")) {
                    m.setQuery(q);
                }
                else {
                    // This must be a select-mode, so if this isn't a
                    // select-mode, then we want the ClassCastException
                    ((SelectMode)m).addElaborator(q);
                }
            }
            else {
                state = IN_QUERY;
            }
            String column = atts.getValue("column");
            if (column == null) {
                column = "ID";
            }
            q.setColumn(column.toLowerCase());
            q.setParams(atts.getValue("params"));
            q.setSortOptions(atts.getValue("sort"));
            q.setDefaultSort(atts.getValue("defaultsort"));
            q.setSortOrder(atts.getValue("sortorder"));
            String mult = atts.getValue("multiple");
            if (mult != null && mult.equals("t")) {
                q.setMultiple(true);
            }
            else {
                q.setMultiple(false);
            }
        }
    }

    /** {@inheritDoc} */
    public void endElement(String namespaceURI, String localName,
            String qualifiedName) {
        if (state == MODE_AFTER_QUERY) {
            modes.put(m.getName(), m);
            state = TOP_LEVEL;
            m = null;
            return;
        }
        q.setQuery(query.toString().trim());
        if (state == IN_QUERY) {
            internal_queries.put(q.getName(), q);
            state = TOP_LEVEL;
        }
        else if (state == QUERY_THROUGH_MODE) {
            state = MODE_AFTER_QUERY;
        }
        else if (state == IN_ELABORATOR) {
            state = MODE_AFTER_QUERY;
        }
    }

    /** {@inheritDoc} */
    public void endDocument() {
        Iterator i = modes.values().iterator();

        Mode curr;
        while (i.hasNext()) {
            curr = (Mode)i.next();
            if (curr.getQuery().getQuery().trim().equals("")) {
                curr.setQuery((CachedStatement)internal_queries.get(
                                                   curr.getQuery().getName()));
            }
            if (curr instanceof SelectMode) {
                ListIterator el = ((SelectMode)curr).getElaborators().listIterator();
                while (el.hasNext()) {
                    CachedStatement currElaborator = (CachedStatement)el.next();
                    if (currElaborator.getQuery().trim().equals("")) {
                        String name = currElaborator.getName();
                        el.remove();
                        el.add(internal_queries.get(name));
                    }
                }
            }
        }

        /*
        i = modes.values().iterator();

        while (i.hasNext()) {
            curr = (SelectMode)i.next();
        }
        */
    }

    // do-nothing methods
    /** {@inheritDoc} */
    public void setDocumentLocator(Locator locator) {
    }

    /** {@inheritDoc} */
    public void startDocument() {
    }

    /** {@inheritDoc} */
    public void startPrefixMapping(String prefix, String uri) {
    }

    /** {@inheritDoc} */
    public void endPrefixMapping(String prefix) {
    }

    /** {@inheritDoc} */
    public void ignorableWhitespace(char[] text, int start,
            int length) throws SAXException {
    }

    /** {@inheritDoc} */
    public void processingInstruction(String target, String data) {
    }

    /** {@inheritDoc} */
    public void skippedEntity(String name) {
    }

} // end DataSourceParserHelper
