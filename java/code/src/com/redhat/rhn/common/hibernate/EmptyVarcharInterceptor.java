/**
 * Copyright (c) 2010--2012 Red Hat, Inc.
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
package com.redhat.rhn.common.hibernate;

import org.apache.log4j.Logger;
import org.apache.log4j.Priority;
import org.hibernate.EmptyInterceptor;
import org.hibernate.type.StringType;
import org.hibernate.type.Type;

import java.io.Serializable;

/**
 * Hibernate interceptor that searches all objects being saved and checks if all
 * varchar fields are not empty. It can either print a warning in the log or
 * convert empty varchar to null automatically. It depends on the setting of the
 * interceptor.
 */
public class EmptyVarcharInterceptor extends EmptyInterceptor {

    private static final long serialVersionUID = 5351605245345217308L;

    private static final Logger LOG = Logger
            .getLogger(EmptyVarcharInterceptor.class);

    private boolean autoConvert = false;

    protected static boolean emptyStringToNull(Object entity, Serializable id,
            Object[] state, String[] propertyNames, Type[] types,
            boolean autoConvert) {

        boolean modified = false;

        for (int i = 0; i < types.length; i++) {
            // type is string (VARCHAR) and state is empty string
            if ((types[i] instanceof StringType) && "".equals(state[i])) {
                if (LOG.isEnabledFor(Priority.WARN)) {
                    LOG.warn("Object " + entity.getClass().getCanonicalName() +
                            " is setting empty string " + propertyNames[i]);
                }
                if (autoConvert) {
                    state[i] = null;
                    modified = true;
                }
            }
        }
        return modified;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public boolean onSave(Object entity, Serializable id, Object[] state,
            String[] propertyNames, Type[] types) {
        return emptyStringToNull(entity, id, state, propertyNames, types,
                autoConvert);
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public boolean onFlushDirty(Object entity, Serializable id,
            Object[] currentState, Object[] previousState,
            String[] propertyNames, Type[] types) {
        return emptyStringToNull(entity, id, currentState, propertyNames,
                types, autoConvert);
    }

    /**
     * Flag indicating if the interceptor correct the varchar errors automatically
     *
     * @return boolean
     */
    public boolean isAutoConvert() {
        return autoConvert;
    }

    /**
     * Flag indicating if the interceptor correct the varchar errors automatically
     *
     * @param autoConvertIn true - convert automatically
     */
    public void setAutoConvert(boolean autoConvertIn) {
        this.autoConvert = autoConvertIn;
    }

}
