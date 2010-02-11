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
package com.redhat.rhn.domain.server;

import com.redhat.rhn.domain.BaseDomainHelper;
import com.redhat.rhn.domain.user.User;

import org.apache.commons.lang.builder.EqualsBuilder;
import org.apache.commons.lang.builder.HashCodeBuilder;

/**
 * Note
 * @version $Rev$
 */
public class Note extends BaseDomainHelper {

    private Long id;
    private String subject;
    private String note;
    private User creator;
    private Server server;
    
    
    /**
     * @return Returns the creator.
     */
    public User getCreator() {
        return creator;
    }
    
    /**
     * @param c The creator to set.
     */
    public void setCreator(User c) {
        this.creator = c;
    }
    
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
     * @return Returns the note.
     */
    public String getNote() {
        return note;
    }
    
    /**
     * @param n The note to set.
     */
    public void setNote(String n) {
        this.note = n;
    }
    
    /**
     * @return Returns the server.
     */
    public Server getServer() {
        return server;
    }
    
    /**
     * @param s The server to set.
     */
    public void setServer(Server s) {
        this.server = s;
    }
    
    /**
     * @return Returns the subject.
     */
    public String getSubject() {
        return subject;
    }
    
    /**
     * @param s The subject to set.
     */
    public void setSubject(String s) {
        this.subject = s;
    }
    
    /**
     * {@inheritDoc}
     */
    public boolean equals(final Object other) {
        if (!(other instanceof Note)) {
            return false;
        }
        Note castOther = (Note) other;
        return new EqualsBuilder().append(id, castOther.id)
                                  .append(subject, castOther.subject)
                                  .append(note, castOther.note)
                                  .append(creator, castOther.creator)
                                  .append(server, castOther.server)
                                  .append(getCreated(), castOther.getCreated())
                                  .append(getModified(), castOther.getModified())
                                  .isEquals();
    }
    
    /**
     * {@inheritDoc}
     */
    public int hashCode() {
        return new HashCodeBuilder().append(id)
                                    .append(subject)
                                    .append(note)
                                    .append(creator)
                                    .append(server)
                                    .append(getCreated())
                                    .append(getModified())
                                    .toHashCode();
    }
}
