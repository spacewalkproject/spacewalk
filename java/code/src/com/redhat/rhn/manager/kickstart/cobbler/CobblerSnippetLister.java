/**
 * Copyright (c) 2008 Red Hat, Inc.
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

import com.redhat.rhn.domain.kickstart.cobbler.CobblerSnippet;
import com.redhat.rhn.manager.BaseManager;

import org.apache.log4j.Logger;

import java.io.File;
import java.util.Arrays;
import java.util.ArrayList;
import java.util.List;

/**
 * CobblerSnippetLister
 * @version $Rev$
 */
public class CobblerSnippetLister extends BaseManager {

    /**
     * Logger for this class
     */
    private static Logger logger = Logger.getLogger(CobblerSnippetLister.class);

    private static CobblerSnippetLister instance = new CobblerSnippetLister();
    private static String globalSnippetDir = "/var/lib/cobbler/snippets";

    private List<CobblerSnippet> snippetFiles = new ArrayList<CobblerSnippet>();

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
        return instance;
    }

    private void recurseDirectory(File path) {
        CobblerSnippet snippy = new CobblerSnippet();
        if (path.isDirectory() && !path.isHidden()) {
            String[] children = path.list();
            Arrays.sort(children);
            for (int i = 0; i < children.length; i++) {
                recurseDirectory(new File(path, children[i]));
            }
        }
        else {
            if (!path.isHidden()) {
                snippy.setName(path.toString().substring(26));
                snippy.setContents(null);
                snippetFiles.add(snippy);
            }
        }
    }

    /**
     * Get the list of snippets 
     * List
     * @return List of snippets
     */
    public List listSnippets() {
        String processPath = globalSnippetDir;
        File f = new File(processPath);

        snippetFiles.clear();
        recurseDirectory(f);

        return snippetFiles;
    }

}
