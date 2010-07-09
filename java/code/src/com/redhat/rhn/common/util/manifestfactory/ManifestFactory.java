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

import com.redhat.rhn.common.util.AttributeCopyRule;

import org.apache.commons.digester.Digester;

import java.net.URL;
import java.util.Collection;
import java.util.HashMap;
import java.util.Map;

/**
 * ManifestFactory, a generic factory system to load other factories
 * based on an xml manifest
 *
 * @version $Rev$
 */

public class ManifestFactory {
    private Map objects;
    private ManifestFactoryBuilder builder;

    /** public constructor, requires a builder
    * @param builderIn the ManifestFactoryBuilder used to create this Factory
    */
    public ManifestFactory(ManifestFactoryBuilder builderIn) {
        builder = builderIn;
        synchronized (this) {
            loadObjects();
        }
    }

    /** generally used by a wrapper static class, returns the object
     * stored inside this factory
     * @param key key to lookup Object by
     * @return Object found will throw ManifestFactoryLookupException if
     * not found.
     */
    public Object getObject(String key) {
        Object ret = objects.get(key);
        if (ret == null) {
            throw new ManifestFactoryLookupException("No object for " +
                                                    builder + " of name " +
                                                    key);
        }

        return ret;
    }

    /**
     * Get the list of keys from the factory
     * @return Collection the Collection of keys contained within this Factory
     */
    public Collection getKeys() {
        return objects.keySet();
    }

    private void loadObjects() {
        String filename = builder.getManifestFilename();
        URL u = builder.getClass().getResource(filename);

        objects = new HashMap();
        parseURL(u);
    }

    private void parseURL(URL u) {
        Digester d = new Digester();
        d.setValidating(false);

        d.push(this);
        d.addObjectCreate("factory/template", HashMap.class);
        d.addRule("factory/template", new AttributeCopyRule());
        d.addSetNext("factory/template", "addFactoryTemplate");

        try {
            d.parse(u.openStream());
        }
        catch (Exception e) {
            throw new ManifestFactoryParseException("Unable to parse " +
                                                    builder.getManifestFilename(), e);
        }
    }

    /** helper function for when Digesting an xml file.  sadly, must
     * be public or Digester freaks out, otherwise it would be private.
     * @param m used by Digester to build template
     */
    public void addFactoryTemplate(Map m) {
        String name = (String)m.get("name");
        if (name == null) {
            throw new NullPointerException("factory/template must have name attribute");
        }
        m.remove("name");

        objects.put(name, builder.createObject(m));
    }
}
