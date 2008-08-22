package com.redhat.rhn.domain.org;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Iterator;
import java.util.List;
import java.util.Set;

/**
 * This class provides a wrapper around an Org's trustedOrgs set to ensure that
 * operations on the set result in a bidirectional trust relationship.
 */
public class TrustSet implements Set<Org> {

    private final Org org;
    private final Set<Org> trusted;

    /**
     * {@inheritDoc}
     */
    public TrustSet(Org org, Set<Org> trusted) {
        this.org = org;
        this.trusted = trusted;
    }

    /**
     * {@inheritDoc}
     */
    public boolean add(Org org) {
        this.org.addTrust(org);
        return false;
    }

    /**
     * {@inheritDoc}
     */
    public boolean addAll(Collection<? extends Org> c) {
        for (Org org : c) {
            add(org);
        }
        return true;
    }

    /**
     * {@inheritDoc}
     */
    public void clear() {
        List<Org> list = new ArrayList<Org>(trusted);
        for (Org org : list) {
            remove(org);
        }
    }

    /**
     * {@inheritDoc}
     */
    public boolean contains(Object o) {
        return trusted.contains(o);
    }

    /**
     * {@inheritDoc}
     */
    public boolean containsAll(Collection<?> c) {
        return trusted.containsAll(c);
    }

    /**
     * {@inheritDoc}
     */
    public boolean isEmpty() {
        return trusted.isEmpty();
    }

    /**
     * {@inheritDoc}
     */
    public Iterator<Org> iterator() {
        return trusted.iterator();
    }

    /**
     * {@inheritDoc}
     */
    public boolean remove(Object o) {
        if (o instanceof Org) {
            return remove((Org) o);
        }
        return false;
    }

    /**
     * {@inheritDoc}
     */
    public boolean remove(Org org) {
        this.org.removeTrust(org);
        return true;
    }

    /**
     * {@inheritDoc}
     */
    public boolean removeAll(Collection<?> c) {
        for (Object o : c) {
            remove(o);
        }
        return true;
    }

    /**
     * {@inheritDoc}
     */
    public boolean retainAll(Collection<?> c) {
        for (Org org : trusted) {
            if (c.contains(org)) continue;
            remove(org);
        }
        return true;
    }

    /**
     * {@inheritDoc}
     */
    public int size() {
        return trusted.size();
    }

    /**
     * {@inheritDoc}
     */
    public Object[] toArray() {
        return trusted.toArray();
    }

    /**
     * {@inheritDoc}
     */
    @SuppressWarnings("unchecked")
    public Object[] toArray(Object[] a) {
        // NOT SUPPORTED
        return null;
    }

}
