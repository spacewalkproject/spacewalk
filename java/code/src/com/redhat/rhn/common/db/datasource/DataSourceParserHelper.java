/**
 * Copyright (c) 2009--2016 Red Hat, Inc.
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

import org.apache.log4j.Logger;
import org.xml.sax.Attributes;
import org.xml.sax.ContentHandler;
import org.xml.sax.Locator;
import org.xml.sax.SAXException;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.StringTokenizer;

/**
 * A contentHandler that knows how to parse the DataSource XML files.
 *
 * @version $Rev$
 */
class DataSourceParserHelper implements ContentHandler, Serializable {

    private static final long serialVersionUID = 1L;

    private static Logger logger = Logger.getLogger(DataSourceParserHelper.class);

    private HashMap<String, ParsedQueryImpl> internalQueries;
    private HashMap<String, ParsedMode> modes;
    private ParsedModeImpl m = null;
    private ParsedQueryImpl q = null;

    private StringBuilder sqlBuilder = null;

    /**
     * Create a new DataSourceParserHelper
     */
    DataSourceParserHelper() {
    }

    /**
     * Get the modes Map
     * @return the modes map.
     */
    public HashMap<String, ParsedMode> getModes() {
        return modes;
    }

    /** {@inheritDoc} */
    public void characters(char[] text, int start, int length) throws SAXException {

        if (sqlBuilder != null) {
            sqlBuilder.append(text, start, length);
        }
    }

    /** {@inheritDoc} */
    public void startElement(String namespaceURI, String localName, String qualifiedName,
            Attributes atts) {

        logger.debug("startElement(" + localName + ")");

        //sqlStatement = new StringBuffer();
        if (localName.equals("datasource_modes")) {
            if (m != null || q != null) {
                throw new RuntimeException(
                        "'datasource_modes' element only valid at start of mode file.");
            }
            modes = new HashMap<String, ParsedMode>();
            internalQueries = new HashMap<String, ParsedQueryImpl>();
        }
        else if (localName.equals("mode")) {
            if (q != null) {
                throw new RuntimeException(
                        "'mode' element not valid within mode or elaborator element.");
            }
            m = new ParsedModeImpl(atts, ParsedMode.ModeType.SELECT);
        }
        else if (localName.equals("callable-mode")) {
            if (q != null) {
                throw new RuntimeException("'callable-mode' element not valid within " +
                        "mode or elaborator element.");
            }
            m = new ParsedModeImpl(atts, ParsedMode.ModeType.CALLABLE);
        }
        else if (localName.equals("write-mode")) {
            if (q != null) {
                throw new RuntimeException("'write-mode' element not valid within mode " +
                        "or elaborator element.");
            }
            m = new ParsedModeImpl(atts, ParsedMode.ModeType.WRITE);
        }
        else if (localName.equals("query")) {
            q = new ParsedQueryImpl(atts);
            sqlBuilder = new StringBuilder();
        }
        else if (localName.equals("elaborator")) {
            if (m == null) {
                throw new RuntimeException(
                        "Elaborator can only be defined within a mode definition.");
            }
            q = new ParsedQueryImpl(atts);
            sqlBuilder = new StringBuilder();
        }
        else {
            throw new RuntimeException("Invalid element '" + localName + "'");
        }
    }

    /** {@inheritDoc} */
    public void endElement(String namespaceURI, String localName, String qualifiedName) {

        logger.debug("endElement(" + localName + ")");

        switch (localName) {
            case "mode":
            case "callable-mode":
            case "write-mode":
                modes.put(m.getName(), m);
                m = null;
                break;

            case "query":
                String querySql = sqlBuilder.toString().trim();
                if (!querySql.isEmpty()) {
                    q.setSqlStatement(querySql);
                }
                if (m == null) {
                    ParsedQueryImpl pqi = getOrCreateInternalQuery(q);
                    pqi.setValues(q);
                }
                else {
                    if (querySql.isEmpty()) {
                        m.setParsedQuery(getOrCreateInternalQuery(q));
                    }
                    else {
                        m.setParsedQuery(q);
                    }
                }
                sqlBuilder = null;
                q = null;
                break;

            case "elaborator":
                String elabSql = sqlBuilder.toString().trim();
                if (!elabSql.isEmpty()) {
                    q.setSqlStatement(elabSql);
                }
                // NOTE: m can't be null since we checked in startElement()
                if (elabSql.isEmpty()) {
                    m.addElaborator(getOrCreateInternalQuery(q));
                }
                else {
                    m.addElaborator(q);
                }
                sqlBuilder = null;
                q = null;
                break;

            case "datasource_modes":
                if (q != null || m != null) {
                    throw new RuntimeException("Invalid xml");
                }
                break;

            default:
                throw new RuntimeException("Invalid end element '" + localName + "'");
        }
    }

    private ParsedQueryImpl getOrCreateInternalQuery(ParsedQueryImpl parsedQuery) {
        ParsedQueryImpl pqi = internalQueries.get(parsedQuery.getName());
        if (pqi == null) {
            pqi = parsedQuery;
            internalQueries.put(pqi.getName(), pqi);
        }
        return pqi;
    }

