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
package com.redhat.rhn.common.util.download;

import com.redhat.rhn.common.RhnRuntimeException;


/**
 * DownloadException
 * @version $Rev$
 */
public class DownloadException extends RhnRuntimeException {

    /**
     * Comment for <code>serialVersionUID</code>
     */
    private static final long serialVersionUID = -4736455302534983513L;
    private String content;
    private String url;
    private int errorCode;
    private static final String ERROR_TEMPLATE = "Error occured while downloading " +
                                "contents from [%s].\nHere are the contents of" +
                                 " the error\n [%s] \n \n error code = [%s]";
    
    /**
     * @param msg the error message
     * @param t the throwable exception
     */
    public DownloadException(String msg, Throwable t) {
        super(msg, t);
    }

    /**
     * Raised by the DownloadUtil class
     * when an error occurs while downloading  contentst from an 
     * http url
     * @param urlIn the http url where the attempt was made
     * @param contentIn the contents of the error stream
     * @param errorCodeIn the response code
     */
    public DownloadException(String urlIn,
                        String contentIn, 
                        int errorCodeIn) {
        super(String.format(ERROR_TEMPLATE, urlIn, contentIn, errorCodeIn));
        url = urlIn;
        content = contentIn;
        errorCode = errorCodeIn;
    }
    
    /**
     * the error response code
     * matches the codes from HttpURLConnection 
     * @return the error code.
     */
    public int getErrorCode() {
        return errorCode;
    }
    
    /**
     * The Download Url where the error came from ..  
     * @return the download URL
     */
    public String getUrl()  {
        return url;
    }
    
    /**
     * The contents of the error stream  
     * @return the contents of the error stream
     */
    public String getContent() {
        return content;
    }
    
}
