<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://rhn.redhat.com/tags/config-managment" prefix="cfg" %>

<html:xhtml/>
<html>
<body>
<%@ include file="/WEB-INF/pages/common/fragments/configuration/files/header.jspf"%>

<h2><bean:message key="deploy.jsp.header2"/></h2>

<div>
<c:choose>
  <c:when test="${file.configChannel.globalChannel}">  				<!--  GLOBAL CHANNEL  -->
<%@  include file="/WEB-INF/pages/common/fragments/configuration/files/deployglobal.jspf" %>
  </c:when>

  <c:when test="${file.configChannel.localChannel}">				<!--  LOCAL CHANNEL  -->
<%@  include file="/WEB-INF/pages/common/fragments/configuration/files/deploylocal.jspf" %>
  </c:when>

  <c:otherwise> 															<!--  SANDBOX -->
	<bean:message key="deploy.jsp.sandbox-note1"
		arg1="/rhn/systems/details/Overview.do?sid=${sid}"
  		arg0="${system}"/>
  	<p />
  	<c:set var="copyname" scope="request">
  		<bean:message key="copycentral.jsp.copy" />
  	</c:set>
	<bean:message key="deploy.jsp.sandbox-note2"
		arg0="/rhn/configuration/file/CopyFileLocal.do?cfid=${cfid}"
		arg1="/rhn/configuration/file/CopyFileCentral.do?cfid=${cfid}"
		arg2="/rhn/configuration/file/CopyFileCentral.do?cfid=${cfid}"
		arg3="/rhn/configuration/file/CopyFileCentral.do?cfid=${cfid}"
  		arg4="${requestScope.copyname}"/>
  </c:otherwise>
</c:choose>
</div>

</body>
</html>

