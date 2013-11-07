<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://www.opensymphony.com/sitemesh/decorator" prefix="decorator" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>



<html>

<body>

<%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>

<h2>
  <i class="fa spacewalk-icon-package-extra"></i>
  <bean:message key="packagelist.jsp.extrapackages" />
</h2>

<div class="page-summary">
  <p><bean:message key="packagelist.jsp.extrapackagessummary" /></p>
</div>

<c:set var="pageList" value="${requestScope.all}" />

<rl:listset name="packageListSet">
  <rhn:csrf />
  <rhn:submitted />

  <rl:list dataset="pageList"
           width="100%"
           styleclass="list"
           name="packageList"
           emptykey="packagelist.jsp.nopackages"
           alphabarcolumn="nvre">

    <rl:decorator name="PageSizeDecorator"/>
    <rl:decorator name="SelectableDecorator"/>
    <rl:selectablecolumn value="${current.selectionKey}"
                         selected="${current.selected}"
                         disabled="${not current.selectable}"/>

    <rl:column headerkey="packagelist.jsp.packagename"
               bound="false"
               sortattr="nvre"
               sortable="true"
               filterattr="nvre">${current.nvre}</rl:column>
    <rl:column headerkey="packagelist.jsp.packagearch"
               bound="false">
      <c:choose>
        <c:when test ="${not empty current.arch}">${current.arch}</c:when>
        <c:otherwise><bean:message key="packagelist.jsp.notspecified"/></c:otherwise>
      </c:choose>
    </rl:column>
    <rl:column headerkey="packagelist.jsp.installtime"
               bound="false"
               sortattr="installTimeObj"
               sortable="true">
      <c:choose>
        <c:when test ="${not empty current.installTime}">${current.installTime}</c:when>
        <c:otherwise><bean:message key="packagelist.jsp.notspecified"/></c:otherwise>
      </c:choose>
    </rl:column>
  </rl:list>

<c:if test="${not empty requestScope.all}">
  <div class="text-right">
    <rhn:submitted/>
    <hr/>
      <rhn:require acl="system_feature(ftr_package_remove)">
        <input type="submit"
               name ="dispatch"
               value='<bean:message key="packagelist.jsp.removepackages"/>'/>
      </rhn:require>
  </div>
</c:if>

</rl:listset>
</body>
</html>
