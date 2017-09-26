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
            <h2><bean:message key="erratalist.jsp.synopsis" /></h2>
        </div>
        <div class="panel-body">
            <div class="page-summary">${errata.synopsis}</div>
            <br/>
            <table class="details">
                <tr>
                    <th><bean:message key="details.jsp.issued"/></th>
                     <td>${issued}</td>
                </tr>
                <tr>
                    <th><bean:message key="details.jsp.updated"/></th>
                    <td>${updated}</td>
                </tr>
                <tr>
                    <th><bean:message key="details.jsp.from"/></th>
                    <td>${errataFrom}</td>
                </tr>
            </table>
        </div>
    </div>

    <div class="panel panel-default">
        <div class="panel-heading">
            <h2><bean:message key="details.jsp.topic"/></h2>
        </div>
        <div class="panel-body">
            <div class="page-summary">
                ${topic}
                <c:if test="${empty topic}">
                        <bean:message key="details.jsp.none"/>
                </c:if>
                <c:if test="${not empty topic}">
                    <c:if test="${empty fn:trim(topic)}">
                        <bean:message key="details.jsp.none"/>
                    </c:if>
                </c:if>
            </div>
        </div>
    </div>

    <div class="panel panel-default">
        <div class="panel-heading">
            <h2><bean:message key="details.jsp.description"/></h2>
        </div>
        <div class="panel-body">
            <div class="page-summary">
                ${description}
                <c:if test="${empty description}">
                        <bean:message key="details.jsp.none"/>
                </c:if>
                <c:if test="${not empty description}">
                    <c:if test="${empty fn:trim(description)}">
                        <bean:message key="details.jsp.none"/>
                    </c:if>
                </c:if>
            </div>
        </div>
    </div>

    <div class="panel panel-default">
        <div class="panel-heading">
            <h2><bean:message key="details.jsp.solution"/></h2>
        </div>
        <div class="panel-body">
            <div class="page-summary">
                ${solution}
                <c:if test="${empty solution}">
                        <bean:message key="details.jsp.none"/>
                </c:if>
                <c:if test="${not empty solution}">
                    <c:if test="${empty fn:trim(solution)}">
                        <bean:message key="details.jsp.none"/>
                    </c:if>
                </c:if>
            </div>
        </div>
    </div>

    <div class="panel panel-default">
        <div class="panel-heading">
            <h2><bean:message key="details.jsp.affectedchannels"/></h2>
        </div>
        <div class="panel-body">
            <c:forEach items="${channels}" var="current">
            <div class="page-summary">
                <a href="/rhn/channels/ChannelPackages.do?cid=${current.id}">
                    ${current.name}</a>
            </div>
            </c:forEach>
            <c:if test="${empty channels}">
                <div class="page-summary">
                    <bean:message key="details.jsp.none"/>
                </div>
                <c:if test="${not empty channels}">
                    <c:if test="${empty fn:trim(channels)}">
                        <div class="page-summary">
                            <bean:message key="details.jsp.none"/>
                        </div>
                    </c:if>
                </c:if>
            </c:if>
        </div>
    </div>

    <div class="panel panel-default">
        <div class="panel-heading">
            <h2><bean:message key="details.jsp.fixes"/></h2>
        </div>
        <div class="panel-body">
            <c:forEach items="${fixed}" var="current">
                <div class="page-summary">
                    <c:choose>
                        <c:when test="${current.href == null && errata.org == null}">
                            <a href="https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=${current.bugId}">
                                <c:out value="${current.summary}"/>
                            </a>
                        </c:when>
                        <c:when test="${current.href == null && errata.org != null}">
                            <bean:message key="details.jsp.bugnumber" arg0="${current.bugId}"/>
                            <c:out value="${current.summary}"/>
                        </c:when>
                        <c:otherwise>
                            <a href="${current.href}">
                                <c:out value="${current.summary}"/>
                            </a>
                        </c:otherwise>
                    </c:choose>
                </div>
            </c:forEach>
            <c:if test="${empty fixed}">
                <div class="page-summary">
                    <bean:message key="details.jsp.none"/>
                </div>
            </c:if>
            <c:if test="${not empty fixed}">
                    <c:if test="${empty fn:trim(fixed)}">
                        <div class="page-summary">
                            <bean:message key="details.jsp.none"/>
                        </div>
                    </c:if>
                </c:if>
        </div>
    </div>

    <div class="panel panel-default">
        <div class="panel-heading">
            <h2><bean:message key="details.jsp.keywords"/></h2>
        </div>
        <div class="panel-body">
            <div class="page-summary">
                ${keywords}
                <c:if test="${empty keywords}">
                        <bean:message key="details.jsp.none"/>
                </c:if>
                <c:if test="${not empty keywords}">
                    <c:if test="${empty fn:trim(keywords)}">
                        <bean:message key="details.jsp.none"/>
                    </c:if>
                </c:if>
            </div>
        </div>
    </div>

    <div class="panel panel-default">
        <div class="panel-heading">
            <h2><bean:message key="details.jsp.cves"/></h2>
        </div>
        <div class="panel-body">
            <c:forEach items="${cve}" var="current">
            <div class="page-summary">
                <a href="http://cve.mitre.org/cgi-bin/cvename.cgi?name=${current.name}">
                    ${current.name}
                </a>
            </div>
            </c:forEach>
            <c:if test="${empty cve}">
                <div class="page-summary">
                    <bean:message key="details.jsp.none"/>
                </div>
            </c:if>
            <c:if test="${not empty cve}">
                <c:if test="${empty fn:trim(cve)}">
                    <div class="page-summary">
                        <bean:message key="details.jsp.none"/>
                    </div>
                </c:if>
            </c:if>
        </div>
    </div>

    <div class="panel panel-default">
        <div class="panel-heading">
            <h2><bean:message key="erratalist.jsp.oval"/></h2>
        </div>
        <div class="panel-body">
            <c:if test="${ovalFile != null}">
                <div class="page-summary">
                    <c:out value="${ovalFile}" escapeXml="false" />
                </div>
            </c:if>
            <c:if test="${ovalFile == null}">
                <div class="page-summary">
                    <bean:message key="details.jsp.none"/>
                </div>
            </c:if>
        </div>
    </div>


    <div class="panel panel-default">
        <div class="panel-heading">
            <h2><bean:message key="details.jsp.references"/></h2>
        </div>
        <div class="panel-body">
            <div class="page-summary">
                ${references}
                <c:if test="${empty references}">
                    <bean:message key="details.jsp.none"/>
                </c:if>
                <c:if test="${not empty references}">
                    <c:if test="${empty fn:trim(references)}">
                        <bean:message key="details.jsp.none"/>
                    </c:if>
                </c:if>
            </div>
        </div>
    </div>

    <div class="panel panel-default">
        <div class="panel-heading">
            <h2><bean:message key="actiondetails.jsp.notes"/></h2>
        </div>
        <div class="panel-body">
            <div class="page-summary">
                ${notes}
                <c:if test="${empty notes}">
                    <bean:message key="details.jsp.none"/>
                </c:if>
                <c:if test="${not empty notes}">
                    <c:if test="${empty fn:trim(notes)}">
                        <bean:message key="details.jsp.none"/>
                    </c:if>
                </c:if>
            </div>
        </div>
    </div>

</body>
</html>
