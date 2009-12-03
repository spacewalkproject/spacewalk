/**
 * Copyright (c) 2009 Red Hat, Inc.
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
package com.redhat.rhn.common.hibernate;

import com.redhat.rhn.common.db.DatabaseException;
import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.SelectMode;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.hibernate.EntityMode;
import org.hibernate.Hibernate;
import org.hibernate.HibernateException;
import org.hibernate.MappingException;
import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.metadata.ClassMetadata;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.Serializable;
import java.io.UnsupportedEncodingException;
import java.sql.Blob;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * HibernateFactory - Helper superclass that contains methods for fetching and
 * storing Objects from the DB using Hibernate.
 * <p>
 * Abstract methods define what the subclass must implement to determine what is
 * specific to that Factory's instance.
 *
 * @version $Rev$
 */
public abstract class HibernateFactory {
    
    private static ConnectionManager connectionManager = new ConnectionManager();
    private static final Logger LOG = Logger.getLogger(HibernateFactory.class);

    protected HibernateFactory() {
    }

    /**
     * Register a class with HibernateFactory, to give the registered class a
     * chance to modify the Hibernate configuration before creating the
     * SessionFactory.
     * @param c Configurator to override Hibernate configuration.
     */
    public static void addConfigurator(Configurator c) {
        connectionManager.addConfigurator(c);
    }

    /**
     * Close the sessionFactory
     */
    public static void closeSessionFactory() {
        connectionManager.close();
    }

    /**
     * Is the factory closed
     * @return boolean
     */
    public static boolean isClosed() {
        return connectionManager.isClosed();
    }

    /**
     * Create a SessionFactory, loading the hbm.xml files from the default
     * location (com.redhat.rhn.domain).
     */
    public static void createSessionFactory() {
        connectionManager.initialize();
    }

    /**
     * Get the Logger for the derived class so log messages show up on the
     * correct class
     * @return Logger for this class.
     */
    protected abstract Logger getLogger();

    /**
     * Binds the values of the map to a named query parameter, whose value
     * matches the key in the given Map, guessing the Hibernate type from the
     * class of the given object.
     * @param query Query to be modified.
     * @param parameters named query parameters to be bound.
     * @return Modified Query.
     * @throws HibernateException if there is a problem with updating the Query.
     * @throws ClassCastException if the key in the given Map is NOT a String.
     */
    private Query bindParameters(Query query, Map parameters)
        throws HibernateException {
        if (parameters == null) {
            return query;
        }

        Set entrySet = parameters.entrySet();
        for (Iterator itr = entrySet.iterator(); itr.hasNext();) {
            Map.Entry entry = (Map.Entry) itr.next();
            if (entry.getValue() instanceof Collection) {
                Collection c = (Collection) entry.getValue();
                if (c.size() > 100) {
                    LOG.error("Query exectued with Collection larger than 1000");
                }
                query.setParameterList((String) entry.getKey(), c);
            }
            else {
                query.setParameter((String) entry.getKey(), entry.getValue());
            }
        }

        return query;
    }

    /**
     * Finds a single instance of a persistent object given a named query.
     * @param qryName The name of the query used to find the persistent object.
     * It should be formulated to ensure a single object is returned or an error
     * will occur.
     * @param qryParams Map of named bind parameters whose keys are Strings. The
     * map can also be null.
     * @return Object found by named query or null if nothing found.
     */
    protected Object lookupObjectByNamedQuery(String qryName, Map qryParams) {
        return lookupObjectByNamedQuery(qryName, qryParams, false);
    }

    /**
     * Finds a single instance of a persistent object given a named query.
     * @param qryName The name of the query used to find the persistent object.
     * It should be formulated to ensure a single object is returned or an error
     * will occur.
     * @param qryParams Map of named bind parameters whose keys are Strings. The
     * map can also be null.
     * @param cacheable if we should cache the results of this object
     * @return Object found by named query or null if nothing found.
     */
    protected Object lookupObjectByNamedQuery(String qryName, Map qryParams,
            boolean cacheable) {
        Object retval = null;
        Session session = null;

        try {
            session = HibernateFactory.getSession();

            Query query = session.getNamedQuery(qryName)
                    .setCacheable(cacheable);
            bindParameters(query, qryParams);
            retval = query.uniqueResult();
        }
        catch (MappingException me) {
            throw new HibernateRuntimeException("Mapping not found for " + qryName, me);
        }
        catch (HibernateException he) {
            throw new HibernateRuntimeException("Executing query " + qryName +
                    " with params " + qryParams + " failed", he);
        }

        return retval;
    }

    /**
     * Using a named query, find all the objects matching the criteria within.
     * Warning: This can be very expensive if the returned list is large. Use
     * only for small tables with static data
     * @param qryName Named query to use to find a list of objects.
     * @param qryParams Map of named bind parameters whose keys are Strings. The
     * map can also be null.
     * @return List of objects returned by named query, or null if nothing
     * found.
     */
    protected List listObjectsByNamedQuery(String qryName, Map qryParams) {
        return listObjectsByNamedQuery(qryName, qryParams, false);
    }

