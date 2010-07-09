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
package com.redhat.rhn.domain.task;

import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.domain.org.Org;

import org.apache.log4j.Logger;
import org.hibernate.Criteria;
import org.hibernate.HibernateException;
import org.hibernate.Session;
import org.hibernate.criterion.CriteriaSpecification;
import org.hibernate.criterion.Order;

import java.util.Collections;
import java.util.Date;
import java.util.List;

/**
 * TaskFactory
 * @version $Rev$
 */
public class TaskFactory extends HibernateFactory {

    private static TaskFactory singleton = new TaskFactory();
    private static Logger log = Logger.getLogger(TaskFactory.class);
    public static final int NO_MAXIMUM = -1;

    private TaskFactory() {
        super();
    }

    /**
     * {@inheritDoc}
     */
    protected Logger getLogger() {
        return log;
    }

    /**
     * Creates a new Task object.
     * @param org The org to which this task will belong
     * @param name A name for the task
     * @param data The data for this task (usually corresponds to an object id)
     * @return Returns the newly created task object.
     */
    public static Task createTask(Org org, String name, Long data) {
        Task t = new Task();
        t.setPriority(0); //default
        t.setOrg(org);
        t.setName(name);
        t.setData(data);
        t.setEarliest(new Date()); //set to now
        save(t); //store the task to the db
        return t;
    }

    /**
     * list All tasks with the given name
     * @param name the name of the task
     * @return List of tasks
     */
    public static List<Task> listTasks(String name) {
        Session session = null;
        try {
            session = HibernateFactory.getSession();
            return session.getNamedQuery("Task.listTasksByName")
                                     .setString("name", name).list();
        }
        catch (HibernateException he) {
            log.error("Hibernate exception: " + he.toString());
        }
        return Collections.EMPTY_LIST;
    }

    /**
     * Remove a task from teh database
     * @param task the task to remove
     */
    public static void removeTask(Task task) {
        TaskFactory.getSession().delete(task);
    }


    /**
     * Saves the object to the db
     * @param taskIn The task to save
     */
    public static void save(Task taskIn) {
        singleton.saveObject(taskIn);
    }

    /**
     * Remove a completed Task from the queue.
     *
     * @param taskIn to remove
     */
    public static void remove(Task taskIn) {
        singleton.removeObject(taskIn);
    }


    /**
     * Lookups up a task.
     * @param org The org containing the task
     * @param name The name of the task
     * @param data The data in the task
     * @return Returns the task that matches all three parameters or null.
     */
    public static Task lookup(Org org, String name, Long data) {
        Session session = HibernateFactory.getSession();
        return (Task) session.getNamedQuery("Task.lookup")
                                 .setString("name", name)
                                   .setLong("data", data.longValue())
                                 .setEntity("org", org)
                                 .uniqueResult();
    }

    /**
     * Gets the list of tasks with "update_errata_cache_by_channel" for their name attr.
     * @param org The org containing the tasks
     * @return Returns a list of task objects
     */
    public static List getTaskListByChannel(Org org) {
        Session session = HibernateFactory.getSession();
        return session.getNamedQuery("Task.lookupByOrgAndName")
                      .setEntity("org", org)
                      .setString("name", "update_errata_cache_by_channel")
                      .list();
    }

    /**
     * Returns a list of tasks ordered by earliest date.  This could return
     * many records use cautiously.
     * @param distinct return distinct records.
     * @param maxresults Number of rows to return or TaskFactory.NO_MAXIMUM
     * @return list of tasks ordered by earliest date.
     */
    public static List getTaskList(boolean distinct, int maxresults) {
        Session session = HibernateFactory.getSession();

        Criteria c = session.createCriteria(Task.class);
        c.setCacheable(false); // don't want to cache all this
        c.addOrder(Order.asc("earliest"));

        if (maxresults != TaskFactory.NO_MAXIMUM) {
            c.setMaxResults(maxresults);
        }

        if (distinct) {
            c.setResultTransformer(CriteriaSpecification.DISTINCT_ROOT_ENTITY);
        }

        return c.list();
    }

    /**
     * Lookup a list of Tasks who's name start with passed in param
     * @param nameIn to lookup
     * @return List of Tasks or null if not found.
     */
    public static List<Task> getTaskListByNameLike(String nameIn) {
        return HibernateFactory.getSession().getNamedQuery("Task.lookupByNameLike")
          .setString("namelike", nameIn + "%")
          .list();
    }
}
