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
package com.redhat.rhn.manager.satellite;

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.domain.user.User;

import org.apache.commons.lang.BooleanUtils;
import org.apache.commons.lang.StringUtils;

import java.util.LinkedList;
import java.util.List;

/**
 * 
 * ConfigureBootstrapCommand - contains logic for setting up and reconfiguring the 
 * bootstrap command on the satellite.
 * @version $Rev$
 */
public class ConfigureBootstrapCommand extends BaseConfigureCommand
        implements SatelliteConfigurator {

    private String hostname;
    private String sslPath;
    private Boolean enableSsl;
    private Boolean enableGpg;
    private Boolean allowConfigActions;
    private Boolean allowRemoteCommands;
    private String httpProxy;
    private String httpProxyUsername;
    private String httpProxyPassword;
    
    
    /**
     * Construct new ConfigureBootstrapCommand
     * @param userIn who wants to reconfig the bootstrap script
     */
    public ConfigureBootstrapCommand(User userIn) {
        super(userIn);
    }

    /**
     * {@inheritDoc}
     */
    public ValidatorError[] storeConfiguration() {
        Executor e = getExecutor();
        ValidatorError[] errors = new ValidatorError[1];
        String errorKey = "bootstrap.config.error.";
        
        List args = new LinkedList();
        args.add("/usr/bin/sudo");
        args.add("/usr/bin/rhn-bootstrap");
        if (BooleanUtils.toBooleanDefaultIfNull(this.allowConfigActions, false)) {
            args.add("--allow-config-actions");
        }
        if (BooleanUtils.toBooleanDefaultIfNull(this.allowRemoteCommands, false)) {
            args.add("--allow-remote-commands");
        }
        if (!BooleanUtils.toBooleanDefaultIfNull(this.enableSsl, false)) {
            args.add("--no-ssl");
        }
        if (!BooleanUtils.toBooleanDefaultIfNull(this.enableGpg, false)) {
            args.add("--no-gpg");
        }

        if (!StringUtils.isEmpty(this.hostname)) {
            args.add("--hostname=" + this.hostname);
        }
        if (!StringUtils.isEmpty(this.sslPath)) {
            args.add("--ssl-cert=" + this.sslPath);
        }
        if (!StringUtils.isEmpty(this.httpProxy)) {
            args.add("--http-proxy=" + this.httpProxy);
        }
        if (!StringUtils.isEmpty(this.httpProxyUsername)) {
            args.add("--http-proxy-username=" + this.httpProxyUsername);
        }
        if (!StringUtils.isEmpty(this.httpProxyPassword)) {
            args.add("--http-proxy-password=" + this.httpProxyPassword);
        }
        
        int exitcode = e.execute((String[]) args.toArray(new String[0]));
        if (exitcode != 0) {
            errorKey = errorKey + exitcode;
            if (!LocalizationService.getInstance().hasMessage(errorKey)) {
                errorKey = "bootstrap.config.error.127";
            }
            errors[0] = new ValidatorError(errorKey); 
            return errors;
        }
        else {
            return null;
        }

    }

    
    /**
     * @return Returns the allowConfigActions.
     */
    public Boolean getAllowConfigActions() {
        return allowConfigActions;
    }

    
    /**
     * @param allowConfigActionsIn The allowConfigActions to set.
     */
    public void setAllowConfigActions(Boolean allowConfigActionsIn) {
        this.allowConfigActions = allowConfigActionsIn;
    }

    
    /**
     * @return Returns the allowRemoteCommands.
     */
    public Boolean getAllowRemoteCommands() {
        return allowRemoteCommands;
    }

    
    /**
     * @param allowRemoteCommandsIn The allowRemoteCommands to set.
     */
    public void setAllowRemoteCommands(Boolean allowRemoteCommandsIn) {
        this.allowRemoteCommands = allowRemoteCommandsIn;
    }

    
    /**
     * @return Returns the enableGpg.
     */
    public Boolean getEnableGpg() {
        return enableGpg;
    }

    
    /**
     * @param enableGpgIn The enableGpg to set.
     */
    public void setEnableGpg(Boolean enableGpgIn) {
        this.enableGpg = enableGpgIn;
    }

    
    /**
     * @return Returns the enableSsl.
     */
    public Boolean getEnableSsl() {
        return enableSsl;
    }

    
    /**
     * @param enableSslIn The enableSsl to set.
     */
    public void setEnableSsl(Boolean enableSslIn) {
        this.enableSsl = enableSslIn;
    }

    
    /**
     * @return Returns the hostname.
     */
    public String getHostname() {
        return hostname;
    }

    
    /**
     * @param hostnameIn The hostname to set.
     */
    public void setHostname(String hostnameIn) {
        this.hostname = hostnameIn;
    }

    
    /**
     * @return Returns the httpProxy.
     */
    public String getHttpProxy() {
        return httpProxy;
    }

    
    /**
     * @param httpProxyIn The httpProxy to set.
     */
    public void setHttpProxy(String httpProxyIn) {
        this.httpProxy = httpProxyIn;
    }

    
    /**
     * @return Returns the httpProxyPassword.
     */
    public String getHttpProxyPassword() {
        return httpProxyPassword;
    }

    
    /**
     * @param httpProxyPasswordIn The httpProxyPassword to set.
     */
    public void setHttpProxyPassword(String httpProxyPasswordIn) {
        this.httpProxyPassword = httpProxyPasswordIn;
    }

    
    /**
     * @return Returns the httpProxyUsername.
     */
    public String getHttpProxyUsername() {
        return httpProxyUsername;
    }

    
    /**
     * @param httpProxyUsernameIn The httpProxyUsername to set.
     */
    public void setHttpProxyUsername(String httpProxyUsernameIn) {
        this.httpProxyUsername = httpProxyUsernameIn;
    }

    
    /**
     * @return Returns the sslPath.
     */
    public String getSslPath() {
        return sslPath;
    }

    
    /**
     * @param sslPathIn The sslPath to set.
     */
    public void setSslPath(String sslPathIn) {
        this.sslPath = sslPathIn;
    }


}
