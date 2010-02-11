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
package com.redhat.rhn.frontend.action.user;

/**
 * Stores information about available languages
 * Used in the Locale Preferences page
 * 
 * @version $Rev $
 */
public class LangDisplayBean {
    
    private String languageCode;
    private String localizedName;
    private String imageUri;
    
    /**
     * Returns relative uri pointing to the 
     * language example image
     * @return string uri
     */
    public String getImageUri() {
        return imageUri;
    }
    
    /**
     * Sets the langauge example image uri
     * @param uri relative uri
     */
    public void setImageUri(String uri) {
        this.imageUri = uri;
    }
    
    /**
     * Returns lang code
     * @return string lang code
     */
    public String getLanguageCode() {
        return languageCode;
    }
    
    /**
     * Sets lang code
     * @param langCode lang code
     */
    public void setLanguageCode(String langCode) {
        this.languageCode = langCode;
    }
    
    /**
     * Returns localized name of language
     * @return string
     */
    public String getLocalizedName() {
        return localizedName;
    }
    
    /**
     * Sets localized name of lang
     * @param name localized name
     */
    public void setLocalizedName(String name) {
        this.localizedName = name;
    }
    
    
}
