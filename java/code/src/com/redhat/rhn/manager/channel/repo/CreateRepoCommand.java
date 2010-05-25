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
public class CreateRepoCommand {

    private String label;
    private String url;
    private Org org;
    private ContentSource newRepo;
    private List<ValidatorError> errors;

    /**
     * Constructor to create an org
     * @param nameIn to set on the org
     * @param loginIn to use for 1st user in org
     * @param passwordIn to set for first user
     * @param emailIn to set for first user
     */
    public CreateRepoCommand(String labelIn, String urlIn, Org orgIn) {
        this.label = labelIn;
        this.url = urlIn;
        this.org = orgIn;
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
     * @param org to set for repo
     */
    public void setOrg(Org org) {
        this.org = org;
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
    public void setLabel(String LabelIn) {
        this.label = LabelIn;
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
        ValidatorError[] errors = validate();
        if (errors != null && errors.length > 0) {
            return errors;
        }
        else {
            // Create repo
            ContentSource repo = ChannelFactory.createRepo();
            repo.setLabel(this.label);
            repo.setSourceUrl(this.url);
            repo.setOrg(this.org);
            repo.setType(ChannelFactory.CONTENT_SOURCE_TYPE_YUM);
            ChannelFactory.save(repo);
            this.newRepo = repo;
        }
        return null;
    }

    /**
     * Get the newly created org.
     * @return Org that was stored to DB
     */
    public ContentSource getNewRepo() {
        return this.newRepo;
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
