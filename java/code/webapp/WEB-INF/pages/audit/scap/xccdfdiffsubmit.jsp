<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>


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

<rhn:toolbar base="h1" icon="header-search" imgAlt="search.alt.img">
  <bean:message key="scapdiff.jsp.toolbar"/>
</rhn:toolbar>

<div style="float: right;">
  <c:if test="${view != 'full'}">
    <a href="/rhn/audit/scap/DiffSubmit.do?first=${param.first}&second=${param.second}&view=full">
  </c:if>
  <bean:message key="diff.jsp.full"/>
  <c:if test="${view != 'full'}"></a></c:if>

  &nbsp;&nbsp;|&nbsp;&nbsp;
  <c:if test="${view != 'changed'}">
    <a href="/rhn/audit/scap/DiffSubmit.do?first=${param.first}&second=${param.second}&view=changed">
  </c:if>
  <bean:message key="xccdfdiff.view.changed"/>
  <c:if test="${view != 'changed'}"></a></c:if>

  &nbsp;&nbsp;|&nbsp;&nbsp;
  <c:if test="${view != 'same'}">
    <a href="/rhn/audit/scap/DiffSubmit.do?first=${param.first}&second=${param.second}&view=same">
  </c:if>
  <bean:message key="xccdfdiff.view.same"/>
  <c:if test="${view != 'same'}"></a></c:if>
</div>


<rl:listset name="groupSet">
  <rhn:csrf/>

  <h2><bean:message key="system.audit.xccdfdetails.jsp.header"/></h2>

  <rl:list emptykey="generic.jsp.none" dataset="metadataList" name="1">
    <rl:column headerkey="xccdfdiff.fieldnames">
      <c:if test="${not empty current.msg}">
        <strong><bean:message key="${current.msg}"/>:</strong>
      </c:if>
    </rl:column>

    <rl:column headerkey="xccdfdiff.firstscan">
      <c:if test="${current.differs == true}"><div class="differs"></c:if>
        <c:choose>
          <c:when test="${not empty current.first}">
            ${current.first}
          </c:when>
          <c:otherwise>
            <c:out value="-"/>
          </c:otherwise>
        </c:choose>
      <c:if test="${current.differs == true}"></div></c:if>
    </rl:column>

    <rl:column headerkey="xccdfdiff.secondscan">
      <c:if test="${current.differs == true}"><div class="differs"></c:if>
        <c:choose>
          <c:when test="${not empty current.second}">
            ${current.second}
          </c:when>
          <c:otherwise>
            <c:out value="-"/>
          </c:otherwise>
        </c:choose>
      <c:if test="${current.differs == true}"></div></c:if>
    </rl:column>
  </rl:list>

  <h2><bean:message key="system.audit.xccdfdetails.jsp.xccdfrules"/></h2>

  <rl:list emptykey="generic.jsp.none" name="2">
    <rl:decorator name="PageSizeDecorator"/>

    <rl:column headerkey="system.audit.xccdfdetails.jsp.idref" sortattr="documentIdref"
        sortable="true">
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
    <rl:column headerkey="xccdfdiff.secondscan" headerclass="center">
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

