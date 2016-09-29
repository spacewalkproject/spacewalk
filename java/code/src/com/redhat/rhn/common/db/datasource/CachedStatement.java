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
package com.redhat.rhn.common.db.datasource;

import com.redhat.rhn.common.ObjectCreateWrapperException;
import com.redhat.rhn.common.RhnRuntimeException;
import com.redhat.rhn.common.db.NamedPreparedStatement;
import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.common.hibernate.HibernateHelper;
import com.redhat.rhn.common.hibernate.HibernateRuntimeException;
import com.redhat.rhn.common.translation.SqlExceptionTranslator;
import com.redhat.rhn.common.util.MethodUtil;
import com.redhat.rhn.common.util.StringUtil;

import org.apache.log4j.Logger;
import org.hibernate.HibernateException;
import org.hibernate.Session;
import org.hibernate.jdbc.ReturningWork;

import java.io.Serializable;
import java.lang.reflect.Method;
import java.math.BigDecimal;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.StringTokenizer;

/**
 * A cached set of query/elaborator strings and the parameterMap hash maps.
 */
public class CachedStatement implements Serializable {

    /**
     * Comment for <code>serialVersionUID</code>
     */
    private static final long serialVersionUID = -6256397039512492615L;
    /**
     * Logger for this class
     */
    private static Logger log = Logger
            .getLogger(CachedStatement.class);
    static final int BATCH_SIZE = 500;
    private final String alias;
    private final String name;
    /** the original query, before the named bind parameters were removed. */
    private String origQuery;
    private String query;
    private String column;
    private Map<String, List<Integer>> qMap;
    private List<String> params;
    private List<String> sortOptions;
    private String defaultSort;
    private String sortOrder;
    private boolean multiple;
    // This is only set if the current CachedStatement is a duplicate of an
    // existing one with the %s expanded out.
    private CachedStatement parentStatement;
    private RestartData restartData = null;

    // We could (and probably should) cache the ResultSet metadata here as
    // well.  There is no reason that the first call to each statement
    // couldn't do the work to determine what is returned.

    /**
     * Create a CachedStatement for a query
     * @param n The name to set
     * @param a Alias
     */
    public CachedStatement(String n, String a) {
        name = n;
        alias = a;
        params = new ArrayList<String>();
        sortOptions = new ArrayList<String>();
    }

    /**
     * Returns the arity of the statement
     * @return number of parameters
     */
    public int getArity() {
        return params == null ? 0 : params.size();
    }

    /**
     * Create a CachedStatement for a query
     * @param n The name to set
     * @param a Alias
     * @param orig Original CachedStatement
     */
    public CachedStatement(String n, String a, CachedStatement orig) {
        this(n, a);
        parentStatement = orig;
    }

    /**
     * Copy constructor
     * @param orig Original CachedStatement
     */
    public CachedStatement(CachedStatement orig) {
        this(orig.getName(), orig.getAlias());
        this.setQuery(new String(orig.getOrigQuery()));

        if (orig.column != null) {
            this.column = new String(orig.column);
        }

        this.params = new ArrayList<String>(orig.params);
        this.sortOptions = new ArrayList<String>(orig.sortOptions);

        if (orig.defaultSort != null) {
            this.defaultSort = new String(orig.defaultSort);
        }

        if (orig.sortOrder != null) {
            this.sortOrder = new String(orig.sortOrder);
        }

        this.multiple = orig.multiple;
    }

    /**
     * Get the query's alias
     * @return the querys alias
     */
    public String getAlias() {
        return alias;
    }

    /**
     * Get the query's name
     * @return the querys name
     */
    public String getName() {
        return name;
    }

    /**
     * Get the query string
     * @return the query string
     */
    public String getQuery() {
        return query;
    }

    /**
     * Get the original query string
     * @return the original query, before the named bind parameters were
     *         removed.
     */
    public String getOrigQuery() {
        return origQuery;
    }

    /**
     * Set the query string
     * @param q the query to set.
     */
    public void setQuery(String q) {
        qMap = new HashMap<String, List<Integer>>();
        origQuery = q;
        query = NamedPreparedStatement.replaceBindParams(q, qMap);
    }

