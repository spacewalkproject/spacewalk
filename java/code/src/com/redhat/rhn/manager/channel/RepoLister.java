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
package com.redhat.rhn.manager.channel;

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
public class RepoLister extends BaseManager {

    /**
     * Logger for this class
     */
    private static final Logger LOG = Logger.getLogger(RepoLister.class);
    private static final RepoLister INSTANCE = new RepoLister();
    /**
     * Default constructor
     */
    public RepoLister() {

    }

    /**
     * Get the instance of the RepoLister
     * @return CobblerSnippetLister instance
     */
    public static RepoLister getInstance() {
        return INSTANCE;
    }

    private void loadDefaultSnippets(File path, 
                    List<CobblerSnippet> snippetFiles) {
        if (path.exists() && !path.isHidden()) {
            final String spacewalkSnippetsDir = CobblerSnippet.
                        getSpacewalkSnippetsDir().getAbsolutePath();
            if (!path.getAbsolutePath().startsWith(spacewalkSnippetsDir)) {
                if (path.isDirectory()) {
                    String[] children = path.list();
                    Arrays.sort(children);
                    for (int i = 0; i < children.length; i++) {
                        loadDefaultSnippets(new File(path, children[i]), snippetFiles);
                    }
                }
                else {
                    snippetFiles.add(CobblerSnippet.loadReadOnly(path));    
                }
            }
        }
    }
    
    private void loadSnippetsInSpacewalkDir(List<CobblerSnippet> snippetFiles) {
        for (File path : CobblerSnippet.getSpacewalkSnippetsDir().listFiles()) {
            if (path.isFile() && !path.isHidden()) {
                snippetFiles.add(CobblerSnippet.loadReadOnly(path));
            }
        }
        
    }
    
    /**
     * Returns a list of snippets accessible to this user
     * @param user the user has to be atleast a 
     * config admin to be able to access snippets.
     * @param common true if we want the common snippets
     *                   i.e ones in /var/lib/cobbler/snippets minus spacewalk
     *                   false if want the  editable snippets
     *                   i.e ones in /var/lib/cobbler/snippets/spacewalk
     * @return the snippets accessible to the user.
     */
    private List<CobblerSnippet> listSnippets(User user, boolean common) {
        if (!user.hasRole(RoleFactory.CONFIG_ADMIN)) {
            throw new PermissionException(RoleFactory.CONFIG_ADMIN);
        }
        
        if (common) {
            List<CobblerSnippet> snippetFiles = new LinkedList<CobblerSnippet>();
            loadDefaultSnippets(CobblerSnippet.getCobblerSnippetsDir(),
                                                                snippetFiles);
            loadSnippetsInSpacewalkDir(snippetFiles);
            return snippetFiles;
        }

        List<CobblerSnippet> snippetFiles = new LinkedList<CobblerSnippet>();
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

    /**
     * Returns a list of default snippets accessible to this user
     * i.e ones in /var/lib/cobbler/snippets minus spacewalk
     * @param user the user has to be atleast a 
     * config admin to be able to access snippets.
     * @return the snippets accessible to the user.
     */
    public List<CobblerSnippet> listDefault(User user) {
        return listSnippets(user, true);
    }


    /**
     * Returns a list of custom snippets accessible to this user
     * i.e ones in /var/lib/cobbler/snippets/spacewalk
     * @param user the user has to be atleast a 
     * config admin to be able to access snippets.
     * @return the snippets accessible to the user.
     */    
    public List<CobblerSnippet> listCustom(User user) {
        return listSnippets(user, false);
    }
    
    /**
     * Returns a list of snippets accessible to this user
     * @param user the user has to be atleast a 
     * config admin to be able to access snippets.
     * @return the snippets accessible to the user.
     */
    public List<CobblerSnippet> list(User user) {
        List <CobblerSnippet> snip = new LinkedList<CobblerSnippet>(listDefault(user));
        snip.addAll(listCustom(user));
        return snip;
    }
}
