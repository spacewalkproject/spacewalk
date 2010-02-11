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
package com.redhat.rhn.frontend.taglibs.list;

import org.apache.commons.lang.StringUtils;

import javax.servlet.jsp.JspException;
import javax.servlet.jsp.tagext.BodyTagSupport;


/**
 * DecoratorTag
 * @version $Rev$
 */
public class DecoratorTag extends BodyTagSupport {

    /**
     * Comment for <code>serialVersionUID</code>
     */
    private static final long serialVersionUID = -4725527714962599693L;
    
    private String name;
    
    /**
     * sets the name of the decorator. A classname.. 
     * @param decoratorName the names of the decorator
     */
    public void setName(String decoratorName) {
        name = decoratorName;
    }
    
    /**
     * {@inheritDoc}
     */
    public int doEndTag() throws JspException {
        ListCommand command = (ListCommand) 
                    ListTagUtil.getCurrentCommand(this, pageContext);
        if (command.equals(ListCommand.ENUMERATE)) {
            if (!StringUtils.isBlank(name)) {
                ListTag parent = (ListTag) BodyTagSupport.findAncestorWithClass(this, 
                        ListTag.class);
                parent.addDecorator(name);
            }
        }
        return super.doEndTag();
    }
}
