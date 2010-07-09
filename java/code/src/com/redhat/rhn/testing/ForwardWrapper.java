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
package com.redhat.rhn.testing;

import org.apache.commons.lang.StringUtils;
import org.apache.struts.action.ActionForward;
import org.apache.struts.config.ForwardConfig;

import java.util.HashMap;

/**
 * A decorator for a {@link org.apache.struts.action.ActionForward}. In
 * addition to decorating a forward, this class adds the capability of getting
 * parameters from the forward's path with {@link #getParam} and
 * {@link #getLongParam}.
 * @version $Rev$
 */
public class ForwardWrapper extends ActionForward {

    private ForwardConfig fc;
    private HashMap       params;

    /**
     * Create a new forward that decorates <code>fc0</code>
     * @param fc0 the forward to decorate
     */
    public ForwardWrapper(ForwardConfig fc0) {
        fc = fc0;
    }

    //
    // Decorate ForwardConfig
    //

    /**
     * {@inheritDoc}
     */
    public boolean equals(Object obj) {
        return fc.equals(obj);
    }

    /**
     * {@inheritDoc}
     */
    public void freeze() {
        fc.freeze();
    }

    /**
     * {@inheritDoc}
     */
    public String getModule() {
        return fc.getModule();
    }

    /**
     * {@inheritDoc}
     */
    public String getName() {
        return fc.getName();
    }

    /**
     * {@inheritDoc}
     */
    public String getPath() {
        return fc.getPath();
    }

    /**
     * {@inheritDoc}
     */
    public boolean getRedirect() {
        return fc.getRedirect();
    }

    /**
     * {@inheritDoc}
     */
    public int hashCode() {
        return fc.hashCode();
    }

    /**
     * {@inheritDoc}
     */
    public void setModule(String module0) {
        fc.setModule(module0);
    }

    /**
     * {@inheritDoc}
     */
    public void setName(String name0) {
        // The super constructor calls this method
        // before fc is initialized; we want to ignore that
        if (fc != null) {
            fc.setName(name0);
        }
    }

    /**
     * {@inheritDoc}
     */
    public void setPath(String path0) {
        // The super constructor calls this method
        // before fc is initialized; we want to ignore that
        if (fc != null) {
            fc.setPath(path0);
            params = null;
        }
    }

    /**
     * {@inheritDoc}
     */
    public void setRedirect(boolean redirect0) {
        // The super constructor calls this method
        // before fc is initialized; we want to ignore that
        if (fc != null) {
            fc.setRedirect(redirect0);
        }
    }

    /**
     * {@inheritDoc}
     */
    public String toString() {
        return fc.toString();
    }

    /**
     * Return the parameter <code>pname</code> from the path of this forward
     * @param pname the name of the parameter to get
     * @return the value of the parameter <code>pname</code>, or
     * <code>null</code> if there is no such parameter
     */
    public Long getLongParam(String pname) {
        String v = getParam(pname);
        return (v == null) ? null : Long.valueOf(v);
    }

    /**
     * Return the parameter <code>pname</code> from the path of this forward
     * @param pname the name of the parameter to get
     * @return the value of the parameter <code>pname</code>, or
     * <code>null</code> if there is no such parameter
     */
    public String getParam(String pname) {
        if (params == null) {
            populateParams();
        }
        return (String) params.get(pname);
    }

    private void populateParams() {
        params = new HashMap();
        int index = getPath().indexOf('?');
        if (index == -1) {
            return;
        }
        // This is a little simplistic since it will get fooled if
        // the query string contains &amp; entities
        String query = getPath().substring(index + 1);
        String[] nv = StringUtils.split(query, '&');
        for (int i = 0; i < nv.length; i++) {
            String[] param = StringUtils.split(nv[i], '=');
            params.put(param[0], param[1]);
        }
    }

}