    /**
     * Set the column used to relate driving queries and elaborators
     * @param c Column name.
     */
    public void setColumn(String c) {
        column = c;
    }

    /**
     * Get the column used to relate driving queries and elaborators
     * @return column name.
     */
    public String getColumn() {
        return column;
    }

    /**
     * Set the parameters.  This is used by passing in a comma-delimited
     * list of parameters, and the method will internally convert it to a
     * List.
     * @param p the parameters to set.
     */
    public void setParams(String p) {
        if (p != null) {
            StringTokenizer st = new StringTokenizer(p, ",");
            while (st.hasMoreTokens()) {
                params.add(st.nextToken().trim());
            }
        }
    }

    /**
     * Set the parameters.
     * @param p the parameters to set.
     */
    public void setParams(List<String> p) {
        params.addAll(p);
    }

    /**
     * Set the sort options. Expects a comma separated list of columns used
     * for sorting.
     * @param p Comma separated list of columns used for sorting.
     */
    public void setSortOptions(String p) {
        if (p != null) {
            StringTokenizer st = new StringTokenizer(p, ",");
            while (st.hasMoreTokens()) {
                sortOptions.add(st.nextToken().trim());
            }
        }
    }

    /**
     * Set the parameters.
     * @param p the parameters to set.
     */
    public void setSortOptions(List<String> p) {
        sortOptions.addAll(p);
    }

    /**
     * Set the default sort order
     * @param d Specifies the default sort order.
     */
    public void setDefaultSort(String d) {
        defaultSort = d;
    }

    /**
     * Set the sort order if not specified, default sort order is used.
     * @param o Specifies the sort order.
     * @see #setDefaultSort(String)
     */
    public void setSortOrder(String o) {
        sortOrder = o;
    }

    /**
     * Set the multiple flag.  If true, elaboration might return multiple
     * rows for a single row in the input set.
     * @param m the flag to set.
     */
    public void setMultiple(boolean m) {
        multiple = m;
    }

    int executeUpdate(Map<String, Object> parameters) {
        Integer res = (Integer)execute(query, qMap, parameters, null);
        return res.intValue();
    }

    int executeUpdate(Map<String, Object> parameters, List<Object> inClause) {
        Integer res = (Integer)execute(parameters, inClause, "", "", null);
        return res.intValue();
    }

    DataResult<Object> execute(Map<String, Object> parameters, Mode mode) {
        return execute(parameters, defaultSort, sortOrder, mode);
    }

    DataResult<Object> execute(List<Object> parameters, Mode mode) {
        return (DataResult<Object>) execute(null, parameters, "", "", mode);
    }

    DataResult<Object> execute(Map<String, Object> parameters,
            List<Object> inClause,
            Mode mode) {
        return (DataResult<Object>) execute(parameters, inClause, "", "", mode);
    }

    Object execute(Map<String, Object> parameters, List<Object> inClause,
            String sortColumn,
            String order, Mode mode) {
        if (query.indexOf("%o") > 0 && !sortOptions.contains(sortColumn)) {
            throw new IllegalArgumentException("Sort Column, " + sortColumn +
                    " invalid for query " + this);
        }
        String finalQuery = query.replaceFirst("%o",
                sortColumn + " " + order);

        if (query.indexOf("%s") > 0 &&
                (inClause != null && !inClause.isEmpty())) {

            // TODO: what if inClause is > 1000 items, do we let
            // the DB blow up or catch it here? what do we do if
            // we have > 1000.  Not much we can do.
            StringBuilder buf = new StringBuilder();

            int len = inClause.size();
            Object o = inClause.get(0);
            if (o instanceof String) {
                buf.append("'");
                buf.append((String) o);
                buf.append("'");
            }
            else {
                buf.append(String.valueOf(o));
            }

            for (int i = 1; i < len; i++) {
                buf.append(",");
                o = inClause.get(i);
                if (o instanceof String) {
                    buf.append("'");
                    buf.append((String) o);
                    buf.append("'");
                }
                else {
                    buf.append(String.valueOf(inClause.get(i)));
                }
            }

            finalQuery = finalQuery.replaceAll("%s", buf.toString());
        }

        return execute(finalQuery, qMap, parameters, mode);
    }