    /**
     * Using a named query, find all the objects matching the criteria within.
     * Warning: This can be very expensive if the returned list is large. Use
     * only for small tables with static data
     * @param qryName Named query to use to find a list of objects.
     * @param qryParams Map of named bind parameters whose keys are Strings. The
     * map can also be null.
     * @param col the collection to use as an inclause
     * @param colLabel the label the collection will have
     * @return List of objects returned by named query, or null if nothing
     * found.
     */
    protected List listObjectsByNamedQuery(String qryName, Map qryParams,
                                        Collection col, String colLabel) {

        if (col.isEmpty()) {
            return Collections.EMPTY_LIST;
        }

        ArrayList<Long> tmpList = new ArrayList<Long>();
        List<Long> toRet = new ArrayList<Long>();
        tmpList.addAll(col);

        for (int i = 0; i < col.size();) {
            int initial = i;
            int fin = i + 500 < col.size() ? i + 500 : col.size();
            List<Long> sublist = tmpList.subList(i, fin);

            qryParams.put(colLabel, sublist);
            toRet.addAll(listObjectsByNamedQuery(qryName, qryParams, false));
            i = fin;
        }
        return toRet;
    }



    /**
     * Using a named query, find all the objects matching the criteria within.
     * Warning: This can be very expensive if the returned list is large. Use
     * only for small tables with static data
     * @param qryName Named query to use to find a list of objects.
     * @param qryParams Map of named bind parameters whose keys are Strings. The
     * map can also be null.
     * @param cacheable if we should cache the results of this query
     * @return List of objects returned by named query, or null if nothing
     * found.
     */
    protected List listObjectsByNamedQuery(String qryName, Map qryParams,
            boolean cacheable) {
        Session session = null;
        List retval = null;
        session = HibernateFactory.getSession();
        Query query = session.getNamedQuery(qryName);
        query.setCacheable(cacheable);
        bindParameters(query, qryParams);
        retval = query.list();
        return retval;
    }

    /**
     * Saves the given object to the database using Hibernate.
     * @param toSave Object to be persisted.
     * @param saveOrUpdate true if saveOrUpdate should be called, false if
     * save() is to be called directly.
     */
    protected void saveObject(Object toSave, boolean saveOrUpdate) {
        Session session = null;
        session = HibernateFactory.getSession();
        if (saveOrUpdate) {
            session.saveOrUpdate(toSave);
        }
        else {
            session.save(toSave);
        }
    }

    /**
     * Saves the given object to the database using Hibernate.
     * @param toSave Object to be persisted.
     */
    protected void saveObject(Object toSave) {
        saveObject(toSave, true);
    }

    /**
     * Remove a Session from the DB
     * @param toRemove Object to be removed.
     * @return int number of objects affected.
     */
    protected int removeObject(Object toRemove) {
        Session session = null;
        int numDeleted = 0;
        session = HibernateFactory.getSession();

        session.delete(toRemove);
        numDeleted++;

        return numDeleted;
    }

    /**
     * Returns the Hibernate session stored in ThreadLocal storage. If not
     * present, creates a new one and stores it in ThreadLocal; creating the
     * session also begins a transaction implicitly.
     *
     * @return Session Session asked for
     */
    public static Session getSession() {
        return connectionManager.getSession();
    }

    /**
     * Commit the transaction for the current session. This method or
     * {@link #rollbackTransaction}can only be called once per session.
     *
     * @throws HibernateException if the commit fails
     */
    public static void commitTransaction() throws HibernateException {
        connectionManager.commitTransaction();
    }

    /**
     * Roll the transaction for the current session back. This method or
     * {@link #commitTransaction}can only be called once per session.
     *
     * @throws HibernateException if the commit fails
     */
    public static void rollbackTransaction() throws HibernateException {
        connectionManager.rollbackTransaction();
    }

    /**
     * Is transaction pending for thread?
     * @return boolean
     */
    public static boolean inTransaction() {
        return connectionManager.isTransactionPending();
    }
    
    /**
     * Closes the Hibernate Session stored in ThreadLocal storage.
     */
    public static void closeSession() {
        connectionManager.closeSession();
    }

    /**
     * Return the persistent instance of the given entity class with the given
     * identifier, or null if there is no such persistent instance. (If the
     * instance, or a proxy for the instance, is already associated with the
     * session, return that instance or proxy.)
     * @param clazz a persistent class
     * @param id an identifier
     * @return Object persistent instance or null
     */
    public Object getObject(Class clazz, Serializable id) {
        Object retval = null;
        Session session = null;

        try {
            session = HibernateFactory.getSession();

            retval = session.get(clazz, id);
        }
        catch (MappingException me) {
            getLogger().error("Mapping not found for " + clazz.getName(), me);

        }
        catch (HibernateException he) {
            getLogger().error("Hibernate exception: " + he.toString());
        }

        return retval;
    }

    private void throwRuntimeException(String msg, HibernateException he) {
        getLogger().error(msg, he);
        throw new HibernateRuntimeException(msg, he);
    }

