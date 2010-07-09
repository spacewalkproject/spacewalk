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
package com.redhat.rhn.domain.monitoring.test;

import com.redhat.rhn.domain.monitoring.MonitoringConstants;
import com.redhat.rhn.domain.monitoring.Probe;
import com.redhat.rhn.domain.monitoring.ProbeParameterValue;
import com.redhat.rhn.domain.monitoring.command.Command;
import com.redhat.rhn.domain.monitoring.command.CommandParameter;
import com.redhat.rhn.testing.ActionHelper;

import org.apache.commons.collections.CollectionUtils;
import org.apache.commons.collections.Transformer;

import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;

import junit.framework.Assert;

public final class MonitoringTestUtils {

    private MonitoringTestUtils() {
    }

    /**
     * Return a map of parameter names to their values for <code>probe</code>
     * @param probe the probe
     * @return a map of parameter names to their values
     */
    public static Map parameterValueMap(Probe probe) {
        Set ppvSet = probe.getProbeParameterValues();
        HashMap result = new HashMap();
        for (Iterator i = ppvSet.iterator(); i.hasNext();) {
            ProbeParameterValue ppv = (ProbeParameterValue) i.next();
            result.put(ppv.getParamName(), ppv.getValue());
        }
        return result;
    }

    /**
     * Return the names of the probe parameters of <code>probe</code>
     * @param probe the probe
     * @return the names of the probe parameters
     */
    public static Set parameterNameSet(Probe probe) {
        Set ppvSet = probe.getProbeParameterValues();
        assert ppvSet != null && ppvSet.size() > 0;
        Transformer transform = new ProbeParameterToName();
        return (Set) CollectionUtils.collect(ppvSet, transform, new HashSet());
    }

    /**
     * Return the names of the parameters of <code>command</code>
     * @param command the command
     * @return the names of the parameters of <code>command</code>
     */
    public static Set parameterNameSet(Command command) {
        Set cps = command.getCommandParameters();
        Transformer transform = new CommandParameterToName();
        return (Set) CollectionUtils.collect(cps, transform, new HashSet());
    }

    /**
     * Verify that the parameters in the probe have been set in accordance
     * with what {@link #setupParamValues} has set up.
     *
     * @param probe the probe to verify
     * @param command the command the probe uses
     */
    public static void verifyParameters(Probe probe, Command command) {
        Set probeNames = parameterNameSet(probe);
        Set cmdNames = parameterNameSet(command);
        Assert.assertEquals(cmdNames, probeNames);
        Map probeValues = parameterValueMap(probe);
        Assert.assertEquals(makeParamDefaults(command, true), probeValues);
    }

    /**
     * Setup request parameters for the command parameters for
     * <code>command</code>.
     * @param ah the action helper
     * @param command the command
     * @param multiplicity the number of times the parameter values
     * will be accessed
     */
    public static void setupParamValues(ActionHelper ah, Command command,
            int multiplicity) {
        HashMap defaults = makeParamDefaults(command, true);
        setupParamValues(ah, defaults, multiplicity);
    }

    public static void setupParamValues(ActionHelper ah, HashMap params,
            int multiplicity) {
        for (Iterator i = params.keySet().iterator(); i.hasNext();) {
            String name = (String) i.next();
            for (int j = 0; j < multiplicity; j++) {
                ah.getRequest().setupAddParameter("param_" + name,
                        (String) params.get(name));
            }
        }
    }

    /**
     * Return a map of fixed values for the visible parameters
     * of {@link com.redhat.rhn.domain.monitoring.MonitoringConstants#COMMAND_CHECK_TCP}
     * @param includeInvisible TODO
     */
    public static HashMap makeParamDefaults(Command command, boolean includeInvisible) {
        Assert.assertEquals("Only CHECK_TCP is supported",
                MonitoringConstants.getCommandCheckTCP().getName(), command.getName());
        HashMap result = new HashMap();
        result.put("send", "send it");
        result.put("expect", "expect it");
        result.put("r_port_0", "666");
        result.put("timeout", "111");
        result.put("critical", "555");
        result.put("warning", "333");
        if (includeInvisible) {
            // Non-visible params, use their default values in the DB
            result.put("r_ip_0", "$HOSTADDRESS$");
            result.put("r_svc_0", "BAD_FIXME");
            result.put("r_tproto_0", "tcp");
        }
        return result;
    }

    private static class ProbeParameterToName implements Transformer {
        public Object transform(Object input) {
            return ((ProbeParameterValue) input).getParamName();
        }
    }

    private static class CommandParameterToName implements Transformer {
        public Object transform(Object input) {
            return ((CommandParameter) input).getParamName();
        }
    }
}
