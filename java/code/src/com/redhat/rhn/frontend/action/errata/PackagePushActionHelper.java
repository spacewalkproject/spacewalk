package com.redhat.rhn.frontend.action.errata;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.rhnpackage.Package;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.PackageOverview;
import com.redhat.rhn.manager.channel.ChannelManager;
import com.redhat.rhn.manager.rhnpackage.PackageManager;
import java.util.Iterator;

/**
 * PackagePushActionHelper
 * Helper class to allow PackagePushAction and PackagePushSetupAction to share logic
 * @version $Rev$
 */
@SuppressWarnings("unchecked")
public class PackagePushActionHelper {
    /** utility class **/
    private PackagePushActionHelper() {
        
    }
    
    /**
     * Gets the packages that don't need user confirmation to be pushed into the
     * channel to which an errata has recently been assigned and adds them to channel.
     * @param c channel to push packages into
     * @param eid errata from which the packages will be retrieved
     * @param user user who is pushing the packages
     */
    public static void pushPackagesNotAlreadyInChannelIntoChannel(Channel c, 
                                                                  Long eid, 
                                                                  User user) {
        DataResult dr = PackageManager.packagesToAutoPushIntoChannel(c.getId(), eid);
        
        Iterator i = dr.iterator();
        
        while (i.hasNext()) {
            PackageOverview po = (PackageOverview) i.next();
            Package p = PackageManager.lookupByIdAndUser(new Long(po.getId().longValue()), 
                                                         user);
            c.addPackage(p);
        }
        
        // Mark the affected channel to have its metadata evaluated, where necessary
        // (RHEL5+, mostly)
        ChannelManager.queueChannelChange(c.getLabel(), 
                "java::pushPackagesNotAlreadyInChannelIntoChannel", null);

    }
}
