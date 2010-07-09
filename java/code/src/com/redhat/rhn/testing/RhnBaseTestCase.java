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
package com.redhat.rhn.testing;

import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.messaging.MessageQueue;
import com.redhat.rhn.common.util.Asserts;
import com.redhat.rhn.domain.kickstart.test.KickstartDataTest;

import org.apache.commons.beanutils.PropertyUtils;
import org.apache.log4j.Level;
import org.apache.log4j.Logger;
import org.hibernate.HibernateException;
import org.hibernate.Session;

import java.io.File;
import java.io.Serializable;
import java.lang.reflect.InvocationTargetException;
import java.text.DateFormat;
import java.util.Collection;
import java.util.Date;

import junit.framework.ComparisonFailure;
import junit.framework.TestCase;

/**
 * RhnBaseTestCase is the base class for all RHN TestCases.
 * It ensures that the HibernateSession is closed after each
 * test to similuate what happens when the code is run
 * in a web application server.
 * @version $Rev$
 */
public abstract class RhnBaseTestCase extends TestCase {

    /**
     * Constructs a TestCase with the given name.
     * @param name Name of TestCase.
     */
    public RhnBaseTestCase(String name) {
        super(name);
    }

    /**
     * Default Constructor
     */
    public RhnBaseTestCase() {
        super();
        MessageQueue.configureDefaultActions();
    }

    /**
     * Called once per test method.
     * @throws Exception if an error occurs during setup.
     */
    protected void setUp() throws Exception {
        super.setUp();
        KickstartDataTest.setupTestConfiguration();
    }

    /**
     * Tears down the fixture, and closes the HibernateSession.
     * @see TestCase#tearDown()
     * @see HibernateFactory#closeSession()
     */
    protected void tearDown() throws Exception {
        super.tearDown();
        TestCaseHelper.tearDownHelper();
    }

    /**
     * PLEASE Refrain from using this unless you really have to.
     *
     * Try clearSession() instead
     * @throws HibernateException
     */
    protected void commitAndCloseSession() throws HibernateException {
        HibernateFactory.commitTransaction();
        HibernateFactory.closeSession();
    }

    protected void clearSession() {
        HibernateFactory.getSession().clear();
    }

    protected void flushAndEvict(Object obj) throws HibernateException {
        Session session = HibernateFactory.getSession();
        session.flush();
        session.evict(obj);
    }

    protected Object reload(Class objClass, Serializable id) throws HibernateException {
        assertNotNull(id);
        Object obj = TestUtils.reload(objClass, id);
        return reload(obj);
    }

    protected static Object reload(Object obj) throws HibernateException {
        assertNotNull(obj);
        Object result = TestUtils.reload(obj);
        assertNotSame(obj, result);
        return result;
    }

    /**
     * Get a date representing "now" and wait for one second to
     * ensure that future attempts to get a date will use a date
     * that is definitely later.
     *
     * @return a date representing now
     */
    protected Date getNow() {
        Date now = new Date();
        try {
            Thread.sleep(1000);
        }
        catch (InterruptedException e) {
            throw new RuntimeException("Sleep interrupted", e);
        }
        return now;
    }

    //
    // Utility methods for assertions
    //

    /**
     * Assert that <code>coll</code> contains <code>elem</code>
     * @param coll a collection
     * @param elem the element that should be in the collection
     */
    public static void assertContains(Collection coll, Object elem) {
        Asserts.assertContains(coll, elem);
    }

    /**
     * Assert that <code>coll</code> is not empty
     * @param coll the collection
     */
    public static void assertNotEmpty(Collection coll) {
        assertNotEmpty(null, coll);
    }

    /**
     * Assert that <code>coll</code> is not empty
     * @param msg the message to print if the assertion fails
     * @param coll the collection
     */
    public static void assertNotEmpty(String msg, Collection coll) {
        assertNotNull(coll);
        if (coll.size() == 0) {
            fail(msg);
        }
    }