    DataResult<Object> execute(Map<String, Object> parameters,
            String sortColumn,
            String order, Mode mode) {
        return (DataResult<Object>) execute(parameters, null, sortColumn,
                order, mode);
    }

    Collection<Object> executeElaborator(List<Object> resultList, Mode mode,
            Map<String, Object> parametersIn) {
        List<Object> elaborated = new LinkedList<Object>();
        for (int batch = 0; batch < resultList.size(); batch = batch + BATCH_SIZE) {
            int toIndex = batch + BATCH_SIZE;
            if (toIndex > resultList.size()) {
                toIndex = resultList.size();
            }
            elaborated.addAll(
                    executeElaboratorBatch(resultList.subList(batch, toIndex),
                            mode, parametersIn));
        }
        return elaborated;
    }

    @SuppressWarnings("unchecked")
    private Collection<Object> executeElaboratorBatch(List<Object> resultList,
            Mode mode,
            Map<String, Object> parametersIn) {
        int len = resultList.size();
        Map<String, Object> parameters = new HashMap<String, Object>(
                parametersIn);

        if (len == 0) {
            // Nothing to elaborate, just return;
            return resultList;
        }

        // If we aren't actually operating on a list, just elaborate.
        if (origQuery.indexOf("%s") == -1) {
            return (DataResult<Object>) executeChecking(query, qMap, parameters, mode,
                    resultList);
        }

        StringBuilder bindParams = new StringBuilder(":l0");
        List<String> newParams = new ArrayList<String>(params);
        if (!checkForColumn(resultList.get(0), column)) {
            throw new MapColumnNotFoundException("Column, " + column +
                    ", not found " +
                    "in driving query results");
        }

        parameters.put("l0", getKey(resultList.get(0), column));
        newParams.add("l0");
        // start at 1, because we already added the first one
        for (int i = 1; i < len; i++) {
            bindParams.append(", :l" + i);
            parameters.put("l" + i, getKey(resultList.get(i), column));
            newParams.add("l" + i);
        }

        // This should all be removed and replaced with a copy constructor.
        String newName = "";
        if (!name.equals("")) {
            newName = name + len;
        }
        CachedStatement cs = new CachedStatement(newName, alias, this);
        cs.setQuery(origQuery.replaceAll("%s", bindParams.toString()));
        cs.setMultiple(multiple);
        cs.setParams(newParams);
        cs.setColumn(column);
        cs.setSortOptions(sortOptions);
        cs.setSortOrder(sortOrder);
        cs.setDefaultSort(defaultSort);
        // Should cache the new CachedStatment here
        return cs.executeElaboratorBatch(resultList, mode, parameters);
    }

    private Map<String, Object> setupParamMap(Map<String, Object> parameters) {
        if (parameters == null && !params.isEmpty()) {
            throw new IllegalArgumentException("Query contains named parameter," +
                    " but value map is null");
        }
        // Only pass the parameters from the original query.
        Map<String, Object> intersection = new HashMap<String, Object>();
        Iterator<String> i = params.iterator();
        while (i.hasNext()) {
            String curr = i.next();
            if (!parameters.containsKey(curr)) {
                throw new ParameterValueNotFoundException("Parameter '" + curr +
                        "' not given for query: " + query);
            }
            intersection.put(curr, parameters.get(curr));
        }
        return intersection;
    }

    private Object execute(String sql, Map<String, List<Integer>> parameterMap,
            Map<String, Object> parameters, Mode mode) {
        return executeChecking(sql, parameterMap, parameters, mode, null);
    }

