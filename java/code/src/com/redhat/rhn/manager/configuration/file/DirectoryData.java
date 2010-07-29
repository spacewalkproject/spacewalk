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
package com.redhat.rhn.manager.configuration.file;

import com.redhat.rhn.common.validator.ValidatorResult;
import com.redhat.rhn.domain.config.ConfigFileType;
import com.redhat.rhn.domain.config.ConfigRevision;

import java.io.ByteArrayInputStream;
import java.io.InputStream;


/**
 * DirectoryData
 * @version $Rev$
 */
public class DirectoryData extends ConfigFileData {
    /**
     * Constructor
     */
    public DirectoryData() {
        super();
        setType(ConfigFileType.dir());
    }

    /**
     *
     * {@inheritDoc}
     */
    @Override
    public ConfigFileType getType() {
        return ConfigFileType.dir();
    }
    /**
     * {@inheritDoc}
     */
    @Override
    public long getContentSize() {
        return 0;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public InputStream getContentStream() {
        return new ByteArrayInputStream(new byte[0]);
    }

    /**
     * {@inheritDoc}
     */
    @Override
    protected void validateContents(ValidatorResult result, boolean onCreate) {
        //NO OP
    }

    /**
     *
     * {@inheritDoc}
     */
    @Override
    public void processRevisedContentFrom(ConfigRevision current) {
        // NO -OP because directory has NO content!
    }
}
