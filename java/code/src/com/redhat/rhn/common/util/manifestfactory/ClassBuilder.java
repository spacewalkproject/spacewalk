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
package com.redhat.rhn.common.util.manifestfactory;

import com.redhat.rhn.common.ObjectCreateWrapperException;

import java.util.Map;

/**
 * ClassBuilder - a ManifestFactory builder which instantiates clases by name.
 * @version $Rev$
 */
public final class ClassBuilder implements ManifestFactoryBuilder {

    private String filename;
    
    /**
     * Instantiates objects by name for use by the ManifestFactory. Takes in
     * a filename of the manifest xml file which MUST BE in your classpath to
     * be found.
     * @param pkg Package name of Factory using this builder
     * @param fname manifest filename
     */
    public ClassBuilder(String pkg, String fname) {
        if (!fname.startsWith("/")) {
            fname = "/" + fname;
        }
        filename = packageAsPath(pkg) + fname;
    }
    
    /** {@inheritDoc} */
    public Object createObject(Map params) {
        String className = (String)params.get("classname");
        if (className == null) {
            throw new NullPointerException("classname is null");
        }

        try {
            return Class.forName(className).newInstance();
        }
        catch (Exception e) {
            throw new ObjectCreateWrapperException("Unable to create: " + 
                                                   className, e);
        }
    }

    /** {@inheritDoc} */
    public String getManifestFilename() {
        return filename;
    }
    
    private String packageAsPath(String pkg) {
        if (pkg == null) {
            return "";
        }
        
        // Start by translating into an absolute path.
        String name = pkg;
        if (!pkg.startsWith("/")) {
            name = "/" + name;
        }
        return name.replace('.', '/');
    }
}
