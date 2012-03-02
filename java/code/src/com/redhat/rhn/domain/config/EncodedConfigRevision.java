/**
 * Copyright (c) 2011--2012 Red Hat, Inc.
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
package com.redhat.rhn.domain.config;


/**
 * empty class, just to distinguish
 * when to return base64 encoded content
 * in the ConfigRevisionSerializer
 * EncodedConfigRevision
 * @version $Rev$
 */
public class EncodedConfigRevision extends ConfigRevision {

    /**
     * construct object from ConfigRevision
     * @param cr config revision
     */
    public EncodedConfigRevision(ConfigRevision cr) {
        id = cr.getId();
        revision = cr.getRevision();
        configFile = cr.getConfigFile();
        configContent = cr.getConfigContent();
        configInfo = cr.getConfigInfo();
        configFileType = cr.getConfigFileType();
        changedById = cr.getChangedById();
    }
}
