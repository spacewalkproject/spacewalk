/**
 * Copyright (c) 2008--2010 Red Hat, Inc.
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
package com.redhat.satellite.search.scheduler.tasks;


import com.redhat.satellite.search.db.models.GenericRecord;
import com.redhat.satellite.search.db.models.Server;
import com.redhat.satellite.search.index.builder.BuilderFactory;

import java.util.HashMap;

import java.util.Map;


// Main tasks:
// 1) Index new systems, i.e. system id is greater than last recorded system id indexed.
// 2) Update the existing index of systems which have been modified
// 3) Remove systems which have been deleted from the system.

/**
 * IndexSystemsTask
 * @version $Rev$
 */
public class IndexSystemsTask extends GenericIndexTask {
    /**
     *  {@inheritDoc}
     */
    @Override
    protected Map<String, String> getFieldMap(GenericRecord data)
            throws ClassCastException {
        Server srvr = (Server)data;

        Map<String, String> attrs = new HashMap<String, String>();
        attrs.put("id", new Long(srvr.getId()).toString());
        attrs.put("system_id", new Long(srvr.getId()).toString());
        attrs.put("name", srvr.getName());
        attrs.put("description", srvr.getDescription());
        attrs.put("info", srvr.getInfo());
        attrs.put("runningKernel", srvr.getRunningKernel());
        attrs.put("machine", srvr.getMachine());
        attrs.put("rack", srvr.getRack());
        attrs.put("room", srvr.getRoom());
        attrs.put("building", srvr.getBuilding());
        attrs.put("address1", srvr.getAddress1());
        attrs.put("address2", srvr.getAddress2());
        attrs.put("city", srvr.getCity());
        attrs.put("state", srvr.getState());
        attrs.put("country", srvr.getCountry());
        attrs.put("hostname", srvr.getHostname());
        attrs.put("ipaddr", srvr.getIpaddr());
        attrs.put("dmiVendor", srvr.getDmiVendor());
        attrs.put("dmiSystem", srvr.getDmiSystem());
        attrs.put("dmiProduct", srvr.getDmiProduct());
        attrs.put("dmiBiosVendor", srvr.getDmiBiosVendor());
        attrs.put("dmiBiosVersion", srvr.getDmiBiosVersion());
        attrs.put("dmiBiosRelease", srvr.getDmiBiosRelease());
        attrs.put("dmiAsset", srvr.getDmiAsset());
        attrs.put("dmiBoard", srvr.getDmiBoard());
        attrs.put("cpuBogoMIPs", srvr.getCpuBogoMIPS());
        attrs.put("cpuCache", srvr.getCpuCache());
        attrs.put("cpuFamily", srvr.getCpuFamily());
        attrs.put("cpuMhz", srvr.getCpuMhz());
        attrs.put("cpuStepping", srvr.getCpuStepping());
        attrs.put("cpuFlags", srvr.getCpuFlags());
        attrs.put("cpuModel", srvr.getCpuModel());
        attrs.put("cpuVersion", srvr.getCpuVersion());
        attrs.put("cpuVendor", srvr.getCpuVendor());
        if (srvr.getCpuNumberOfCpus() != null) {
            attrs.put("cpuNumberOfCpus", srvr.getCpuNumberOfCpus().toString());
        }
        attrs.put("cpuAcpiVersion", srvr.getCpuAcpiVersion());
        attrs.put("cpuApic", srvr.getCpuApic());
        attrs.put("cpuApmVersion", srvr.getCpuApmVersion());
        attrs.put("cpuChipset", srvr.getCpuChipset());
        attrs.put("checkin", srvr.getCheckin());
        attrs.put("registered", srvr.getRegistered());
        attrs.put("ram", srvr.getRam());
        attrs.put("swap", srvr.getSwap());
        return attrs;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public String getIndexName() {
        return BuilderFactory.SERVER_TYPE;
    }

    /**
     *  {@inheritDoc}
     */
    @Override
    protected String getQueryCreateLastRecord() {
        return "createLastServer";
    }

    /**
     * {@inheritDoc}
     */
    @Override
    protected String getQueryLastRecord() {
       return "getLastServerId";
    }

    /**
     * {@inheritDoc}
     */
    @Override
    protected String getQueryLastIndexDate() {
        return "getLastServerIndexRun";
    }

    /**
     * {@inheritDoc}
     */
    @Override
    protected String getQueryRecordsToIndex() {
        return "getServerByIdOrDate";
    }

    /**
     * {@inheritDoc}
     */
    @Override
    protected String getQueryUpdateLastRecord() {
        return "updateLastServer";
    }
    
    /**
     * {@inheritDoc}
     */
    public String getUniqueFieldId() {
        return "id";
    }
    
    /**
     * {@inheritDoc}
     */
    public String getQueryAllIds() {
        return "queryAllServerIds";
    }
}
