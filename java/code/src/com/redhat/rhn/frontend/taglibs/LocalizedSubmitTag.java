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
package com.redhat.rhn.frontend.taglibs;

import com.redhat.rhn.common.localization.LocalizationService;

import org.apache.struts.taglib.html.SubmitTag;

import javax.servlet.jsp.JspException;

/**
 * HTML Submit tag that supports localization of the value
 * @version $Rev: 1036 $
 */
public class LocalizedSubmitTag extends SubmitTag {

    private String valueKey;

    /**
     * Set the valueKey for the tag.  Used to
     * lookup the localized message for this tag
     * @param key Value key used to lookup the localized message.
     */
    public void setValueKey(String key) {
        this.valueKey = key;
    }

    /**
     * Get the valueKey for this tag
     * @return the value key for this tag.
     */
    public String getValueKey() {
        return this.valueKey;
    }

    /** {@inheritDoc}
     * @throws JspException
     */
    public int doStartTag() throws JspException {
        this.setValue(LocalizationService.getInstance().getMessage(getValueKey()));
        super.doStartTag();
        return (SKIP_BODY);
    }

    /**
     * {@inheritDoc}
     */
    public void release() {
        valueKey = null;
        super.release();
    }
}

