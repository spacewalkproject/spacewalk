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
package com.redhat.rhn.frontend.filter.test;

import com.redhat.rhn.frontend.filter.DepthAware;

import org.apache.commons.lang.builder.EqualsBuilder;
import org.apache.commons.lang.builder.HashCodeBuilder;


/**
 * DepthAwareBean
 * @version $Rev$
 */
public class DepthAwareBean implements DepthAware {
    private long depth;
    private String content;
    
    private DepthAwareBean() {
    }
    
    /**
     * 
     * @param contentVal value of the content to be filtered on
     * @param depthVal the depth of the item in a tree
     * @return a new DepthAware bean.
     */
    public static DepthAwareBean instance(String contentVal, int depthVal) {
        DepthAwareBean bean  = new DepthAwareBean();
        bean.content = contentVal;
        bean.depth = depthVal;
        return bean;
    }
    
    /**
     * {@inheritDoc}
     */
    public long depth() {
        // TODO Auto-generated method stub
        return depth;
    }

    /**
     * @return the content value
     */
    public String getContent() {
        // TODO Auto-generated method stub
        return content;
    }
    
    /**
     * 
     * {@inheritDoc}
     */
    public boolean equals(Object o) {
        if (this == o) {
            return true;
        }
        if (!(o instanceof DepthAwareBean)) {
            return false;
        }
        DepthAwareBean that = (DepthAwareBean) o;
        
        return new EqualsBuilder().
                append(this.content, that.content).
                append(this.depth, that.depth).isEquals();
    }
    
    /**
     * 
     * {@inheritDoc}
     */
    public String toString() {
        return "(" + content + ", " + depth + ")"; 
    }
    
    /**
     * 
     * {@inheritDoc}
     */
    public int hashCode() {
        return new HashCodeBuilder().append(content).append(depth).toHashCode();
    }
}
