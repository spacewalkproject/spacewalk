<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>


<html>
<body>
<%@ include file="/WEB-INF/pages/common/fragments/ssm/header.jspf" %>
<h2>
  <bean:message key="ssm.delete.systems.header" />
</h2>
<p><bean:message key="ssm.delete.systems.summary" /></p>
<c:set var="notSelectable" value="true"/>
<c:set var="showLastCheckin" value="true"/>
<c:set var="noPackages" value="true"/>
<c:set var="noErrata" value="true"/>

<rl:listset name="systemListSet" legend="system">
    <rhn:csrf />
    <rhn:submitted />
    <%@ include file="/WEB-INF/pages/common/fragments/systems/system_listdisplay.jspf" %>
	<div class="text-right">
      <hr />
      <input class="btn btn-default" type ="submit" name="dispatch" value="${rhn:localize('ssm.delete.systems.confirmbutton')}"/>
    </div>
</rl:listset>


</body>
</html>
