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
package com.redhat.rhn.manager.kickstart;

import com.redhat.rhn.domain.common.CommonFactory;
import com.redhat.rhn.domain.common.FileList;
import com.redhat.rhn.domain.user.User;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Iterator;
import java.util.Set;

/**
 * KickstartFilePreservationListsCommand
 * @version $Rev$
 */
public class FilePreservationListsCommand extends BaseKickstartCommand {        
    
    /**
     * 
     * @param ksid Kickstart Id 
     * @param userIn Logged in User
     */
    public FilePreservationListsCommand(Long ksid, User userIn) {
        super(ksid, userIn);        
    }
    
    /** 
     * Removes file lists from the kickstart profile.
     * @param ids The ids of the file lists to remove.
    */
    public void removeFileListsByIds(ArrayList ids) {
        Iterator toRemoveIter = ids.iterator();

        while (toRemoveIter.hasNext()) {
            Long id = (Long) toRemoveIter.next();

            Iterator listsIter = this.getKickstartData().getPreserveFileLists().iterator();

            while (listsIter.hasNext()) {
                FileList list = (FileList) listsIter.next();


                if (list.getId() == id) {
                    listsIter.remove();
                }
            }
        }
    }

    /** 
     * Adds file lists to the kickstart profile.
     * @param ids The ids of the regtokens to add.
    */
    public void addFileListsByIds(ArrayList ids) {
        Iterator toAddIter = ids.iterator();

        while (toAddIter.hasNext()) {
            Long id = (Long) toAddIter.next();
            
            this.getKickstartData()
                .addPreserveFileList(CommonFactory.lookupFileList(id, this.user.getOrg()));
        }
    }

    /**
     * Get the PreservationList items associated with this profile
     * @return Set of PreservationList, or EMPTY_SET if not.
     */
    public Set getPreserveFileLists() {
        if (ksdata.getPreserveFileLists() != null) {
            return ksdata.getPreserveFileLists();
        }
        else {
            return Collections.EMPTY_SET;
        }
    }    

}
