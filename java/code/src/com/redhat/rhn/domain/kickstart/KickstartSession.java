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
package com.redhat.rhn.domain.kickstart;

import com.redhat.rhn.common.security.SessionSwap;
import com.redhat.rhn.domain.action.Action;
import com.redhat.rhn.domain.common.CommonFactory;
import com.redhat.rhn.domain.common.TinyUrl;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.rhnpackage.profile.Profile;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.manager.action.ActionManager;

import java.util.Date;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Set;
import java.util.SortedMap;
import java.util.TreeMap;

/**
 * KickstartSession - Class representation of the table rhnkickstartsession.
 * @version $Rev: 1 $
 */
public class KickstartSession {

    // Indicating this KickstartSession is being
    // used for a 'one time' kickstart of a System
    public static final String MODE_ONETIME = "one_time";

    // Indicating this KickstartSession is the default session
    // that is associated with the KickstartData at creation time.
    public static final String MODE_DEFAULT_SESSION = "default_session";

    private Long id;
    private Long packageFetchCount;

    private String kickstartMode;
    private String lastFileRequest;
    private String systemRhnHost;
    private String kickstartFromHost;
    private Boolean deployConfigs;

    private KickstartableTree kstree;
    private KickstartData ksdata;
    private Org org;
    private User user;
    private Action action;
    private KickstartSessionState state;
    private KickstartVirtualizationType virtualizationType;
    private Server oldServer;
    private Server newServer;
    private Server hostServer;
    private Profile serverProfile;
    private Set history;
    private String clientIp;

    private Date created;
    private Date modified;
    private Date lastAction;

    /**
     * Getter for id
     * @return Long to get
    */
    public Long getId() {
        return this.id;
    }

    /**
     * Setter for id
     * @param idIn to set
    */
    public void setId(Long idIn) {
        this.id = idIn;
    }

    /**
     * Getter for kickstartId
     * @return Long to get
    */
    public KickstartData getKsdata() {
        return this.ksdata;
    }

    /**
     * Setter for kickstartId
     * @param ksdataIn to set
    */
    public void setKsdata(KickstartData ksdataIn) {
        this.ksdata = ksdataIn;
    }

    /**
     * Getter for kickstartMode
     * @return String to get
    */
    public String getKickstartMode() {
        return this.kickstartMode;
    }

    /**
     * Setter for kickstartMode
     * @param kickstartModeIn to set
    */
    public void setKickstartMode(String kickstartModeIn) {
        this.kickstartMode = kickstartModeIn;
    }

    /**
     * Getter for client IP.
     * @return Client IP string.
     */
    public String getClientIp() {
        return this.clientIp;
    }

    /**
     * Setter for client IP.
     * @param clientIpIn to set.
     */
    public void setClientIp(String clientIpIn) {
        this.clientIp = clientIpIn;
    }

    /**
     * Getter for kstree
     * @return KickstartableTree to get
    */
    public KickstartableTree getKstree() {
        return this.kstree;
    }

    /**
     * Setter for kstree
     * @param kstreeIn to set
    */
    public void setKstree(KickstartableTree kstreeIn) {
        this.kstree = kstreeIn;
    }

    /**
     * Getter for org
     * @return Org to get
    */
    public Org getOrg() {
        return this.org;
    }

    /**
     * Setter for orgId
     * @param orgIn to set
    */
    public void setOrg(Org orgIn) {
        this.org = orgIn;
    }

    /**
     * Getter for user
     * @return User to get
    */
    public User getUser() {
        return this.user;
    }

    /**
     * Setter for user
     * @param userIn to set
    */
    public void setUser(User userIn) {
        this.user = userIn;
    }

    /**
     * Getter for action
     * @return Action to get
    */
    public Action getAction() {
        return this.action;
    }

    /**
     * Setter for action
     * @param actionIn to set
    */
    public void setAction(Action actionIn) {
        this.action = actionIn;
    }

