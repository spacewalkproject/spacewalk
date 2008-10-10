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

package com.redhat.rhn.frontend.xmlrpc.serializer;

import com.redhat.rhn.domain.config.ConfigChannelType;
import com.redhat.rhn.frontend.dto.ConfigFileDto;
import com.redhat.rhn.frontend.dto.ConfigFileNameDto;
import com.redhat.rhn.frontend.xmlrpc.serializer.util.SerializerHelper;

import java.io.IOException;
import java.io.Writer;

import redstone.xmlrpc.XmlRpcCustomSerializer;
import redstone.xmlrpc.XmlRpcException;
import redstone.xmlrpc.XmlRpcSerializer;


/**
 * ConfigFileDtoSerializer
 * @version $Rev$
 * @xmlrpc.doc
 * #struct("Configuration File information") 
 *   #prop("string", "type")
 *              #options()
 *                  #item("file")
 *                  #item("directory")
 *              #options_end()
 *   #prop_desc("string", "path","File Path")
 *   #prop("struct", "configChannelType") 
 *   $ConfigChannelTypeSerializer
 *   #prop_desc($date, "last_modified","Last Modified Date")
 * #struct_end()
 */
public class ConfigFileNameDtoSerializer implements XmlRpcCustomSerializer {

    /**
     * {@inheritDoc}
     */
    @Override
    public Class getSupportedClass() {
        return ConfigFileNameDto.class;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public void serialize(Object value, Writer output,
            XmlRpcSerializer builtInSerializer)
        throws XmlRpcException, IOException {
        ConfigFileNameDto dto = (ConfigFileNameDto) value;
        SerializerHelper helper = new SerializerHelper(builtInSerializer);
        helper.add("type", dto.getConfigFileType());
        helper.add("path", dto.getPath());
        helper.add("configChannelType", 
                ConfigChannelType.lookup(dto.getConfigChannelType()));
        helper.add("last_modified", dto.getLastModifiedDate());
        helper.writeTo(output);
    }

    /**
     * Basically creates ConfigFileNameDto and populates the
     *  appropriate fields from the ConfigFileDto.. This 
     *  is here and NOT in ConfigFileDto because
     *  the fields we will be populating here
     *  must match with what we want when we serialize.
     * in ConfigFileName 
     * @param dto configle file dto
     * @param configChannelType the config channel type
     * @return ConfigFileNameDto
     */
    public static ConfigFileNameDto toNameDto(ConfigFileDto dto,
                                        String configChannelType) {
        ConfigFileNameDto nameDto = new ConfigFileNameDto();
        nameDto.setConfigFileType(dto.getType());
        nameDto.setConfigChannelType(configChannelType);
        nameDto.setPath(dto.getPath());
        nameDto.setLastModifiedDate(dto.getModified());
        return nameDto;
    }
}
