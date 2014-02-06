<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>


<html>
<head>
</head>
<body>
<rhn:toolbar base="h1" icon="header-errata"
	           helpUrl="/rhn/help/getting-started/en-US/chap-Getting_Started_Guide-Errata_Management.jsp#sect-Getting_Started_Guide-Errata_Management-Creating_and_Editing_Errata">
    <bean:message key="errata.edit.toolbar"/> <c:out value="${advisory}" />
  </rhn:toolbar>

  <rhn:dialogmenu mindepth="0" maxdepth="1" definition="/WEB-INF/nav/manage_errata.xml"
                  renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />

  <h2><rhn:icon type="header-package" />
      <bean:message key="errata.edit.packages.confirm.confirmpackageremoval"/></h2>

  <p><bean:message key="errata.edit.packages.confirm.remove.instructions"/></p>

<form method="POST" name="rhn_list" action="/rhn/errata/manage/RemovePackagesSubmit.do">
  <rhn:csrf />

  <%@ include file="/WEB-INF/pages/common/fragments/errata/package-confirm-list.jspf" %>

<input type="hidden" name="eid" value="<c:out value="${param.eid}"/>" />
</form>

</body>
</html>
