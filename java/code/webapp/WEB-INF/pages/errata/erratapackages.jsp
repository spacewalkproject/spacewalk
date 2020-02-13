<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>


<html>
<head>
</head>
<body>

    <%@ include file="/WEB-INF/pages/common/fragments/errata/errata-header.jspf" %>

    <div class="panel panel-default">
        <div class="panel-heading">
            <h2><bean:message key="packagelist.jsp.header.packages"/></h2>
        </div>

        <div class="panel-body">
            <c:forEach items="${channels}" var="current">
                <div class="page-summary">
                    <b>
                        <a href="/rhn/channels/ChannelDetail.do?cid=${current.id}">
                            <c:out value="${current.name}"/>
                        </a>
                    </b>
                    <br/>

                    <c:if test="${empty current.packages}">
                        <div class="page-summary">
                            <bean:message key="details.jsp.none"/>
                        </div>
                    </c:if>
                    <c:if test="${not empty current.packages}">
                        <c:if test="${empty fn:trim(current.packages)}">
                            <bean:message key="details.jsp.none"/>
                        </c:if>
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
        </div>
    </div>
</body>
</html>
