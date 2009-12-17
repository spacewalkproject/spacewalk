<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>

<html:xhtml/>
<html>
<head>
    <meta name="page-decorator" content="none" />
</head>
<body>

<%@ include file="/WEB-INF/pages/common/fragments/errata/errata-header.jspf" %>

<h2><bean:message key="packagelist.jsp.header.packages"/></h2>
    


    <c:forEach items="${channels}" var="current">
        <div class="page-summary">
		<b><c:out value="${current.name}"/> </b>
			<br/>

			    <c:if test="${empty current.packages}">
			        <div class="page-summary">
			            <bean:message key="details.jsp.none"/>
			        </div>
			    </c:if>

			 <c:forEach items="${current.packages}" var="pack">
				<tt>${pack.checksumType}:${pack.checksum}</tt>
				<a href="/rhn/software/packages/Details.do?pid=${pack.id}">
						<c:out value="${pack.name}"/>
				</a>
	            <br/>
			</c:forEach>
			<br/>
        </div>
    </c:forEach>
</body>
</html>
