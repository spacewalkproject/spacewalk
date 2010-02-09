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

package com.redhat.rhn.common.util.manifestfactory.test;

import com.redhat.rhn.common.util.manifestfactory.ManifestFactoryBuilder;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * PrimitiveBuilder
 * @version $Rev$
 */

public class PrimitiveBuilder implements ManifestFactoryBuilder {
    public String getManifestFilename() {
        return "factory-manifest.xml";
    }

    public Object createObject(Map params) {
        String type = (String)params.get("type");
        if (type == null) {
            throw new NullPointerException("type is null");
        }

        if (type.equals("String")) {
            String ret = (String)params.get("value");
            return ret;
        }
        else if (type.equals("Integer")) {
            Integer ret = Integer.valueOf((String)params.get("value"));
            return ret;
        }
        else if (type.equals("List")) {
            String lenStr = (String)params.get("length");
            String containedType = (String)params.get("contained-type");

            int len = Integer.valueOf(lenStr).intValue();
            List ret = new ArrayList();
            for (int i = 0; i < len; i++) {
                try {
                    ret.add(Class.forName(containedType).newInstance());
                }
                catch (Exception e) {
                    throw new RuntimeException("Instantiation of " + containedType +
                                               "error", e);
                }
            }

            return ret;
        }
        else {
            throw new UnsupportedOperationException("Unknown type " + type);
        }
    }
}
