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
package com.redhat.rhn.domain.rhnset;

import java.util.Collection;
import java.util.Collections;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Set;

/**
 * RhnSetImpl
 * @version $Rev$
 */
public class RhnSetImpl implements RhnSet {
    private Long uid;
    private String label;
    private Set elements;
    private Set synced;
    private SetCleanup cleanup;

    /**
     * Default constructor.
     */
    public RhnSetImpl() {
        this(null, null, SetCleanup.NOOP);
    }

    /**
     * Constructs an RhnSet with the given user id and label.
     * @param id userid to associate with this RhnSet.
     * @param lbl label to associate with this RhnSet.
     * @param cleanup0 the cleanup to use after storing this set
     */
    public RhnSetImpl(Long id, String lbl, SetCleanup cleanup0) {
        super();
        uid = id;
        label = lbl;
        elements = new HashSet();
        cleanup = cleanup0;
    }

    /**
     * {@inheritDoc}
     */
    public void setUserId(Long id) {
        uid = id;
    }

    /**
     * {@inheritDoc}
     */
    public Long getUserId() {
        return uid;
    }

    /**
     * {@inheritDoc}
     */
    public void setLabel(String lbl) {
        label = lbl;
    }

    /**
     * {@inheritDoc}
     */
    public String getLabel() {
        return label;
    }

    /**
     * Adds an element to the set.
     * @param element Element to be added to the set.
     */
    public void addElement(RhnSetElement element) {
        elements.add(element);
    }

    /**
     * Adds an element to the set.
     * @param elem Element one
     * @param elemTwo Element two
     */
    public void addElement(Long elem, Long elemTwo) {
        addElement(new RhnSetElement(getUserId(), getLabel(), elem, elemTwo));
    }

    /** {@inheritDoc} */
    public void addElement(Long elem, Long elemTwo, Long elemThree) {
       addElement(new RhnSetElement(getUserId(), getLabel(), elem, elemTwo, elemThree));
    }

    /**
     * Adds an element to the set.
     * @param elem Element one
     */
    public void addElement(Long elem) {
        addElement(elem, null);
    }

    /**
     * {@inheritDoc}
     */
    public void addElement(String elem) {
        if (elem != null && elem.length() > 0) {
            addElement(new RhnSetElement(getUserId(), getLabel(), elem));
        }

    }


    /**
     * Adds an array of elements to the set.
     * @param elems String [] - array of elements to add
     */
    public void addElements(String [] elems) {
        if (elems == null) {
            return;
        }

        for (int i = 0; i < elems.length; i++) {
            addElement(elems[i]);
        } // for
    }

    /**
     * Removes an array of elements to the set.
     * @param elems String [] - array of elements to add
     */
    public void removeElements(String [] elems) {
        if (elems == null) {
            return;
        }

        for (int i = 0; i < elems.length; i++) {
            if (elems[i] != null && elems[i].length() > 0) {
                RhnSetElement elem = new RhnSetElement(getUserId(),
                                                        getLabel(), elems[i]);
                removeElement(elem);
            } // if
        } // for
    }

    /**
     * {@inheritDoc}
     */
    public void removeElement(RhnSetElement element) {
        elements.remove(element);
    }

    /**
     * {@inheritDoc}
     */
    public void removeElement(Long elem, Long elemTwo) {
        removeElement(new RhnSetElement(getUserId(), getLabel(), elem, elemTwo));
    }

    /**
     * {@inheritDoc}
     */
    public void removeElement(Long elem) {
        removeElement(new RhnSetElement(getUserId(), getLabel(), elem, null));
    }

    /**
     * {@inheritDoc}
     */
    public void clear() {
        elements = new HashSet();
    }

    /**
     * {@inheritDoc}
     */
    public Set<RhnSetElement> getElements() {
        return elements;
    }

    /**
     * {@inheritDoc}
     */
    public Set getElementValues() {
        Set values = new HashSet();
        for (Iterator it = elements.iterator(); it.hasNext();) {
            RhnSetElement element = (RhnSetElement)it.next();
            values.add(element.getElement());
        }
        return values;
    }

    /**
     * {@inheritDoc}
     */
    public boolean contains(RhnSetElement e) {
        return elements.contains(e);
    }

    /**
     * {@inheritDoc}
     */
    public boolean contains(Long elem, Long elemTwo) {
        return elements.contains(new RhnSetElement(getUserId(), getLabel(),
                elem, elemTwo));
    }

