<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>

<html:html xhtml="true">
  <body>
    <%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>
    <h2><bean:message key="sdc.details.hardware.header"/></h2>

    <bean:message key="sdc.details.hardware.refresh"/>

    <html:form method="post" action="/systems/details/SystemHardware.do?sid=${sid}">
      <html:hidden property="submitted" value="true"/>
        <div align="right">
          <html:submit>
            <bean:message key="sdc.details.hardware.schedule"/>
          </html:submit>
        </div>
    </html:form>
 
    <h2><bean:message key="sdc.details.hardware.general"/></h2>
    (COUNT) ${cpu_model} ${cpu_mhz} MHZ
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

    <c:if test="${not (no_vendor or no_bios or no_system or no_product or no_asset_tag or no_board)}">
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
          ${network_hostname}
        </td>
      </tr>
      <tr>
        <th>
          <bean:message key="sdc.details.hardware.network_ip_addr"/>
        </th>
        <td>
          ${network_ip_addr}
        </td>
      </tr>
    </table>
  </body>
</html:html>

