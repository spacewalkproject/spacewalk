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
package com.redhat.rhn.common.hibernate;

import org.hibernate.HibernateException;
import org.hibernate.collection.PersistentCollection;
import org.hibernate.collection.PersistentList;
import org.hibernate.engine.SessionImplementor;
import org.hibernate.persister.collection.CollectionPersister;
import org.hibernate.usertype.UserCollectionType;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

/**
 * This is special user collection type that should be used when
 * one wants to force the recreation of a list  
 * on a Many-Many mapping table. The example case where
 * we are using this 
 *
 * Domain Model ->  Many  Servers (s) - Many Config Channels(cc) 
 * rhnServer (s) 1 <-* rhnServerConfigChannel (scc)* -> 1 rhnConfigChannel(cc)
 * s -> (id),  scc ->(server_id, config_channel_id, position ), cc->(id)
 * here we are representing  Server as holding a list of config channels
 * that is indexed according to the value of scc.position.
 * Now lets say we subscribed and unsubscribed channels from the Server...
 * When saving server, with hibernates default mechanism,
 * the links between the Server & ConfigChannels are not  deleted
 * and remapped from scratch. Instead an "optimization" is done
 * using updates. 
 * For eg, if SCC read -> (sid, ccid, position) ->{(2,1,0),(2,2,1),(2,3,2)}
 * And we remove the link for CCID = 1 to end up with  ->{(2,2,1),(2,3,2)}
 * Hibernate achieves this in the following order
 * a) remove(2,3,2) ,b) moves (2,1,0)-> (2,2,0), c) move (2,2,1) -> (2,3,1)
 * Problem here is since (sid, ccid) combination must be unique
 * step b fails (since 2,2,1 still exists).. So we have to force hibernate
 * to do the following a) remove (2,*,*) b) insert(2,2,0) and c)insert(2,3,1)
 * This list type will help us achieve that.
 *
 * When you use a list in hbm.xml , to use this collection
 * you must specify <list name="...." 
 * collection-type="com.redhat.rhn.common.hibernate.ForceRecreationListType">
 *
 * Note in the above example if (sid, ccid, position) combination as
 * a whole was unique we wouldn't have had to deal with this......
 * but positions can be null twice for the same server, so we 
 * cannot enforce that constraint..
 * 
 * 
 * ForceRecreationListType
 * @version $Rev$
 */
public class ForceRecreationListType implements UserCollectionType {

    /**
     * {@inheritDoc}
     */
    public PersistentCollection instantiate(SessionImplementor session,
            CollectionPersister persister) throws HibernateException {
        return new ForceRecreationList(session);
    }

    /**
     * {@inheritDoc}
     */
    public PersistentCollection wrap(SessionImplementor session,
            Object collection) {
        return new ForceRecreationList(session, (List) collection);
        
    }

    /**
     * 
     * {@inheritDoc}
     */
    public Iterator getElementsIterator(Object collection) {
        return ((List) collection).iterator();
    }

    /**
     * 
     * {@inheritDoc}
     */
    public boolean contains(Object collection, Object entity) {
        return ((List) collection).contains(entity);
    }

    /**
     * 
     * {@inheritDoc}
     */
    public Object indexOf(Object collection, Object entity) {
        int l = ((List) collection).indexOf(entity);
        if (l < 0) {
            return null;
        }
        else {
            return new Integer(l);
        }
    }

    /**
     * 
     * {@inheritDoc}
     */
    public Object replaceElements(Object original, Object target,
            CollectionPersister persister, Object owner, Map copyCache,
            SessionImplementor session) throws HibernateException {
        List result = (List) target;
        result.clear();
        result.addAll((Collection) original);
        return result;
    }
    
    /**
     * Instantiates an empty list.  This method will be useful
     * when hibernate 3.2 is added.
     * @param anticipatedSize sample size
     * @return an empty  list.
     */
    public Object instantiate(int anticipatedSize) {
        if (anticipatedSize > 0) {
            return new ArrayList(anticipatedSize);
        }
        return new ArrayList();
    }
    
    /**
     * Returns an ArrayList. Not sure what the heck this is here for.
     * TODO: WHAT IS THIS FOR? 2007-11-8 jesusr
     * @return ArrayList as an Object.
     */
    public Object instantiate() {
        return new ArrayList();
    }
    
    /**
     * 
     * ForceRecreationList
     * @version $Rev$
     */
    private static class ForceRecreationList extends PersistentList {

        /**
         * Comment for <code>serialVersionUID</code>
         */
        private static final long serialVersionUID = -5203696410584457675L;

        /**
         * 
         * @param session session implementation
         */
        public ForceRecreationList(SessionImplementor session) {
            super(session);
        }

        /**
         * @param session session implementation
         * @param list  list to persist
         */
        public ForceRecreationList(SessionImplementor session, List list) {
            super(session, list);
        }

        /**
         * 
         * {@inheritDoc}
         */
        public boolean needsRecreate(CollectionPersister persister) {
            return true;
        }

    }
}
