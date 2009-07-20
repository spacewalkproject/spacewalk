<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>

<html:html xhtml="true">
<body>
<rhn:toolbar base="h1" img="/img/rhn-icon-info.gif" imgAlt="info.alt.img">
  <bean:message key="preservation_create.jsp.toolbar"/>
</rhn:toolbar>

<bean:message key="preservation_edit.jsp.summary"/>

<h2><bean:message key="preservation_create.jsp.header2"/></h2>

<div>
    <html:form action="/systems/provisioning/preservation/PreservationListCreate" method="post">
    <html:hidden property="submitted" value="true"/>
    <html:hidden property="file_list_id" value="${fileList.id}"/>
    <%@ include file="preservation-form.jspf" %>
    <hr /><table align="right">
    <tr>
      <td></td>

      <td align="right"><html:submit><bean:message key="preservationlist.jsp.createlist"/></html:submit></td>
    </tr>
    </table>
    </html:form>
</div>

</body>
</html:html>

