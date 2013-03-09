/**
 * Copyright (c) 2013 Red Hat, Inc.
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
package com.redhat.rhn.domain.server;

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.domain.BaseDomainHelper;
import com.redhat.rhn.domain.user.User;

import org.apache.commons.lang.StringUtils;


/**
 * CrashNote
 * @version $Rev$
 */
public class CrashNote extends BaseDomainHelper {

    private Long id;
    private String subject;
    private String note;
    private User creator;
    private Crash crash;


    /**
     * Default Constructor
     */
    public CrashNote() {
    }

    /**
     * Constructor
     * @param crashIn associated crash
     */
    public CrashNote(Crash crashIn) {
        crash = crashIn;
    }

    /**
     * @return Returns the id.
     */
    public Long getId() {
        return id;
    }

    /**
     * @param idIn The id to set.
     */
    public void setId(Long idIn) {
        id = idIn;
    }

    /**
     * @return Returns the subject.
     */
    public String getSubject() {
        return subject;
    }

    /**
     * @param subjectIn The subject to set.
     */
    public void setSubject(String subjectIn) {
        subject = subjectIn;
    }

    /**
     * @return Returns the note.
     */
    public String getNote() {
        return note;
    }

    /**
     * @param noteIn The note to set.
     */
    public void setNote(String noteIn) {
        if (StringUtils.isEmpty(noteIn)) {
            note = null;
        }
        else {
            note = noteIn;
        }
    }

    /**
     * @return Returns the creator.
     */
    public User getCreator() {
        return creator;
    }

    /**
     * @param creatorIn The creator to set.
     */
    public void setCreator(User creatorIn) {
        creator = creatorIn;
    }

    /**
     * @return Returns the crash.
     */
    public Crash getCrash() {
        return crash;
    }

    /**
     * @param crashIn The crash to set.
     */
    public void setCrash(Crash crashIn) {
        crash = crashIn;
    }

    /**
     * @return Returns printable modified date.
     *
     */
    public String getModifiedString() {
        return LocalizationService.getInstance().formatDate(getModified());
    }
}
