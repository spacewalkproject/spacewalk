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
<rhn:toolbar base="h1" img="/img/rhn-icon-errata.gif" imgAlt="errata.common.errataAlt"
	           helpUrl="/rhn/help/channel-mgmt/en-US/channel-mgmt-Custom_Errata_Management-Managed_Errata_Details.jsp">
    <bean:message key="errata.edit.toolbar"/> <c:out value="${advisory}" />
  </rhn:toolbar>

  <rhn:dialogmenu mindepth="0" maxdepth="1" definition="/WEB-INF/nav/manage_errata.xml"
                  renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />

  <h2>
    <img src="/img/rhn-icon-packages.gif"
         alt="<bean:message key='errata.common.packageAlt' />" />
    <bean:message key="errata.edit.packages.erratapackages"/>
  </h2>

  <ul>
      <li>
        <a href="/rhn/errata/manage/ListPackages.do?eid=<c:out value="${param.eid}"/>">
	      List / Remove Packages
	    </a>
      </li>

      <li>
        <a href="/rhn/errata/manage/AddPackages.do?eid=<c:out value="${param.eid}"/>">
          Add Packages
        </a>
      </li>
  </ul>

</body>
</html>
