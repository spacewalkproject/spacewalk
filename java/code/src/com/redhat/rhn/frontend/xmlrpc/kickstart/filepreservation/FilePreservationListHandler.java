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
package com.redhat.rhn.frontend.xmlrpc.kickstart.filepreservation;

import com.redhat.rhn.FaultException;
import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.common.CommonFactory;
import com.redhat.rhn.domain.common.FileList;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.xmlrpc.BaseHandler;
import com.redhat.rhn.frontend.xmlrpc.FileListAlreadyExistsException;
import com.redhat.rhn.frontend.xmlrpc.NoSuchUserException;
import com.redhat.rhn.manager.common.CreateFileListCommand;
import com.redhat.rhn.manager.kickstart.KickstartLister;

import java.util.List;

/**
 * @xmlrpc.namespace kickstart.filepreservation
 * @xmlrpc.doc Provides methods to retrieve and manipulate kickstart file
 * preservation lists.
 *
 * @version $Revision$
 */
public class FilePreservationListHandler extends BaseHandler {

    /**
     * Lists all file preservation lists associated with the org of the user
     * (identified by the session key).
     *
     * @param sessionKey identifies the user that is logged in and performing the call
     * @throws FaultException A FaultException is thrown if:
     *   - The sessionKey is invalid
     * @return a list of maps containing the file preservation lists
     *
     * @xmlrpc.doc List all file preservation lists for the organization
     * associated with the user logged into the given session
     * @xmlrpc.param #session_key()
     * @xmlrpc.returntype
     *      #array()
     *        $FilePreservationDtoSerializer
     *      #array_end()
     */
    public List listAllFilePreservations(String sessionKey)
        throws FaultException {

        User loggedInUser = getLoggedInUser(sessionKey);

        if (loggedInUser == null) {
            throw new NoSuchUserException();
        }

        Org org = loggedInUser.getOrg();
        KickstartLister lister = KickstartLister.getInstance();

        DataResult dataResult = lister.preservationListsInOrg(org, null);
        return dataResult;
    }

    /**
     * Creates a new file preservation list.
     *
     * @param sessionKey identifies the user that is logged in and performing the call
     * @param name  name of the file list to create
     * @param files list of file names to include
     * @return 1 if the creation was successful
     * @throws FaultException A FaultException is thrown if:
     *   - The sessionKey is invalid
     *   - The name already exists
     *
     * @xmlrpc.doc Create a new file preservation list.
     * @xmlrpc.param #param("string", "session_key")
     * @xmlrpc.param #param_desc("string", "name", "name of the file list to create")
     * @xmlrpc.param #array_single("string", "name - file names to include")
     * @xmlrpc.returntype #return_int_success()
     */
    public int create(String sessionKey, String name, List<String> files)
        throws FaultException {

        User loggedInUser = getLoggedInUser(sessionKey);
        if (loggedInUser == null) {
            throw new NoSuchUserException();
        }

        if (CommonFactory.lookupFileList(name, loggedInUser.getOrg()) != null) {
            // file list already exists...
            throw new FileListAlreadyExistsException(name);
        }

        CreateFileListCommand command = new CreateFileListCommand(loggedInUser);
        command.setLabel(name);
        for (String file : files) {
            command.getFileList().addFileName(file);
        }
        command.store();

        return 1;
    }

    /**
     * Delete a file preservation list.
     *
     * @param sessionKey identifies the user that is logged in and performing the call
     * @param name  name of the file list to delee
     * @return 1 if the creation was successful
     * @throws FaultException A FaultException is thrown if:
     *   - The sessionKey is invalid
     *   - The name already exists
     *
     * @xmlrpc.doc Delete a file preservation list.
     * @xmlrpc.param #param("string", "session_key")
     * @xmlrpc.param #param_desc("string", "name", "name of the file list to delete")
     * @xmlrpc.returntype #return_int_success()
     */
    public int delete(String sessionKey, String name)
        throws FaultException {

        User loggedInUser = getLoggedInUser(sessionKey);
        if (loggedInUser == null) {
            throw new NoSuchUserException();
        }

        FileList fileList = CommonFactory.lookupFileList(name, loggedInUser.getOrg());
        if (fileList != null) {
            CommonFactory.removeFileList(fileList);
        }
        return 1;
    }

    /**
     * Returns all of the data associated with the given file preservation list.
     *
     * @param sessionKey  identifies the user that is logged in and performing the call
     * @param name identifies the file preservation list
     * @throws FaultException A FaultException is thrown if:
     *   - The sessionKey is invalid
     * @return holder object containing the data associated with the list
     *
     * @xmlrpc.doc Returns all of the data associated with the given file preservation
     * list.
     * @xmlrpc.param #param("string", "session_key")
     * @xmlrpc.param #param_desc("string", "name", "name of the file list to retrieve
     * details for")
     * @xmlrpc.returntype
     *     $FileListSerializer
     */
    public FileList getDetails(String sessionKey, String name)
        throws FaultException {

        User loggedInUser = getLoggedInUser(sessionKey);
        if (loggedInUser == null) {
            throw new NoSuchUserException();
        }

        return CommonFactory.lookupFileList(name, loggedInUser.getOrg());
    }
}
