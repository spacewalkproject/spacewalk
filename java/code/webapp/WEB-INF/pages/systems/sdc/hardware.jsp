<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>

<html:html>
  <body>
    <%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>
    <div class="panel panel-default">
      <div class="panel-heading">
        <h4>
          <bean:message key="sdc.details.hardware.header" />
        </h4>
      </div>
      <div class="panel-body">
        <bean:message key="sdc.details.hardware.refresh" />
        <html:form method="post"
        action="/systems/details/SystemHardware.do?sid=${sid}">
          <rhn:csrf />
          <html:hidden property="submitted" value="true" />
          <div class="text-right margin-bottom-sm">
            <html:submit styleClass="btn btn-default">
              <bean:message key="sdc.details.hardware.schedule" />
            </html:submit>
          </div>
          <div class="panel panel-default">
            <div class="panel-heading">
              <h4>
                <bean:message key="sdc.details.hardware.general" />
              </h4>
            </div>
            <div class="panel-body">
              <c:if test="${cpu_mhz != null}">(${cpu_count})
              ${cpu_model} (${cpu_mhz} MHz)</c:if>
              <table class="table table-condensed">
                <tr>
                  <th>
                    <bean:message key="sdc.details.hardware.arch" />
                  </th>
                  <td>${cpu_arch}</td>
                  <th>
                    <bean:message key="sdc.details.hardware.sockets" />
                  </th>
                  <td>${cpu_sockets}</td>
                  <th>
                    <bean:message key="sdc.details.hardware.cache" />
                  </th>
                  <td>${cpu_cache}</td>
                </tr>
                <tr>
                  <th>
                    <bean:message key="sdc.details.hardware.vendor" />
                  </th>
                  <td>${cpu_vendor}</td>
                  <th>
                    <bean:message key="sdc.details.hardware.cores" />
                  </th>
                  <td>${cpu_cores}</td>
                  <th>
                    <bean:message key="sdc.details.hardware.memory" />
                  </th>
                  <td>${system_ram} MB</td>
                </tr>
                <tr>
                  <th>
                    <bean:message key="sdc.details.hardware.family" />
                  </th>
                  <td>${cpu_family}</td>
                  <th>
                    <bean:message key="sdc.details.hardware.stepping" />
                  </th>
                  <td>${cpu_stepping}</td>
                  <th>
                    <bean:message key="sdc.details.hardware.swap" />
                  </th>
                  <td>${system_swap} MB</td>
                </tr>
              </table>
            </div>
          </div>
          <c:if test="${empty dmi_vendor}" var="no_vendor" />
          <c:if test="${empty dmi_bios}" var="no_bios" />
          <c:if test="${empty dmi_system}" var="no_system" />
          <c:if test="${empty dmi_product}" var="no_product" />
          <c:if test="${empty dmi_asset_tag}" var="no_asset_tag" />
          <c:if test="${empty dmi_board}" var="no_board" />
          <c:if test="${!(empty dmi_vendor and empty dmi_bios and empty dmi_system and empty dmi_product and empty dmi_asset_tag and empty dmi_board)}">

            <div class="panel panel-default">
              <div class="panel-heading">
                <h4>
                  <bean:message key="sdc.details.hardware.dmi" />
                </h4>
              </div>
              <div class="panel-body">
                <table class="table table-condensed">
                  <tr>
                    <th>
                      <bean:message key="sdc.details.hardware.dmi_vendor" />
                    </th>
                    <td>${dmi_vendor}</td>
                    <th rowspan="2">
                      <bean:message key="sdc.details.hardware.dmi_bios" />
                    </th>
                    <td rowspan="2">${dmi_bios}</td>
                  </tr>
                  <tr>
                    <th>
                      <bean:message key="sdc.details.hardware.dmi_system" />
                    </th>
                    <td>${dmi_system}</td>
                  </tr>
                  <tr>
                    <th rowspan="2">
                      <bean:message key="sdc.details.hardware.dmi_product" />
                    </th>
                    <td rowspan="2">${dmi_product}</td>
                    <th>
                      <bean:message key="sdc.details.hardware.dmi_asset_tag" />
                    </th>
                    <td>${dmi_asset_tag}</td>
                  </tr>
                  <tr>
                    <th>
                      <bean:message key="sdc.details.hardware.dmi_board" />
                    </th>
                    <td>${dmi_board}</td>
                  </tr>
                </table>
              </div>
            </div>
          </c:if>
          <div class="panel panel-default">
            <div class="panel-heading">
              <h4>
                <bean:message key="sdc.details.hardware.networking" />
              </h4>
            </div>
            <div class="panel-body">
              <table class="table table-condensed">
                <tr>
                  <th>
                    <bean:message key="sdc.details.hardware.network_hostname" />
                  </th>
                  <td>
                    <c:choose>
                      <c:when test="${network_hostname == null}">
                        <bean:message key="sdc.details.overview.unknown" />
                      </c:when>
                      <c:otherwise>
                        <c:out value="${network_hostname}" />
                      </c:otherwise>
                    </c:choose>
                  </td>
                </tr>
                <c:forEach items="${network_cnames}"
                var="cname_alias" varStatus="loop">
                  <tr>
                    <th>
                      <bean:message key="sdc.details.hardware.network_cname" />
                    </th>
                    <td>${cname_alias}</td>
                  </tr>
                </c:forEach>
                <tr>
                  <th>
                    <bean:message key="sdc.details.hardware.network_ip_addr" />
                  </th>
                  <td>${network_ip_addr}</td>
                </tr>
                <tr>
                  <th>
                    <bean:message key="sdc.details.hardware.network_ip6_addr" />
                  </th>
                  <td>${network_ip6_addr}</td>
                </tr>
                <tr>
                  <th>
                    <c:out value="Primary network interface:" />
                  </th>
                  <td>
                  <c:if test="${not empty networkInterfaces}">
                    <html:select property="primaryInterface"
                    styleId="primaryInterface">
                      <html:options collection="networkInterfaces"
                      property="value" labelProperty="display" />
                    </html:select>
                    </c:if>
                  </td>
                </tr>
              </table>
            </div>
          </div>
          <rhn:csrf />
          <div class="text-right margin-bottom-sm">
          <c:if test="${not empty networkInterfaces}">
            <html:submit property="update_interface"
            styleClass="btn btn-default">
              <bean:message key="sdc.details.edit.update" />
            </html:submit>
            </c:if>
          </div>
          <div class="panel panel-default">
            <div class="panel-body">
              <table class="table table-condensed" width="90%"
              cellspacing="0">
                <thead>
                  <tr>
                    <th>Interface</th>
                    <th>IP Address</th>
                    <th>Netmask</th>
                    <th>Broadcast</th>
                    <th>Hardware Address</th>
                    <th>Driver Module</th>
                  </tr>
                </thead>
                <c:forEach items="${network_interfaces}"
                var="current" varStatus="loop">
                  <c:choose>
                    <c:when test="${loop.count % 2 == 0}">
                      <c:set var="style_class"
                      value="list-row-even" />
                    </c:when>
                    <c:otherwise>
                      <c:set var="style_class"
                      value="list-row-odd" />
                    </c:otherwise>
                  </c:choose>

                  <tr class="${style_class}">
                    <td>${current.name}</td>
                    <c:choose>
                      <c:when test="${empty current.ip}">
                        <td>
                          <span class="no-details">(unknown)</span>
                        </td>
                      </c:when>
                      <c:otherwise>
                        <td>${current.ip}</td>
                      </c:otherwise>
                    </c:choose>
                    <c:choose>
                      <c:when test="${empty current.netmask}">
                        <td>
                          <span class="no-details">(unknown)</span>
                        </td>
                      </c:when>
                      <c:otherwise>
                        <td>${current.netmask}</td>
                      </c:otherwise>
                    </c:choose>
                    <c:choose>
                      <c:when test="${empty current.broadcast}">
                        <td>
                          <span class="no-details">(unknown)</span>
                        </td>
                      </c:when>
                      <c:otherwise>
                        <td>${current.broadcast}</td>
                      </c:otherwise>
                    </c:choose>
                    <c:choose>
                      <c:when test="${empty current.hwaddr}">
                        <td>
                          <span class="no-details">(unknown)</span>
                        </td>
                      </c:when>
                      <c:otherwise>
                        <td>${current.hwaddr}</td>
                      </c:otherwise>
                    </c:choose>
                    <td>${current.module}</td>
                  </tr>
                </c:forEach>
              </table>
            </div>
          </div>
          <div class="panel panel-default">
            <div class="panel-body">
              <table class="table table-condensed">
                <thead>
                  <tr>
                    <th>Interface</th>
                    <th>IPv6 Address</th>
                    <th>Netmask</th>
                    <th>Scope</th>
                    <th>Hardware Address</th>
                    <th>Driver Module</th>
                  </tr>
                </thead>
                <c:forEach items="${ipv6_network_interfaces}"
                var="current" varStatus="loop">
                  <c:choose>
                    <c:when test="${loop.count % 2 == 0}">
                      <c:set var="style_class"
                      value="list-row-even" />
                    </c:when>
                    <c:otherwise>
                      <c:set var="style_class"
                      value="list-row-odd" />
                    </c:otherwise>
                  </c:choose>
                  <tr class="${style_class}">
                    <td>${current.name}</td>
                    <c:choose>
                      <c:when test="${empty current.ip6}">
                        <td>
                          <span class="no-details">(unknown)</span>
                        </td>
                      </c:when>
                      <c:otherwise>
                        <td>${current.ip6}</td>
                      </c:otherwise>
                    </c:choose>
                    <c:choose>
                      <c:when test="${empty current.netmask}">
                        <td>
                          <span class="no-details">(unknown)</span>
                        </td>
                      </c:when>
                      <c:otherwise>
                        <td>${current.netmask}</td>
                      </c:otherwise>
                    </c:choose>
                    <c:choose>
                      <c:when test="${empty current.scope}">
                        <td>
                          <span class="no-details">(unknown)</span>
                        </td>
                      </c:when>
                      <c:otherwise>
                        <td>${current.scope}</td>
                      </c:otherwise>
                    </c:choose>
                    <c:choose>
                      <c:when test="${empty current.hwaddr}">
                        <td>
                          <span class="no-details">(unknown)</span>
                        </td>
                      </c:when>
                      <c:otherwise>
                        <td>${current.hwaddr}</td>
                      </c:otherwise>
                    </c:choose>
                    <td>${current.module}</td>
                  </tr>
                </c:forEach>
              </table>
            </div>
          </div>
          <c:if test="${not empty storageDevices}">
            <div class="panel panel-default">
              <div class="panel-heading">
                <h4>
                  <bean:message key="sdc.details.hardware.storage" />
                </h4>
              </div>
              <div class="panel-body">
                <table class="table table-condensed">
                  <thead>
                    <tr>
                      <th width="40%">Description</th>
                      <th width="10%">Bus</th>
                      <th width="25%">Device</th>
                      <th width="25%">Physical</th>
                    </tr>
                  </thead>
                  <tbody>
                    <c:forEach items="${storageDevices}"
                    var="current" varStatus="loop">
                      <c:choose>
                        <c:when test="${loop.count % 2 == 0}">
                          <c:set var="style_class"
                          value="list-row-even" />
                        </c:when>
                        <c:otherwise>
                          <c:set var="style_class"
                          value="list-row-odd" />
                        </c:otherwise>
                      </c:choose>
                      <tr class="${style_class}">
                        <td>${current.description}</td>
                        <td>${current.bus}</td>
                        <td>${current.device}</td>
                        <td>${loop.count - 1}</td>
                      </tr>
                    </c:forEach>
                  </tbody>
                </table>
              </div>
            </div>
          </c:if>
          <c:if test="${not empty videoDevices}">
            <div class="panel panel-default">
              <div class="panel-heading">
                <h4>
                  <bean:message key="sdc.details.hardware.video" />
                </h4>
              </div>
              <div class="panel-body">
                <table class="table table-condensed">
                  <thead>
                    <tr>
                      <th width="40%">Description</th>
                      <th width="10%">Bus</th>
                      <th width="10%">Vendor</th>
                      <th width="40%">Driver</th>
                    </tr>
                  </thead>
                  <tbody>
                    <c:forEach items="${videoDevices}"
                    var="current" varStatus="loop">
                      <c:choose>
                        <c:when test="${loop.count % 2 == 0}">
                          <c:set var="style_class"
                          value="list-row-even" />
                        </c:when>
                        <c:otherwise>
                          <c:set var="style_class"
                          value="list-row-odd" />
                        </c:otherwise>
                      </c:choose>
                      <tr class="${style_class}">
                        <td>${current.description}</td>
                        <td>${current.bus}</td>
                        <td>${current.vendor}</td>
                        <td>${current.driver}</td>
                      </tr>
                    </c:forEach>
                  </tbody>
                </table>
              </div>
            </div>
          </c:if>
          <c:if test="${not empty audioDevices}">
            <div class="panel panel-default">
              <div class="panel-heading">
                <h4>
                  <bean:message key="sdc.details.hardware.audio" />
                </h4>
              </div>
              <div class="panel-body">
                <table class="table table-condensed">
                  <thead>
                    <tr>
                      <th width="40%">Description</th>
                      <th width="10%">Bus</th>
                      <th width="10%">Vendor</th>
                      <th width="40%">Driver</th>
                    </tr>
                  </thead>
                  <tbody>
                    <c:forEach items="${audioDevices}"
                    var="current" varStatus="loop">
                      <c:choose>
                        <c:when test="${loop.count % 2 == 0}">
                          <c:set var="style_class"
                          value="list-row-even" />
                        </c:when>
                        <c:otherwise>
                          <c:set var="style_class"
                          value="list-row-odd" />
                        </c:otherwise>
                      </c:choose>
                      <tr class="${style_class}">
                        <td>${current.description}</td>
                        <td>${current.bus}</td>
                        <td>${current.vendor}</td>
                        <td>${current.driver}</td>
                      </tr>
                    </c:forEach>
                  </tbody>
                </table>
              </div>
            </div>
          </c:if>
          <c:if test="${not empty usbDevices}">
            <div class="panel panel-default">
              <div class="panel-heading">
                <h4>
                  <bean:message key="sdc.details.hardware.usb" />
                </h4>
              </div>
              <div class="panel-body">
                <table class="table table-condensed">
                  <thead>
                    <tr>
                      <th width="40%">Description</th>
                      <th width="10%">Bus</th>
                      <th width="25%">Vendor</th>
                      <th width="25%">Driver</th>
                    </tr>
                  </thead>
                  <tbody>
                    <c:forEach items="${usbDevices}" var="current"
                    varStatus="loop">
                      <c:choose>
                        <c:when test="${loop.count % 2 == 0}">
                          <c:set var="style_class"
                          value="list-row-even" />
                        </c:when>
                        <c:otherwise>
                          <c:set var="style_class"
                          value="list-row-odd" />
                        </c:otherwise>
                      </c:choose>
                      <tr class="${style_class}">
                        <td>${current.description}</td>
                        <td>${current.bus}</td>
                        <td>${current.vendor}</td>
                        <td>${current.driver}</td>
                      </tr>
                    </c:forEach>
                  </tbody>
                </table>
              </div>
            </div>
          </c:if>
          <c:if test="${not empty captureDevices}">
            <div class="panel panel-default">
              <div class="panel-heading">
                <h4>
                  <bean:message key="sdc.details.hardware.capture" />
                </h4>
              </div>
              <div class="panel-body">
                <table class="table table-condensed">
                  <thead>
                    <tr>
                      <th width="40%">Description</th>
                      <th width="10%">Bus</th>
                      <th width="25%">Vendor</th>
                      <th width="25%">Driver</th>
                    </tr>
                  </thead>
                  <tbody>
                    <c:forEach items="${miscDevices}" var="current"
                    varStatus="loop">
                      <c:choose>
                        <c:when test="${loop.count % 2 == 0}">
                          <c:set var="style_class"
                          value="list-row-even" />
                        </c:when>
                        <c:otherwise>
                          <c:set var="style_class"
                          value="list-row-odd" />
                        </c:otherwise>
                      </c:choose>
                      <tr class="${style_class}">
                        <td class="${style_class}">Loop: ${loop} :
                        ${current.description}</td>
                        <td class="${style_class}">
                        ${current.bus}</td>
                        <td class="${style_class}">
                        ${current.vendor}</td>
                        <td class="${style_class}">
                        ${current.driver}</td>
                      </tr>
                    </c:forEach>
                  </tbody>
                </table>
              </div>
            </div>
          </c:if>
          <c:if test="${not empty miscDevices}">
            <div class="panel panel-default">
              <div class="panel-heading">
                <h4>
                  <bean:message key="sdc.details.hardware.misc" />
                </h4>
              </div>
              <div class="panel-body">
                <table class="table table-condensed">
                  <thead>
                    <tr>
                      <th width="40%">Description</th>
                      <th width="10%">Bus</th>
                      <th width="25%">Vendor</th>
                      <th width="25%">Driver</th>
                    </tr>
                  </thead>
                  <tbody>
                    <c:forEach items="${miscDevices}" var="current"
                    varStatus="loop">
                      <c:choose>
                        <c:when test="${loop.count % 2 == 0}">
                          <c:set var="style_class"
                          value="list-row-even" />
                        </c:when>
                        <c:otherwise>
                          <c:set var="style_class"
                          value="list-row-odd" />
                        </c:otherwise>
                      </c:choose>
                      <tr class="${style_class}">
                        <td>${current.description}</td>
                        <td>${current.bus}</td>
                        <td>${current.vendor}</td>
                        <td>${current.driver}</td>
                      </tr>
                    </c:forEach>
                  </tbody>
                </table>
              </div>
            </div>
          </c:if>
        </html:form>
      </div>
    </div>
  </body>
</html:html>
