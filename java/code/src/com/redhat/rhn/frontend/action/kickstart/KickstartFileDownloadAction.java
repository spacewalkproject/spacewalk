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
package com.redhat.rhn.frontend.action.kickstart;

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.kickstart.BaseKickstartCommand;
import com.redhat.rhn.manager.kickstart.KickstartFileDownloadCommand;
import com.redhat.rhn.manager.kickstart.KickstartUrlHelper;
import com.redhat.rhn.manager.kickstart.cobbler.CobblerXMLRPCHelper;

import org.apache.commons.lang.StringEscapeUtils;
import org.apache.struts.action.DynaActionForm;
import org.cobbler.Profile;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.MalformedURLException;
import java.net.URL;

import javax.servlet.http.HttpServletRequest;

/**
 * KickstartFileDownloadAction extends RhnAction
 * @version $Rev: 1 $
 */
public class KickstartFileDownloadAction extends BaseKickstartEditAction {
        
    public static final String FILEDATA = "filedata";
    public static final String KSURL = "ksurl";
    private static final String INVALID_CHANNEL = "invalid_channel";

    /**
     * {@inheritDoc}
     * no form to process. return null. 
     */
    protected ValidatorError processFormValues(HttpServletRequest request, 
            DynaActionForm form, 
            BaseKickstartCommand cmdIn) {                  
        return null;                
    }

    /**
     * 
     * {@inheritDoc}
     * no success msg to process...return empty string.
     */
    protected String getSuccessKey() {
        return "";
    }

    /**
     * {@inheritDoc}
     */
    protected void setupFormValues(RequestContext ctx, 
            DynaActionForm form, BaseKickstartCommand cmdIn) {
        HttpServletRequest request = ctx.getRequest();
        KickstartFileDownloadCommand cmd = (KickstartFileDownloadCommand) cmdIn;
        KickstartHelper helper = new KickstartHelper(request);
        KickstartUrlHelper urlHelper = new KickstartUrlHelper(
                cmd.getKickstartData(), helper.getKickstartHost());
        

        Profile prof = Profile.lookupById(
                CobblerXMLRPCHelper.getConnection(ctx.getLoggedInUser()),
                cmd.getKickstartData().getCobblerId());
        
        String  url = "http://" + Config.get().getCobblerHost() +  
        urlHelper.getCobblerProfileUrl(prof.getName());
        
        String contents = downloadUrl(url);
        
        /*
         * To generate the file data, our kickstart channel must have at least
         * a minimum list of packages. Verify that those are there before even
         * trying to render the file. However, the auto-kickstart packages are
         * not needed.
         */
        if (helper.verifyKickstartChannel(
                cmdIn.getKickstartData(), ctx.getLoggedInUser(), false)) {
            request.setAttribute(FILEDATA, StringEscapeUtils.escapeHtml(contents));
            request.setAttribute(KSURL, url);
        }
        else {
            request.setAttribute(INVALID_CHANNEL, "true");
        }
    }

    /**
     * {@inheritDoc}
     */
    protected BaseKickstartCommand getCommand(RequestContext ctx) {
        return new KickstartFileDownloadCommand(
                ctx.getRequiredParam(RequestContext.KICKSTART_ID),
                ctx.getCurrentUser(), ctx.getRequest());
    }
    
    
    /**
     * Downloads text from the URL and returns it as a string
     * @param url the url
     * @return the text downloaded
     */
    private String downloadUrl(String url) {
        StringBuffer toReturn = new StringBuffer();
        URL u;
        InputStream is = null;
        try {
           u = new URL(url);
           is = u.openStream();      
           BufferedReader br = new BufferedReader(new InputStreamReader(is));
           
           String s;          
           while ((s = br.readLine()) != null) {
               toReturn.append(s + "\n");
           }
        } 
        catch (MalformedURLException mue) {
            toReturn.append(mue.getLocalizedMessage());
        } 
        catch (IOException ioe) {
            toReturn.append(ioe.getLocalizedMessage());
        }
        finally {
           try {
              if (is != null) {
                  is.close();
              }
           } 
           catch (IOException ioe) {
               toReturn.append(ioe.getLocalizedMessage());
           }
        }
        return toReturn.toString();
    }
    
        
}