    /**
     * Getter for state
     * @return KickstartSessionState to get
    */
    public KickstartSessionState getState() {
        return this.state;
    }

    /**
     * Setter for state
     * @param stateIn to set
    */
    public void setState(KickstartSessionState stateIn) {
        this.state = stateIn;
    }

    /**
     * Getter for virtualization type
     * @return KickstartVirtualizationType to get
    */
    public KickstartVirtualizationType getVirtualizationType() {
        return this.virtualizationType;
    }

    /**
     * Setter for virtualization type
     * @param typeIn KickstartVirtualizationType to set
    */
    public void setVirtualizationType(KickstartVirtualizationType typeIn) {
        this.virtualizationType = typeIn;
    }

    /**
     * Getter for lastAction
     * @return Date to get
    */
    public Date getLastAction() {
        return this.lastAction;
    }

    /**
     * Setter for lastAction
     * @param lastActionIn to set
    */
    public void setLastAction(Date lastActionIn) {
        this.lastAction = lastActionIn;
    }

    /**
     * Getter for packageFetchCount
     * @return Long to get
    */
    public Long getPackageFetchCount() {
        return this.packageFetchCount;
    }

    /**
     * Setter for packageFetchCount
     * @param packageFetchCountIn to set
    */
    public void setPackageFetchCount(Long packageFetchCountIn) {
        this.packageFetchCount = packageFetchCountIn;
    }

    /**
     * Getter for lastFileRequest
     * @return String to get
    */
    public String getLastFileRequest() {
        return this.lastFileRequest;
    }

    /**
     * Setter for lastFileRequest
     * @param lastFileRequestIn to set
    */
    public void setLastFileRequest(String lastFileRequestIn) {
        this.lastFileRequest = lastFileRequestIn;
    }

    /**
     * Getter for created
     * @return Date to get
    */
    public Date getCreated() {
        return this.created;
    }

    /**
     * Setter for created
     * @param createdIn to set
    */
    public void setCreated(Date createdIn) {
        this.created = createdIn;
    }

    /**
     * Getter for modified
     * @return Date to get
    */
    public Date getModified() {
        return this.modified;
    }

    /**
     * Setter for modified
     * @param modifiedIn to set
    */
    public void setModified(Date modifiedIn) {
        this.modified = modifiedIn;
    }

    /**
     * Getter for hostServer
     * @return Server to get
    */
    public Server getHostServer() {
        return this.hostServer;
    }

    /**
     * Setter for hostServer
     * @param hostServerIn to set
    */
    public void setHostServer(Server hostServerIn) {
        this.hostServer = hostServerIn;
    }

    /**
     * Getter for oldServer
     * @return Server to get
    */
    public Server getOldServer() {
        return this.oldServer;
    }

    /**
     * Setter for oldServer
     * @param oldServerIn to set
    */
    public void setOldServer(Server oldServerIn) {
        this.oldServer = oldServerIn;
    }

    /**
     * Getter for newServer
     * @return Server to get
    */
    public Server getNewServer() {
        return this.newServer;
    }

    /**
     * Setter for newServerId
     * @param newServerIn to set
    */
    public void setNewServer(Server newServerIn) {
        this.newServer = newServerIn;
    }

    /**
     * Getter for systemRhnHost
     * @return String to get
    */
    public String getSystemRhnHost() {
        return this.systemRhnHost;
    }

    /**
     * Setter for systemRhnHost
     * @param systemRhnHostIn to set
    */
    public void setSystemRhnHost(String systemRhnHostIn) {
        this.systemRhnHost = systemRhnHostIn;
    }

    /**
     * Getter for kickstartFromHost
     * @return String to get
    */
    public String getKickstartFromHost() {
        return this.kickstartFromHost;
    }

    /**
     * Setter for kickstartFromHost
     * @param kickstartFromHostIn to set
    */
    public void setKickstartFromHost(String kickstartFromHostIn) {
        this.kickstartFromHost = kickstartFromHostIn;
    }

