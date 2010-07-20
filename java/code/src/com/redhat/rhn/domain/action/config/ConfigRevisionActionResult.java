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
package com.redhat.rhn.domain.action.config;

import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.domain.BaseDomainHelper;

/**
 * ConfigRevisionAction - Class representation of the table rhnActionConfigRevision.
 *
 * @version $Rev$
 */
public class ConfigRevisionActionResult extends BaseDomainHelper {

    private Long actionConfigRevisionId;
    private ConfigRevisionAction configRevisionAction;
    private byte[] result;

    /**
     * Getter for actionConfigRevisionId
     * @return Long to get
    */
    public Long getActionConfigRevisionId() {
        return this.actionConfigRevisionId;
    }

    /**
     * Setter for actionConfigRevisionId
     * @param actionConfigRevisionIdIn to set
    */
    public void setActionConfigRevisionId(Long actionConfigRevisionIdIn) {
        this.actionConfigRevisionId = actionConfigRevisionIdIn;
    }

    /**
     * Getter for result
     * @return Blob to get
    */
    public byte[] getResult() {
        return  result;
    }


    /**
     * set the result
     * @param resultIn the result
     */
    public void setResult(byte[] resultIn) {
        this.result = resultIn;
    }

   /**
     * Get the String version of the result contents
     * @return String version of the result contents
     */
    public String getResultContents() {
        return HibernateFactory.getByteArrayContents(getResult());
    }

    /**
     * Get the ConfigRevisionAction (parent) of this object
     * @return Returns the configRevisionAction.
     */
    public ConfigRevisionAction getConfigRevisionAction() {
        return configRevisionAction;
    }
    /**
     * Set the ConfigRevisionAction (parent) of this object
     * @param configRevisionActionIn The configRevisionAction to set.
     */
    public void setConfigRevisionAction(ConfigRevisionAction configRevisionActionIn) {
        this.configRevisionAction = configRevisionActionIn;
    }
}
