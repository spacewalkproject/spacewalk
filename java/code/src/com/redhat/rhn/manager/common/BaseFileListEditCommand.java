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
import com.redhat.rhn.domain.common.FileList;
import com.redhat.rhn.domain.config.ConfigFileName;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.manager.BasePersistOperation;

import org.apache.commons.lang.StringUtils;

import java.util.Iterator;

/**
 * BaseFileListEditCommand - baseclass for editing a FileList class. 
 * @version $Rev$
 */
public abstract class BaseFileListEditCommand extends BasePersistOperation {
    
    protected User user;
    protected FileList list;
    protected String newLabel;

    /**
     * Construct a command with a User. 
     * @param userIn to use.
     */    
    public BaseFileListEditCommand(User userIn) {
        super();
        this.user = userIn;
    }


    /**
     * @return Returns the user.
     */
    public User getUser() {
        return user;
    }

    /**
     * Get the Filelist
     * @return FileList for this CMD
     */
    public FileList getFileList() {
        return this.list;
    }
    
    /**
     * Set the label on the list. 
     * @param labelIn to set.
     */
    public void setLabel(String labelIn) {
        this.newLabel = labelIn;
    }

    /**
     * Store the FileList.
     *
     * @return ValidatorError[] if there were errors before the save.
     */ 
    public abstract ValidatorError store();

    /**
     * Parse the incoming list of files by newline.  
     *   
     * @param listIn to parse
     */
    public void updateFiles(String listIn) {
        this.list.getFileNames().clear();                
        String[] files = StringUtils.split(listIn, "\n");
        for (int i = 0; i < files.length; i++) {
            String cleanFile = files[i].trim();
            if (cleanFile != null && !cleanFile.equals("")) {
                this.list.addFileName(files[i].trim());
            }
        }        
    }

    /**
     * Convert the list of file names into a single String with \n 
     * at the end of each name.  Useful for display purposes:
     * 
     *  /tmp/file1.txt
     *  /tmp/file2.txt
     *  /tmp/file3.txt
     *  
     *  becomes:
     *  /tmp/file1.txt\n/tmp/file2.txt\n/tmp/file3.txt
     * @return String of file names
     */
    public String getFileListString() {
        if (this.list.getFileNames() == null) {
            return "";  /**return null*/
        }
        StringBuffer names = new StringBuffer();
        Iterator i = this.list.getFileNames().iterator();
        while (i.hasNext()) {
            ConfigFileName cfn = (ConfigFileName) i.next();
            names.append(cfn.getPath());
           
            if (i.hasNext()) {
                names.append("\n");
            }
        }
        
        return names.toString();
    }

}
