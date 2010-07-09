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
package com.redhat.rhn.frontend.dto;

import java.util.ArrayList;
import java.util.List;

/**
 * ISOSet - structure for holding info about all ISOs for a given entity
 * This is used for two kinds of ISOs, installation-ISOs and Spacewalk Content ISOs.
 * Installation ISOs can be divided into binary and source ISOs.  Content ISOs can
 * be divided into Base and Incremental.  The division is done heuristically, based on
 * three rules: 1) if "-source-" appears in the download--path, this must be a source ISO
 * else it is binary;  2) If "(Base" appears in the category this is a Base content ISO;
 * 3) If "(Incremental" appears in the category this is an Incremental Content ISO.
 *
 * A given ISOSet will be either src/binary OR base/incr, never both.  This code takes
 * advantage of that context, knowing that the caller will "know" what kind of ISOSet
 * they're dealing with.
 *
 * If any of these assumptions changes, this code will break.  Ultimately, it would be
 * optimal if the DB content flagged ISOImages as one kind or another.
 *
 * @version $Rev$
 */
public class ISOSet {

    private static final String SRC = "-source-";

    private List binaries = new ArrayList();
    private List sources = new ArrayList();
    private String category = null;

    /**
     * get dl category all images in set belong to
     * @return category name
     */
    public String getCategory() {
        return category;
    }

    /**
     * Get List<ISOImage> of the non-source-discs in this set
     * @return List<ISOImage>
     */
    public List getBinaries() {
        return binaries;
    }

    /**
     * Set the List that contains the binary-discs for this Set
     * @param newBin new binaries-list
     */
    public void setBinaries(List newBin) {
        binaries = newBin;
    }

    /**
     * Get List<ISOImage> of all images whose path contains "-source-"
     * @return List<ISOImage> of source imgs
     */
    public List getSources() {
        return sources;
    }

    /**
     * Set the List that contains the source-discs for this Set
     * @param newSrcs new source-list
     */
    public void setSources(List newSrcs) {
        sources = newSrcs;
    }

    /**
     * Add a new image to the "right" (binaries or source) list
     * @param img ISOImage to add to a list
     * @throws Error if the image belons to a different Category than the one the Set
     * defines
     */
    public void add(ISOImage img) {
        if (getCategory() == null) {
            category = img.getCategory();
        }
        else if (!getCategory().equals(img.getCategory())) {
            throw new Error("NEW IMG DOESN'T MATCH THE SET!!");
        }

        if (img.getDownloadPath().indexOf(SRC) >= 0) {
            getSources().add(img);
        }
        else {
            getBinaries().add(img);
        }
    }
}
