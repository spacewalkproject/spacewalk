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
package com.redhat.rhn.frontend.action.kickstart;

import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.kickstart.BaseKickstartCommand;
import com.redhat.rhn.manager.kickstart.KickstartDeleteCommand;

import org.apache.struts.action.DynaActionForm;

import javax.servlet.http.HttpServletRequest;

/**
 * KickstartDeleteAction extends BaseKickstartEditAction
 * @version $Rev:$
 */
public class KickstartDeleteAction extends BaseKickstartEditAction {
    
   /**
    * {@inheritDoc}
    */
   protected String getSuccessKey() {
       return "kickstart.delete.success";
   }

   /**
    * {@inheritDoc}
    */
   protected String getSuccessForward() {
       return "success";
   }
   
   /**
    * {@inheritDoc}
    */
   protected BaseKickstartCommand getCommand(RequestContext ctx) {
       return new KickstartDeleteCommand(ctx.getRequiredParam(RequestContext.KICKSTART_ID),
               ctx.getCurrentUser());
   }
   
   /**
    * {@inheritDoc}
    */
   protected ValidatorError processFormValues(HttpServletRequest request, 
           DynaActionForm form, 
           BaseKickstartCommand cmd) {
       return null;
   }

   /**
    * {@inheritDoc}
    */
   protected void setupFormValues(RequestContext ctx, DynaActionForm form, 
                                                    BaseKickstartCommand cmd) {
       // no-op
   }
}
