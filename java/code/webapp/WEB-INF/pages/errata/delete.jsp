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
	           helpUrl="/rhn/help/channel-mgmt/en-US/channel-mgmt-Custom_Errata_Management-Creating_and_Editing_Errata.jsp">
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
  <div align="right">
    <form action="/rhn/errata/manage/Delete.do?eid=${param.eid}">
    <input type="hidden" name="eid" value="<c:out value="${param.eid}"/>" />
      <html:submit property="dispatch">
        <bean:message key="delete.jsp.delete"/>
      </html:submit>
    </form>
  </div>

</body>
</html>
