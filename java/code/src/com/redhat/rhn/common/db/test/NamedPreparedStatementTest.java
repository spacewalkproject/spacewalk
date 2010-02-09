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
package com.redhat.rhn.common.db.test;

import com.redhat.rhn.common.db.BindVariableNotFoundException;
import com.redhat.rhn.common.db.NamedPreparedStatement;
import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.testing.RhnBaseTestCase;

import org.hibernate.Session;

import java.sql.PreparedStatement;
import java.util.HashMap;
import java.util.List;

public class NamedPreparedStatementTest extends RhnBaseTestCase {

    private Session session;

    private static final int LIST_SIZE = 2;
    private static final int FIRST_POS = 2;
    private static final int SECOND_POS = 3;


    private String SIMPLE_QUERY = "SELECT wc.id AS ID, " +
                                  "wc.login, " +
                                  "wc.login_uc " +
                                  " FROM web_contact wc " +
                                  " WHERE wc.org_id = :org_id " +
                                  " ORDER BY wc.login_uc, wc.id";

    private String SIMPLE_QUERY_SUBST = "SELECT wc.id AS ID, " +
                                        "wc.login, " +
                                        "wc.login_uc " +
                                        " FROM web_contact wc " +
                                        " WHERE wc.org_id = ? " +
                                        " ORDER BY wc.login_uc, wc.id";

    private String TWO_VAR_QUERY = "SELECT DISTINCT E.id, E.update_date " +
                                   "FROM rhnErrata E, " +
                                   "rhnServerNeededPackageCache SNPC " +
                                   "WHERE EXISTS (SELECT server_id FROM " +
                                   "rhnUserServerPerms USP WHERE " +
                                   "USP.user_id = :user_id AND " +
                                   "USP.server_id = :sid) " +
                                   "AND SNPC.server_id = :sid " +
                                   "AND SNPC.errata_id = E.id " +
                                   "ORDER BY E.update_date, E.id";

    private String TWO_VAR_QUERY_SUBST = "SELECT DISTINCT E.id, " +
                                         "E.update_date " +
                                         "FROM rhnErrata E, " +
                                         "rhnServerNeededPackageCache SNPC " +
                                         "WHERE EXISTS (SELECT server_id " +
                                         "FROM rhnUserServerPerms USP " +
                                         "WHERE USP.user_id = ? AND " +
                                         "USP.server_id = ?) " +
                                         "AND SNPC.server_id = ? " +
                                         "AND SNPC.errata_id = E.id " +
                                         "ORDER BY E.update_date, E.id";

    private String COLON_IN_QUOTES = "SELECT 'FOO:BAR:MI:SS' " +
                                     "FROM FOOBAR";


    protected void setUp() throws Exception {
        super.setUp();
        session = HibernateFactory.getSession();
    }

    protected void tearDown() throws Exception {
        session = null;
        super.tearDown();
    }
    
    public void testColonInQuotes() throws Exception {
        String jdbcQuery;
        HashMap pMap = new HashMap();

        jdbcQuery = NamedPreparedStatement.replaceBindParams(COLON_IN_QUOTES,
                                                             pMap);
                                                             
        assertEquals(COLON_IN_QUOTES, jdbcQuery);

        assertTrue(pMap.isEmpty());
    }
    
    public void testCreateSQL() throws Exception {
        String jdbcQuery;
        HashMap pMap = new HashMap();

        jdbcQuery = NamedPreparedStatement.replaceBindParams(SIMPLE_QUERY,
                                                             pMap);
        assertEquals(SIMPLE_QUERY_SUBST, jdbcQuery);

        List lst = (List)pMap.get("org_id");
        assertNotNull(lst);
        assertEquals(1, lst.size());
        assertEquals(1, ((Integer)lst.get(0)).intValue());
    }

    public void testPrepare() throws Exception {
        String jdbcQuery;
        HashMap pMap = new HashMap();

        jdbcQuery = NamedPreparedStatement.replaceBindParams(SIMPLE_QUERY,
                                                             pMap);
        assertEquals(SIMPLE_QUERY_SUBST, jdbcQuery);

        List lst = (List)pMap.get("org_id");
        assertNotNull(lst);
        assertEquals(1, lst.size());
        assertEquals(1, ((Integer)lst.get(0)).intValue());

        session.connection().prepareStatement(jdbcQuery);
    }

    public void testTwoBindPrepare() throws Exception {
        List lst;
        String jdbcQuery;
        HashMap pMap = new HashMap();

        jdbcQuery = NamedPreparedStatement.replaceBindParams(TWO_VAR_QUERY,
                                                             pMap);
        assertEquals(TWO_VAR_QUERY_SUBST, jdbcQuery);

        lst = (List)pMap.get("sid");
        assertNotNull(lst);
        assertEquals(LIST_SIZE, lst.size());
        assertEquals(FIRST_POS, ((Integer)lst.get(0)).intValue());
        assertEquals(SECOND_POS, ((Integer)lst.get(1)).intValue());

        lst = (List)pMap.get("user_id");
        assertNotNull(lst);
        assertEquals(1, lst.size());
        assertEquals(1, ((Integer)lst.get(0)).intValue());

        session.connection().prepareStatement(jdbcQuery);
    }

    public void testNotFoundBindParam() throws Exception {
        List lst;
        String jdbcQuery;
        HashMap pMap = new HashMap();

        jdbcQuery = NamedPreparedStatement.replaceBindParams(TWO_VAR_QUERY,
                                                             pMap);
        assertEquals(TWO_VAR_QUERY_SUBST, jdbcQuery);

        lst = (List)pMap.get("sid");
        assertNotNull(lst);
        assertEquals(LIST_SIZE, lst.size());
        assertEquals(FIRST_POS, ((Integer)lst.get(0)).intValue());
        assertEquals(SECOND_POS, ((Integer)lst.get(1)).intValue());

        lst = (List)pMap.get("user_id");
        assertNotNull(lst);
        assertEquals(1, lst.size());
        assertEquals(1, ((Integer)lst.get(0)).intValue());

        PreparedStatement ps = session.connection().prepareStatement(jdbcQuery);

        HashMap parameters = new HashMap();
        parameters.put("BAD_DATA", "GARBAGE");
        try {
            NamedPreparedStatement.execute(ps, pMap, parameters);
            fail("Should have received BindVariableNotFoundException");
        }
        catch (BindVariableNotFoundException e) {
            // Expected exception
        }
    }
}
