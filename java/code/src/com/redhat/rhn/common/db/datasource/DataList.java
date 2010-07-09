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
package com.redhat.rhn.common.db.datasource;

import org.apache.log4j.Logger;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Iterator;
import java.util.List;
import java.util.ListIterator;
import java.util.Map;


/**
 * Replacement for DataResult.
 * Used for displayed lists for which the data comes from database queries.
 * Main functionality: elaborates the data right before it is requested so
 * that only the subset of data needed is elaborated and nobody needs to
 * remember to elaborate the list.
 *
 * Differences from DataResult:
 * DataList elaborates on its own, DataResult had to be told.
 * DataList contains no pagination data, expecting the UI to handle that
 * whereas DataResult contained start, end, and total size data expecting UI
 * to deal directly with these methods rather than just those of a list.
 * @param <E> the type of the objects to be used in this list.
 * @version $Rev$
 */
public class DataList<E> extends ArrayList<E> {
    /**
     * Comment for <code>serialVersionUID</code>
     */
    private static final long serialVersionUID = -4742688110496214350L;

    private static final Logger LOG = Logger.getLogger(DataList.class);

    //used for elaborating only
    private SelectMode mode;
    private Map elaboratorParams;

    //switch to turn on or off automatic elaboration
    private boolean autoElab = true;

    /**
     * Helper method so that one can get a dataresult through the usual way
     * of querying database with a driving query from a datasource select mode.
     * @param m Datasource's SelectMode
     * @param params Driving query parameters.
     * @param elabParams Elaborator parameters.
     * @return A new DataList object containing the results of the driving query.
     */
    public static DataList getDataList(SelectMode m, Map params, Map elabParams) {
        if (m == null || params == null || elabParams == null) {
            throw new NullPointerException("Parameters for getDataList cannot " +
                    "be null. Maps may be empty if necessary.");
        }
        //get driving query results
        DataList retval = new DataList(m.execute(params));
        //prepare to elaborate
        retval.setMode(m);
        retval.setElaboratorParams(elabParams);
        return retval;
    }

    /**
     * Collection constructor for special cases.  Also used internally.
     * @param c The collection.
     */
    public DataList(Collection c) {
        super(c);
    }

    /**
     * Elaborates this DataList. This is private because you should
     * never have to call it explicitly.
     */
    private void elaborate() {
        if (mode != null && elaboratorParams != null) {
            if (autoElab) {
                /*
                 * If we were to simply send this object to elaborate, it
                 * would eventually ask for an iterator on this object which
                 * would in turn call this function creating a large loop.
                 * To avoid this, turn off automatic elaboration.
                 */
                autoElab = false;
                mode.elaborate(this, elaboratorParams);
                //we are done, turn automatic elaboration back to what it was.
            }
        }
        else {
            LOG.warn("mode or elaborator params is null. When these are null, " +
                    "DataList functions exactly the same as ArrayList.");
        }
    }

    /**
     * {@inheritDoc}
     */
    public List subList(int start, int end) {
        //The act of asking for a subList will access the list,
        //which would normally cause the list to elaborate.  This
        //would violate the 'elaborate as late as possible' idea.
        boolean temp = autoElab;
        autoElab = false;
        //create a sublist
        DataList retval = new DataList(super.subList(start, end));
        //set autoElab back to what it was.
        autoElab = temp;

        //copy non-list attributes to new sublist.
        retval.setMode(mode);
        retval.setElaboratorParams(elaboratorParams);
        //don't want to elaborate again.
        retval.setAutoElab(autoElab);
        return retval;
    }

    /**
     * {@inheritDoc}
     */
    public E get(int arg0In) {
        elaborate();
        return super.get(arg0In);
    }

    /**
     * {@inheritDoc}
     */
    public Iterator<E> iterator() {
        //they will be dealing with anything in this list, so elaborate
        //everything. Hopefully they are dealing with a sublist.
        elaborate();
        return super.iterator();
    }

    /**
     * {@inheritDoc}
     */
    public ListIterator<E> listIterator() {
        //they will be dealing with anything in this list, so elaborate
        //everything. Hopefully they are dealing with a sublist.
        elaborate();
        return super.listIterator();
    }

    /**
     * {@inheritDoc}
     */
    public ListIterator<E> listIterator(int arg) {
        //they will be dealing with anything in this list, so elaborate
        //everything. Hopefully they are dealing with a sublist.
        elaborate();
        return super.listIterator(arg);
    }

    /**
     * {@inheritDoc}
     */
    public Object[] toArray() {
        //they will be dealing with anything in this list, so elaborate
        //everything. Hopefully they are dealing with a sublist.
        elaborate();
        return super.toArray();
    }

    /**
     * {@inheritDoc}
     */
    public Object[] toArray(Object[] arg) {
        //they will be dealing with anything in this list, so elaborate
        //everything. Hopefully they are dealing with a sublist.
        elaborate();
        return super.toArray(arg);
    }


    /**
     * @return Returns the elaboratorParams.
     */
    public Map getElaboratorParams() {
        return elaboratorParams;
    }


    /**
     * @param elaboratorParamsIn The elaboratorParams to set.
     */
    public void setElaboratorParams(Map elaboratorParamsIn) {
        elaboratorParams = elaboratorParamsIn;
    }


    /**
     * @return Returns the mode.
     */
    public SelectMode getMode() {
        return mode;
    }


    /**
     * @param modeIn The mode to set.
     */
    public void setMode(SelectMode modeIn) {
        mode = modeIn;
    }

    private void setAutoElab(boolean b) {
        autoElab = b;
    }

    /**
     * {@inheritDoc}
     *
     * Prints meta-data about the list instead of the list itself.
     * Prevents a database call to elaborate by not accessing the
     * data of the list.
     */
    public String toString() {
        StringBuffer buffy = new StringBuffer();
        buffy.append("DataList(");
        buffy.append("mode:");
        buffy.append(mode.toString());
        buffy.append(" ");
        buffy.append("elabParams:");
        buffy.append(elaboratorParams.toString());
        buffy.append(" ");
        buffy.append("elaborated:");
        buffy.append(!autoElab);
        buffy.append(")");
        return buffy.toString();
    }

}
