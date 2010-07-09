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
package com.redhat.rhn.scripts;

import com.redhat.rhn.common.db.datasource.Mode;
import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.SelectMode;
import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.common.hibernate.HibernateRuntimeException;

import org.hibernate.HibernateException;
import org.hibernate.Session;

import java.io.FileOutputStream;
import java.io.IOException;
import java.io.PrintStream;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Collection;
import java.util.Iterator;
import java.util.Map;
import java.util.TreeSet;

/**
 * Program to generate Exceptions.
 * Make sure that you have set rhn.checkout.dir in your
 * ~/.rhn.properties file.  Without that property, these tests will
 * _NOT_ run.  When the DataSource xml files get moved into the rhn-java
 * repo, that requirement will be removed.
 *
 * @version $Rev$
 */
public class ExplainPlanGenerator {
    private String outfile;

    private static final String QUERY_NAME = "ryan_query";

    /**
     * Create a new explain plan generator
     * @param source The path to the cvs rhn checkout.
     * @param output The file to write the plans to.
     */
    public ExplainPlanGenerator(String source, String output) {
        if (source != null && !source.equals("")) {
            source = source + "/web/modules/rhn/RHN/DB/DataSource/xml";
        }
        outfile = output;
    }

    private static final String EXPLAIN_QUERY = "select " +
                                   "to_char(parent_id) explain_parent_id, " +
                                   "to_char(id) explain_id, " +
                                   "lpad(' ',2*(LEVEL-1)) || operation || " +
                                   "'  ' || options || '  ' || object_name " +
                                   "explain_operation " +
                                   "from " +
                                   "    plan_table " +
                                   "start with id = 1 and statement_id = ? " +
                                   "connect by prior id = parent_id " +
                                   "    and statement_id = ?";

    private boolean shouldSkip(Mode m) {
        /* Don't do plans for queries that use system tables or for
         * dummy queries.
         */
        return (m != null && m.getQuery() != null &&
                (m.getName().equals("tablespace_overview") ||
                 m.getQuery().getOrigQuery().trim().startsWith("--")));
    }

    /** Execute the task
     *  @throws IOException If the output file can't be opened.
     *  @throws SQLException if something goes wrong with the DB.
     */
    public void execute() throws IOException, SQLException {
        Session session = null;
        Connection conn = null;
        try {
            session = HibernateFactory.getSession();
            conn = session.connection();
            PrintStream out = new PrintStream(new FileOutputStream(outfile));

            Collection fileKeys = ModeFactory.getKeys();

            TreeSet ts = new TreeSet(fileKeys);
            Iterator i = ts.iterator();
            while (i.hasNext()) {
                String file = (String)i.next();
                Map queries = ModeFactory.getFileKeys(file);
                if (file.equals("test_queries")) {
                    continue;
                }
                out.println("\nFile:   " + file);

                Iterator q = new TreeSet(queries.keySet()).iterator();
                int count = 0;
                while (q.hasNext()) {
                    Mode m = (Mode)queries.get(q.next());

                    /* Don't do plans for queries that use system tables or for
                     * dummy queries.
                     */
                    if (shouldSkip(m)) {
                        out.println("\nSkipping dummy query:  " + m.getName());
                        continue;
                    }
                    if (!(m instanceof SelectMode)) {
                        out.println("\nSkipping Write or Callable mode: " + m.getName());
                        continue;
                    }
                    out.println("\nPlan for " + m.getName());

                    String query = "EXPLAIN PLAN " +
                        "SET STATEMENT_ID='" + QUERY_NAME + "' FOR " +
                        m.getQuery().getOrigQuery();

                    // HACK!  Some of the queries actually have %s in them.
                    // So, replace all %s with :rbb so that the explain plan
                    // can be generated.
                    query = query.replaceAll("%s", ":rbb");

                    PreparedStatement ps = conn.prepareStatement(query);

                    ps.execute();
                    ps.close();

                    // Now that we have generated the explain plan, we just
                    // need to get it from the DB.
                    ps = conn.prepareStatement(EXPLAIN_QUERY);
                    ps.setString(1, QUERY_NAME);
                    ps.setString(2, QUERY_NAME);
                    ResultSet rs = ps.executeQuery();
                    while (rs.next()) {
                        String parentId = rs.getString("explain_parent_id");
                        String id = rs.getString("explain_id");
                        String operation = rs.getString("explain_operation");

                        out.println(parentId + " " + id + " " + operation);
                    }
                    count++;
                    rs.close();
                    ps.close();
                    Statement st = conn.createStatement();
                    st.execute("Delete FROM plan_table where " +
                                    "STATEMENT_ID='" + QUERY_NAME + "'");
                    st.close();

                }
            }
            out.close();
        }
        catch (HibernateException he) {
            throw new
                HibernateRuntimeException(
                    "HibernateException in ExplainPlanGenerator.", he);
        }
    }

    /**
     * Run the program
     * @param args The arguments to the java program.
     */
    public static void main(String[] args) {
        if (args.length != 2) {
            System.err.println("Not enough arguments, usage:");
            System.err.println("ExplainPlanGenerator /path/to/rhn " +
                               "/path/to/output_file");
            System.exit(1);
        }
        ExplainPlanGenerator ep = new ExplainPlanGenerator(args[0], args[1]);
        try {
            ep.execute();
            System.out.println("Done generating explain plans in " + args[1]);
        }
        catch (SQLException e) {
            System.err.println("Something went wrong in the DB: " +
                               e.getMessage());
        }
        catch (IOException e) {
            System.err.println("Couldn't write to disk: " + e.getMessage());
        }
    }

}
