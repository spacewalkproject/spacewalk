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

import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.common.validator.ValidatorResult;
import com.redhat.rhn.domain.config.ConfigFileType;
import com.redhat.rhn.domain.config.ConfigRevision;
import com.redhat.rhn.manager.configuration.ConfigurationValidation;

import org.apache.commons.lang.StringUtils;
import org.apache.commons.lang.builder.ToStringBuilder;

import java.io.ByteArrayInputStream;
import java.io.InputStream;


/**
 * TestFileData
 * @version $Rev$
 */
public class TextFileData extends ConfigFileData {
    private String contents;
    /**
     *
     * @param data the contents to set
     */
    public TextFileData(String data) {
        super();
        setType(ConfigFileType.file());
        setContents(data);
    }

    /**
     *
     */
    public TextFileData() {
        super();
    }

    /**
     * @return the contents
     */
    public String getContents() {
        return contents;
    }


    /**
     * @param data the contents to set
     */
    public void setContents(String data) {
        this.contents = data;
    }

    /**
     *
     * {@inheritDoc}
     */
    @Override
    public long getContentSize() {
        return StringUtils.isBlank(getContents()) ? 0 :
                            getContents().getBytes().length;
    }

    /**
     *
     * {@inheritDoc}
     */
    @Override
    public InputStream getContentStream() {
        if (getContents() != null) {
            // Note we didn;t do getContents().getBytes("UTF-8")
            // becasue linux config files are not utf8..
            // So default platform encoding should be ok...
            return new ByteArrayInputStream(getContents().getBytes());
        }
        return new ByteArrayInputStream(new byte[0]);
    }


    /**
     *
     * {@inheritDoc}
     */

    public boolean isBinary() {
        return false;
    }


    /**
     *
     * {@inheritDoc}
     */
    @Override
    protected void validateContents(ValidatorResult result, boolean onCreate) {
        String content = getContents();
        // Validate size
        if (content != null && content.length() > MAX_FILE_SIZE) {
            result.addError(new ValidatorError("error.configtoolarge", MAX_FILE_SIZE));
        }

        // Validate contents (only if everything else has passed)
        if (result.isEmpty()) { // No errors yet!
            result.append(ConfigurationValidation.validateContent(
                    content, getMacroStart(), getMacroEnd()));
        }
    }

    /**
     *
     * {@inheritDoc}
     */
    @Override
    protected void copyRevisedContentFrom(ConfigRevision rev) {
       setContents(rev.getConfigContent().getContentsString());
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public String toString() {
        ToStringBuilder builder = new ToStringBuilder(this);
        builder.append("ConfigFileData", super.toString()).
                        append("Size", getContentSize()).
                        append("Contents", getContents());
        return builder.toString();
    }
}
