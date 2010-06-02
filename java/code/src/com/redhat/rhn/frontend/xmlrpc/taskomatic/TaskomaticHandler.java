/**
 * Copyright (c) 2008 Red Hat, Inc.
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
package com.redhat.rhn.frontend.xmlrpc.taskomatic;

import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.xmlrpc.BaseHandler;
import com.redhat.rhn.taskomatic.TaskoTask;
import com.redhat.rhn.taskomatic.core.SchedulerKernel;
import com.redhat.rhn.taskomatic.core.TaskomaticException;

import org.apache.log4j.Logger;
import org.quartz.JobDetail;
import org.quartz.SchedulerException;
import org.quartz.Trigger;
import org.quartz.TriggerUtils;

import java.net.MalformedURLException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.List;

import redstone.xmlrpc.XmlRpcClient;
import redstone.xmlrpc.XmlRpcException;
import redstone.xmlrpc.XmlRpcFault;


/**
 * TaskoHandler
 * @version $Rev$
 */
public class TaskomaticHandler extends BaseHandler {

    public static String DEFAULT_GROUP = "RHN";
    private String TASKOMATIC_NAMESPACE = "tasko";
    private static Logger log = Logger.getLogger(TaskomaticHandler.class);

    public Object invoke(String methodCalled, List arguments) throws XmlRpcFault {
        List params = new ArrayList(arguments);
        String sessionKey = (String) params.remove(0);
        User loggedInUser =  getLoggedInUser(sessionKey);
        ensureUserRole(loggedInUser, RoleFactory.ORG_ADMIN);

        params.add(0, loggedInUser.getOrg().getId());

        XmlRpcClient client;
        log.info("Translating " + methodCalled);

        try {
            client = new XmlRpcClient(ConfigDefaults.get().getTaskoServerUrl(), false);
        }
        catch (MalformedURLException e) {
            e.printStackTrace();
            throw new XmlRpcFault(0, "Malformed URL");
        }

        try {
            Object obj = client.invoke(TASKOMATIC_NAMESPACE + "." + methodCalled, params);
            return obj;
        }
        catch (XmlRpcException e) {
            throw new XmlRpcFault(1, "Taskomatic not accessible");
        }
    }
}
