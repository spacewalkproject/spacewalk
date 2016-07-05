/**
 * Copyright (c) 2016 Red Hat, Inc.
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
package com.redhat.rhn.frontend.action.systems.test;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.redhat.rhn.frontend.action.systems.SystemSearchHelper;
import com.redhat.rhn.frontend.dto.SystemOverview;

import junit.framework.TestCase;

/**
 * JUnit primarily for SystemSearchHelper.SearchResultScoreComparator
 * Could/should be expanded to cover more of SystemSearchHelper (which
 * has zero Junit coverage currently...)
 *
 * @author ggainey
 *
 */
public class SystemSearchHelperTest extends TestCase {

    // LABEL;SCORE;PROFILE-NAME;SID
    // SCORE==-1 => null-score
    static final int LABEL = 0;
    static final int SCORE = 1;
    static final int PROFILE_NAME = 2;
    static final int SID = 3;

    static final int A_EQUAL_B = 0;
    static final int A_FIRST = -1;
    static final int B_FIRST = 1;

    static final String[] TEST_DATA = {
                    "null-1-1101;-1.0d;profile1;1101",
                    "null-1-1102;-1.0d;profile1;1102",
                    "10-1-1100;10.0d;profile1;1100",
                    "20-1-1110;20.0d;profile1;1110",
                    "30-1-1115;30.0d;profile1;1115",
                    "null-2-1201;-1.0d;profile2;1201",
                    "10-2-1200;10.0d;profile2;1200",
                    "20-2-1210;20.0d;profile2;1210",
                    "30-2-1215;30.0d;profile2;1215",
                    "10-3-1300;10.0d;profile3;1300",
                    "10-3-1310;10.0d;profile3;1310",
                    "10-3-1315;10.0d;profile3;1315"
                    };

    static final long EMPTY_SID = 666L;

    protected Map<String, SystemOverview> dtos;
    protected Map<Long, Map<String, Double>> scores;
    protected SystemSearchHelper.SearchResultScoreComparator cmp;
    protected SystemSearchHelper.SearchResultScoreComparator nullCmp;

    public SystemSearchHelperTest() {
        // TODO Auto-generated constructor stub
    }

    public SystemSearchHelperTest(String name) {
        super(name);
    }

    @Override
    public void setUp() throws Exception {
        super.setUp();
        dtos = new HashMap<String, SystemOverview>();
        scores = new HashMap<Long, Map<String, Double>>();

        for (String vals : TEST_DATA) {
            String[] entries = vals.split(";");
            Map<String, Double> serverScore = new HashMap<String, Double>();
            SystemOverview aDto = new SystemOverview();
            aDto.setId(Long.parseLong(entries[SID]));
            aDto.setName(entries[PROFILE_NAME]);
            Double aScore = Double.parseDouble(entries[SCORE]);
            if (aScore > 0.0d) {
                serverScore.put("score", aScore);
            }
            scores.put(aDto.getId(), serverScore);
            dtos.put(entries[LABEL], aDto);
        }

        SystemOverview aDto = new SystemOverview();
        aDto.setId(EMPTY_SID);
        aDto.setName("NO-RESULTS");
        scores.put(EMPTY_SID, null);
        dtos.put("NO_RESULTS", aDto);

        cmp = new SystemSearchHelper.SearchResultScoreComparator(scores);

        nullCmp = new SystemSearchHelper.SearchResultScoreComparator(null);
    }

    // No results?
    // Sort by profile then reverse-SID
    public void testNullResultsSameDto() {
        assertEquals(A_EQUAL_B,
                        nullCmp.compare(dtos.get("10-1-1100"), dtos.get("10-1-1100")));
    }
    public void testNullResultsSameScoreDiffProfAFirst() {
        assertEquals(A_FIRST,
                        nullCmp.compare(dtos.get("10-1-1100"), dtos.get("10-2-1200")));
    }
    public void testNullResultsSameScoreDiffProfBFirst() {
        assertEquals(B_FIRST,
                        nullCmp.compare(dtos.get("10-2-1200"), dtos.get("10-1-1100")));
    }
    public void testNullResultsSameScoreSameProfDiffSidAFirst() {
        assertEquals(A_FIRST,
                        nullCmp.compare(dtos.get("10-3-1310"), dtos.get("10-3-1300")));
    }
    public void testNullResultsSameScoreSameProfDiffSidBFirst() {
        assertEquals(B_FIRST,
                        nullCmp.compare(dtos.get("10-3-1300"), dtos.get("10-3-1310")));
    }

