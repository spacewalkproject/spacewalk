/**
 * Copyright (c) 2008--2012 Red Hat, Inc.
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

import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.Reader;
import java.util.Properties;

import com.redhat.satellite.search.config.Configuration;
import com.redhat.satellite.search.config.ConfigException;

import org.apache.ibatis.session.SqlSessionFactory;
import org.apache.ibatis.session.SqlSessionFactoryBuilder;
import org.apache.log4j.Logger;

/**
 * Manages DB activity - connections, running queries, etc
 * @version $Rev$
 */
public class DatabaseManager {

    private SqlSessionFactory sessionFactory = null;
    private static boolean isOracle;
    private static Logger log = Logger.getLogger(DatabaseManager.class);


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

        String[] options = {"db_name", "db_password", "db_user"};
        for (String option : options) {
            overrides.setProperty(option, config.getString(option));
        }
        isOracle = config.getString("db_backend").equals("oracle");
        if (isOracle) {
            overrides.setProperty("db_name", "@" + overrides.getProperty("db_name"));
        } else {
            String dbHost = config.getString("db_host");
            String dbPort = config.getString("db_port");
            if (dbHost != null && dbHost.length() > 0) {
                String connectionUrl = "//" + dbHost;
                if (dbPort != null && dbPort.length() > 0) {
                    connectionUrl += ":" + dbPort;
                }
                connectionUrl += "/" + overrides.getProperty("db_name");

                if (config.getBoolean("db_ssl_enabled")) {
                    connectionUrl += "?ssl=true";
                    String trustStore = config.getString("java.ssl_truststore");
                    if (trustStore == null || ! new File(trustStore).isFile()) {
                        throw new ConfigException("Can not find java truststore at " +
                            trustStore + ". Path can be changed with java.ssl_truststore option.");
                    }
                    System.setProperty("javax.net.ssl.trustStore", trustStore);
                    overrides.setProperty("db_name", connectionUrl);
                }
            }
        }

        sessionFactory = new SqlSessionFactoryBuilder(). build(reader, overrides);
    }

    /**
     * Open a named select query
     * @param <T> type returned by query
     * @param name name of query
     * @return query object
     */
    public <T> Query<T> getQuery(String name) {
        return new Query<T>(sessionFactory.openSession(), name);
    }

    /**
     * Open a named write (insert, update, delete) query
     * @param name of query
     * @return query object
     */
    public WriteQuery getWriterQuery(String name) {
        return new WriteQuery(sessionFactory.openSession(), name);
    }

    public static boolean isOracle() {
        return isOracle;
    }
}
