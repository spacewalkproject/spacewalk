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

<h2><bean:message key="erratalist.jsp.synopsis"/></h2>
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
      </table>

<h2><bean:message key="details.jsp.topic"/></h2>
    <div class="page-summary">${topic}</div>

<h2><bean:message key="details.jsp.description"/></h2>
    <div class="page-summary">${description}</div>

<h2><bean:message key="details.jsp.solution"/></h2>
    <div class="page-summary">${solution}</div>

<h2><bean:message key="details.jsp.affectedchannels"/></h2>
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
    </c:if>

<h2><bean:message key="details.jsp.fixes"/></h2>
    <c:forEach items="${fixed}" var="current">
        <div class="page-summary">
            <c:choose>
              <c:when test="${errata.org == null}">
            <a href="https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=${current.bugId}">
                <c:out value="${current.summary}"/></a>
              </c:when>
              <c:otherwise>
                <bean:message key="details.jsp.bugnumber" arg0="${current.bugId}"/> <c:out value="${current.summary}"/>
              </c:otherwise>
            </c:choose>
        </div>
    </c:forEach>
    <c:if test="${empty fixed}">
        <div class="page-summary">
            <bean:message key="details.jsp.none"/>
        </div>
    </c:if>

<h2><bean:message key="details.jsp.keywords"/></h2>
    <div class="page-summary">
        ${keywords}
        <c:if test="${empty keywords}">
            <bean:message key="details.jsp.none"/>
        </c:if>
    </div>

<h2><bean:message key="details.jsp.cves"/></h2>
    <c:forEach items="${cve}" var="current">
        <div class="page-summary">
            <a href="http://cve.mitre.org/cgi-bin/cvename.cgi?name=${current.name}">
                ${current.name}</a>
        </div>
    </c:forEach>
    <c:if test="${empty cve}">
        <div class="page-summary">
            <bean:message key="details.jsp.none"/>
        </div>
    </c:if>

<h2><bean:message key="erratalist.jsp.oval"/></h2>
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


<h2><bean:message key="details.jsp.references"/></h2>
    <div class="page-summary">
        ${references}
        <c:if test="${empty references}">
            <bean:message key="details.jsp.none"/>
        </c:if>
    </div>

<h2><bean:message key="actiondetails.jsp.notes"/></h2>
    <div class="page-summary">
        ${notes}
        <c:if test="${empty notes}">
            <bean:message key="details.jsp.none"/>
        </c:if>
    </div>

</body>
</html>
