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
package com.redhat.rhn.taskomatic;

import com.redhat.rhn.common.hibernate.HibernateFactory;

import redstone.xmlrpc.XmlRpcInvocation;
import redstone.xmlrpc.XmlRpcInvocationInterceptor;


/**
 * TaskoXmlRpcInvocationInterceptor
 * @version $Rev$
 */
public class TaskoXmlRpcInvocationInterceptor implements
        XmlRpcInvocationInterceptor {

    /**
     * {@inheritDoc}
     */
    public Object after(XmlRpcInvocation invocation, Object returnValue) {
        if (HibernateFactory.getSession().getTransaction().isActive()) {
            HibernateFactory.commitTransaction();
        }
        HibernateFactory.closeSession();
        return returnValue;
    }

    /**
     * {@inheritDoc}
     */
    public boolean before(XmlRpcInvocation invocation) {
        return true;
    }

    /**
     * {@inheritDoc}
     */
    public void onException(XmlRpcInvocation incovation, Throwable exception) {
        HibernateFactory.rollbackTransaction();
        HibernateFactory.closeSession();
    }

}
