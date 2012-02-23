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
package com.redhat.rhn.domain.action.scap;

import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.domain.action.ActionChild;

/**
 * ScapActionDetails
 * @version $Rev$
 */
public class ScapActionDetails extends ActionChild {

    private Long id;
    private String path;
    private byte[] parameters;

    /**
     * ScapActionDetails constructor.
     * @param pathIn New setting for the path.
     * @param parametersIn New setting for the parameters.
     */
    public ScapActionDetails(String pathIn, String parametersIn) {
        super();
        this.setPath(pathIn);
        this.setParameters(parametersIn);
    }

    /**
     * Set the path to the main scap content.
     * @param pathIn New setting for the path.
     */
    public void setPath(String pathIn) {
        path = pathIn;
    }

    /**
     * Get the path to the scap content.
     * @return The path settings.
     */
    public String getPath() {
        return path;
    }

    /**
     * Set the additional parameters for the oscap tool.
     * @param parametersIn New setting for the parameters.
     */
    public void setParameters(String parametersIn) {
        parameters = HibernateFactory.stringToByteArray(parametersIn);
    }

    /**
     * Set the additional parameters for the oscap tool.
     * @param parametersIn New setting for the parameters.
     */
    public void setParameters(byte[] parametersIn) {
        parameters = parametersIn;
    }

    /**
     * Get the parameters for the oscap tool.
     * @return The parameters for oscap tool.
     */
    public byte[] getParameters() {
        return parameters;
    }

    /**
     * Get the parameters for the oscap tool.
     * @return The parameters for oscap tool.
     */
    public String getParametersContents() {
        return HibernateFactory.getByteArrayContents(parameters);
    }

    /**
     * @return Returns the id.
     */
    public Long getId() {
        return id;
    }

    /**
     * @param i The id to set.
     */
    public void setId(Long i) {
        this.id = i;
    }
}
