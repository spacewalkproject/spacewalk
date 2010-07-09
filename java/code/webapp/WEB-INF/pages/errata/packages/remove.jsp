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
<rhn:toolbar base="h1" img="/img/rhn-icon-errata.gif"
	           helpUrl="/rhn/help/channel-mgmt/en-US/channel-mgmt-Custom_Errata_Management-Managed_Errata_Details.jsp">
    <bean:message key="errata.edit.toolbar"/> <c:out value="${advisory}" />
  </rhn:toolbar>

  <rhn:dialogmenu mindepth="0" maxdepth="1" definition="/WEB-INF/nav/manage_errata.xml"
                  renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />

  <h2><img src="/img/rhn-icon-packages.gif">
      <bean:message key="errata.edit.packages.confirm.confirmpackageremoval"/></h2>

  <p><bean:message key="errata.edit.packages.confirm.remove.instructions"/></p>

<form method="POST" name="rhn_list" action="/rhn/errata/manage/RemovePackagesSubmit.do">

  <%@ include file="/WEB-INF/pages/common/fragments/errata/package-confirm-list.jspf" %>

<input type="hidden" name="eid" value="<c:out value="${param.eid}"/>" />
</form>

</body>
</html>
