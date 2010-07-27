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
package com.redhat.rhn.frontend.xmlrpc.serializer;

import java.util.LinkedList;
import java.util.List;


/**
 * SerializerRegistry
 *
 * Stores a list of serializer classes for registration the first time a SerializerFactory
 * is used. Previously we were doing this by searching a package in the jar and extracting
 * classes that implement the correct interface, but problems were encountered with
 * existing satellite's and likely Tomcat caching. We're unsure of how stable this will be
 * in the future so resorting to an explicit method of declaring serializer classes once
 * again.
 *
 * @version $Rev$
 */
public class SerializerRegistry {

    private SerializerRegistry() {
        // Hide the default constructor.
    }

    private static final List<Class> SERIALIZER_CLASSES;
    static {
        SERIALIZER_CLASSES = new LinkedList<Class>();
        SERIALIZER_CLASSES.add(ActivationKeySerializer.class);
        SERIALIZER_CLASSES.add(TokenSerializer.class);
        SERIALIZER_CLASSES.add(ChannelArchSerializer.class);
        SERIALIZER_CLASSES.add(ChannelOverviewSerializer.class);
        SERIALIZER_CLASSES.add(ChannelSerializer.class);
        SERIALIZER_CLASSES.add(CpuSerializer.class);
        SERIALIZER_CLASSES.add(DeviceSerializer.class);
        SERIALIZER_CLASSES.add(DmiSerializer.class);
        SERIALIZER_CLASSES.add(EntitlementServerGroupSerializer.class);
        SERIALIZER_CLASSES.add(ErrataOverviewSerializer.class);
        SERIALIZER_CLASSES.add(ErrataSerializer.class);
        SERIALIZER_CLASSES.add(HistoryEventSerializer.class);
        SERIALIZER_CLASSES.add(ManagedServerGroupSerializer.class);
        SERIALIZER_CLASSES.add(ObjectSerializer.class);
        SERIALIZER_CLASSES.add(OrgSerializer.class);
        SERIALIZER_CLASSES.add(OrgTrustOverviewSerializer.class);
        SERIALIZER_CLASSES.add(PackageMetadataSerializer.class);
        SERIALIZER_CLASSES.add(PackageSerializer.class);
        SERIALIZER_CLASSES.add(RhnTimeZoneSerializer.class);
        SERIALIZER_CLASSES.add(ScriptResultSerializer.class);
        SERIALIZER_CLASSES.add(ServerSerializer.class);
        SERIALIZER_CLASSES.add(ServerPathSerializer.class);
        SERIALIZER_CLASSES.add(SystemSearchResultSerializer.class);
        SERIALIZER_CLASSES.add(SystemOverviewSerializer.class);
        SERIALIZER_CLASSES.add(UserSerializer.class);
        SERIALIZER_CLASSES.add(KickstartTreeSerializer.class);
        SERIALIZER_CLASSES.add(KickstartTreeDetailSerializer.class);
        SERIALIZER_CLASSES.add(BigDecimalSerializer.class);
        SERIALIZER_CLASSES.add(ConfigRevisionSerializer.class);
        SERIALIZER_CLASSES.add(ConfigChannelSerializer.class);
        SERIALIZER_CLASSES.add(ConfigChannelDtoSerializer.class);
        SERIALIZER_CLASSES.add(ConfigChannelTypeSerializer.class);
        SERIALIZER_CLASSES.add(ConfigFileDtoSerializer.class);
        SERIALIZER_CLASSES.add(ConfigFileNameDtoSerializer.class);
        SERIALIZER_CLASSES.add(ConfigSystemDtoSerializer.class);
        SERIALIZER_CLASSES.add(ChannelFamilySystemGroupSerializer.class);
        SERIALIZER_CLASSES.add(OrgDtoSerializer.class);
        SERIALIZER_CLASSES.add(MultiOrgUserOverviewSerializer.class);
        SERIALIZER_CLASSES.add(VirtualSystemOverviewSerializer.class);
        SERIALIZER_CLASSES.add(MultiOrgEntitlementsDtoSerializer.class);
        SERIALIZER_CLASSES.add(MultiOrgSystemEntitlementsDtoSerializer.class);
        SERIALIZER_CLASSES.add(OrgEntitlementDtoSerializer.class);
        SERIALIZER_CLASSES.add(EntitlementSerializer.class);
        SERIALIZER_CLASSES.add(OrgChannelFamilySerializer.class);
        SERIALIZER_CLASSES.add(OrgSoftwareEntitlementDtoSerializer.class);
        SERIALIZER_CLASSES.add(NetworkInterfaceSerializer.class);
        SERIALIZER_CLASSES.add(ScheduleActionSerializer.class);
        SERIALIZER_CLASSES.add(ScheduleSystemSerializer.class);
        SERIALIZER_CLASSES.add(KickstartDtoSerializer.class);
        SERIALIZER_CLASSES.add(KickstartScriptSerializer.class);
        SERIALIZER_CLASSES.add(ServerSnapshotSerializer.class);
        SERIALIZER_CLASSES.add(PackageNevraSerializer.class);
        SERIALIZER_CLASSES.add(NoteSerializer.class);
        SERIALIZER_CLASSES.add(KickstartIpRangeSerializer.class);
        SERIALIZER_CLASSES.add(CryptoKeySerializer.class);
        SERIALIZER_CLASSES.add(CryptoKeyDtoSerializer.class);
        SERIALIZER_CLASSES.add(CryptoKeyTypeSerializer.class);
        SERIALIZER_CLASSES.add(KickstartDataSerializer.class);
        SERIALIZER_CLASSES.add(KickstartCommandSerializer.class);
        SERIALIZER_CLASSES.add(KickstartCommandNameSerializer.class);
        SERIALIZER_CLASSES.add(KickstartOptionValueSerializer.class);
        SERIALIZER_CLASSES.add(KickstartAdvancedOptionsSerializer.class);
        SERIALIZER_CLASSES.add(CustomDataKeySerializer.class);
        SERIALIZER_CLASSES.add(KickstartInstallTypeSerializer.class);
        SERIALIZER_CLASSES.add(FilePreservationDtoSerializer.class);
        SERIALIZER_CLASSES.add(FileListSerializer.class);
        SERIALIZER_CLASSES.add(ServerActionSerializer.class);
        SERIALIZER_CLASSES.add(ChannelTreeNodeSerializer.class);
        SERIALIZER_CLASSES.add(TrustedOrgDtoSerializer.class);
        SERIALIZER_CLASSES.add(PackageKeySerializer.class);
        SERIALIZER_CLASSES.add(PackageProviderSerializer.class);
        SERIALIZER_CLASSES.add(PackageDtoSerializer.class);
        SERIALIZER_CLASSES.add(PackageOverviewSerializer.class);
        SERIALIZER_CLASSES.add(ProfileOverviewDtoSerializer.class);
        SERIALIZER_CLASSES.add(SnippetSerializer.class);
        SERIALIZER_CLASSES.add(NetworkDtoSerializer.class);
        SERIALIZER_CLASSES.add(DistChannelMapSerializer.class);
    }

    /**
     * Returns the list of all available custom XMLRPC serializers.
     * @return List of serializer classes.
     */
    public static List<Class> getSerializationClasses() {
        return SERIALIZER_CLASSES;
    }
}
