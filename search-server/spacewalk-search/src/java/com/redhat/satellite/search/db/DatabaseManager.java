/**
 * Copyright (c) 2008--2010 Red Hat, Inc.
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

package com.redhat.satellite.search.db;

import com.redhat.satellite.search.config.Configuration;

import com.ibatis.sqlmap.client.SqlMapClient;
import com.ibatis.sqlmap.client.SqlMapClientBuilder;
import com.ibatis.sqlmap.client.SqlMapSession;

import java.io.FileReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.Reader;
import java.util.Properties;

/**
 * Manages DB activity - connections, running queries, etc
 * @version $Rev$
 */
public class DatabaseManager {

    private SqlMapClient client = null;

    /**
     * Constructor 
     * @param config
     * @throws IOException
     */
    public DatabaseManager(Configuration config) throws IOException {
        String configPath = config.getString("search.db_config_path",
                "classpath");
        Reader reader = null;
        if (configPath.equals("classpath")) {
            ClassLoader cl = Thread.currentThread().getContextClassLoader();
            InputStream stream = cl
                    .getResourceAsStream("com/redhat/satellite/search/db/config.xml");
            if (stream == null) {
                throw new IllegalArgumentException(
                        "com/redhat/satellite/search/db/" +
                                "config.xml resource missing");
            }
            reader = new InputStreamReader(stream);
        }
        else {
            reader = new FileReader(configPath);
        }
        Properties overrides = config.getNamespaceProperties("search");
        client = SqlMapClientBuilder.buildSqlMapClient(reader, overrides);
    }

    /**
     * Open a named select query
     * @param <T> type returned by query
     * @param name name of query
     * @return query object
     */
    public <T> Query<T> getQuery(String name) {
        SqlMapSession session = client.openSession();
        return new Query<T>(session, name);
    }
    
    /**
     * Open a named write (insert, update, delete) query
     * @param name of query
     * @return query object
     */
    public WriteQuery getWriterQuery(String name) {
        SqlMapSession session = client.openSession();
        return new WriteQuery(session, name);
    }
    
    /**
     * Opens a direct DB connection
     * @return connection object
     */
    public Connection getConnection() {
        return new Connection(client.openSession());
    }
}
