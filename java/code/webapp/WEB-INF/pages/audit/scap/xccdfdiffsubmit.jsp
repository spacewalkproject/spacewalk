<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>

<html:xhtml/>
<html>
<head>
<style>
div.differs {
    background-color: #f5f3c4;
    display: inline-block;
    padding-bottom: 2px;
    padding-left: 9px;
    padding-right: 9px;
    margin-bottom: 0px;
    border-radius: 10px;
}
</style>
</head>
<body>

<rhn:toolbar base="h1" img="/img/rhn-icon-search.gif" imgAlt="search.alt.img">
  <bean:message key="scapdiff.jsp.toolbar"/>
</rhn:toolbar>

<rl:listset name="groupSet" legend="xccdf">
  <rhn:csrf/>
  <rl:list emptykey="generic.jsp.none">
    <rl:decorator name="PageSizeDecorator"/>

    <rl:column headerkey="system.audit.xccdfdetails.jsp.idref" sortattr="documentIdref"
        sortable="true" styleclass="first-column">
      <c:out value="${current.documentIdref}"/>
    </rl:column>
    <rl:column headerkey="xccdfdiff.firstscan" styleclass="center" headerclass="center">
      <c:if test="${current.differs == true}"><div class="differs"></c:if>
      <c:choose>
        <c:when test="${not empty current.first}">
          <a href="/rhn/systems/details/audit/RuleDetails.do?sid=${current.first.testResult.server.id}&rrid=${current.first.id}">
            <c:out value="${current.first.label}"/>
          </a>
          <c:if test="${current.onlyIdentDiffers}"><c:out value="(${current.first.identsString})"/></c:if>
        </c:when>
        <c:otherwise>
          <c:out value="-"/>
        </c:otherwise>
      </c:choose>
    </rl:column>
    <c:if test="${current.differs == true}"></div></c:if>
    <rl:column headerkey="xccdfdiff.secondscan" styleclass="center" headerclass="center">
      <c:if test="${current.differs == true}"><div class="differs"></c:if>
      <c:choose>
        <c:when test="${not empty current.second}">
          <a href="/rhn/systems/details/audit/RuleDetails.do?sid=${current.second.testResult.server.id}&rrid=${current.second.id}">
            <c:out value="${current.second.label}"/>
          </a>
          <c:if test="${current.onlyIdentDiffers}"><c:out value="${current.second.identsString}"/></c:if>
        </c:when>
        <c:otherwise>
          <c:out value="-"/>
        </c:otherwise>
      </c:choose>
      <c:if test="${current.differs == true}"></div></c:if>
    </rl:column>
  </rl:list>
</rl:listset>

</body>
</html>