    /**
     * Assert that the beans <code>exp</code> and <code>act</code> have the same values
     * for property <code>propName</code>
     *
     * @param propName name of the proeprty to compare
     * @param exp the bean with the expected values
     * @param act the bean with the actual values
     */
    public static void assertPropertyEquals(String propName, Object exp, Object act) {
        assertEquals(getProperty(exp, propName), getProperty(act, propName));
    }

    private static Object getProperty(Object bean, String propName) {
        try {
            return PropertyUtils.getProperty(bean, propName);
        }
        catch (IllegalAccessException e) {
            throw new RuntimeException("Could not get property " + propName +
                    " from " + bean, e);
        }
        catch (InvocationTargetException e) {
            throw new RuntimeException("Could not get property " + propName +
                    " from " + bean, e);
        }
        catch (NoSuchMethodException e) {
            throw new RuntimeException("Could not get property " + propName +
                    " from " + bean, e);
        }
    }

    /**
     * Assert that the date <code>later</code> is after the date
     * <code>earlier</code>. The assertion succeeds if the dates
     * are equal. Both dates must be non-null.
     *
     * @param earlier the earlier date to compare
     * @param later teh later date to compare
     */
    public static void assertNotBefore(Date earlier, Date later) {
        assertNotBefore(null, earlier, later);
    }

    /**
     * Assert that the date <code>later</code> is after the date
     * <code>earlier</code>. The assertion succeeds if the dates
     * are equal. Both dates must be non-null.
     *
     * @param msg the message to print if the assertion fails
     * @param earlier the earlier date to compare
     * @param later the later date to compare
     */
    public static void assertNotBefore(String msg, Date earlier, Date later) {
        assertNotNull(msg, earlier);
        assertNotNull(msg, later);
        if (earlier.after(later) && !earlier.equals(later)) {
            String e = DateFormat.getDateTimeInstance().format(earlier);
            String l = DateFormat.getDateTimeInstance().format(later);
            throw new ComparisonFailure(msg, e, l);
        }
    }

    /**
     * Assert that <code>fragment</code> is a substring of <code>body</code>
     * @param body the larger string in which to search
     * @param fragment the substring that must be contained in <code>body</code>
     */
    public static void assertContains(String body, String fragment) {
        if (body.indexOf(fragment) == -1) {
            fail("The string '" + body + "' must contain '" + fragment + "'");
        }
    }

    /**
     * Assert that <code>fragment</code> is a substring of <code>body</code>
     * @param msg the message to print if the assertion fails
     * @param body the larger string in which to search
     * @param fragment the substring that must be contained in <code>body</code>
     */
    public static void assertContains(String msg, String body, String fragment) {
        if (body.indexOf(fragment) == -1) {
            fail(msg);
        }
    }

    /**
     * Util for turning of the spew from the l10n service for
     * test cases that make calls with dummy string IDs.
     */
    public static void disableLocalizationServiceLogging() {
        Logger log = Logger.getLogger(LocalizationService.class);
        log.setLevel(Level.OFF);
    }

    /**
     * Util for turning on the spew from the l10n service for
     * test cases that make calls with dummy string IDs.
     */
    public static void enableLocalizationServiceLogging() {
        Logger log = Logger.getLogger(LocalizationService.class);
        log.setLevel(Level.ERROR);
    }

    protected static void createDirIfNotExists(File dir) {
        String error =
                "Could not create the following directory:[" + dir.getPath() +
                    "] . Please create that directory before proceeding with the tests";
        if (dir.exists() && !dir.isDirectory()) {
            if (!dir.renameTo(new File(dir.getPath() + ".bak")) &&
                         !dir.delete()) {
                throw new RuntimeException(error);
            }
        }

        if (!dir.exists() && !dir.mkdirs()) {
            throw new RuntimeException(error);
        }
    }
}
