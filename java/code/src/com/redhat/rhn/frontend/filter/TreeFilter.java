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
package com.redhat.rhn.frontend.filter;

import com.redhat.rhn.common.db.datasource.DataResult;

import org.apache.commons.lang.StringUtils;

import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Set;


/**
 * TreeFilter
 * @version $Rev$
 */
public class TreeFilter implements ResultsFilter {
    private Matcher matcher = Matcher.DEFAULT_MATCHER;
    private Set positions;
    private List filtered;
    /**
     * Set a matcher to match individual elements.
     * This facility was added so that we could evaluate things like
     * if a given DTO had a condition x match on column X, 
     * else match on column Y.
     * @param m the matcher that evaluates individual elements.
     */
    public void setMatcher(Matcher m) {
        matcher = m;
    }
    
    /**
     * {@inheritDoc}
     * There are some preconditions
     * We expect each element of DataResult to implement
     * "DepthAware". The depth value has to be >=0
     * with 0 being the root depth. We need this keep track of the parents.
     * Another assumption is that the list is ordered depthwise
     * For example
     * A data result with - {(C1,0), (C2,1), (C3,2), 
     *      (C4,1), (C5,2), (D1,0), (D2,1), (D3,1), (E1,0), (E2,1), (E3,1) }
     * will resemble the following tree (
     * Note - In our notation (X,Y), the X = content while Y = depth, 
     * while 2nd is a unique id)
     * 
     *     C1       D1       E1
     *    /  \      /  \    /  \
     *   C2   C4 D2   D3   E2  E3
     *  /      \
     * C3      C5
     */
    public void filterData(DataResult dr, String filterData,
            String filterColumn) {
        
        /*
         * The overall logic of this function is to go through
         * the flat list of our results, and build a tree using 
         * this logic.. If the Depth of a successor element is one greater
         * than the current, then the successor must be a  
         *  child of the current.. As we build this tree 
         *  we try to find our filter match..   
         *  When we find a match we trace it 
         *  up to the topmost parent and add all elements 
         *  in our path to a "filtered" list.  
         *  When we are finally done, we clear the data result here 
         *  and re-add the  items from the filtered list to the data result..
         *  We use a "NodeTracker" to keep track of the parent nodes
         *  and positions of the current node.. 
         */        
        
        //Don't even bother filtering if there is
        // no filterData text or filterColumn specified
        // Or if the list is empty
        if (!dr.isEmpty() &&
                !StringUtils.isBlank(filterData) &&
                !StringUtils.isBlank(filterColumn)) {
            positions = new HashSet();
            filtered = new LinkedList();
            Iterator it = dr.iterator();
            NodeInfo current = NodeInfo.instance((DepthAware)it.next(),
                                                                new Integer(0));
            while (it.hasNext()) {
                if (matcher.include(current.node, filterData, filterColumn)) {
                    addMatchedPath(current, dr);
                }
                
                NodeInfo successor = NodeInfo.instance((DepthAware) it.next(),
                                            new Integer(current.position.intValue() + 1));
                if (successor.node.depth() == current.node.depth()) {
                    successor.parent = current.parent;
                }
                else if (successor.node.depth() == current.node.depth() + 1) {
                    successor.parent = current;
                }
                else if (successor.node.depth() != 0 && 
                            successor.node.depth() < current.node.depth()) {
                    NodeInfo temp = current;
                    while (temp.parent != null &&
                            temp.parent.node.depth() >= successor.node.depth()) {
                        temp = temp.parent;
                    }
                    if (temp.parent != null) {
                        successor.parent = temp.parent;    
                    }
                    
                }
                current = successor;
            }
            //check on the last 'current' element also...
            if (matcher.include(current.node, filterData, filterColumn)) {
                addMatchedPath(current, dr);
            }
            dr.clear();
            dr.addAll(filtered);
            dr.setTotalSize(filtered.size());
        }
    }

    /**
     * Adds all the elements in the path from current to its 
     * topmost parent to the "filtered" list.. At the same time
     * it also ensures that duplicate elements are NOT added to the  
     * filtered list.    
     * @param current the Node info of the matched object 
     * @param result the main data result passed in the input.
     */
    private void addMatchedPath(NodeInfo current, DataResult result) {
        LinkedList path = new LinkedList();
        if (!positions.contains(current.position)) {
            positions.add(current.position);
            path.addFirst(result.get(current.position.intValue()));
        }
        while (current.parent != null) {
            current = current.parent;
            if (!positions.contains(current.position)) {
                positions.add(current.position);
                path.addFirst(result.get(current.position.intValue()));
            }            
        }
        filtered.addAll(path);
    }
    
    /**
     * This class basically serves as a holder 
     * of extra information needed by TreeFilter to identify parents. 
     * NodeWrapper
     * @version $Rev$
     */
    private static class NodeInfo {
        private DepthAware node;
        private NodeInfo parent;
        private Integer position;
        
        private NodeInfo() {
        }
        
        public static NodeInfo instance(DepthAware nd, Integer pos) {
            NodeInfo wrapper = new NodeInfo();
            wrapper.node = nd;
            wrapper.position = pos;
            return wrapper;
        }
    }
}
