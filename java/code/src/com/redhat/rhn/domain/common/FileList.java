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
package com.redhat.rhn.domain.common;

import com.redhat.rhn.domain.BaseDomainHelper;
import com.redhat.rhn.domain.Identifiable;
import com.redhat.rhn.domain.config.ConfigFileName;
import com.redhat.rhn.domain.config.ConfigurationFactory;
import com.redhat.rhn.domain.org.Org;

import java.util.Collection;
import java.util.LinkedList;

/**
 * FileList
 * @version $Rev$
 */
public class FileList extends BaseDomainHelper implements Identifiable {

    private Long id;
    private String label;
    private Org org;
    private Collection fileNames;

    /**
     * @return Returns the id.
     */
    public Long getId() {
        return id;
    }

    /**
     * @param i The id to set.
     */
    public void setId(Long i) {
        this.id = i;
    }

    /**
     * @return Returns the label.
     */
    public String getLabel() {
        return label;
    }

    /**
     * @param l The label to set.
     */
    public void setLabel(String l) {
        this.label = l;
    }


    /**
     * @return Returns the org.
     */
    public Org getOrg() {
        return org;
    }


    /**
     * @param orgIn The org to set.
     */
    public void setOrg(Org orgIn) {
        this.org = orgIn;
    }


    /**
     * Add a filename to this list.
     * @param fileIn to add
     */
    public void addFileName(String fileIn) {
        if (this.fileNames == null) {
            this.fileNames = new LinkedList();
        }
        ConfigFileName cfn = ConfigurationFactory.lookupOrInsertConfigFileName(fileIn);
        cfn.setPath(fileIn);
        this.fileNames.add(cfn);
    }


    /**
     * Returns Set of ConfigFileName instances.
     * @return Returns the fileNames.
     */
    public Collection getFileNames() {
        if (this.fileNames == null) {
            this.fileNames = new LinkedList();
        }
        return fileNames;
    }


    /**
     * @param fileNamesIn The fileNames to set.
     */
    public void setFileNames(Collection fileNamesIn) {
        this.fileNames = fileNamesIn;
    }

}