    /** {@inheritDoc} */
    public void endDocument() {
        // Implement sanity check? Look for queries with names but no sql
        // statement.
        ArrayList<String> errors = new ArrayList<String>();
        String errmsg;
        for (String modeKey : modes.keySet()) {
            logger.debug("Sanity check for mode " + modeKey);
            ParsedMode pm = modes.get(modeKey);
            if (pm == null) {
                errors.add("ParsedMode is null for key '" + modeKey + "'");
            }
            logger.debug("Checking query");
            errmsg = sanityCheckParsedQuery(pm.getParsedQuery(), modeKey);
            if (errmsg != null) {
                errors.add(errmsg);
            }
            logger.debug("Checking elaborators");
            for (ParsedQuery pq : pm.getElaborators()) {
                errmsg = sanityCheckParsedQuery(pq, modeKey);
                if (errmsg != null) {
                    errors.add(errmsg);
                }
            }
        }
        if (!errors.isEmpty()) {
            StringBuilder sb = new StringBuilder();
            for (String e : errors) {
                sb.append(e).append("/n");
            }
            throw new RuntimeException(sb.toString());
        }
    }

    private String sanityCheckParsedQuery(ParsedQuery pq, String modeKey) {
        if (pq == null) {
            return "ParsedQuery is null for key '" + modeKey + "'";
        }
        if (pq.getSqlStatement() == null) {
            return "ParsedQuery '" + pq.getName() + "' for key '" + modeKey +
                    "' has null sql statement - instance " + pq;
        }
        if (pq.getSqlStatement().trim().equals("")) {
            return "ParsedQuery '" + pq.getName() + "' for key '" + modeKey +
                    "' has empty sql statement - instance " + pq;
        }
        return null;
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
    public void ignorableWhitespace(char[] text, int start, int length)
        throws SAXException {
    }

    /** {@inheritDoc} */
    public void processingInstruction(String target, String data) {
    }

    /** {@inheritDoc} */
    public void skippedEntity(String name) {
    }

    /**
     * The DataSourceParserHelper creates an instance of this ParsedQueryImpl
     * for each query it parses. The ParsedQuery is used by ModeFactory when
     * creating new Mode objects and the elaborators and queries contained
     * therein.
     */
    private class ParsedQueryImpl implements ParsedQuery, Serializable {

        private static final long serialVersionUID = 1L;

        private String name;
        private String alias;
        private String elaboratorJoinColumn;
        private List<String> parameterList;
        private boolean multiple;
        private String sqlStatement;

        /**
         * Constructor used to create an instance of this class and reading
         * member variable values from Attributes while parsing the xml.
         * @param parsedAttributes
         */
        private ParsedQueryImpl(Attributes parsedAttributes) {
            name = parsedAttributes.getValue("name");
            if (name == null) {
                name = "";
            }

            alias = parsedAttributes.getValue("alias");
            if (alias == null) {
                alias = "";
            }

            String column = parsedAttributes.getValue("column");
            elaboratorJoinColumn = (column == null) ? "id" : column.toLowerCase();

            String mult = parsedAttributes.getValue("multiple");
            multiple = (mult != null && mult.equals("t"));

            parameterList = new ArrayList<String>();
            String parameters = parsedAttributes.getValue("params");
            if (parameters != null && !parameters.isEmpty()) {
                StringTokenizer st = new StringTokenizer(parameters, ",");
                while (st.hasMoreTokens()) {
                    parameterList.add(st.nextToken().trim());
                }
            }
        }

        private void setValues(ParsedQueryImpl parsedQuery) {
            // name must already be set.
            alias = parsedQuery.getAlias();
            elaboratorJoinColumn = parsedQuery.getElaboratorJoinColumn();
            multiple = parsedQuery.isMultiple();
            parameterList = parsedQuery.getParameterList();
            sqlStatement = parsedQuery.getSqlStatement();
        }

        private void setSqlStatement(String newSqlStatement) {
            this.sqlStatement = newSqlStatement;
        }

        @Override
        public String getName() {
            return name;
        }

        @Override
        public String getAlias() {
            return alias;
        }

        @Override
        public String getSqlStatement() {
            return sqlStatement;
        }

        @Override
        public String getElaboratorJoinColumn() {
            return elaboratorJoinColumn;
        }

        @Override
        public List<String> getParameterList() {
            return parameterList;
        }

        @Override
        public boolean isMultiple() {
            return multiple;
        }
    }

    /**
     * The DataSourceParserHelper creates an instance of this ParsedModeImpl for
     * each mode it parses. The ParsedMode is used by ModeFactory when creating
     * new Mode objects and the elaborators and queries contained therein.
     */
    private class ParsedModeImpl implements ParsedMode, Serializable {

        private static final long serialVersionUID = 1L;

        private String name;
        private ModeType modeType;

        private ParsedQuery parsedQuery;

        // SELECT modes only
        private String classname;
        private List<ParsedQuery> elaborators = new ArrayList<ParsedQuery>();

        private ParsedModeImpl(Attributes parsedAttributes, ModeType newModeType) {
            name = parsedAttributes.getValue("name");
            this.modeType = newModeType;
            if (newModeType == ModeType.SELECT) {
                classname = parsedAttributes.getValue("class");
            }
        }

        private void setParsedQuery(ParsedQuery newParsedQuery) {
            this.parsedQuery = newParsedQuery;
        }

        private void addElaborator(ParsedQuery elaborator) {
            if (modeType != ModeType.SELECT) {
                throw new IllegalArgumentException(
                        "Mode " + name + " must be ModeType SELECT to add elaborator.");
            }
            elaborators.add(elaborator);
        }

        @Override
        public String getName() {
            return name;
        }

        @Override
        public ModeType getType() {
            return modeType;
        }

        @Override
        public ParsedQuery getParsedQuery() {
            return parsedQuery;
        }

        @Override
        public String getClassname() {
            return classname;
        }

        @Override
        public List<ParsedQuery> getElaborators() {
            return elaborators;
        }
    }
} // end DataSourceParserHelper
