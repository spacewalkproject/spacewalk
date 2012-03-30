/**
 * Copyright (c) 2012 Novell
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

package com.redhat.rhn.frontend.action.renderers;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.LinkedList;
import java.util.List;

import javax.servlet.http.HttpServletRequest;

import org.apache.log4j.Logger;

import com.redhat.rhn.domain.credentials.Credentials;
import com.redhat.rhn.domain.credentials.CredentialsFactory;
import com.redhat.rhn.domain.image.Image;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.listview.PageControl;
import com.redhat.rhn.frontend.taglibs.list.ListTagHelper;
import com.suse.studio.client.SUSEStudio;
import com.suse.studio.client.model.Appliance;
import com.suse.studio.client.model.Build;

/**
 * Asynchronously render the page content for image selection and deployment.
 */
public class ImagesRenderer extends BaseFragmentRenderer {

    private static Logger logger = Logger.getLogger(ImagesRenderer.class);

    // Attribute keys
    public static final String ATTRIB_IMAGES_LIST = "imagesList";
    public static final String ATTRIB_ERROR_MSG = "errorMsg";

    // List of all valid image types
    private static List<String> validImageTypes = Arrays.asList("vmx", "xen");

    // The URL of the page to render
    private static final String PAGE_URL =
            "/WEB-INF/pages/systems/details/virtualization/images/images-render-async.jsp";

    /**
     * {@inheritDoc}
     */
    @Override
    protected void render(User user, PageControl pc, HttpServletRequest request) {
        List<Image> images = null;
        try {
            // Get the list of images and sort it
            images = getImages(user, request);
            Collections.sort(images);

            // Set the "parentUrl" for the form (in rl:listset)
            request.setAttribute(ListTagHelper.PARENT_URL, "");

            // Store the set of images (if any) to the session
            if (images != null && !images.isEmpty()) {
                request.getSession().setAttribute(ATTRIB_IMAGES_LIST, images);
            }
        }
        catch (IOException e) {
            logger.error(e.getMessage());
            request.setAttribute(ATTRIB_ERROR_MSG, "images.message.error.connection");
        }
    }

    /**
     * Get a list of appliance builds from SUSE Studio.
     * @param user
     * @return list of {@link Image} objects
     */
    private List<Image> getImages(User user, HttpServletRequest request)
            throws IOException {
        List<Appliance> ret = new ArrayList<Appliance>();

        // Lookup credentials and url
        Credentials creds = CredentialsFactory.lookupStudioCredentials(user);
        if (creds != null && creds.isComplete()) {
            String studioUser = creds.getUsername();
            String studioKey = creds.getPassword();
            String studioUrl = creds.getUrl();

            // Get appliance builds from studio
            SUSEStudio studio = new SUSEStudio(studioUser, studioKey, studioUrl);
            ret = studio.getAppliances();
        }
        else {
            request.setAttribute(ATTRIB_ERROR_MSG, "images.message.error.nocreds");
        }

        // Convert to a list of images
        return convertAppliances(ret);
    }

    /**
     * Convert a list of {@link Appliance}s to a list of {@link Image}s.
     * @param appliances list of appliances
     * @return list of images
     */
    private List<Image> convertAppliances(List<Appliance> appliances) {
        List<Image> ret = new LinkedList<Image>();
        for (Appliance appliance : appliances) {
            // Create one image object for every build
            for (Build build : appliance.getBuilds()) {
                // Skip this build if image type is unsupported
                if (!validImageTypes.contains(build.getImageType())) {
                    continue;
                }
                Image img = new Image();
                // Appliance attributes
                img.setArch(appliance.getArch());
                img.setEditUrl(appliance.getEditUrl());
                img.setName(appliance.getName());
                // Build attributes
                img.setDownloadUrl(build.getDownloadUrl());
                img.setId(new Long(build.getId()));
                img.setImageSize(build.getImageSize());
                img.setImageType(build.getImageType());
                img.setVersion(build.getVersion());
                ret.add(img);
            }
        }
        return ret;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    protected String getPageUrl() {
        return PAGE_URL;
    }
}
