<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>


<html:html >
<body>
<%@ include file="/WEB-INF/pages/common/fragments/package/package_header.jspf" %>

<h2>
<bean:message key="channel.jsp.changelog.title"/>
</h2>

<div>

<c:if test="${changelog != null}">

   <c:forEach items="${changelog}" var="line">
		${line}<br />
   </c:forEach>
</c:if>
<c:if test="${changelog == null}">
   <bean:message key="channel.jsp.changelog.error"/>
</c:if>



</div>

</body>
</html:html>
