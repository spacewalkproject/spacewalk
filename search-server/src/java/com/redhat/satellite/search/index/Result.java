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

package com.redhat.satellite.search.index;


/**
 * PackageResult
 * @version $Rev$
 */
public class Result {
    private int rank;
    private String id;
    private String name;
    private float score;

    
    /**
     * Constructor
     */
    public Result() {
        rank = -1;
        id = "";
        name = "";
        score = 0;
    }

    /**
     * Constructs a pre populated 
     * @param r rank
     * @param idIn package id
     * @param nameIn package name
     */
    public Result(int r, String idIn, String nameIn, float scoreIn) {
        rank = r;
        id = idIn;
        name = nameIn;
        score = scoreIn;
    }
    
    /**
     * Sets the rank
     * @param rankIn rank
     */
    public void setRank(int rankIn) {
        rank = rankIn;
    }
    /**
     * Returns the rank.
     * @return the rank.
     */
    public int getRank() {
        return rank;
    }

    /**
     * Sets the id
     * @param idIn id
     */
    public void setId(String idIn) {
        id = idIn;
    }

    /**
     * Returns the package id.
     * @return the package id.
     */
    public String getId() {
        return id;
    }
    
    /**
     * Sets the name
     * @param nameIn name
     */
    public void setName(String nameIn) {
        name = nameIn;
    }
    /**
     * Returns the package name.
     * @return the package name.
     */
    public String getName() {
        return name;
    }    

    /**
     * Sets the score from lucene
     * @param scoreIn score
     */
    public void setScore(float scoreIn) {
        score = scoreIn;
    }
    /**
     * Returns the score.
     * @return the score.
     */
    public float getScore() {
        return score;
    }

}
