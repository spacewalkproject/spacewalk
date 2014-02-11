<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>


<html>
<head>
</head>
<body>
<rhn:toolbar base="h1" icon="header-errata" iconAlt="errata.common.errataAlt"
	           helpUrl="/rhn/help/getting-started/en-US/chap-Getting_Started_Guide-Errata_Management.jsp#sect-Getting_Started_Guide-Errata_Management-Creating_and_Editing_Errata">
    <bean:message key="errata.edit.toolbar"/> <c:out value="${errata.advisory}" />
  </rhn:toolbar>

  <rhn:dialogmenu mindepth="0" maxdepth="1" definition="/WEB-INF/nav/manage_errata.xml"
                  renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />

  <h2><bean:message key="delete.jsp.header"/></h2>

    <div class="page-summary">
      <p><bean:message key="delete.jsp.summary"/></p>
    </div>

  <table class="details">
    <tr>
      <th><bean:message key="delete.jsp.erratum"/></th>
      <td>
      <strong>${errata.advisoryName}</strong><br />
      ${errata.synopsis}
      </td>
    </tr>
    <tr>
      <th><bean:message key="delete.jsp.description"/></th>
      <td>${errata.description}</td>
    </tr>
  </table>

  <hr />
  <div class="text-right">
    <form action="/rhn/errata/manage/Delete.do" method="POST">
    <rhn:csrf />
    <rhn:submitted />
    <input type="hidden" name="eid" value="<c:out value="${param.eid}"/>" />
      <html:submit styleClass="btn btn-default" property="dispatch">
        <bean:message key="delete.jsp.delete"/>
      </html:submit>
    </form>
  </div>

</body>
</html>
