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
package com.redhat.rhn.frontend.action.systems.provisioning;

import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.frontend.action.BaseEditAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.PersistOperation;
import com.redhat.rhn.manager.common.BaseFileListEditCommand;

import org.apache.struts.action.DynaActionForm;

/**
 * AbstractPreservationListEditAction - stuts action for editing/creating
 * FileLists.
 * @version $Rev: 1 $
 */
public abstract class BasePreservationListEditAction extends BaseEditAction {

    public static final String FILE_LIST = "fileList";
    public static final String LABEL = "label";
    public static final String FILES_STRING = "files";

    protected String getSuccessKey() {
        return "preservation.key.success";
    }

    protected void processRequestAttributes(RequestContext rctx, PersistOperation opr) {
        BaseFileListEditCommand bopr = (BaseFileListEditCommand) opr;
        rctx.getRequest().setAttribute(FILE_LIST, bopr.getFileList());
    }

    protected ValidatorError processCommandSetters(PersistOperation opr,
                                                        DynaActionForm form) {
        BaseFileListEditCommand bopr = (BaseFileListEditCommand) opr;
        bopr.setLabel(form.getString(LABEL));
        bopr.updateFiles(form.getString(FILES_STRING));
        return null;
    }

    protected void processFormValues(PersistOperation opr, DynaActionForm form) {
        BaseFileListEditCommand bopr = (BaseFileListEditCommand) opr;
        form.set(LABEL, bopr.getFileList().getLabel());
        form.set(FILES_STRING, bopr.getFileListString());
    }

}
