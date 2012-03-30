/**
 * Copyright (c) 2011 Novell
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
package com.redhat.rhn.domain.action.image;

import com.redhat.rhn.domain.action.ActionChild;

/**
 * DeployImageActionDetails - Class representation of the table rhnActionImageDeploy.
 * @version $Rev$
 */
public class DeployImageActionDetails extends ActionChild {

    private Long id;
    private Long vcpus;
    private Long memKb;
    private String bridgeDevice;
    private String downloadUrl;
    private String proxyServer;
    private String proxyUser;
    private String proxyPass;

    /**
     * Return the ID.
     * @return id
     */
    public Long getId() {
        return id;
    }

    /**
     * Set the ID.
     * @param idIn id
     */
    public void setId(Long idIn) {
        this.id = idIn;
    }

    /**
     * Return the number of virtual CPUs.
     * @return vcpus
     */
    public Long getVcpus() {
        return vcpus;
    }

    /**
     * Set the number of virtual CPUs.
     * @param vcpusIn vcpus
     */
    public void setVcpus(Long vcpusIn) {
        this.vcpus = vcpusIn;
    }

    /**
     * Return the amount of memory in KB.
     * @return memKb
     */
    public Long getMemKb() {
        return memKb;
    }

    /**
     * Set the amount of memory in KB.
     * @param memkb memory in KB
     */
    public void setMemKb(Long memkb) {
        this.memKb = memkb;
    }

    /**
     * Return the bridge device.
     * @return bridgeDevice
     */
    public String getBridgeDevice() {
        return bridgeDevice;
    }

    /**
     * Set the bridge device.
     * @param bridgeDeviceIn bridge device
     */
    public void setBridgeDevice(String bridgeDeviceIn) {
        this.bridgeDevice = bridgeDeviceIn;
    }

    /**
     * Set the download URL.
     * @return downloadUrl
     */
    public String getDownloadUrl() {
        return downloadUrl;
    }

    /**
     * Return the download URL.
     * @param downloadUrlIn download URL
     */
    public void setDownloadUrl(String downloadUrlIn) {
        this.downloadUrl = downloadUrlIn;
    }

    /**
     * Return the proxy server.
     * @return proxyServer
     */
    public String getProxyServer() {
        return proxyServer;
    }

    /**
     * Set the proxy server.
     * @param proxyServerIn proxy server
     */
    public void setProxyServer(String proxyServerIn) {
        this.proxyServer = proxyServerIn;
    }

    /**
     * Return the proxy user.s
     * @return proxyUser
     */
    public String getProxyUser() {
        return proxyUser;
    }

    /**
     * Set the proxy user.
     * @param proxyUserIn proxy user
     */
    public void setProxyUser(String proxyUserIn) {
        this.proxyUser = proxyUserIn;
    }

    /**
     * Return the proxy password.
     * @return proxyPass
     */
    public String getProxyPass() {
        return proxyPass;
    }

    /**
     * Set the proxy password.
     * @param proxyPassIn proxy password
     */
    public void setProxyPass(String proxyPassIn) {
        this.proxyPass = proxyPassIn;
    }
}
