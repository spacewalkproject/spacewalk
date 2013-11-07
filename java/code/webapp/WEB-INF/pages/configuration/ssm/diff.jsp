<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>


<html>
<body>
<%@ include file="/WEB-INF/pages/common/fragments/ssm/header.jspf" %>
<h2>
  <i class="fa spacewalk-icon-manage-configuration-files" title="<bean:message key="ssmdiff.jsp.imgAlt" />"></i>
  <bean:message key="ssmdiff.jsp.header" />
</h2>

  <div class="page-summary">
    <p>
    <bean:message key="ssmdiff.jsp.summary"/>
    </p>
  </div>

<form method="post" name="rhn_list" action="/rhn/systems/ssm/config/DiffSubmit.do">
  <rhn:csrf />
  <c:set scope="request" var="buttonname" value="ssmdiff.jsp.schedule" />
  <%@ include file="/WEB-INF/pages/common/fragments/configuration/ssm/configlist.jspf"%>
</form>

</body>
</html>