    /**
     * Prepares and executes a SQL statements with parameters, handling
     * Exceptions appropriately.
     * @param sql SQL string to be prepared and executed
     * @param parameterMap The Map returned setup by replaceBindParams
     * @param parameters The Map returned setup by replaceBindParams
     * @param mode Mode for selection queries
     * @param dr Data result list or null
     * @return either an integer count of the number of rows updated, or the
     *         DataResult. Casting to int or DataResult is caller's
     *         responsibility
     */
    private Object executeChecking(String sql, Map<String, List<Integer>> parameterMap,
            Map<String, Object> parameters, Mode mode, List<Object> dr) {

        try {
            return execute(sql, parameterMap, parameters, mode, dr);
        }
        catch (SQLException e) {
            throw SqlExceptionTranslator.sqlException(e);
        }
        catch (HibernateException he) {
            throw new
            HibernateRuntimeException(
                    "HibernateException executing CachedStatement", he);

        }
        catch (RhnRuntimeException e) {
            // we just add more information for better bug tracking
            log.error("Error while processing cached statement sql: " + sql, e);
            throw e;
        }
    }

    /**
     * Executes a prepared SQL statement with parameters.
     * @param sql SQL string to be prepared and executed
     * @param parameterMap The Map returned setup by replaceBindParams
     * @param parameters The Map returned setup by replaceBindParams
     * @param mode Mode for selection queries
     * @param dr Data result list or null
     * @return either an integer count of the number of rows updated, or the
     *         DataResult. Casting to int or DataResult is caller's
     *         responsibility
     * @throws SQLException
     */
    private Object execute(String sql, Map<String, List<Integer>> parameterMap,
            Map<String, Object> parameters, Mode mode,
            List<Object> dr) throws SQLException {
        if (log.isDebugEnabled()) {
            log.debug("execute() - Executing: " + sql);
            log.debug("execute() - With: " + parameters);
        }

        storeForRestart(sql, parameterMap, parameters, mode, dr);

        return doWithStolenConnection(connection -> {
            PreparedStatement ps = null;
            try {
                ps = prepareStatement(connection, sql, mode);
                boolean returnType = NamedPreparedStatement.execute(ps, parameterMap,
                        setupParamMap(parameters));
                if (log.isDebugEnabled()) {
                    log.debug("execute() - Return type: " + returnType);
                }
                if (returnType) {
                    return processResultSet(ps.getResultSet(), (SelectMode) mode, dr);
                }
                return new Integer(ps.getUpdateCount());
            }
            finally {
                HibernateHelper.cleanupDB(ps);
            }
        });
    }

    /**
     * Executes a prepared SQL statement with parameters.
     * @param connection JDBC connection object in which create the statement
     * @param sql SQL string to be prepared and executed
     * @param mode Mode for selection queries
     * @return the prepared statement
     * @throws SQLException
     */
    private PreparedStatement prepareStatement(Connection connection, String sql, Mode mode)
        throws SQLException, HibernateException {
        PreparedStatement ps = connection.prepareStatement(sql);

        // allow limiting the results for better performance.
        if (mode != null && mode instanceof SelectMode) {
            ps.setMaxRows(((SelectMode) mode).getMaxRows());
        }
        return ps;
    }

    private Map<String, Object> processOutputParams(CallableStatement cs,
            Map<String, Integer> outParams)
                    throws SQLException {

        Iterator<String> i = outParams.keySet().iterator();
        Map<String, Object> result = new HashMap<String, Object>();
        while (i.hasNext()) {
            String param = i.next();
            Iterator<Integer> positions = NamedPreparedStatement.getPositions(
                    param, qMap);
            // For now assume that we only specify each output parameter once,
            // to do otherwise just doesn't make a lot of sense.
            Integer pos = positions.next();
            Object o = cs.getObject(pos.intValue());
            if (o instanceof BigDecimal) {
                o = new Long(((BigDecimal)o).longValue());
            }
            result.put(param, o);
        }
        return result;
    }

