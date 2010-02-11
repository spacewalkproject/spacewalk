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
package com.redhat.rhn.manager.system;

import com.redhat.rhn.domain.action.ActionFactory;
import com.redhat.rhn.domain.action.ActionType;

import java.util.HashMap;

/**
 * A map between virtualization states and actions
 * 
 * @version $Rev $
 */
public class VirtualizationActionMap {
    private static VirtualizationActionMap singleton = new VirtualizationActionMap();

    private HashMap actionMap;
                                // Essentially a state machine to answer:
                                // "Given a desired action (start,
                                // suspend, resume, restart, shutdown) and a
                                // current state (running, stopped,
                                // crashed, paused), what RHN action
                                // should be used?"

    private HashMap startMap;
    private HashMap suspendMap;
    private HashMap resumeMap;
    private HashMap restartMap;
    private HashMap shutdownMap;
    private HashMap deleteMap;
    private HashMap setVcpusMap;
    private HashMap setMemoryMap;

    private VirtualizationActionMap() {
        setup();
    }

    private void setup() {
        startMap = new HashMap();
        startMap.put("running", null);
        startMap.put("stopped", ActionFactory.TYPE_VIRTUALIZATION_START);
        startMap.put("crashed", ActionFactory.TYPE_VIRTUALIZATION_START);
        startMap.put("paused", ActionFactory.TYPE_VIRTUALIZATION_RESUME);

        suspendMap = new HashMap();
        suspendMap.put("running", ActionFactory.TYPE_VIRTUALIZATION_SUSPEND);
        suspendMap.put("stopped", null);
        suspendMap.put("crashed", null);
        suspendMap.put("paused", null);

        resumeMap = new HashMap();
        resumeMap.put("running", null);
        resumeMap.put("stopped", null);
        resumeMap.put("crashed", null);
        resumeMap.put("paused", ActionFactory.TYPE_VIRTUALIZATION_RESUME);

        restartMap = new HashMap();
        restartMap.put("running", ActionFactory.TYPE_VIRTUALIZATION_REBOOT);
        restartMap.put("stopped", ActionFactory.TYPE_VIRTUALIZATION_START);
        restartMap.put("crashed", ActionFactory.TYPE_VIRTUALIZATION_START);
        restartMap.put("paused", ActionFactory.TYPE_VIRTUALIZATION_REBOOT);
    
        shutdownMap = new HashMap();
        shutdownMap.put("running", ActionFactory.TYPE_VIRTUALIZATION_SHUTDOWN);
        shutdownMap.put("stopped", null);
        shutdownMap.put("crashed", ActionFactory.TYPE_VIRTUALIZATION_SHUTDOWN);
        shutdownMap.put("paused", ActionFactory.TYPE_VIRTUALIZATION_SHUTDOWN);
        
        deleteMap = new HashMap();
        deleteMap.put("destroy", ActionFactory.TYPE_VIRTUALIZATION_DESTROY);

        setMemoryMap = new HashMap();
        setMemoryMap.put("running", ActionFactory.TYPE_VIRTUALIZATION_SET_MEMORY);
        setMemoryMap.put("stopped", ActionFactory.TYPE_VIRTUALIZATION_SET_MEMORY);
        setMemoryMap.put("crashed", ActionFactory.TYPE_VIRTUALIZATION_SET_MEMORY);
        setMemoryMap.put("paused", ActionFactory.TYPE_VIRTUALIZATION_SET_MEMORY);

        setVcpusMap = new HashMap();
        setVcpusMap.put("running", ActionFactory.TYPE_VIRTUALIZATION_SET_VCPUS);
        setVcpusMap.put("stopped", ActionFactory.TYPE_VIRTUALIZATION_SET_VCPUS);
        setVcpusMap.put("crashed", ActionFactory.TYPE_VIRTUALIZATION_SET_VCPUS);
        setVcpusMap.put("paused", ActionFactory.TYPE_VIRTUALIZATION_SET_VCPUS);

        actionMap = new HashMap();
        actionMap.put("start", startMap);
        actionMap.put("suspend", suspendMap);
        actionMap.put("resume", resumeMap);
        actionMap.put("restart", restartMap);
        actionMap.put("shutdown", shutdownMap);
        actionMap.put("setMemory", setMemoryMap);
        actionMap.put("setVcpu", setVcpusMap);
    }

    /**
     * Find the appropriate action label for a given action name and current state.
     *
     * @param currentState The current state of the instance
     * @param actionName The name of the action the user wants to perform 
     *                   from the button on the form in the web UI.
     * @return The ActionType of the (RHN) action that should be performed.
     */
    public static ActionType lookupActionType(String currentState, String actionName) {
        if (singleton.actionMap.get(actionName) != null) {
            HashMap aMap = (HashMap) singleton.actionMap.get(actionName);
            return (ActionType) aMap.get(currentState);
        }

        return null;
    }

}
