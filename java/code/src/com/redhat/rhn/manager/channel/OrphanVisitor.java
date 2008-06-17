/**
 * Copyright (c) 2008 Red Hat, Inc.
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
package com.redhat.rhn.manager.channel;

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.frontend.dto.ChannelTreeNode;

import org.apache.commons.collections.Closure;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Iterator;
import java.util.List;
import java.util.ListIterator;


/**
 * OrphanVisitor
 * @version $Rev$
 */
public class OrphanVisitor implements Closure {
    
    private List visitedNodes;
    private List visitedOrphans;
    private ChannelTreeNode lastParent;
    
    /**
     * 
     *
     */
    public OrphanVisitor() {
        visitedNodes = new ArrayList();
        visitedOrphans = new ArrayList();
    }
    
    /**
     * This constructor is for testing <strong>only</strong>.
     * 
     * @param testVisitedNodes A fake/mock list to use for testing
     */
    protected OrphanVisitor(List testVisitedNodes, List testVisitedOrphans) {
        visitedNodes = testVisitedNodes;
        visitedOrphans = testVisitedOrphans;
        
        ListIterator iterator = visitedNodes.listIterator(visitedNodes.size());
        ChannelTreeNode node = null;
        
        while (iterator.hasPrevious()) {
            node = (ChannelTreeNode)iterator.previous();
            if (node.isParent()) {
                lastParent = node;
                break;
            }
        }
    }
    
    /**
     * 
     * @param node The node to visit
     */
    public void visit(ChannelTreeNode node) {
        if (node.isParent()) {
            lastParent = node;
            visitedNodes.add(node);
        }
        else if (node.isChildOf(lastParent)) {
            visitedNodes.add(node);
        }
        else {  // else we have an orphan
            if (visitedOrphansContainsParent(node)) {
                //visitedNodes.add(node);
                visitedOrphans.add(node);
            }
            else {
                //visitedNodes.add(newRestrictedParent(node));
                //visitedNodes.add(node);
                visitedOrphans.add(newRestrictedParent(node));
                visitedOrphans.add(node);
            }
        }
    }

    /**
     * 
     * @param channelTreeNode The node to visit
     */
    public void execute(Object channelTreeNode) {
        visit((ChannelTreeNode)channelTreeNode);
    }
    
    private boolean visitedOrphansContainsParent(ChannelTreeNode child) {
        ChannelTreeNode node;
        
        for (Iterator iterator = visitedOrphans.iterator(); iterator.hasNext();) {
            node = (ChannelTreeNode)iterator.next();
            if (child.isChildOf(node)) {
                return true;
            }
        }
        
        return false;
    }
    
    private ChannelTreeNode newRestrictedParent(ChannelTreeNode child) {
        ChannelTreeNode parent;
        parent = new ChannelTreeNode();
        parent.setAccessible(false);
        parent.setName(LocalizationService.getInstance().getMessage("channel.unavailable"));
        parent.setDepth(new Long(1));
        parent.setId(child.getParentOrSelfId());
        parent.setParentOrSelfId(child.getParentOrSelfId());
        
        return parent;
    }
    
    /**
     * Returns the visited nodes.
     * @return The visited nodes
     */
    public Collection getVisitedNodes() {
        List allVisitedNodes = new ArrayList(visitedNodes);
        allVisitedNodes.addAll(visitedOrphans);
        return allVisitedNodes;
        //return visitedNodes;
    }

}
