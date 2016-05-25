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

package com.redhat.rhn.common.util.test;

import com.redhat.rhn.common.util.ServletUtils;
import com.redhat.rhn.testing.RhnMockHttpServletRequest;
import com.redhat.rhn.testing.ServletTestUtils;

import org.jmock.Expectations;
import org.jmock.integration.junit3.MockObjectTestCase;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Hashtable;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeMap;
import java.util.Vector;

import javax.servlet.http.HttpServletRequest;

public class ServletUtilsTest extends MockObjectTestCase {

    private HttpServletRequest mockRequest;

    private String param1Name;
    private String param1Value;

    private String param2Name;
    private String param2Value;

    protected void setUp() throws Exception {
        super.setUp();

        mockRequest = mock(HttpServletRequest.class);

        param1Name = "param1";
        param1Value = "param 1 = 'Neo is the one!'";

        param2Name = "param2";
        param2Value = "param 2 = What is the matrix?";
    }

    private HttpServletRequest getRequest() {
        return mockRequest;
    }

    private Hashtable<String, String> createParameterMap() {
        Hashtable<String, String> parameterMap = new Hashtable<String, String>();

        parameterMap.put(param1Name, param1Value);
        parameterMap.put(param2Name, param2Value);

        return parameterMap;
    }

    private String encode(String string) throws UnsupportedEncodingException {
        return URLEncoder.encode(string, "UTF-8");
    }

    public void testRequestPath() {
        RhnMockHttpServletRequest request = new RhnMockHttpServletRequest();
        request.setRequestURL("http://localhost:8080/rhnjava/index.jsp");

        assertEquals("/rhnjava/index.jsp", ServletUtils.getRequestPath(request));
    }

    public void testPathWithParams() {
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("a", new Object[] { new Integer(1), new Integer(3) });
        params.put("b", new Integer(2));

        String result = ServletUtils.pathWithParams("/foo", params);

        assertTrue(result.startsWith("/foo?"));
        Set<String> actualParams =
                new HashSet<String>(Arrays.asList(result.substring(5).split("&")));
        Set<String> expectedParams = new HashSet<String>();
        expectedParams.add("a=1");
        expectedParams.add("a=3");
        expectedParams.add("b=2");
        assertEquals(expectedParams, actualParams);
    }

    public void testPathWithParamsValueUrlEncoding() {
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("key", "some; value&");
        String result = ServletUtils.pathWithParams("/foo", params);
        assertEquals("/foo?key=some%3B+value%26", result);
    }

    public void testPathWithParamsNullValue() {
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("key", null);
        String result = ServletUtils.pathWithParams("/foo", params);
        assertEquals("/foo", result);
    }

    public void testPathWithParamsArrayValueUrlEncoding() {
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("key", new Object[] {"value;", "value&", "$", "normal"});
        String result = ServletUtils.pathWithParams("/foo", params);
        assertEquals("/foo?key=value%3B&key=value%26&key=%24&key=normal", result);
    }

    public void testPathWithParamsListValue() {
        Map<String, Object> params = new HashMap<String, Object>();
        List<String> values = new ArrayList<String>();
        values.add("value;");
        values.add("value&");
        values.add("$");
        values.add("normal");
        params.put("key", values);
        String result = ServletUtils.pathWithParams("/foo", params);
        assertEquals("/foo?key=value%3B&key=value%26&key=%24&key=normal", result);

    }

    public void testPathWithParamsKeyUrlEncoding() {
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("a;", "somevalue");
        String result = ServletUtils.pathWithParams("/foo", params);
        assertEquals("/foo?a%3B=somevalue", result);
    }

    public void testPathWithParamsKeyArrayUrlEncoding() {
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("a;", new Object[] {"1", "2", "3"});
        String result = ServletUtils.pathWithParams("/foo", params);
        assertEquals("/foo?a%3B=1&a%3B=2&a%3B=3", result);
    }

    public final void testRequestParamsToQueryStringWithNoParams() throws Exception {
        context().checking(new Expectations() { {
            allowing(mockRequest).getParameterNames();
            will(returnValue(new Vector<String>().elements()));
            allowing(mockRequest).getParameterMap();
            will(returnValue(new TreeMap<>()));
        } });
        String queryString = ServletUtils.requestParamsToQueryString(getRequest());
        assertNotNull(queryString);
        assertEquals(0, queryString.length());
    }

    public final void testRequestParamsToQueryStringWithParams() throws Exception {
        Hashtable<String, String> parameterMap = createParameterMap();
        context().checking(new Expectations() { {
            allowing(mockRequest).getParameterMap();
            will(returnValue(parameterMap));
            allowing(mockRequest).getParameterNames();
            will(returnValue(parameterMap.keys()));
            allowing(mockRequest).getParameter(param1Name);
            will(returnValue(param1Value));
            allowing(mockRequest).getParameter(param2Name);
            will(returnValue(param2Value));
        } });

        String expectedQueryString = encode(param1Name) + "=" + encode(param1Value) +
                "&" + encode(param2Name) + "=" + encode(param2Value);

        String actualQueryString = ServletUtils.requestParamsToQueryString(
                getRequest()).toString();

        ServletTestUtils.assertQueryStringEquals(expectedQueryString, actualQueryString);
    }
}
