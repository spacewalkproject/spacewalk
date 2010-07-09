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
package com.redhat.rhn.taskomatic.core;

import com.redhat.rhn.common.conf.Config;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.Option;
import org.apache.commons.cli.OptionBuilder;
import org.apache.commons.cli.Options;
import org.apache.log4j.Logger;

import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

import redstone.xmlrpc.XmlRpcClient;

/**
 * Implementation of the Taskomatic schedule task execution system.
 * This class serves merely as an interface between the native daemon
 * library and the actual scheduler setup and running logic implemented
 * in SchedulerKernel.
 * @version $Rev$
 * @see SchedulerKernel
 */
public class TaskomaticDaemon  extends BaseDaemon {

    public static final int ERR_SCHED_CREATE = -5;

    private Map masterOptionsMap = new HashMap();
    private SchedulerKernel kernel;

    /**
     * Main entry point for the native daemon
     * @param argv "Command-line" parameters
     */
    public static void main(String[] argv) {
        TaskomaticDaemon daemon = new TaskomaticDaemon();
        daemon.registerImplementation(argv);
    }

    protected Options buildOptionsList() {
        Options accum = new Options();
        createOption(accum, TaskomaticConstants.CLI_DEBUG,
                false, null, "turn on debug mode");
        createOption(accum, TaskomaticConstants.CLI_DAEMON,
                false, null, "turn on daemon mode");
        createOption(accum, TaskomaticConstants.CLI_SINGLE,
                false, null, "run a single task and exit");
        createOption(accum, TaskomaticConstants.CLI_HELP,
                false, null, "prints out help screen");
        createOption(accum, TaskomaticConstants.CLI_PIDFILE,
                true, "<pidfile>", "use PID file <pidfile>");
        createOption(accum, TaskomaticConstants.CLI_TASK,
                true, "taskname", "run this task (may be specified multiple times)");
        createOption(accum, TaskomaticConstants.CLI_DBURL,
                true, "url", "jdbcurl");
        createOption(accum, TaskomaticConstants.CLI_DBUSER,
                true, "username", "database username");
        createOption(accum, TaskomaticConstants.CLI_DBPASSWORD,
                true, "password", "database password");
        return accum;
    }

    protected int onStartup(CommandLine commandLine) {
        Logger log = Logger.getLogger(this.getClass());
        Map overrides = null;
        int retval = BaseDaemon.SUCCESS;

        //since the cobbler sync tasks rely on tomcat to be up
        //   let sleep until it is up
        while (!isTomcatUp()) {
            try {
                log.info("Tomcat is not up yet, sleeping 4 seconds");
                Thread.sleep(4000);
            }
            catch (Exception e) {
                e.printStackTrace();
            }
        }
        if (commandLine != null) {
            overrides = parseOverrides(commandLine);
        }
        try {
            this.kernel = new SchedulerKernel();
            this.kernel.configure(Config.get(), overrides);
            Runnable r = new Runnable() {
                public void run() {
                    try {
                        kernel.startup();
                    }
                    catch (TaskomaticException e) {
                        logMessage(BaseDaemon.LOG_FATAL, e.getMessage(), e);

                    }
                }
            };
            Thread t = new Thread(r);
            t.start();
        }
        catch (Throwable t) {
            logMessage(BaseDaemon.LOG_FATAL, t.getMessage(), t);
            System.exit(-1);
        }
        return retval;
    }

    protected int onShutdown(boolean breakFromUser) {
        // TODO Auto-generated method stub
        return 0;
    }

    private Map parseOverrides(CommandLine commandLine) {
        Map configOverrides = new HashMap();
        // Loop thru all possible options and let's see what we get
        for (Iterator iter = this.masterOptionsMap.keySet().iterator(); iter.hasNext();) {

            String optionName = (String) iter.next();

            if (commandLine.hasOption(optionName)) {

                // All of these options are single-value options so they're
                // grouped together here
                if (optionName.equals(TaskomaticConstants.CLI_PIDFILE) ||
                        optionName.equals(TaskomaticConstants.CLI_DBURL) ||
                        optionName.equals(TaskomaticConstants.CLI_DBUSER) ||
                        optionName.equals(TaskomaticConstants.CLI_DBPASSWORD)) {
                    configOverrides.put(optionName,
                            commandLine.getOptionValue(optionName));
                }

                // The presence of these options toggle them on, hence the use of
                // Boolean.TRUE
                else if (optionName.equals(TaskomaticConstants.CLI_DEBUG) ||
                        optionName.equals(TaskomaticConstants.CLI_DAEMON) ||
                        optionName.equals(TaskomaticConstants.CLI_SINGLE)) {
                    configOverrides.put(optionName, Boolean.TRUE);
                }

                // Possibly multi-value list of task implementations to schedule
                else if (optionName.equals(TaskomaticConstants.CLI_TASK)) {
                    String[] taskImpls = commandLine.getOptionValues(optionName);
                    if (taskImpls != null && taskImpls.length > 0) {
                        configOverrides.put(optionName, Arrays.asList(taskImpls));
                    }
                }
            }
        }
        return configOverrides;
    }

    private void createOption(Options accum, String longopt, boolean arg,
            String argName, String description) {
        OptionBuilder.withArgName(argName);
        OptionBuilder.withLongOpt(longopt);
        OptionBuilder.hasArg(arg);
        OptionBuilder.withDescription(description);
        Option option = OptionBuilder.create(longopt);
        accum.addOption(option);
        if (this.masterOptionsMap.get(longopt) == null) {
            this.masterOptionsMap.put(longopt, option);
        }
    }

    private boolean isTomcatUp() {
        boolean toRet = false;
        try {
            XmlRpcClient client = new XmlRpcClient("http://localhost/rpc/api", false);
            Object obj = client.invoke("api.getVersion", Collections.EMPTY_LIST);
            if (obj instanceof String) {
                toRet = true;
            }
        }
        catch (Exception e) {
            toRet = false;
        }
        return toRet;
    }
}
