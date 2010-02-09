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



import org.jfree.io.IOUtils;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.StringWriter;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;

/**
 * 
 * DownloadUtils
 * @version $Rev$
 */
public class DownloadUtils {

    private DownloadUtils() {
        
    }
    
    /**
     * Downloads text from the URL and returns it as a string
     * @param url the url
     * @return the text downloaded
     */
    public static String downloadUrl(String url) {
        URL u;
        InputStream is = null;
        StringBuilder toReturn = new StringBuilder();
        try {
           u = new URL(url);
           HttpURLConnection conn = (HttpURLConnection)u.openConnection();
           if (conn.getResponseCode() != HttpURLConnection.HTTP_OK) {
               throw new DownloadException(url, 
                               toString(conn.getErrorStream()), 
                               conn.getResponseCode());
           }
           toReturn.append(toString(conn.getInputStream()));
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
    
    private static String toString(InputStream stream) throws IOException {
        StringWriter writer = new StringWriter();
        IOUtils.getInstance().copyWriter(
                new BufferedReader(new InputStreamReader(stream)), writer);
        return writer.toString();
    }
}
