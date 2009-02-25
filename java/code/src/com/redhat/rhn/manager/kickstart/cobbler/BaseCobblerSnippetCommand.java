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

import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.domain.kickstart.cobbler.CobblerSnippet;

import java.io.BufferedInputStream;
import java.io.BufferedWriter;
import java.io.DataInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileWriter;
import java.io.IOException;

/**
 * BaseCobblerSnippetCommand - base for edit/create CryptKeys
 * @version $Rev$
 */
public abstract class BaseCobblerSnippetCommand {

    public static final String SNIPDIR = "/var/lib/cobbler/snippets/";
    
    protected CobblerSnippet snippet;

    /**
     * Constructor
     */
    public BaseCobblerSnippetCommand() {
        this.snippet = new CobblerSnippet();
    }

    /**
     * get the name
     * @return name
     */
    public String getName() {
        return this.snippet.getName();
    }

    /**
     * Set the name
     * @param nameIn to set
     */
    public void setName(String nameIn) {
        this.snippet.setName(nameIn);
    }

    /**
     * Set the contents
     * @param contentsIn to set
     */
    public void setContents(String contentsIn) {
        this.snippet.setContents(contentsIn);
    }

    /**
     * Get the CobblerSnippet used by this cmd
     * @return CobblerSnippet instance
     */
    public CobblerSnippet getCobblerSnippet() {
        return snippet;
    }

    /**
     * Save the Snippet to the filesystem.
     * @return ValidatorError if we failed to store
     */
    public ValidatorError store() { 
        try {
            File f = new File(SNIPDIR + this.snippet.getName());
            FileWriter fstream = new FileWriter(SNIPDIR + this.snippet.getName());
            BufferedWriter out = new BufferedWriter(fstream);
            out.write(this.snippet.getContents());
            out.close();
        }
        catch (Exception e) {
            System.err.println("Couldn't write snippet: " + e.getMessage());
            throw new RuntimeException(e);
        }
        return null;
    }
    
    /**
     * Read the contents of the snippet
     *
     * @return string contents of the snippet
     */
    public String getContents() {
        if (this.snippet.getName().equals(null)) {
            return "";
        }
        File f = new File(SNIPDIR + this.snippet.getName());
        BufferedInputStream bis = null;
        DataInputStream dis = null;
        FileInputStream fis = null;

        String contents = new String();

        try {
            fis = new FileInputStream(f);
            bis = new BufferedInputStream(fis);
            dis = new DataInputStream(bis);

            while (dis.available() != 0) {
                contents = contents + dis.readLine() + "\n";
            }

            dis.close();
            bis.close();
            fis.close();
        }
        catch (FileNotFoundException e) {
            e.printStackTrace();
        }
        catch (IOException e) {
            e.printStackTrace();
        }
        return contents;
    }

}
