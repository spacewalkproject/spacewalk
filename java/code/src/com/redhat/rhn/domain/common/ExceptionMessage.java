/**
 * Copyright (c) 2010 Red Hat, Inc.
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
package  com.redhat.rhn.domain.common;

import com.redhat.rhn.common.hibernate.HibernateFactory;

import org.apache.commons.lang.builder.EqualsBuilder;
import org.apache.commons.lang.builder.HashCodeBuilder;
import org.hibernate.Criteria;
import org.hibernate.Session;
import org.hibernate.criterion.Restrictions;


/**
 * RhnException
 * @version $Rev$
 */
public class ExceptionMessage {
    private Long id;
    private String label;
    private String message;

    protected ExceptionMessage() {
        //protected because this is
        //class is mutable.. Data is already in the database
        //Use lookup
    }

    /**
     * Returns the exception message object associated to this id
     * @param exceptionId the exception id
     * @return the associated exception object / null if not found otherwise
     */
    public static ExceptionMessage lookup(long exceptionId) {
        Session session = HibernateFactory.getSession();
        Criteria criteria = session.createCriteria(ExceptionMessage.class);
        criteria.add(Restrictions.or(
                Restrictions.eq("id", -1 * exceptionId),
                Restrictions.eq("id", exceptionId)));
        return (ExceptionMessage) criteria.uniqueResult();
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
    protected void setId(Long i) {
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
    protected void setLabel(String l) {
        this.label = l;
    }

    /**
     * @return Returns the message.
     */
    public String getMessage() {
        return message;
    }

    /**
     * @param n The message to set.
     */
    protected void setMessage(String n) {
        this.message = n;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public int hashCode() {
        return new HashCodeBuilder().append(this.getId())
        .append(this.getMessage())
        .append(this.getLabel())
        .toHashCode();
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public boolean equals(Object oth) {
        if (!(oth instanceof ExceptionMessage)) {
            return false;
        }
        ExceptionMessage other = (ExceptionMessage) oth;
        return new EqualsBuilder().append(this.getId(), other.getId())
        .append(this.getMessage(), other.getMessage())
        .append(this.getLabel(), other.getLabel())
        .isEquals();
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public String toString() {
        StringBuilder sb = new StringBuilder();
        sb.append(getClass().getName());
        sb.append(" : id: ");
        sb.append(getId());
        return sb.toString();
    }
}
