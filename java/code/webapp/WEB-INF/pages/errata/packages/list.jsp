<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>

<html>
<head>
</head>
<body>
<rhn:toolbar base="h1" icon="header-errata" iconAlt="errata.common.errataAlt" >
  <bean:message key="errata.edit.toolbar"/>
  <c:out value="${advisory}" />
</rhn:toolbar>

<rhn:dialogmenu mindepth="0" maxdepth="1" definition="/WEB-INF/nav/manage_errata.xml"
                renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />

<h2><rhn:icon type="header-package" title="errata.common.packageAlt" />
  <bean:message key="errata.edit.packages.list.erratapackages"/>
</h2>

<p><bean:message key="errata.edit.packages.list.instructions"/></p>

<rl:listset name="packageList">
  <rhn:csrf />
  <rhn:submitted/>
  <rhn:hidden name="eid" value="${param.eid}" />
  <rl:list
    dataset="packages"
    emptykey="errata.edit.packages.add.nopackages"
    name="packageList"
    alphabarcolumn="packageNvre">

    <rl:decorator name="PageSizeDecorator"/>
    <rl:decorator name="SelectableDecorator"/>

    <rl:selectablecolumn
               value="${current.id}"
               selected="${current.selected}" />

    <rl:column headerkey="errata.edit.packages.add.package"
               bound="false"
               sortattr="packageNvre"
               sortable="true"
               filterattr="packageNvre"
               defaultsort="asc" >
      <a href="/rhn/software/packages/Details.do?pid=${current.id}">
        <c:out value="${current.packageNvre}" />
      </a>
    </rl:column>

    <rl:column headerkey="errata.edit.packages.add.channels">
      <c:choose>
        <c:when test="${current.packageChannels != null}">
          <c:forEach items="${current.packageChannels}" var="channel">
            <c:out value="${channel}"/><br />
          </c:forEach>
        </c:when>
        <c:otherwise>
          <bean:message key="none" />
        </c:otherwise>
      </c:choose>
    </rl:column>
  </rl:list>
  <c:if test="${not empty packages}">
    <div class="text-right">
      <hr />
      <input type="submit" class="btn btn-primary" name ="dispatch"
             value='<bean:message key="errata.edit.packages.list.removepackages"/>' />
    </div>
  </c:if>
</rl:listset>
</body>
</html>