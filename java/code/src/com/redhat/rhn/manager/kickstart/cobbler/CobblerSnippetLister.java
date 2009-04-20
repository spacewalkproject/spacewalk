/**
 * Copyright (c) 2009 Red Hat, Inc.
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
package com.redhat.rhn.manager.kickstart.cobbler;

import com.redhat.rhn.common.security.PermissionException;
import com.redhat.rhn.domain.kickstart.cobbler.CobblerSnippet;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.manager.BaseManager;

import org.apache.log4j.Logger;

import java.io.File;
import java.util.Arrays;
import java.util.LinkedList;
import java.util.List;

/**
 * CobblerSnippetLister
 * @version $Rev$
 */
public class CobblerSnippetLister extends BaseManager {

    /**
     * Logger for this class
     */
    private static final Logger LOG = Logger.getLogger(CobblerSnippetLister.class);
    private static final CobblerSnippetLister INSTANCE = new CobblerSnippetLister();
    /**
     * Default constructor
     */
    public CobblerSnippetLister() {

    }

    /**
     * Get the instance of the CobblerSnippetLister
     * @return CobblerSnippetLister instance
     */
    public static CobblerSnippetLister getInstance() {
        return INSTANCE;
    }

    private void loadReadOnlySnippets(File path, 
                    List<CobblerSnippet> snippetFiles) {
        if (path.exists() && !path.isHidden()) {
            final String spacewalkSnippetsDir = CobblerSnippet.getSpacewalkSnippetsDir();
            if (!path.getAbsolutePath().startsWith(spacewalkSnippetsDir)) {
                if (path.isDirectory()) {
                    String[] children = path.list();
                    Arrays.sort(children);
                    for (int i = 0; i < children.length; i++) {
                        loadReadOnlySnippets(new File(path, children[i]), snippetFiles);
                    }
                }
                else {
                    snippetFiles.add(CobblerSnippet.loadReadOnly(path));    
                }
            }
        }
    }
    /**
     * Returns a list of snippets accessible to this user
     * @param user the user has to be atleast a 
     * config admin to be able to access snippets. 
     * @return the snippets accessible to the user.
     */
    public List<CobblerSnippet> listSnippets(User user) {
        if (!user.hasRole(RoleFactory.CONFIG_ADMIN)) {
            throw new PermissionException(RoleFactory.CONFIG_ADMIN);
        }
        
        List<CobblerSnippet> snippetFiles = new LinkedList<CobblerSnippet>();
        loadReadOnlySnippets(new File(CobblerSnippet.getCobblerSnippetsDir()),
                                                            snippetFiles);
        File spacewalkDir = new File(CobblerSnippet.getPrefixFor(user.getOrg()));
        
        if (spacewalkDir.exists() && spacewalkDir.isDirectory()) {
            for (File file : spacewalkDir.listFiles()) {
                if (!file.isHidden() && file.isFile()) {
                    snippetFiles.add(CobblerSnippet.loadEditable(file.getName(),
                                                            user.getOrg()));
                }
            }
        }
        return snippetFiles;
    }

}
