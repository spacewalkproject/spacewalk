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

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.CommandLineParser;
import org.apache.commons.cli.Options;
import org.apache.commons.cli.ParseException;
import org.apache.commons.cli.PosixParser;
import org.tanukisoftware.wrapper.WrapperListener;
import org.tanukisoftware.wrapper.WrapperManager;

import java.io.PrintWriter;
import java.io.StringWriter;

/**
 * This is the base implementation for all RHN Java daemons.
 * It serves at the interface between the Tanuki service/daemon 
 * wrapper library and also provides very basic lifecycle callbacks.
 * @version $Rev: $
 */
public abstract class BaseDaemon implements WrapperListener {
    
    public static final int LOG_DEBUG = WrapperManager.WRAPPER_LOG_LEVEL_DEBUG;
    public static final int LOG_INFO = WrapperManager.WRAPPER_LOG_LEVEL_INFO;
    public static final int LOG_ERROR = WrapperManager.WRAPPER_LOG_LEVEL_ERROR;
    public static final int LOG_FATAL = WrapperManager.WRAPPER_LOG_LEVEL_FATAL;
    
    public static final int SUCCESS = Integer.MIN_VALUE;

    /**
     * Interface method required by WrapperListener
     * @param argv Arguments configured in the daemon's config file
     * @return Integer indicating status (null indicates success, else value indicates 
     * error code)
     */
    public Integer start(String[] argv) {
        Integer retval = null;
        Options options = buildOptionsList();
        int status = BaseDaemon.SUCCESS;
        if (options != null) {
            status = startupWithOptions(options, argv);
            if (status != BaseDaemon.SUCCESS) {
                retval = new Integer(status);
            }
        }
        else {
            status = startupWithoutOptions();
            if (status != BaseDaemon.SUCCESS) {
                retval  = new Integer(status);
            }
        }
        return retval;
    }

    /**
     * Interface method required by WrapperListener
     * @param code int
     * @return int
     */
    public int stop(int code) {
        int retval = onShutdown(false);
        if (retval == BaseDaemon.SUCCESS) {
            return 0;
        }
        else {
            return retval;
        }
    }

    /**
     * Interface method required by WrapperListener
     * @param event int
     */
    public void controlEvent(int event) {
        switch(event) {
            case WrapperManager.WRAPPER_CTRL_C_EVENT:
                onShutdown(true);
                break;
            case WrapperManager.WRAPPER_CTRL_CLOSE_EVENT:
            case WrapperManager.WRAPPER_CTRL_LOGOFF_EVENT:
            case WrapperManager.WRAPPER_CTRL_SHUTDOWN_EVENT:
                onShutdown(false);
                break;
            default:
                break;
        }
    }
    /**
     * Convenience method to allow daemon implementations to log messages directly 
     * to the host system's system log, ie not log4j or commons-logging. If a 
     * java.lang.Throwable is passed in then the stack trace will be logged as well.
     * @param logLevel Desired log level
     * @param msg Message to log 
     * @param err Optional
     */
    public void logMessage(int logLevel, String msg, Throwable err) {
        StringBuffer buf  = new StringBuffer();
        buf.append(msg);
        if (err != null) {
           buf.append("\n");
           StringWriter writer = new StringWriter();
           PrintWriter printWriter = new PrintWriter(writer);
           err.printStackTrace(printWriter);
           printWriter.flush();
           buf.append(writer.toString());
        }
        WrapperManager.log(logLevel, buf.toString());
    }
    
    /**
     * Registers the daemon implementation with the Tanuki wrapper
     * @param argv startup parameters (if any)
     */
    protected void registerImplementation(String[] argv) {
        WrapperManager.start(this, argv);        
    }
    
    /**
     * Creates the "master" list of options which the daemon implementation 
     * knows about. Implementations should override this method if they need 
     * param parsing.
     * @return org.apache.commons.cli.Options instance populated with options or null if 
     * no options
     */
    protected Options buildOptionsList() {
        return null;
    }
    
    /**
     * Lifecycle method called when startup parameters cannot be parsed. This gives 
     * the daemon implementation an opportunity to do something about the error such 
     * as display a usage message.
     * @param e
     * @return int indicates error code. If BaseDaemon.SUCCESS is returned, then 
     * the framework will still try to start the daemon implementation _without_ parameters.
     */
    protected  int onOptionsParseError(ParseException e) {
        return BaseDaemon.SUCCESS;
    }
    
    /**
     * Lifecycle method called when the daemon implementation is started. This 
     * method _must_ return otherwise the daemon will appear to hang at startup. 
     * This implies that all "real" work needs to be done in a separate thread.
     * @param commandLine Parsed params, if present. Otherwise null.
     * @return int indicates status where <code>BaseDaemon.SUCCESS</code> 
     * indicates success and any other number indicates failure
     */
    protected abstract int onStartup(CommandLine commandLine);

    /**
     * Lifecycle method called when the daemon implementation is stopped. 
     * @param breakFromUser True if the user sent a Ctrl-C
     * @return int indicates status where <code>BaseDaemon.SUCCESS</code> 
     * indicates success and any other number indicates an error
     */
    protected abstract int onShutdown(boolean breakFromUser);
    
    
    /**
     * Parse startup options using jakarta-commons-cli and start
     * the daemon implementation
     * @param options Master list of options built by the daemon implementation
     * @param argv Startup arguments
     * @return int indicates status where <code>BaseDaemon.SUCCESS</code> 
     * indicates success and any other number indicates failure
     * 
     * @see buildOptionsList
     */
    private int startupWithOptions(Options options, String[] argv) {
        int retval = BaseDaemon.SUCCESS;
        CommandLineParser parser = null;
        try {
            parser = new PosixParser();
            CommandLine cl = parser.parse(options, argv);
            retval = onStartup(cl);
        }
        catch (ParseException e) {
            retval = onOptionsParseError(e);
            if (retval == BaseDaemon.SUCCESS) {
                retval = onStartup(null);
            }
        }
        return retval;
    }
    
    /**
     * Start the daemon implementation with no startup parameters
     * @return int indicates status where <code>BaseDaemon.SUCCESS</code> 
     * indicates success and any other number indicates failure
     */
    private int startupWithoutOptions() {
        return onStartup(null);
    }
}
