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
package com.redhat.rhn.frontend.taglibs.list.decorators;

import com.redhat.rhn.common.db.datasource.Elaborator;
import com.redhat.rhn.frontend.taglibs.list.ListTag;
import com.redhat.rhn.frontend.taglibs.list.TagHelper;

import java.util.List;


/**
 * ElaborationDecorator
 * @version $Rev$
 */
public class ElaborationDecorator extends BaseListDecorator {


    /**
     * {@inheritDoc}
     */
    public void setCurrentList(ListTag current) {
        super.setCurrentList(current);
        if (current != null) {
            elaborateContents();
        }

    }

    private void elaborateContents() {
        List data = getCurrentList().getPageData();
        Elaborator elab = TagHelper.lookupElaboratorFor(getCurrentList().
                                                                  getUniqueName(),
                                    getCurrentList().getContext().getRequest());
        if ((data == null) || (data.isEmpty())) {
            return;
        }
        if (elab == null) {
            String msg = "Elaborator NOT BOUND!.." +
                        " This is needed if you are using the ElborationDecorator." +
                            " Check out TagHelper.bindElaboratorTo.." +
                            " for List -> " + getCurrentList().getUniqueName();
            throw new RuntimeException(msg);
        }
        elab.elaborate(data);
    }

}
