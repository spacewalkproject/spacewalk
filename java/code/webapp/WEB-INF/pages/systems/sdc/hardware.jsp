<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>

<html:html xhtml="true">
  <body>
    <%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>

    <h2><bean:message key="sdc.details.hardware.header"/></h2>

    <bean:message key="sdc.details.hardware.refresh"/>

    <html:form method="post" action="/systems/details/SystemHardware.do?sid=${sid}">
      <rhn:csrf />
      <html:hidden property="submitted" value="true"/>
        <div align="right">
          <html:submit>
            <bean:message key="sdc.details.hardware.schedule"/>
          </html:submit>
        </div>
    </html:form>
 
    <h2><bean:message key="sdc.details.hardware.general"/></h2>

    <c:if test="${cpu_mhz != null}" >
    (${cpu_count}) ${cpu_model} (${cpu_mhz} MHz)
    </c:if>

    <table class="details">
      <tr>
        <th>
          <bean:message key="sdc.details.hardware.arch"/>
        </th>
        <td>
          ${cpu_arch}
        </td>
        <th>
          <bean:message key="sdc.details.hardware.cache"/>
        </th>
        <td>
          ${cpu_cache}
        </td>
      </tr>
      <tr>
        <th>
          <bean:message key="sdc.details.hardware.vendor"/>
        </th>
        <td>
          ${cpu_vendor}
        </td>
        <th rowspan="2">
          <bean:message key="sdc.details.hardware.memory"/>
        </th>
        <td rowspan="2">
          ${system_ram} MB
        </td>
      </tr>
      <tr>
        <th>
          <bean:message key="sdc.details.hardware.stepping"/>
        </th>
        <td>
          ${cpu_stepping}
        </td>
      </tr>
      <tr>
        <th>
          <bean:message key="sdc.details.hardware.family"/>
        </th>
        <td>
          ${cpu_family}
        </td>
        <th rowspan="2">
          <bean:message key="sdc.details.hardware.swap"/>
        </th>
        <td rowspan="2">
          ${system_swap} MB
        </td>
      </tr>
    </table>

    <c:if test="${empty dmi_vendor}"    var="no_vendor"/>
    <c:if test="${empty dmi_bios}"      var="no_bios"/>
    <c:if test="${empty dmi_system}"    var="no_system"/>
    <c:if test="${empty dmi_product}"   var="no_product"/>
    <c:if test="${empty dmi_asset_tag}" var="no_asset_tag"/>
    <c:if test="${empty dmi_board}"     var="no_board"/>

    <c:if test="${!(empty dmi_vendor and empty dmi_bios and empty dmi_system and empty dmi_product and empty dmi_asset_tag and empty dmi_board)}">
      <h2><bean:message key="sdc.details.hardware.dmi"/></h2>
      <table class="details">
        <tr>
          <th>
            <bean:message key="sdc.details.hardware.dmi_vendor"/>
          </th>
          <td>
            ${dmi_vendor}
          </td>
          <th rowspan="2">
            <bean:message key="sdc.details.hardware.dmi_bios"/>
          </th>
          <td rowspan="2">
            ${dmi_bios}
          </td>
        </tr>
        <tr>
          <th>
            <bean:message key="sdc.details.hardware.dmi_system"/>
          </th>
          <td>
            ${dmi_system}
          </td>
        </tr>
        <tr>
          <th rowspan="2">
            <bean:message key="sdc.details.hardware.dmi_product"/>
          </th>
          <td rowspan="2">
            ${dmi_product}
          </td>
          <th>
            <bean:message key="sdc.details.hardware.dmi_asset_tag"/>
          </th>
          <td>
            ${dmi_asset_tag}
          </td>
        </tr>
        <tr>
          <th>
            <bean:message key="sdc.details.hardware.dmi_board"/>
          </th>
          <td>
            ${dmi_board}
          </td>
        </tr>
      </table>
    </c:if>

    <h2><bean:message key="sdc.details.hardware.networking"/></h2>

    <table class="details">
      <tr>
        <th>
          <bean:message key="sdc.details.hardware.network_hostname"/>
        </th>
        <td>
          <c:choose>
            <c:when test="${network_hostname == null}">
              <bean:message key="sdc.details.overview.unknown"/>
            </c:when>
            <c:otherwise>
              <c:out value="${network_hostname}" />
            </c:otherwise>
          </c:choose>
        </td>
      </tr>
      <c:forEach items="${network_cnames}" var="cname_alias" varStatus="loop">
      <tr>
        <th>
          <bean:message key="sdc.details.hardware.network_cname"/>
        </th>
        <td>
          ${cname_alias}
        </td>
      </tr>
      </c:forEach>
      <tr>
        <th>
          <bean:message key="sdc.details.hardware.network_ip_addr"/>
        </th>
        <td>
          ${network_ip_addr}
        </td>
      </tr>

      <tr>
        <th>
          <bean:message key="sdc.details.hardware.network_ip6_addr"/>
        </th>
        <td>
          ${network_ip6_addr}
        </td>
      </tr>

    </table>
    <br/>
    <table class="list compare-list" width="90%" cellspacing="0">
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
      <c:forEach items="${network_interfaces}" var="current" varStatus="loop">
        <c:choose>
          <c:when test ="${loop.count % 2 == 0}">
            <c:set var ="style_class" value="list-row-even"/>
          </c:when>
          <c:otherwise>
            <c:set var ="style_class" value="list-row-odd"/>
          </c:otherwise>
        </c:choose>
        <tr class="${style_class}">
          <td>${current.name}</td>
          <c:choose>
            <c:when test="${empty current.ip}">
              <td><span class="no-details">(unknown)</span></td>
            </c:when>
            <c:otherwise>
              <td>${current.ip}</td>
            </c:otherwise>
          </c:choose>
          <c:choose>
            <c:when test="${empty current.netmask}">
              <td><span class="no-details">(unknown)</span></td>
            </c:when>
            <c:otherwise>
              <td>${current.netmask}</td>
            </c:otherwise>
          </c:choose>
          <c:choose>
            <c:when test="${empty current.broadcast}">
              <td><span class="no-details">(unknown)</span></td>
            </c:when>
            <c:otherwise>
              <td>${current.broadcast}</td>
            </c:otherwise>
          </c:choose>
          <c:choose>
            <c:when test="${empty current.hwaddr}">
              <td><span class="no-details">(unknown)</span></td>
            </c:when>
            <c:otherwise>
              <td>${current.hwaddr}</td>
            </c:otherwise>
          </c:choose>
          <td>${current.module}</td>
        </tr>
      </c:forEach>
    </table>
    <br/>
    <table class="list compare-list" width="90%" cellspacing="0">
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
      <c:forEach items="${ipv6_network_interfaces}" var="current" varStatus="loop">
        <c:choose>
          <c:when test ="${loop.count % 2 == 0}">
            <c:set var ="style_class" value="list-row-even"/>
          </c:when>
          <c:otherwise>
            <c:set var ="style_class" value="list-row-odd"/>
          </c:otherwise>
        </c:choose>
        <tr class="${style_class}">
          <td>${current.name}</td>
          <c:choose>
            <c:when test="${empty current.ip6}">
              <td><span class="no-details">(unknown)</span></td>
            </c:when>
            <c:otherwise>
              <td>${current.ip6}</td>
            </c:otherwise>
          </c:choose>
          <c:choose>
            <c:when test="${empty current.netmask}">
              <td><span class="no-details">(unknown)</span></td>
            </c:when>
            <c:otherwise>
              <td>${current.netmask}</td>
            </c:otherwise>
          </c:choose>
          <c:choose>
            <c:when test="${empty current.scope}">
              <td><span class="no-details">(unknown)</span></td>
            </c:when>
            <c:otherwise>
              <td>${current.scope}</td>
            </c:otherwise>
          </c:choose>
          <c:choose>
            <c:when test="${empty current.hwaddr}">
              <td><span class="no-details">(unknown)</span></td>
            </c:when>
            <c:otherwise>
              <td>${current.hwaddr}</td>
            </c:otherwise>
          </c:choose>
          <td>${current.module}</td>
        </tr>
      </c:forEach>

    </table>

    <c:if test="${not empty storageDevices}">
    <h2><bean:message key="sdc.details.hardware.storage"/></h2>
    <table class="list" width="90%" cellspacing="0">
      <thead>
      <tr>
        <th width="40%">Description</th>
        <th width="10%">Bus</th>
        <th width="25%">Device</th>
        <th width="25%">Physical</th>
      </tr>
      </thead>
      <tbody>
      <c:forEach items="${storageDevices}" var="current" varStatus="loop">
        <c:choose>
          <c:when test ="${loop.count % 2 == 0}">
            <c:set var ="style_class" value="list-row-even"/>
          </c:when>
          <c:otherwise>
            <c:set var ="style_class" value="list-row-odd"/>
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
    </c:if>

    <c:if test="${not empty videoDevices}">
    <h2><bean:message key="sdc.details.hardware.video"/></h2>
    <table class="list" width="90%" cellspacing="0">
      <thead>
      <tr>
        <th width="40%">Description</th>
        <th width="10%">Bus</th>
        <th width="10%">Vendor</th>
        <th width="40%">Driver</th>
      </tr>
      </thead>
      <tbody>
      <c:forEach items="${videoDevices}" var="current" varStatus="loop">
        <c:choose>
          <c:when test ="${loop.count % 2 == 0}">
            <c:set var ="style_class" value="list-row-even"/>
          </c:when>
          <c:otherwise>
            <c:set var ="style_class" value="list-row-odd"/>
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
    </c:if>

    <c:if test="${not empty audioDevices}">
    <h2><bean:message key="sdc.details.hardware.audio"/></h2>
    <table class="list" width="90%" cellspacing="0">
      <thead>
      <tr>
        <th width="40%">Description</th>
        <th width="10%">Bus</th>
        <th width="10%">Vendor</th>
        <th width="40%">Driver</th>
      </tr>
      </thead>
      <tbody>
      <c:forEach items="${audioDevices}" var="current" varStatus="loop">
        <c:choose>
          <c:when test ="${loop.count % 2 == 0}">
            <c:set var ="style_class" value="list-row-even"/>
          </c:when>
          <c:otherwise>
            <c:set var ="style_class" value="list-row-odd"/>
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
    </c:if>

    <c:if test="${not empty usbDevices}">
    <h2><bean:message key="sdc.details.hardware.usb"/></h2>
    <table class="list" width="90%" cellspacing="0">
      <thead>
      <tr>
        <th width="40%">Description</th>
        <th width="10%">Bus</th>
        <th width="25%">Vendor</th>
        <th width="25%">Driver</th>
      </tr>
      </thead>
      <tbody>
      <c:forEach items="${usbDevices}" var="current" varStatus="loop">
        <c:choose>
          <c:when test ="${loop.count % 2 == 0}">
            <c:set var ="style_class" value="list-row-even"/>
          </c:when>
          <c:otherwise>
            <c:set var ="style_class" value="list-row-odd"/>
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
    </c:if>

    <c:if test="${not empty captureDevices}">
    <h2><bean:message key="sdc.details.hardware.capture"/></h2>
    <table class="list" width="90%" cellspacing="0">
      <thead>
      <tr>
        <th width="40%">Description</th>
        <th width="10%">Bus</th>
        <th width="25%">Vendor</th>
        <th width="25%">Driver</th>
      </tr>
      </thead>
      <tbody>
      <c:forEach items="${miscDevices}" var="current" varStatus="loop">
        <c:choose>
          <c:when test ="${loop.count % 2 == 0}">
            <c:set var ="style_class" value="list-row-even"/>
          </c:when>
          <c:otherwise>
            <c:set var ="style_class" value="list-row-odd"/>
          </c:otherwise>
        </c:choose>
        <tr class="${style_class}">
          <td class="${style_class}">Loop: ${loop} : ${current.description}</td>
          <td class="${style_class}">${current.bus}</td>
          <td class="${style_class}">${current.vendor}</td>
          <td class="${style_class}">${current.driver}</td>
        </tr>
      </c:forEach>
      </tbody>
    </table>
    </c:if>

    <c:if test="${not empty miscDevices}">
    <h2><bean:message key="sdc.details.hardware.misc"/></h2>
    <table class="list" width="90%" cellspacing="0">
      <thead>
      <tr>
        <th width="40%">Description</th>
        <th width="10%">Bus</th>
        <th width="25%">Vendor</th>
        <th width="25%">Driver</th>
      </tr>
      </thead>
      <tbody>
      <c:forEach items="${miscDevices}" var="current" varStatus="loop">
        <c:choose>
          <c:when test ="${loop.count % 2 == 0}">
            <c:set var ="style_class" value="list-row-even"/>
          </c:when>
          <c:otherwise>
            <c:set var ="style_class" value="list-row-odd"/>
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
    </c:if>

  </body>
</html:html>

