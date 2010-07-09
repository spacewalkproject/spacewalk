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
package com.redhat.rhn.manager.kickstart.cobbler;

import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.domain.action.kickstart.KickstartGuestAction;
import com.redhat.rhn.domain.action.kickstart.KickstartGuestActionDetails;
import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;

import org.apache.log4j.Logger;
import org.cobbler.Network;
import org.cobbler.SystemRecord;

import java.util.Collections;
import java.util.LinkedList;
import java.util.List;


/**
 *
 * @version $Rev$
 */
public class CobblerVirtualSystemCommand extends CobblerSystemCreateCommand {

    /**
     * Logger for this class
     */
    private static Logger log = Logger
            .getLogger(CobblerVirtualSystemCommand.class);

    private String guestName;

    /**
     * Constructor
     * @param serverIn to create in cobbler
     * @param cobblerProfileName to use
     * @param guestNameIn the guest name to create
     * @param ksData the kickstart data to associate
     *      system with
     */
    public CobblerVirtualSystemCommand(Server serverIn,
            String cobblerProfileName, String guestNameIn, KickstartData ksData) {
        super(serverIn, cobblerProfileName, ksData);
        guestName = guestNameIn;
    }

    /**
     * Constructor
     * @param userIn who is requesting the sync
     * @param serverIn profile we want to create in cobbler
     * @param ksDataIn profile to associate with with server.
     * @param mediaPathIn mediaPath to override in the server profile.
     * @param activationKeysIn to add to the system record.  Used when the system
     * @param guestNameIn the guest name to create
     * re-registers to Spacewalk
     */
    public CobblerVirtualSystemCommand(User userIn, Server serverIn,
            KickstartData ksDataIn, String mediaPathIn,
                            String activationKeysIn, String guestNameIn) {
        super(userIn, serverIn, ksDataIn, mediaPathIn, activationKeysIn);
        guestName = guestNameIn;
    }

    /**
     * Constructor
     * @param userIn who is requesting the sync
     * @param serverIn profile we want to create in cobbler
     * @param nameIn profile nameIn to associate with with server.
     */
    public CobblerVirtualSystemCommand(User userIn, Server serverIn,
            String nameIn) {
        super(userIn, serverIn, nameIn);
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public String getCobblerSystemRecordName() {
        return super.getCobblerSystemRecordName() + ":" + guestName.replace(' ', '_');
    }

    @Override
    protected void processNetworkInterfaces(SystemRecord rec, Server serverIn) {
        log.debug("processNetworkInterfaces called.");
        String newMac = (String) invokeXMLRPC("get_random_mac", Collections.EMPTY_LIST);
        Network net = new Network("eth0");
        net.setMacAddress(newMac);
        List<Network> nics = new LinkedList<Network>();
        nics.add(net);
        rec.setNetworkInterfaces(nics);
    }


    protected SystemRecord lookupExisting() {
        log.debug("lookupExisting called.");

        return SystemRecord.lookupByName(
                CobblerXMLRPCHelper.getConnection(user), getCobblerSystemRecordName());
    }


    /**
     * Updates the cobbler virt attributes based on
     * params provided
     * @param memoryMB the memory in MB
     * @param diskSizeGb the diskSize in GB
     * @param vcpus the number of cpus
     * @param diskPath the disk path of the virt image.
     */
    protected void setupVirtAttributes(int memoryMB, int diskSizeGb,
            int vcpus, String diskPath) {
        SystemRecord rec = SystemRecord.lookupByName(
                CobblerXMLRPCHelper.getConnection(user), getCobblerSystemRecordName());
        if (rec != null) {
            rec.setVirtRam(memoryMB);
            rec.setVirtFileSize(diskSizeGb);
            rec.setVirtCpus(vcpus);
            rec.setVirtPath(diskPath);
            rec.save();
        }
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public ValidatorError store() {
        ValidatorError error = super.store();
        if (error == null) {
            KickstartGuestAction action = (KickstartGuestAction) getScheduledAction();
            KickstartGuestActionDetails details = action.getKickstartGuestActionDetails();
            setupVirtAttributes(details.getMemMb().intValue(),
                            details.getDiskGb().intValue(),
                            details.getVcpus().intValue(),
                            details.getDiskPath());
        }
        return error;
    }

}
