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
package com.redhat.rhn.common.util.test;

import com.redhat.rhn.common.util.CompressionUtil;
import com.redhat.rhn.testing.RhnBaseTestCase;


public class CompressionUtilTest extends RhnBaseTestCase {

    public void testCompress() {
        String toComp = "<xml> my foo xml</xml>";
        byte[] gzip = CompressionUtil.gzipCompress(toComp);
        String decomp = CompressionUtil.gzipDecompress(gzip);
        assertEquals(toComp, decomp);
    }



}
