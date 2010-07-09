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
package com.redhat.rhn.scripts;

import com.redhat.rhn.frontend.nav.DepthGuard;
import com.redhat.rhn.frontend.nav.NavDigester;
import com.redhat.rhn.frontend.nav.NavNode;
import com.redhat.rhn.frontend.nav.NavTree;
import com.redhat.rhn.frontend.nav.NavTreeIndex;
import com.redhat.rhn.frontend.nav.Renderable;
import com.redhat.rhn.frontend.nav.TextRenderer;

import java.io.File;
import java.io.FileNotFoundException;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.List;
import java.util.Map;

/**
 * DumpNavTree is a utility that will read the given sitenav xml file and dump
 * its contents to stdout in text format.
 * @version $Rev$
 */
public class DumpNavTree {
    private NavTreeIndex treeIndex;
    private StringBuffer result;

    private DumpNavTree(NavTreeIndex ti) {
        treeIndex = ti;
        result = new StringBuffer();
    }

    /**
     * Dumps the nav tree to stdout using the TextRenderer.
     * @see TextRenderer
     */
    private void dumpTree() {
        Renderable r = new TextRenderer();
        r.setRenderGuard(new DepthGuard(0, Integer.MAX_VALUE));
        System.out.println(render(r));
    }

    private static void usage() {
        System.out.println("Usage: DumpNavTree <navfilename>");
    }


    /**
     * Main method, expects a sitenav xml file name
     * @param args the sitenav xml file name as the first argument.
     */
    public static void main(String[] args) {
        if (args.length < 1) {
            usage();
            System.exit(-1);
        }

        String filename = args[0];

        try {
            File file = new File(filename);
            URL url = file.toURL();
            System.out.println("Reading: " + url.toString());
            NavTree nt =
                NavDigester.buildTree(url);
            NavTreeIndex nti = new NavTreeIndex(nt);
            DumpNavTree dnt = new DumpNavTree(nti);
            dnt.dumpTree();
        }
        catch (MalformedURLException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        catch (FileNotFoundException fnfe) {
            System.out.println("Couldn't find [" + filename + "]");
        }
        catch (Exception e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
    }

    private String render(Renderable renderer) {
        result = new StringBuffer();
        List todo = treeIndex.getTree().getNodes();

        renderer.preNav(result);
        this.renderLevel(renderer, todo, null, 0);
        renderer.postNav(result);

        return result.toString();
    }

    private void renderLevel(Renderable renderer, List todo,
                             Map parameters, int depth) {
        if (todo == null || todo.size() == 0) {
            return;
        }

        renderer.preNavLevel(result, depth);

        int size = todo.size();
        for (int i = 0; i < size; i++) {
            NavNode node = (NavNode) todo.get(i);

            // mark the nodes as first or last based on index.
            if (i == 0) {
                node.setFirst(true);
            }
            else if (i == (size - 1)) {
                node.setLast(true);
            }

            renderer.preNavNode(this.result, depth);

            renderer.navNodeActive(result, node, treeIndex, parameters, depth);
            if (renderer.nodeRenderInline(depth)) {
                renderLevel(renderer, node.getNodes(), parameters, depth + 1);
            }

            renderer.postNavNode(this.result, depth);
        }


        renderer.postNavLevel(result, depth);
    }

}
