/**
 * Copyright (c) 2013 SUSE LLC
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

import com.redhat.rhn.common.localization.LocalizationService;

/**
 * Dto for SSM server-operation data pairs.
 * @author Silvio Moioli <smoioli@suse.de>
 */
public class ServerOperationDataDto {

    /** The server id. */
    private long id;

    /** The server name. */
    private String name;

    /** The operation note. */
    private String note;

    /**
     * Instantiates a new server operation data dto.
     */
    public ServerOperationDataDto() {
        super();
    }

    /**
     * Gets the note, translated.
     * @return the note
     */
    public String getTranslatedNote() {
        LocalizationService ls = LocalizationService.getInstance();
        if (ls.hasMessage(note)) {
            return ls.getMessage(note);
        }
        return note;
    }

    /**
     * Gets the server id.
     * @return the id
     */
    public long getId() {
        return id;
    }

    /**
     * Sets the server id.
     * @param idIn the new id
     */
    public void setId(long idIn) {
        id = idIn;
    }

    /**
     * Gets the server name.
     * @return the name
     */
    public String getName() {
        return name;
    }

    /**
     * Sets the server name.
     * @param nameIn the new name
     */
    public void setName(String nameIn) {
        name = nameIn;
    }

    /**
     * Gets the operation note.
     * @return the note
     */
    public String getNote() {
        return note;
    }

    /**
     * Sets the operation note.
     * @param noteIn the new note
     */
    public void setNote(String noteIn) {
        note = noteIn;
    }
}
