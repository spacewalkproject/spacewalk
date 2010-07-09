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
package com.redhat.rhn.manager.channel.repo;

import java.util.ArrayList;
import java.util.List;

import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.domain.channel.ChannelFactory;
import com.redhat.rhn.domain.channel.ContentSource;
import com.redhat.rhn.domain.org.Org;

/**
 * CreateRepoCommand - Command to create a repo
 * @version $Rev: 119601 $
 */
public class BaseRepoCommand {

    protected ContentSource repo;

    private String label;
    private String url;
    private Org org;
    private List<ValidatorError> errors;

    /**
     * Constructor
     */
    BaseRepoCommand() {
    }

    /**
     *
     * @return Org of repo
     */
    public Org getOrg() {
        return org;
    }

    /**
     *
     * @param orgIn to set for repo
     */
    public void setOrg(Org orgIn) {
        this.org = orgIn;
    }

    /**
     *
     * @return label for repo
     */
    public String getLabel() {
        return label;
    }

    /**
     *
     * @param labelIn to set for repo
     */
    public void setLabel(String labelIn) {
        this.label = labelIn;
    }

    /**
     *
     * @return url for repo
     */
    public String getUrl() {
        return url;
    }

    /**
     *
     * @param urlIn to set for repo
     */
    public void setUrl(String urlIn) {
        this.url = urlIn;
    }

    /**
     * Check for errors and store Org to db.
     * @return ValidatorError[] array if there are errors
     */
    public ValidatorError[] store() {
        ValidatorError[] errorst = validate();
        if (errorst != null && errorst.length > 0) {
            return errorst;
        }
        else {
            // Create repo
            repo.setLabel(this.label);
            repo.setSourceUrl(this.url);
            repo.setType(ChannelFactory.CONTENT_SOURCE_TYPE_YUM);
            ChannelFactory.save(repo);
        }
        return null;
    }

    /**
     * Get the newly created org.
     * @return Org that was stored to DB
     */
    public ContentSource getNewRepo() {
        return this.repo;
    }

    /**
     * Validates the repo object.
     * @return an Object array of ValidatorErrors.
     */
    public ValidatorError[] validate() {
        errors = new ArrayList(); //clear validation errors
        return (ValidatorError[]) errors.toArray(new ValidatorError[0]);
    }


}