    /**
     * Util to reload an object using Hibernate
     * @param obj to be reloaded
     * @return Object found if not, null
     * @throws HibernateException if something bad happens.
     */
    public static Object reload(Object obj) throws HibernateException {
        // assertNotNull(obj);
        ClassMetadata cmd = connectionManager.getMetadata(obj);
        Serializable id = cmd.getIdentifier(obj, EntityMode.POJO);
        Session session = getSession();
        session.flush();
        session.evict(obj);
        /*
         * In hibernate 3, the following doesn't work:
         * session.load(obj.getClass(), id);
         * load returns the proxy class instead of the persisted class, ie,
         * Filter$$EnhancerByCGLIB$$9bcc734d_2 instead of Filter.
         * session.get is set to not return the proxy class, so that is what we'll use.
         */
        Object result = session.get(obj.getClass(), id);
        // assertNotSame(obj, result);
        return result;
    }

    /**
     * utility to convert blob to byte array
     * @param fromBlob blob to convert
     * @return byte array converted from blob
     */
    public static byte[] blobToByteArray(Blob fromBlob) {

        if (fromBlob == null) {
            return new byte[0];
        }

        ByteArrayOutputStream baos = new ByteArrayOutputStream();

        try {
            return toByteArrayImpl(fromBlob, baos);
        }
        catch (SQLException e) {
            LOG.error("SQL Error converting blob to byte array", e);
            throw new DatabaseException(e.toString());
        }
        catch (IOException e) {
            LOG.error("I/O Error converting blob to byte array", e);
            throw new DatabaseException(e.toString());
        }
        finally {
            if (baos != null) {
                try {
                    baos.close();
                }
                catch (IOException ex) {
                    throw new DatabaseException(ex.toString());
                }
            }
        }
    }
    /**
     * utility to convert blob to String
     * @param fromBlob blob to convert
     * @return String converted from blob
     */    
    public static String blobToString(Blob fromBlob) {
        if (fromBlob != null) {
            return getByteArrayContents(blobToByteArray(fromBlob));    
        }
        return "";
    }

    /**
     * helper utility to convert blob to byte array
     * @param fromBlob blob to convert
     * @param baos byte array output stream
     * @return String version of the byte array contents
     */
    private static byte[] toByteArrayImpl(Blob fromBlob, ByteArrayOutputStream baos)
        throws SQLException, IOException {

        byte[] buf = new byte[4000];
        InputStream is = fromBlob.getBinaryStream();
        try {
            for (;;) {
                int dataSize = is.read(buf);
                if (dataSize == -1) {
                    break;
                }
                baos.write(buf, 0, dataSize);
            }
        }
        finally {
            if (is != null) {
                try {
                    is.close();
                }
                catch (IOException ex) {
                    throw new RuntimeException(ex);
                }
            }
        }
        return baos.toByteArray();
    }

    /**
     * Get the String version of the byte array contents
     * used to return the string representation of byte arrays constructed from blobs
     * @param barr byte array to convert to String
     * @return String version of the byte array contents
     */
    public static String getByteArrayContents(byte[] barr) {

        String retval = null;

        if (barr != null) {
            try {
                retval = new String(barr, "UTF-8");
            }
            catch (UnsupportedEncodingException uee) {
                throw new RuntimeException("Illegal Argument: " + 
              "This VM or environment doesn't support UTF-8: Data - " +
                                                 barr, uee);
            }
        }
        return retval;
    }

    /**
     * Convert a byte[] array to a Blob object.  Guards against
     * null arrays and 0 length arrays.
     * @param data array to convert to a Blob
     * @return Blob if data[] is non-null and length > 0, null otherwise
     */
    public static Blob byteArrayToBlob(byte[] data) {
        if (data == null) {
            return null;
        }
        else {
            if (data.length == 0) {
                return null;
            }
            else {
                return Hibernate.createBlob(data);
            }
        }

    }

    /**
     * Convert a String to a Blob object.  Guards against
     * null arrays and 0 length arrays.
     * @param data string to convert to a Blob
     * @return Blob if data[] is non-null and length > 0, null otherwise
     */
    public static Blob stringToBlob(String data) {
        if (StringUtils.isEmpty(data)) {
            return null;
        }
        
        try {
            return byteArrayToBlob(data.getBytes("UTF-8"));
        }
        catch (UnsupportedEncodingException e) {
            throw new RuntimeException("Illegal Argument: " + 
            "This VM or environment doesn't support UTF-8 - Data - " +
                                             data, e);
        }
    }    
    
    
    /**
     * Initialize the underlying db layer
     *
     */
    public static void initialize() {
        connectionManager.initialize();
    }
    
    /**
     * Returns the current initialization status
     * @return boolean current status
     */
    public static boolean isInitialized() {
        return connectionManager.isInitialized();
    }

    protected static DataResult executeSelectMode(String name, String mode, Map params) {
        SelectMode m = ModeFactory.getMode(name, mode);
        return m.execute(params);
    }
}
