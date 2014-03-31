<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@taglib uri="http://struts.apache.org/tags-html" prefix="html" %>

<html>
<body>
<%@ include file="/WEB-INF/pages/common/fragments/ssm/header.jspf" %>

<p><bean:message key="reboot.jsp.widgetsummary" /></p>
<rl:listset name="systemListSet">
  <c:set var="notSelectable" value="True"/>
  <c:set var="noCsv" value="1" />
  <c:set var="noAddToSsm" value="1" />
  <%@ include file="/WEB-INF/pages/common/fragments/systems/system_listdisplay.jspf" %>
  <hr />

  <jsp:include page="/WEB-INF/pages/common/fragments/schedule-options.jspf"/>
  <rhn:submitted />
  <div class="text-right">
    <html:submit styleClass="btn btn-success" property="dispatch">
      <bean:message key="ssm.misc.reboot.confirm" />
    </html:submit>
  </div>

</rl:listset>
</body>
</html>
