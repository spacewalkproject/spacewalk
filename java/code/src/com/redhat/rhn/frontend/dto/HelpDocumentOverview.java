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
package com.redhat.rhn.frontend.dto;

/**
 * Simple Package DTO
 * @version $Rev: $
 */
public class HelpDocumentOverview {
    private String url;
    private String title;
    
    /**
     * Getter for document url
     * @return document url
     */
    public String getUrl() {
        return url;
    }

    /**
     * Setter for document url
     * @param urlIn the url of the document
     */
    public void setUrl(String urlIn) {
        this.url = urlIn;
    }
    
    /**
     * Getter for document title
     * @return document title
     */
    public String getTitle() {
        return title;
    }

    /**
     * Setter for document url
     * @param titleIn the title of the document 
     */
    public void setTitle(String titleIn) {
        this.title = titleIn;
    }
    
    
    
    
}