    /**
     * Getter for deployConfigs
     * @return String to get
    */
    public Boolean getDeployConfigs() {
        return this.deployConfigs;
    }

    /**
     * Setter for deployConfigs
     * @param deployConfigsIn to set
    */
    public void setDeployConfigs(Boolean deployConfigsIn) {
        this.deployConfigs = deployConfigsIn;
    }

    /**
     * Get the serverProfile
     * @return Profile object if defined.
     */
    public Profile getServerProfile() {
        return serverProfile;
    }

    /**
     * Set the profile.
     *
     * @param serverProfileIn to set
     */
    public void setServerProfile(Profile serverProfileIn) {
        this.serverProfile = serverProfileIn;
    }

    /**
     * @return the history
     */
    public Set getHistory() {
        return history;
    }

    /**
     * @param historyIn the history to set
     */
    public void setHistory(Set historyIn) {
        this.history = historyIn;
    }

    /**
     * Mark this KickstartSession as failed.
     * @param messageIn to fill into into the History field
     */
    public void markFailed(String messageIn) {
        if (this.action != null) {
            Action parentAction = this.action;
            while (parentAction.getPrerequisite() != null) {
                parentAction = this.action.getPrerequisite();
            }
            if (this.currentServer() != null) {
                ActionManager.
                    removeSystemFromAction(this.currentServer(), parentAction);
            }
        }
        this.setState(KickstartFactory.SESSION_STATE_FAILED);
        this.setAction(null);
        this.addHistory(this.getState(), messageIn);
    }

    /**
     * Add a History entry
     * @param stateIn to set
     * @param messageIn to set on the history item
     */
    public void addHistory(KickstartSessionState stateIn, String messageIn) {
        KickstartSessionHistory hist = new KickstartSessionHistory();
        hist.setState(stateIn);
        hist.setTime(new Date());
        hist.setSession(this);
        hist.setMessage(messageIn);

        if (this.history == null) {
            this.history = new HashSet();
        }
        this.history.add(hist);
    }

    private Server currentServer() {
        if (this.newServer != null) {
            return this.newServer;
        }
        else if (this.oldServer != null) {
            return this.oldServer;
        }
        return null;
    }

    /**
     * Get the URL to this KickstartSession.  We only deal with
     * HTTP urls because anaconda can't deal with https
     * @param kickstartHostIn server where this KS is served from
     * @param earliestDate that we are scheduling this KickstartSession.  This is
     * needed because we generate TinyUrls and they have an expire time.
     * @return String url
     */
    public String getUrl(String kickstartHostIn, Date earliestDate) {
        StringBuffer filepath = new StringBuffer();
        String encodedId = SessionSwap.encodeData(this.getId().toString());
        filepath.append("/kickstart/ks/");
        filepath.append("session/");
        filepath.append(encodedId);
        TinyUrl turl = null;
        if (earliestDate.after(new Date())) {
            turl = CommonFactory.
                createTinyUrl(filepath.toString(), earliestDate);
        }
        else {
           turl = CommonFactory.
            createTinyUrl(filepath.toString(), new Date());
        }
        CommonFactory.saveTinyUrl(turl);
        return turl.computeTinyUrl(kickstartHostIn);
    }

    /**
     * Get the most recent message in the history of this KickstartSession
     * @return String if there is history.  null if not.
     */
    public String getMostRecentHistory() {
        if (this.history != null && this.history.size() > 0) {

            SortedMap sorted = new TreeMap();
            Iterator i = this.history.iterator();
            while (i.hasNext()) {
                KickstartSessionHistory hist =
                    (KickstartSessionHistory) i.next();
                sorted.put(hist.getId(), hist);
            }

            KickstartSessionHistory hist =
                (KickstartSessionHistory) sorted.get(sorted.lastKey());
            return hist.getMessage();
        }
        else {
            return null;
        }

    }

}