    public void testEqual() {
        assertEquals(A_EQUAL_B, cmp.compare(dtos.get("10-1-1100"), dtos.get("10-1-1100")));
    }

    public void testEqualScoreDiffProfile() {
        assertEquals(A_FIRST, cmp.compare(dtos.get("10-1-1100"), dtos.get("10-2-1200")));
        assertEquals(B_FIRST, cmp.compare(dtos.get("10-2-1200"), dtos.get("10-1-1100")));
    }

    public void testEqualScoreSameProfile() {
        assertEquals(B_FIRST, cmp.compare(dtos.get("10-3-1310"), dtos.get("10-3-1315")));
        assertEquals(A_FIRST, cmp.compare(dtos.get("10-3-1315"), dtos.get("10-3-1310")));
    }

    public void testNullScoreBothSame() {
        assertEquals(A_EQUAL_B,
                        cmp.compare(dtos.get("null-1-1101"), dtos.get("null-1-1101")));
    }
    public void testNullScoreBothDiffProfile() {
        assertEquals(A_FIRST,
                        cmp.compare(dtos.get("null-1-1101"), dtos.get("null-2-1201")));
        assertEquals(B_FIRST,
                        cmp.compare(dtos.get("null-2-1201"), dtos.get("null-1-1101")));
    }
    public void testNullScoreBothDiffSID() {
        assertEquals(A_FIRST,
                        cmp.compare(dtos.get("null-1-1102"), dtos.get("null-1-1101")));
        assertEquals(B_FIRST,
                        cmp.compare(dtos.get("null-1-1101"), dtos.get("null-1-1102")));
    }
    public void testNullScoreSecond() {
        assertEquals(A_FIRST, cmp.compare(dtos.get("10-1-1100"), dtos.get("null-1-1101")));
    }
    public void testNullScoreFirst() {
        assertEquals(B_FIRST, cmp.compare(dtos.get("null-1-1101"), dtos.get("10-1-1100")));
    }

/*
    "null-1-1101;-1.0d;profile1;1101",
    "null-1-1102;-1.0d;profile1;1102",
    "10-1-1100;10.0d;profile1;1100",
    "20-1-1110;20.0d;profile1;1110",
    "30-1-1115;30.0d;profile1;1115",
    "null-2-1201;-1.0d;profile2;1201",
    "10-2-1200;10.0d;profile2;1200",
    "20-2-1210;20.0d;profile2;1210",
    "30-2-1215;30.0d;profile2;1215",
    "10-3-1300;10.0d;profile3;1300",
    "10-3-1310;10.0d;profile3;1310",
    "10-3-1315;10.0d;profile3;1315"
should sort to
    "30-1-1115;30.0d;profile1;1115",
    "30-2-1215;30.0d;profile2;1215",
    "20-1-1110;20.0d;profile1;1110",
    "20-2-1210;20.0d;profile2;1210",
    "10-1-1100;10.0d;profile1;1100",
    "10-2-1200;10.0d;profile2;1200",
    "10-3-1315;10.0d;profile3;1315"
    "10-3-1310;10.0d;profile3;1310",
    "10-3-1300;10.0d;profile3;1300",
    "null-1-1102;-1.0d;profile1;1102",
    "null-1-1101;-1.0d;profile1;1101",
    "null-2-1201;-1.0d;profile2;1201",
*/
    public void testListSort() {
        List<SystemOverview> systems = new ArrayList<SystemOverview>(dtos.values());
        assertEquals(dtos.size(), systems.size());
        java.util.Collections.sort(systems, cmp);
        assertTrue(1115L == systems.get(0).getId());
        assertTrue(1215L == systems.get(1).getId());
        assertTrue(1110L == systems.get(2).getId());
        assertTrue(1210L == systems.get(3).getId());
        assertTrue(1100L == systems.get(4).getId());
        assertTrue(1200L == systems.get(5).getId());
        assertTrue(1315L == systems.get(6).getId());
        assertTrue(1310L == systems.get(7).getId());
        assertTrue(1300L == systems.get(8).getId());
        assertTrue(1102L == systems.get(9).getId());
        assertTrue(1101L == systems.get(10).getId());
        assertTrue(1201L == systems.get(11).getId());
    }
}
