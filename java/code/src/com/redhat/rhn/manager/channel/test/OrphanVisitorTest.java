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
package com.redhat.rhn.manager.channel.test;

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.frontend.dto.ChannelTreeNode;
import com.redhat.rhn.manager.channel.OrphanVisitor;
import com.redhat.rhn.testing.Sequence;

import org.jmock.cglib.MockObjectTestCase;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Iterator;
import java.util.List;


/**
 * OrphanVisitorTest
 * @version $Rev$
 */
public class OrphanVisitorTest extends MockObjectTestCase {
    
    private class OrphanVisitorStub extends OrphanVisitor {
        public OrphanVisitorStub(List testVisitedNodes, List testVisitedOrphans) {
            super(testVisitedNodes, testVisitedOrphans);
        }
    }
    
    private static final Long TWO = new Long("2");
    
    private Sequence idSequence;
    private List visitedNodes;
    private List visitedOrphans;
    private OrphanVisitor visitor;
    
    /**
     * @param arg0
     */
    protected void setUp() throws Exception {
        idSequence = new Sequence();
        visitedNodes = new ArrayList();
        visitedOrphans = new ArrayList();
    }
    
    protected void tearDown() throws Exception {
        visitedNodes.addAll(visitedOrphans);
        assertOrderedCollectionsEqual(visitedNodes, 
                visitor.getVisitedNodes());
    }
    
    // TODO Probably want to move this method to a generalized assertion class
    private void assertOrderedCollectionsEqual(Collection expected, Collection actual) {
        assertEquals(expected.size(), actual.size());
        
        Iterator expectedIterator = expected.iterator();
        Iterator actualIterator = actual.iterator();
        
        while (expectedIterator.hasNext()) {
            assertTrue(actualIterator.hasNext());
            assertEquals(expectedIterator.next(), actualIterator.next());
        }
    }
    
    public void testVisitParent() {
        visitor = new OrphanVisitor();
        ChannelTreeNode parent = newParent();
        
        visitor.visit(parent);
    }
    
    public void testVisitChildrenOfVisitedParent() {
        visitor = new OrphanVisitor();
        
        List alreadyVisitedNodes = new ArrayList();
        ChannelTreeNode parent = newParent();
        
        alreadyVisitedNodes.add(parent);
        
        visitor = new OrphanVisitorStub(alreadyVisitedNodes, new ArrayList());
        visitor.visit(newChild(parent));
        visitor.visit(newChild(parent));        
    }
    
    public void testVisitMultipleParentsAndChildren() {
        visitor = new OrphanVisitor();
        
        ChannelTreeNode parent = newParent();
        visitor.visit(parent);
        visitor.visit(newChild(parent));
        visitor.visit(newChild(parent));
        
        parent = newParent();
        visitor.visit(parent);
        visitor.visit(newChild(parent));
        visitor.visit(newChild(parent));
    }
    
    public void testVisitOrphan() {
        visitor = new OrphanVisitor();
        visitor.visit(newOrphan());
    }
    
    public void testVisitParentsAndChildrenAndOrphans() {
        visitor = new OrphanVisitor();
        ChannelTreeNode parent = newParent();
                
        visitor.visit(parent);
        visitor.visit(newChild(parent));
        
        ChannelTreeNode orphan = newOrphan();
        visitor.visit(orphan);
        visitor.visit(newOrphan(orphan.getParentOrSelfId()));
        
        parent = newParent();
        
        visitor.visit(parent);
        visitor.visit(newChild(parent));
        visitor.visit(newOrphan());
        visitor.visit(newOrphan());
        
        orphan = newOrphan();
        
        visitor.visit(orphan);
        visitor.visit(newOrphan(orphan.getParentOrSelfId()));
        visitor.visit(newOrphan(orphan.getParentOrSelfId()));
    }
    
    private ChannelTreeNode newParent() {
        ChannelTreeNode node = new ChannelTreeNode();
        node.setId(idSequence.nextLong());
        node.setParentOrSelfId(node.getId());
        node.setDepth(new Long(1));
        
        visitedNodes.add(node);
        
        return node;
    }
    
    private ChannelTreeNode newChild(ChannelTreeNode parent) {
        ChannelTreeNode child = new ChannelTreeNode();
        child.setId(idSequence.nextLong());
        child.setParentOrSelfId(parent.getId());
        child.setDepth(TWO);
        
        visitedNodes.add(child);
        
        return child;
    }
    
    private ChannelTreeNode newOrphan() {
        ChannelTreeNode orphan = newOrphan(idSequence.nextLong());
        // The parent node needs to be inserted before the orphan
        int index;
        if (visitedOrphans.size() == 0) {
            index = 0;
        }
        else {
            index = visitedOrphans.size() - 1;
        }
        visitedOrphans.add(index, newRestrictedParent(orphan));
        
        return orphan;
    }
    
    private ChannelTreeNode newOrphan(Long parentId) {
        ChannelTreeNode orphan = new ChannelTreeNode();
        orphan.setId(idSequence.nextLong());
        orphan.setDepth(TWO);
        orphan.setParentOrSelfId(parentId);
        
        visitedOrphans.add(orphan);
        
        return orphan;
    }
    
    private ChannelTreeNode newRestrictedParent(ChannelTreeNode orphan) {
        ChannelTreeNode parent = new ChannelTreeNode();
        parent.setAccessible(false);
        parent.setName(LocalizationService.getInstance().getMessage("channel.unavailable"));
        parent.setDepth(new Long(1));
        parent.setId(orphan.getParentOrSelfId());
        parent.setParentOrSelfId(parent.getId());
        
        return parent;
    }

}
