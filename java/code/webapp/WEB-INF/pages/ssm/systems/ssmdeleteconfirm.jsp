<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>

<html:xhtml/>
<html>
<body>
<%@ include file="/WEB-INF/pages/common/fragments/ssm/header.jspf" %>
<h2>
  <bean:message key="ssm.delete.systems.header" />
</h2>
<p><bean:message key="ssm.delete.systems.summary" /></p>
<c:set var="notSelectable" value="true"/>
<c:set var="showLastCheckin" value="true"/>

<rl:listset name="systemListSet" legend="system">
    <%@ include file="/WEB-INF/pages/common/fragments/systems/system_listdisplay.jspf" %>
	<div align="right">
      <hr />
      <input type ="submit" name="dispatch" value="${rhn:localize('ssm.delete.systems.confirmbutton')}"/>
    </div>
</rl:listset>


</body>
</html>