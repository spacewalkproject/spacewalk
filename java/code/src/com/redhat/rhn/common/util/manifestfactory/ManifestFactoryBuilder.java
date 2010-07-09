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

import java.util.Map;

/**
 * ManifestFactoryBuilder, an interface describing a builder for the
 * factory
 * @version $Rev$
 */

public interface ManifestFactoryBuilder {
    /** ask the builder to create an object based upon the Map parameters
    * @param param Map of parameters to produce this Factory by
    * @return Object Object created by Factory
    */
    Object createObject(Map param);

    /** get the filename associated with this builder
     *   TODO: probably should be a URL instead
     *   TODO: probably going to need to generalize this a bit more, so that
     *         we can have different webapps with different manifest files
     * @return String filename used by manifest
    */
    String getManifestFilename();
}
