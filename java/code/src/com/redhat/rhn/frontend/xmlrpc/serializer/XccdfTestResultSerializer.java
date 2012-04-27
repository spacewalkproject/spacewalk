/**
 * Copyright (c) 2012 Red Hat, Inc.
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

package com.redhat.rhn.frontend.xmlrpc.serializer;

import java.io.IOException;
import java.io.Writer;

import redstone.xmlrpc.XmlRpcCustomSerializer;
import redstone.xmlrpc.XmlRpcException;
import redstone.xmlrpc.XmlRpcSerializer;

import com.redhat.rhn.domain.action.Action;
import com.redhat.rhn.domain.action.scap.ScapActionDetails;
import com.redhat.rhn.domain.audit.XccdfBenchmark;
import com.redhat.rhn.domain.audit.XccdfProfile;
import com.redhat.rhn.domain.audit.XccdfTestResult;
import com.redhat.rhn.frontend.xmlrpc.serializer.util.SerializerHelper;


/**
 * XccdfTestResultSerializer
 * @version $Rev$
 * @xmlrpc.doc
 * #struct("OpenSCAP XCCDF Scan")
 *   #prop_desc("int", "xid", "XCCDF TestResult id")
 *   #prop_desc("int", "sid", "serverId")
 *   #prop_desc("int", "action_id", "Id of the parent action.")
 *   #prop_desc("string", "path", "Path to XCCDF document")
 *   #prop_desc("string", "oscap_parameters", "oscap command-line arguments.")
 *   #prop_desc("string", "test_result", "Identifier of XCCDF TestResult.")
 *   #prop_desc("string", "benchmark", "Identifier of XCCDF Benchmark.")
 *   #prop_desc("string", "benchmark_version" , "Version of the Benchmark.")
 *   #prop_desc("string", "profile", "Identifier of XCCDF Profile.")
 *   #prop_desc("string", "profile_title", "Title of XCCDF Profile.")
 *   #prop_desc($date, "start_time", "Client machine time of scan start.")
 *   #prop_desc($date, "end_time", "Client machine time of scan completion.")
 *   #prop_desc("string", "errors", "Stderr output of scan.")
 * #struct_end()
 */
public class XccdfTestResultSerializer implements XmlRpcCustomSerializer {

    /**
     * {@inheritDoc}
     */
    public Class getSupportedClass() {
        return XccdfTestResult.class;
    }

    /**
     * {@inheritDoc}
     */
    public void serialize(Object value, Writer output,
            XmlRpcSerializer builtInSerializer) throws XmlRpcException, IOException {
        XccdfTestResult testResult = (XccdfTestResult) value;
        ScapActionDetails actionDetails = testResult.getScapActionDetails();
        XccdfBenchmark benchmark = testResult.getBenchmark();
        XccdfProfile profile = testResult.getProfile();
        Action parentAction = actionDetails.getParentAction();

        SerializerHelper helper = new SerializerHelper(builtInSerializer);
        addToHelper(helper, "xid", testResult.getId());
        addToHelper(helper, "sid", testResult.getServer().getId());
        addToHelper(helper, "path", actionDetails.getPath());
        addToHelper(helper, "oscap_parameters", actionDetails.getParametersContents());
        addToHelper(helper, "test_result", testResult.getIdentifier());
        addToHelper(helper, "benchmark", benchmark.getIdentifier());
        addToHelper(helper, "benchmark_version", benchmark.getVersion());
        addToHelper(helper, "profile", profile.getIdentifier());
        addToHelper(helper, "profile_title", profile.getTitle());
        addToHelper(helper, "start_time", testResult.getStartTime());
        addToHelper(helper, "end_time", testResult.getEndTime());
        addToHelper(helper, "errors", testResult.getErrrosContents());
        addToHelper(helper, "action_id", parentAction.getId());
        helper.writeTo(output);
    }

    private static void addToHelper(SerializerHelper helper, String label, Object value) {
        if (value != null) {
            helper.add(label, value);
        }
    }
}
