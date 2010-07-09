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
package com.redhat.rhn.frontend.filter.test;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.frontend.filter.TreeFilter;
import com.redhat.rhn.testing.RhnBaseTestCase;

import java.util.LinkedList;
import java.util.List;


/**
 * TreeFilterTest
 * @version $Rev$
 */
public class TreeFilterTest extends RhnBaseTestCase {

    private DataResult main;
    private TreeFilter filter;


    public void setUp() {

        main = populate();
        filter = new TreeFilter();
    }

    private DataResult populate() {

        /**
         * Content Tree looks like this
         *
         *        Aa1              Ba1       Ca1           Dd1    Da1
         *       /  \              /  \      /  \
         *     Aa2   Ab4          Bb2 Bb6   Bb7  Bb8
         *     /     /  \         /                 \
         *    Aa3   Ac5  Ac6     Bb3                Aa4
         *                       /                   \
         *                      Bb4                  Aa5
         *                      /                      \
         *                      Bb5                   Aa6
         */

        String tree = "(Aa1,0) (Aa2,1) (Aa3,2) (Ab4,1) (Ac5,2) (Ac6,2)" +
                          "(Ba1,0)(Bb2,1) (Bb3,2) (Bb4,3) (Bb5,4) (Bb6,1)" +
                            "(Ca1,0) (Bb7,1) (Bb8,1) (Aa4,2) (Aa5,3) (Aa6,4)" +
                            "(Dd1,0) (Da1,0)";
        return makeDataResult(tree);
    }

    public void testEmptySearch() {
        //we search on "" as the search filter value
        // and expect everything to show up.
        DataResult dr = new DataResult(main);
        filter.filterData(dr, "", "");
        assertEquals(main, dr);
        dr = new DataResult(main);
        filter.filterData(dr, "", "content");
        assertEquals(main, dr);

        //now try an impossible search
        dr = new DataResult(main);
        filter.filterData(dr, "HAHAHAHAHAHAHAHA", "content");
        assertTrue(dr.isEmpty());
   }

    public void testRootElementSearch() {
        assertFilter("Aa1", "(Aa1, 0)");
        assertFilter("Ba1", "(Ba1, 0)");
        assertFilter("Ca1", "(Ca1, 0)");
        assertFilter("Dd1", "(Dd1, 0)");
        assertFilter("Da1", "(Da1, 0)");
    }

    public void testSinglePathSearch() {
        assertFilter("Aa2", "(Aa1, 0) (Aa2,1)");
        assertFilter("Ac6", "(Aa1, 0) (Ab4,1) (Ac6,2)");
        assertFilter("Bb6", "(Ba1, 0) (Bb6,1)");
        assertFilter("Bb5", "(Ba1, 0) (Bb2,1) (Bb3,2) (Bb4,3) (Bb5,4)");
        assertFilter("Bb4", "(Ba1, 0) (Bb2,1) (Bb3,2) (Bb4,3)");
        assertFilter("Bb3", "(Ba1, 0) (Bb2,1) (Bb3,2)");

        assertFilter("Aa6", "(Ca1, 0) (Bb8,1) (Aa4,2) (Aa5,3) (Aa6,4)");
        assertFilter("Aa5", "(Ca1, 0) (Bb8,1) (Aa4,2) (Aa5,3)");
        assertFilter("Bb7", "(Ca1, 0) (Bb7,1)");
    }

    public void testMultiPathSearch() {
        assertFilter("Aa",
                "(Aa1, 0) (Aa2,1) (Aa3,2)" +
                "(Ca1,0) (Bb8,1) (Aa4,2) (Aa5,3) (Aa6,4)");


        assertFilter("Bb",
                "(Ba1, 0) (Bb2,1) (Bb3,2) (Bb4,3) (Bb5,4) (Bb6,1)" +
                "(Ca1,0) (Bb7,1) (Bb8,1)");

        assertFilter("a",
                "(Aa1, 0) (Aa2,1) (Aa3,2) (Ab4,1) (Ac5,2) (Ac6,2) (Ba1,0)" +
                "(Ca1,0) (Bb8,1) (Aa4,2) (Aa5,3) (Aa6,4)" +
                "(Da1,0)");

        assertFilter("b",
                "(Aa1, 0) (Ab4,1)" +
                "(Ba1, 0) (Bb2,1) (Bb3,2) (Bb4,3) (Bb5,4) (Bb6,1)" +
                    "(Ca1,0) (Bb7,1) (Bb8,1)");
    }


    private void assertFilter(String searchVal, String expected) {
        DataResult dr = new DataResult(main);
        filter.filterData(dr, searchVal, "content");
        assertEquals(makeDataResult(expected), dr);
    }

    /**
     * Pass in an input string like "(content, depth) (content, depth)..."
     * and it returns a DataResult with a DepthAware Bean for each row..
     * @param input Content String
     * @return DataResult of DepthAwareBeans
     */
    private DataResult makeDataResult(String input) {
        List lst = new LinkedList();
        //input = "(content,depth) (content,depth)"
        input = input.trim();
        input = input.substring(1, input.length() - 1);
        String[] contents =  input.split("\\)\\W*\\(");

        for (int i = 0; i < contents.length; i++) {
            //contents[i] = "(content,depth)"
            String val = contents[i].trim();
          //val = "content,depth"
            String [] tuple = val.split(",");
            lst.add(DepthAwareBean.instance(tuple[0].trim(),
                                Integer.parseInt(tuple[1].trim())));
        }
        return new DataResult(lst);
    }
}