    Map<String, Object> executeCallable(Map<String, Object> inParams,
            Map<String, Integer> outParams) {
        return doWithStolenConnection(connection -> {
            CallableStatement cs = null;
            try {
                cs = connection.prepareCall(query);
                NamedPreparedStatement.execute(cs, qMap, inParams, outParams);
                return processOutputParams(cs, outParams);
            }
            catch (SQLException e) {
                throw SqlExceptionTranslator.sqlException(e);
            }
            catch (HibernateException he) {
                throw new HibernateRuntimeException(
                        "HibernateException executing CachedStatement", he);
            }
            catch (RuntimeException e) {
                if (e.getCause() instanceof SQLException) {
                    throw SqlExceptionTranslator.sqlException((SQLException) e.getCause());
                }
                throw e;
            }
            finally {
                HibernateHelper.cleanupDB(cs);
            }
        });
    }

    private DataResult<Object> processResultSet(ResultSet rs, SelectMode mode,
            List<Object> currentResults) {

        Map<Object, Integer> pointers = null;
        DataResult<Object> dr;
        if (currentResults != null) {
            pointers = generatePointers(currentResults, getColumn());
            dr = new DataResult<Object>(currentResults);
        }
        else {
            dr = new DataResult<Object>(mode);
        }
        String className = mode.getClassString();
        try {
            // Get the column names from the result set.
            List<String> columns = getColumnNames(rs.getMetaData());
            if (currentResults != null &&
                    !columns.contains(getColumn().toLowerCase())) {
                // This is ugly, but we check driving query results someplace
                // else, so this is only executed if we are elaborating.
                throw new MapColumnNotFoundException("Column, " + column +
                        ", not found in elaborator results");
            }

            // loop through the results, adding them to the displayMap
            while (rs.next()) {
                /*
                 * If no className was specified *or* if the caller wants a Map
                 */
                if (className == null || className.equals("java.util.Map")) {
                    Map<String, Object> resultMap;
                    if (pointers == null) {
                        resultMap = new HashMap<String, Object>();
                    }
                    else {
                        Integer pos = pointers.get(getObject(rs, getColumn()));
                        /* TODO: there is a possible bug here. If the elaborator does
                         * not restrict itself to only the current results (%s thing),
                         * then the pos here is null, because the object might not
                         * exist in the map.
                         * Decide if this is a bug here or a bug with the query that
                         * allows such effect. Decide what to do about it.
                         */
                        resultMap = (Map<String, Object>) currentResults
                                .get(pos.intValue());
                    }
                    addToMap(columns, rs, resultMap,
                            mode.getElaborators().indexOf(parentStatement));

                    // bug 141664: Don't add to the DataResult if we are
                    // elaborating the data.
                    if (pointers == null) {
                        dr.add(resultMap);
                    }
                }
                /*
                 * Otherwise, try to set the results to the class given.
                 */
                else {
                    Class<?> clazz = Class.forName(className);
                    Object obj;
                    if (pointers == null) {
                        obj = clazz.newInstance();
                    }
                    else {
                        Integer pos = pointers.get(getObject(rs, getColumn()));
                        if (pos == null) {
                            // possible mismatch on elaborator ids
                            throw new IllegalArgumentException("Null elab match for " +
                                    getColumn() + " " + getObject(rs, getColumn()));
                        }
                        obj = currentResults.get(pos.intValue());
                    }
                    // if pointers are null, we are doing an elaborator.
                    addToObject(columns, rs, obj, (pointers != null));
                    // bug 141664: Don't add to the DataResult if we are
                    // elaborating the data.
                    if (pointers == null) {
                        dr.add(obj);
                    }
                }
            }
            //TODO: this is the only place that we care that we are
            //returning a DataResult object rather than simply a List.
            //Furthermore, this is entirely because of paging in the
            //user interface which should clearly not be done in the
            //bowels of CachedStatement inside datasource.
            //Remove this pointless coupling once we move the paging
            //logic elsewhere.
            if (dr.size() > 0) {
                dr.setStart(1);
                dr.setEnd(dr.size());
                dr.setTotalSize(dr.size());
            }
            return dr;
        }
        catch (SQLException e) {
            throw SqlExceptionTranslator.sqlException(e);
        }
        catch (ClassNotFoundException e) {
            throw new ObjectCreateWrapperException("Could not create " +
                    className, e);
        }
        catch (InstantiationException e) {
            throw new ObjectCreateWrapperException("Could not create " +
                    className, e);
        }
        catch (IllegalAccessException e) {
            throw new ObjectCreateWrapperException("Could not create " +
                    className, e);
        }
        finally {
            HibernateHelper.cleanupDB(rs);
        }
    }

