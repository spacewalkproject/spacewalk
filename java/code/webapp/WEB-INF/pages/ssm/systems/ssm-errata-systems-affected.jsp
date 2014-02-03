<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%@taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>

<html>
<body>
  <%@ include file="/WEB-INF/pages/common/fragments/ssm/header.jspf" %>
  <h2><bean:message key="ssm.errata-relevant-systems.title" arg0="${erratum.advisoryName}" arg1="${erratum.synopsis}" /></h2>
  <p class="page-summary"><bean:message key="ssm.errata-relevant-systems.summary" /></p>

  <rl:listset name="systemSet" legend="system">
    <c:set var="notSelectable" value="True"/>
    <c:set var="noCsv" value="1" />
    <c:set var="noAddToSsm" value="1" />
    <%@ include file="/WEB-INF/pages/common/fragments/systems/system_listdisplay.jspf" %>
  </rl:listset>
</body>
</html>
