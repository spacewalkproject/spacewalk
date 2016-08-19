<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>

<html>
<body>
  <rhn:toolbar base="h1" icon="header-errata"
                   helpUrl="">
    <bean:message key="errata.edit.toolbar"/> <c:out value="${advisory}" />
  </rhn:toolbar>

  <rhn:dialogmenu mindepth="0" maxdepth="1" definition="/WEB-INF/nav/manage_errata.xml"
                  renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />

  <h2><rhn:icon type="header-package" />
      <bean:message key="errata.edit.packages.confirm.confirmpackageremoval"/>
  </h2>

  <p><bean:message key="errata.edit.packages.confirm.remove.instructions"/></p>

<rl:listset name="packageList">
  <rhn:csrf />
  <rhn:submitted />
  <rhn:hidden name="eid" value="${param.eid}" />
  <rl:list emptykey="errata.edit.packages.add.nopackages"
      dataset="packages"
      name="packageList">
    <rl:decorator name="PageSizeDecorator"/>

    <rl:column headerkey="packagelist.jsp.packagename"
               bound="false"
               sortattr="nvrea"
               sortable="true"
               defaultsort="asc" >
      <a href="/rhn/software/packages/Details.do?pid=${current.id}">
        <c:out value="${current.nvrea}" />
      </a>
    </rl:column>
  </rl:list>
  <c:if test="${not empty packages}">
    <div class="text-right">
      <hr />
      <input type="submit" class="btn btn-danger" name="dispatch"
             value='<bean:message key="confirm"/>' />
    </div>
  </c:if>
</rl:listset>

</body>
</html>
