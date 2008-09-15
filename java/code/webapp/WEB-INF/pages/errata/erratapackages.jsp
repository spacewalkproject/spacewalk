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
    
    <c:if test="${empty files}">
        <div class="page-summary">
            <bean:message key="details.jsp.none"/>
        </div>
    </c:if>

    <c:forEach items="${files}" var="current">
        <div class="page-summary">

            <c:if test="${previousChannel != current.channelName}">
                <br/><b>${current.channelName}:</b> <br/>
            </c:if>
        
            <tt>${current.md5sum}</tt>
        
            <c:if test="${not empty current.packageId}">
                <a href="/network/software/packages/details.pxt?pid=${current.packageId}">${current.filename}</a>
            </c:if>
            <c:if test="${empty current.packageId}">
                ${current.filename}
            </c:if>
            <br/>

        </div>
        <c:set var="previousChannel" value="${current.channelName}" />
    </c:forEach>
</body>
</html>
