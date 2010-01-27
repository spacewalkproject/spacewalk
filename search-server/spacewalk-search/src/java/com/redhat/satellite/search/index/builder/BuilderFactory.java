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
package com.redhat.satellite.search.index.builder;


/**
 * BuilderFactory
 * @version $Rev$
 */
public class BuilderFactory {

    public static final String ERRATA_TYPE = "errata";
    public static final String PACKAGES_TYPE = "packages";
    public static final String SERVER_TYPE = "server";
    public static final String DOCS_TYPE = "docs";
    public static final String HARDWARE_DEVICE_TYPE = "hwdevice";
    public static final String SNAPSHOT_TAG_TYPE = "snapshotTag";
    public static final String SERVER_CUSTOM_INFO_TYPE = "serverCustomInfo";
    /**
     * Private constructor.
     */
    private BuilderFactory() {
    }

    /**
     * Returns a Builder suitable for building the wanted type. Invalid types
     * will throw an UnsupportedOperationException.
     * @param type Valid type of builder.
     * @return Suitable builder.
     */
    public static DocumentBuilder getBuilder(String type) {
        if (ERRATA_TYPE.equals(type)) {
            return new ErrataDocumentBuilder();
        }
        else if (PACKAGES_TYPE.equals(type)) {
            return new PackageDocumentBuilder();
        }
        else if (SERVER_TYPE.equals(type)) {
            return new ServerDocumentBuilder();
        }
        else if (HARDWARE_DEVICE_TYPE.equals(type)) {
            return new HardwareDeviceDocumentBuilder();
        }
        else if (SNAPSHOT_TAG_TYPE.equals(type)) {
            return new SnapshotTagDocumentBuilder();
        }
        else if (SERVER_CUSTOM_INFO_TYPE.equals(type)) {
            return new ServerCustomInfoDocumentBuilder();
        }
        else {
            throw new UnsupportedOperationException(type +
                    " is an unsuppported type");
        }
    }
}
