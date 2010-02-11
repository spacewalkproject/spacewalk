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
package com.redhat.rhn.frontend.action.common.test;
import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.common.hibernate.HibernateHelper;
import com.redhat.rhn.domain.Identifiable;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.common.RhnSetAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.testing.ActionHelper;
import com.redhat.rhn.testing.RhnBaseTestCase;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.hibernate.HibernateException;
import org.hibernate.Session;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Arrays;
import java.util.LinkedList;
import java.util.List;
import java.util.Locale;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

/**
 * RhnSetActionTest
 * @version $Rev$
 */
public class RhnSetActionTest extends RhnBaseTestCase {
    private static Logger log = Logger.getLogger(RhnSetActionTest.class);
    private TestAction action = null;

    public void setUp() {
        action = new TestAction();
    }

    public void testUpdateList() throws Exception {
        //TestAction action = new TestAction();
        ActionHelper sah = new ActionHelper();
        sah.setUpAction(action);
        sah.setupClampListBounds();
        sah.getRequest().setRequestURL("foo");
        sah.getRequest().setupAddParameter("items_selected",
            new String[] {"10", "20", "30"});
        sah.getRequest().setupAddParameter("newset", (String)null);
        sah.getRequest().setupAddParameter("items_on_page", (String)null);
        ActionForward forward = sah.executeAction("updatelist");

        // let's go find the data
        verifyRhnSetData(sah.getUser().getId(), action.getSetDecl().getLabel(), 3);
        verifyParam(forward.getPath(), "setupdated", "true");
    }

    public void testUpdateListPipe() throws Exception {
        ActionHelper sah = new ActionHelper();
        sah.setUpAction(action);
        sah.setupClampListBounds();
        sah.getRequest().setRequestURL("foo");
        sah.getRequest().setupAddParameter("items_selected",
            new String[] {"777|999", "99|555", "666|77656"});
        sah.getRequest().setupAddParameter("newset", (String)null);
        sah.getRequest().setupAddParameter("items_on_page", (String)null);
        sah.executeAction("updatelist");

        // let's go find the data
        verifyRhnSetData(sah.getUser().getId(), action.getSetDecl().getLabel(), 3);
    }
    public void testUnselectAll() throws Exception {
        ActionHelper sah = new ActionHelper();
        sah.setUpAction(action);
        sah.setupClampListBounds();
        ActionForward forward = sah.executeAction("unselectall");

        verifyRhnSetData(sah.getUser().getId(), action.getSetDecl().getLabel(), 0);
        verifyParam(forward.getPath(), "setupdated", "true");
    }

    public void testSelectAllBadDataType() throws Exception {
        ActionHelper sah = new ActionHelper();
        TestActionWithData a = new TestActionWithData();
        sah.setUpAction(a);
        sah.setupClampListBounds();
        // We check to make sure we throw
        // exception if the list has invalid types in it.
        boolean failed = false;
        try {
            sah.executeAction("selectall");
        }
        catch (Exception iea) {
            failed = true;
        }
        assertTrue(failed);
    }

    public void testSelectAll() throws Exception {
        ActionHelper sah = new ActionHelper();
        TestActionWithData a = new TestActionWithData() {
            protected DataResult getDataResult(User user, 
                                               ActionForm formIn, 
                                               HttpServletRequest request) {
                List retval = new LinkedList();
                for (int i = 0; i < 10; i++) {
                    retval.add(new TestIdObject(new Long(i)));
                }
                return new DataResult(retval);
            }
        };
        sah.setUpAction(a);
        sah.setupClampListBounds();
        ActionForward forward = sah.executeAction("selectall");
        verifyRhnSetData(sah.getUser().getId(), a.getSetDecl().getLabel(), 10);
        verifyParam(forward.getPath(), "setupdated", "true");
    }



    public void testFilter() throws Exception {
        ActionHelper sah = new ActionHelper();
        sah.setUpAction(action);
        sah.getRequest().setupAddParameter(RequestContext.FILTER_STRING, "zzzz");
        sah.setupClampListBounds();
        
        ActionForward forward = sah.executeAction("filter");
        verifyParam(forward.getPath(), RequestContext.FILTER_STRING, "zzzz");
    }


