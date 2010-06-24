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

import com.redhat.rhn.taskomatic.serializer.TaskoBunchSerializer;
import com.redhat.rhn.taskomatic.serializer.TaskoRunSerializer;
import com.redhat.rhn.taskomatic.serializer.TaskoScheduleSerializer;
import com.redhat.rhn.taskomatic.serializer.TaskoTemplateSerializer;

import java.util.LinkedList;
import java.util.List;


/**
 * TaskoSerializerFactory
 * @version $Rev$
 */
// Note: Cannot extend SerializerRegistry, had to define a new class
// it's not possible to override static methods / attributes
public class TaskoSerializerRegistry {

    private static final List<Class> TASKO_SERIALIZER_CLASSES;
    static {
        TASKO_SERIALIZER_CLASSES = new LinkedList<Class>();
        TASKO_SERIALIZER_CLASSES.add(TaskoScheduleSerializer.class);
        TASKO_SERIALIZER_CLASSES.add(TaskoRunSerializer.class);
        TASKO_SERIALIZER_CLASSES.add(TaskoBunchSerializer.class);
        TASKO_SERIALIZER_CLASSES.add(TaskoTemplateSerializer.class);
    }

    private TaskoSerializerRegistry() {
        // hide contructor
    }

    /**
     * Returns the list of all available custom XMLRPC serializers.
     * @return List of serializer classes.
     */
    public static List<Class> getSerializationClasses() {
        return TASKO_SERIALIZER_CLASSES;
    }
}
