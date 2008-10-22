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
package com.redhat.satellite.search.scheduler.tasks;

import com.redhat.satellite.search.db.models.GenericRecord;
import com.redhat.satellite.search.db.models.HardwareDevice;
import com.redhat.satellite.search.index.builder.BuilderFactory;

import org.apache.log4j.Logger;

import java.util.HashMap;
import java.util.Map;

/**
 * IndexHardwareDevicesTask
 * @version $Rev$
 */
public class IndexHardwareDevicesTask extends GenericIndexTask {

    private static Logger log = Logger.getLogger(IndexHardwareDevicesTask.class);

    /**
     *  {@inheritDoc}
     */
    @Override
    protected Map<String, String> getFieldMap(GenericRecord data)
            throws ClassCastException {
        HardwareDevice dev = (HardwareDevice)data;
        Map<String, String> attrs = new HashMap<String, String>();
        attrs.put("serverId", new Long(dev.getServerId()).toString());
        attrs.put("classInfo", dev.getClassInfo());
        attrs.put("bus", dev.getBus());
        attrs.put("detached", new Long(dev.getDetached()).toString());
        attrs.put("device", dev.getDevice());
        attrs.put("driver", dev.getDriver());
        attrs.put("description", dev.getDescription());
        attrs.put("vendorId", dev.getVendorId());
        attrs.put("deviceId", dev.getDeviceId());
        attrs.put("subVendorId", dev.getSubVendorId());
        attrs.put("subDeviceId", dev.getSubDeviceId());
        attrs.put("pciType", new Long(dev.getPciType()).toString());
        return attrs;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public String getIndexName() {
        return BuilderFactory.HARDWARE_DEVICE_TYPE;
    }

    /**
     *  {@inheritDoc}
     */
    @Override
    protected String getQueryCreateLastRecord() {
        return "createLastHardwareDevice";
    }

    /**
     * {@inheritDoc}
     */
    @Override
    protected String getQueryLastRecord() {
       return "getLastHardwareDeviceId";
    }

    /**
     * {@inheritDoc}
     */
    @Override
    protected String getQueryLastIndexDate() {
        return "getLastHardwareDeviceIndexRun";
    }

    /**
     * {@inheritDoc}
     */
    @Override
    protected String getQueryRecordsToIndex() {
        return "getHardwareDeviceById";
    }

    /**
     * {@inheritDoc}
     */
    @Override
    protected String getQueryUpdateLastRecord() {
        return "updateLastHardwareDevice";
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
        return "queryAllHwDeviceIds";
    }
}
