<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>


<html>
<head>
</head>
<body>

<rhn:toolbar base="h1" icon="header-errata" iconAlt="errata.common.errataAlt"
                   helpUrl="">
    <bean:message key="errata.edit.toolbar"/> <c:out value="${advisory}" />
  </rhn:toolbar>

  <rhn:dialogmenu mindepth="0" maxdepth="1" definition="/WEB-INF/nav/manage_errata.xml"
                  renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />

  <h2>
    <rhn:icon type="header-package" title="errata.common.packageAlt" />
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
