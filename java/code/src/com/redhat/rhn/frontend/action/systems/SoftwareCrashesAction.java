/**
 * Copyright (c) 2013 Red Hat, Inc.
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
package com.redhat.rhn.frontend.action.systems;

import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.systems.sdc.SdcHelper;
import com.redhat.rhn.frontend.dto.SoftwareCrashDto;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.ListRhnSetHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.Listable;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.system.CrashManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


/**
 * SoftwareCrashesAction
 * @version $Rev$
 */
public class SoftwareCrashesAction extends RhnAction implements Listable {

    /**
    * {@inheritDoc}
    */
   public ActionForward execute(ActionMapping mapping,
           ActionForm formIn,
           HttpServletRequest request,
           HttpServletResponse response) {

       RequestContext context = new RequestContext(request);
       context.copyParamToAttributes("sid");
       Server server = context.lookupAndBindServer();

       ListRhnSetHelper helper = new ListRhnSetHelper(this, request,
               RhnSetDecl.setForSystemCrashes(server));
       helper.execute();
       if (helper.isDispatched()) {
           return handleSubmit(mapping, context, server);
       }

       SdcHelper.ssmCheck(request, server.getId(), context.getLoggedInUser());

       return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
   }

  protected ActionForward handleSubmit(ActionMapping mapping,
          RequestContext ctx, Server server) {
      User user = ctx.getCurrentUser();
      RhnSet set = RhnSetDecl.setForSystemCrashes(server).get(user);
      // until we delete crash files from taskomatic, we have to delete them one by one
      for (Iterator<Long> iter = RhnSetDecl.setForSystemCrashes(server).
              get(user).getElementValues().iterator(); iter.hasNext();) {
          CrashManager.deleteCrash(user, iter.next());
      }
      createSuccessMessage(ctx.getRequest(), "message.crashesdeleted",
              Integer.toString(set.size()));
      Map params = new HashMap();
      params.put("sid", server.getId());
      return getStrutsDelegate().forwardParams(mapping.findForward("delete"),
              params);
  }

   /**
   * {@inheritDoc}
   */
    public List<SoftwareCrashDto> getResult(RequestContext contextIn) {
        User user = contextIn.getCurrentUser();
        Long serverId = contextIn.getParamAsLong("sid");
        Server server = ServerFactory.lookupByIdAndOrg(serverId, user.getOrg());
        return ServerFactory.listServerSoftwareCrashes(server);
    }
}