    /**
     * {@inheritDoc}
     */
    public boolean contains(Long elem) {
        return elements.contains(new RhnSetElement(getUserId(), getLabel(), elem, null));
    }

    /**
     * {@inheritDoc}
     */
    public int size() {
        return elements.size();
    }

    /**
     * {@inheritDoc}
     */
    public boolean isEmpty() {
        return elements.isEmpty();
    }

    /**
     * Save the current state of the set. Calls to {@link #getAdded()} and
     * {@link #getRemoved()} will report changes with respect to the state
     * of the set at the last call to this method
     */
    public void sync() {
        synced = new HashSet(elements);
    }

    /**
     * Return <code>true</code> if this set has ever been synced
     * @return <code>true</code> if this set has ever been synced
     */
    public boolean isSynced() {
        return synced != null;
    }

    /**
     * Return a set of all elements that have been added since the last call
     * to {@link #sync()}
     * @return the elements that were added since the last call to {@link #sync()}
     */
    public Set getAdded() {
        if (synced == null) {
            throw new IllegalStateException("The set must be marked first");
        }
        HashSet result = new HashSet(elements);
        result.removeAll(synced);
        return Collections.unmodifiableSet(result);
    }

    /**
     * Return a set of all elements that have been removed since the last call
     * to {@link #sync()}
     * @return the elements that were removed since the last call to {@link #sync()}
     */
    public Set getRemoved() {
        if (synced == null) {
            throw new IllegalStateException("The set must be marked first");
        }
        HashSet result = new HashSet(synced);
        result.removeAll(elements);
        return Collections.unmodifiableSet(result);
    }


    /**
     * @return Returns the cleanup.
     */
    SetCleanup getCleanup() {
        return cleanup;
    }


    /* The following methods were added to implement Set*/


    /**
     * {@inheritDoc}
     */
    public boolean add(Object e) {
        if (e instanceof String) {
            addElement((String)e);
        }
        else if (e instanceof Long) {
            addElement((Long)e);
        }
        else if (e instanceof RhnSetElement) {
            addElement((RhnSetElement)e);
        }
        return false;
    }


    /**
     * {@inheritDoc}
     */
    public boolean addAll(Collection c) {
        for (Object o : c) {
            add(o);
        }
        return false;
    }

    /**
     * {@inheritDoc}
     */
    public boolean contains(Object o) {
        if (o instanceof String) {
            return elements.contains(new RhnSetElement(this.getUserId(),
                    this.getLabel(), (String) o));
        }
        else if (o instanceof Long) {
            return elements.contains(new RhnSetElement(this.getUserId(),
                    this.getLabel(), (Long) o, null, null));
        }
        return elements.contains(o);
    }

    /**
     * {@inheritDoc}
     */
    public boolean containsAll(Collection c) {
        return elements.containsAll(c);
    }

    /**
     * {@inheritDoc}
     */
    public Iterator iterator() {
        return elements.iterator();
    }

    /**
     * {@inheritDoc}
     */
    public boolean remove(Object o) {
        return elements.remove(o);
    }

    /**
     * Remove a item from the set.  The 2nd element is assumed to be null
     * @param o the first element of the RhnSetElement to remove
     * @return true if removed
     */
    public boolean remove(Long o) {
        boolean toRet = false;
        if (contains(o)) {
            toRet = true;
            removeElement(o);
        }
        return toRet;
    }

    /**
     * Remove an rhnSetElement from the set
     * @param o the element
     * @return true if removed
     */
    public boolean remove(RhnSetElement o) {
        boolean toRet = false;
        if (contains(o)) {
            toRet = true;
            removeElement(o);
        }
        return toRet;
    }


    /**
     * removes a collection of RhnSetElemnets from the set
     * {@inheritDoc}
     */
    public boolean removeAll(Collection c) {
        return elements.removeAll(c);
    }

    /**
     * retains a collection of RhnSetElemnets from the set
     * {@inheritDoc}
     */
    public boolean retainAll(Collection c) {
        return elements.retainAll(c);
    }

    /**
     * {@inheritDoc}
     */
    public Object[] toArray() {
        return elements.toArray();
    }

    /**
     * {@inheritDoc}
     */
    public Object[] toArray(Object[] a) {
        return elements.toArray(a);
    }
}
