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
package com.redhat.rhn.manager.common;

import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.domain.common.CommonFactory;
import com.redhat.rhn.domain.user.User;

/**
 * EditFileListCommand - Command for editing an existing FileList
 * @version $Rev$
 */
public class EditFileListCommand extends BaseFileListEditCommand {

    /**
     * Command for editing a FileList
     * @param userIn User who owns the FileList
     * @param listId of the FileList we want to edit.
     */
    public EditFileListCommand(User userIn, Long listId) {
        super(userIn);
        this.list = CommonFactory.lookupFileList(listId, userIn.getOrg());
    }
    
    /**
     * Store the FileList. Checks to make sure that the label doesn't already exist,
     * unless we are passing in the same label as the already existing file list, in
     * which case there isn't a problem. 
     *
     * @return ValidatorError[] if there were errors before the save.
     */ 
    public ValidatorError store() {
        if (list.getLabel() != null && list.getLabel().equals(this.newLabel)) {
            CommonFactory.saveFileList(this.list);
            return null;
        }
        else if (CommonFactory.lookupFileList(this.newLabel, user.getOrg()) == null) {
            list.setLabel(this.newLabel);
            CommonFactory.saveFileList(this.list);
            return null;
        }
        else {
            return new ValidatorError("preservation.key.labelexists");
        }
    }

}
