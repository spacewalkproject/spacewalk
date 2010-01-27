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

import org.apache.lucene.document.Document;


/**
 * DocResult
 * @version $Rev$
 */
public class DocResult extends Result {

    private String url = "";
    private String title = "";
    private String summary = "";

    /**
     * Constructor
     */
    public DocResult() {
        super();
    }

    /**
     * Constructs a result object
     * @param rankIn order of results returned from lucene
     * @param scoreIn score of this hit as defined by lucene query
     * @param doc lucene document containing data fields
     */
    public DocResult(int rankIn, float scoreIn, Document doc) {
        if (doc.getField("url") != null) {
            setUrl(doc.getField("url").stringValue());
            setId(doc.getField("url").stringValue());
        }
        if (doc.getField("title") != null) {
            setTitle(doc.getField("title").stringValue());
            setName(doc.getField("title").stringValue());
        }
        else {
            setTitle("EMPTY");
            setName("EMPTY");
        }
        setRank(rankIn);
        setScore(scoreIn);
    }

    /**
     * @return the url
     */
    public String getUrl() {
        return url;
    }

    /**
     * @param urlIn the url to set
     */
    public void setUrl(String urlIn) {
        if (urlIn.startsWith("file:")) {
            // Translate file:// to a usable URL
            String prefix = "/rhn/help";
            int index = urlIn.indexOf(prefix);
            if (index > 0) {
                urlIn = urlIn.substring(index);
            }
        }
        this.url = urlIn;
    }

    /**
     * @return the title
     */
    public String getTitle() {
        return title;
    }

    /**
     * @param titleIn the title to set
     */
    public void setTitle(String titleIn) {
        this.title = titleIn;
    }

    /**
     * @return the summary
     */
    public String getSummary() {
        return summary;
    }

    /**
     * @param summaryIn the summary to set
     */
    public void setSummary(String summaryIn) {
        this.summary = summaryIn;
    }

    /**
     * @return the string representation of this object
    **/
    public String toString() {
        return super.toString() + ", Title = " + getTitle()  + ", Url = " + getUrl() +
            ", Summary = " + getSummary();
    }

}