    private void addToMap(List<String> columns, ResultSet rs,
            Map<String, Object> resultMap,
            int pos)
                    throws SQLException {
        Map<String, Object> newMap = new HashMap<String, Object>();
        Iterator<String> i = columns.iterator();
        while (i.hasNext()) {
            String columnName = i.next();
            newMap.put(columnName.toLowerCase(),
                    getObject(rs, columnName));
        }
        if (resultMap.isEmpty()) {
            resultMap.putAll(newMap);
        }
        else {
            // To find the elaborator name, check if an alias is set, if not
            // check if name is set, if not use elaborator#.
            String stmtName = getAlias();
            if (stmtName.equals("")) {
                if (parentStatement != null) {
                    stmtName = parentStatement.getName();
                }
                else {
                    stmtName = getName();
                }
            }
            if (stmtName.equals("")) {
                stmtName = "elaborator" + pos;
            }
            if (multiple) {
                List<Object> newList = null;
                if (resultMap.containsKey(stmtName)) {
                    newList = (List<Object>) resultMap.get(stmtName);
                }
                else {
                    newList = new ArrayList<Object>();
                }
                newList.add(newMap);
                resultMap.put(stmtName, newList);
            }
            else {
                resultMap.put(stmtName, newMap);
            }
        }
    }

    private void addToObject(List<String> columns, ResultSet rs, Object obj,
            boolean elaborator)
                    throws SQLException {

        List<String> columnSkip;
        if (elaborator && obj instanceof RowCallback) {
            RowCallback cb = (RowCallback)obj;
            cb.callback(rs);
            columnSkip = cb.getCallBackColumns();
        }
        else {
            columnSkip = new ArrayList<String>();
        }

        Iterator<String> i = columns.iterator();
        while (i.hasNext()) {
            String columnName = i.next();
            if (columnSkip.contains(columnName.toLowerCase())) {
                continue;
            }

            String setName = StringUtil.beanify("set " + columnName.toLowerCase());
            String getName = StringUtil.beanify("get " + columnName.toLowerCase());

            boolean isList = false;
            Method[] methods = obj.getClass().getMethods();
            /*
             * Now loop through the methods and find the set method for this column
             * then decide if it takes a collection
             * Note: This action might not complete correctly if there are two set
             *       methods with the same name
             */
            for (int j = 0; j < methods.length; j++) {
                //getName() gets the name of the set method
                //setName is the name of the set method
                if (methods[j].getName().equals(setName)) {
                    Class<?> paramType = methods[j].getParameterTypes()[0];
                    if (Collection.class.isAssignableFrom(paramType)) {
                        isList = true;
                    }
                    break;
                }
            }

            if (isList) { //requires matching get method returning the same list
                Collection<Object> c = (Collection<Object>) MethodUtil
                        .callMethod(obj,
                                getName, new Object[0]);
                if (c == null) {
                    c = new ArrayList<Object>();
                }
                c.add(getObject(rs, columnName));
                MethodUtil.callMethod(obj, setName, c);
                continue;
            }
            /*
             * Just call the set method.  This will call the same
             * set method multiple times.  If the result set should
             * be a list, but has a non-Collection set method, the
             * attribute corresponding to this column will ultimately
             * contain the last item found for this column.
             */
            MethodUtil.callMethod(obj, setName, getObject(rs, columnName));
        } //while
    }

