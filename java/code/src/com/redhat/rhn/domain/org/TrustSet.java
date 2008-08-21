package com.redhat.rhn.domain.org;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Iterator;
import java.util.List;
import java.util.Set;

public class TrustSet implements Set<Org> {

    private final Org org;
    private final Set<Org> trusted;

    public TrustSet(Org org, Set<Org> trusted) {
        this.org = org;
        this.trusted = trusted;
    }

    public boolean add(Org org) {
        this.org.addTrust(org);
        return false;
    }

    public boolean addAll(Collection<? extends Org> c) {
        for (Org org : c) {
            add(org);
        }
        return true;
    }

    public void clear() {
        List<Org> list = new ArrayList<Org>(trusted);
        for (Org org : list) {
            remove(org);
        }
    }

    public boolean contains(Object o) {
        return trusted.contains(o);
    }

    public boolean containsAll(Collection<?> c) {
        return trusted.containsAll(c);
    }

    public boolean isEmpty() {
        return trusted.isEmpty();
    }

    public Iterator<Org> iterator() {
        return trusted.iterator();
    }

    public boolean remove(Object o) {
        if (o instanceof Org) {
            return remove((Org) o);
        }
        return false;
    }

    public boolean remove(Org org) {
        this.org.removeTrust(org);
        return true;
    }

    public boolean removeAll(Collection<?> c) {
        for (Object o : c) {
            remove(o);
        }
        return true;
    }

    public boolean retainAll(Collection<?> c) {
        for (Org org : trusted) {
            if (c.contains(org)) continue;
            remove(org);
        }
        return true;
    }

    public int size() {
        return trusted.size();
    }

    public Object[] toArray() {
        return trusted.toArray();
    }

    @SuppressWarnings("unchecked")
    public Object[] toArray(Object[] a) {
        // NOT SUPPORTED
        return null;
    }

}