    public void testUnspecified() throws Exception {
        ActionHelper sah = new ActionHelper();
        sah.setUpAction(action);
        sah.setupClampListBounds();
        sah.getRequest().setupAddParameter("items_selected",
            new String[] {"10", "20", "30"});
        sah.getRequest().setupAddParameter("newset", (String)null);
        sah.getRequest().setupAddParameter("items_on_page", (String)null);
        ActionForward forward  = sah.executeAction("unspecified");

        verifyParam(forward.getPath(), "newset", "[10, 20, 30]");
    }

    private void verifyParam(String path, String name, String value) {
        String[] args = StringUtils.split(path, "?&");
        for (int i = 0; i < args.length; i++) {
            String[] param = StringUtils.split(args[i], "=");
            if (param[0].equals(name)) {
                assertEquals(value, param[1]);
                break;
            }
        }
    }

    public static void verifyRhnSetData(User user, RhnSetDecl decl, int size) 
        throws HibernateException, SQLException {
        verifyRhnSetData(user.getId(), decl.getLabel(), size);
    }

    public static void verifyRhnSetData(Long uid, String setname, int size)
             throws HibernateException, SQLException {
        Session session = null;
        Connection c = null;
        Statement stmt = null;
        ResultSet rs = null;
        try {
            session = HibernateFactory.getSession();
            session.flush();
            c = session.connection();
            stmt = c.createStatement();
            String query = "select * from rhnset where user_id = " +
                                   uid.toString();
            rs = stmt.executeQuery(query);

            assertNotNull(rs);

            int cnt = 0;
            while (rs.next()) {
                assertEquals(uid.longValue(), rs.getLong("USER_ID"));
                assertEquals(setname, rs.getString("LABEL"));
                cnt++;
            }

            assertEquals(size, cnt);
        }
        catch (SQLException e) {
            log.error("Error validating data.", e);
            throw e;
        }
        finally {
            HibernateHelper.cleanupDB(rs, stmt);
        }
    }

    public static class TestAction extends RhnSetAction {

        protected RhnSetDecl getSetDecl() {
            return RhnSetDecl.TEST;
        }

        /**
         * {@inheritDoc}
         */
        protected DataResult getDataResult(User user, 
                                           ActionForm formIn, 
                                           HttpServletRequest request) {
            return null;
        }

        /**
         * {@inheritDoc}
         */
        protected void processMethodKeys(Map map) {
            assertNotNull(map.get("updatelist"));
            assertNotNull(map.get("selectall"));
            assertNotNull(map.get("unselectall"));
        }

        /**
         * {@inheritDoc}
         */
        protected void processParamMap(ActionForm formIn, 
                                       HttpServletRequest request, 
                                       Map params) {
            assertNotNull(params);
        }

    }

    public static class TestActionWithData extends RhnSetAction {

        protected RhnSetDecl getSetDecl() {
            return RhnSetDecl.TEST;
        }

        /**
         * {@inheritDoc}
         */
        protected DataResult getDataResult(User user, 
                                           ActionForm formIn, 
                                           HttpServletRequest request) {
            List retval = Arrays.asList(Locale.getISOCountries());
            return new DataResult(retval);
        }

        /**
         * {@inheritDoc}
         */
        protected void processMethodKeys(Map map) {
            assertNotNull(map.get("updatelist"));
            assertNotNull(map.get("selectall"));
            assertNotNull(map.get("unselectall"));
        }

        /**
         * {@inheritDoc}
         */
        protected void processParamMap(ActionForm formIn, 
                                       HttpServletRequest request, 
                                       Map params) {
            assertNotNull(params);
        }

    }

    public class TestIdObject implements Identifiable {
        private Long id;

        public TestIdObject(Long idIn) {
            this.id = idIn;
        }

        public Long getId() {
            return this.id;
        }

    }

}