    /**
     * Basically a wrapper to rs.getObject, except that it returns a timestamp
     * if the column returned is a date, a Long if the column returned is a
     * BigDecimal OR just the object otherwise.
     * Look at the url blow for more info.
     * http://www.oracle.com/technology/tech/java/sqlj_jdbc/htdocs/jdbc_faq.htm#08_01
     * @param rs the sql result set
     * @param columnName the name of the column to be returned
     * @return the timestamp if rs.getObject is a date, the Long if rs.getObject
     * is a BigDecimal, or just rs.getObject otherwise.
     * @throws SQLException if rs.getObject/rs.getTimestamp raise an exception.
     */
    private Object getObject(ResultSet rs, String columnName) throws SQLException {
        Object columnValue = rs.getObject(columnName);
        if (columnValue == null) {
            return null;
        }

        // Workaround for problem where the JDBC driver returns a
        // java.sql.Date that often times will not deliver time
        // precision beyond 12:00AM Midnight so you get dates like
        // this            : August 23, 2005 12:00:00 AM PDT
        // vs the real date: August 23, 2005 1:36:12 PM PDT
        if (columnValue instanceof Date ||
                ("oracle.sql.TIMESTAMPLTZ".equals(columnValue.getClass()
                        .getCanonicalName())) ||
                        ("oracle.sql.TIMESTAMP".equals(columnValue.getClass()
                        .getCanonicalName())) ||
                                ("oracle.sql.TIMESTAMPTZ".equals(columnValue.getClass()
                        .getCanonicalName()))) {
            return rs.getTimestamp(columnName);
        }
        else if (columnValue instanceof BigDecimal) {
            return rs.getLong(columnName);
        }
        return columnValue;
    }

    private List<String> getColumnNames(ResultSetMetaData rsmd) {
        try {
            ArrayList<String> columns = new ArrayList<String>();
            int count = rsmd.getColumnCount();

            for (int i = 1; i <= count; i++) {
                columns.add(rsmd.getColumnName(i).toLowerCase());
            }
            return columns;
        }
        catch (SQLException e) {
            throw SqlExceptionTranslator.sqlException(e);
        }
    }

    private boolean checkForColumn(Object obj, String key) {
        if (obj instanceof Map) {
            return ((Map<String, Object>) obj).containsKey(key);
        }
        Class<?> clazz = obj.getClass();
        Method[] methods = clazz.getMethods();
        for (int i = 0; i < methods.length; i++) {
            if (methods[i].getName().equals(StringUtil.beanify("get " + key))) {
                return true;
            }
        }
        return false;
    }

    private Object getKey(Object obj, String key) {
        if (obj instanceof Map) {
            return ((Map<String, Object>) obj).get(key);
        }
        Object keyData = MethodUtil.callMethod(obj,
                StringUtil.beanify("get " + key),
                new Object[0]);
        return keyData;
    }

    private Map<Object, Integer> generatePointers(List<Object> dr, String key) {

        Iterator<Object> i = dr.iterator();
        int pos = 0;
        Map<Object, Integer> pointers = new HashMap<Object, Integer>();

        while (i.hasNext()) {
            Object row = i.next();

            if (row instanceof Map) {
                pointers.put(((Map<String, Object>) row).get(key), new Integer(
                        pos));
            }
            else {
                Object keyData = MethodUtil.callMethod(row,
                        StringUtil.beanify("get " + key),
                        new Object[0]);
                pointers.put(keyData, new Integer(pos));
            }
            pos++;
        }
        return pointers;
    }

    /**
     * Get the DB connection from Hibernate and run some work on it. Since we
     * will use it to run queries/stored procs, this will also flush the session
     * to ensure that stored procs will see changes made in the Hibenate cache
     */
    private <T> T doWithStolenConnection(ReturningWork<T> work) throws HibernateException {
        Session session = HibernateFactory.getSession();
        session.flush();
        return session.doReturningWork(work);
    }

    private void storeForRestart(String sql,
            Map<String, List<Integer>> parameterMap,
            Map<String, Object> parameters, Mode mode, List<Object> dr) {
        restartData = new RestartData(sql, parameterMap, parameters, mode, dr);
    }

    /**
     * Restart the latest query
     * @return what the previous query returned or null.
     */
    public Object restartQuery() {
        return restartData == null ? null : executeChecking(restartData.getSql(),
                restartData.getParameterMap(), restartData.getParameters(),
                restartData.getMode(), restartData.getDr());
    }
}
