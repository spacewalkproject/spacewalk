<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>

<html:xhtml/>
<html>
<body>
<rhn:toolbar base="h1" img="/img/rhn-kickstart_profile.gif" imgAlt="system.common.kickstartAlt"
               deletionUrl="/rhn/systems/provisioning/preservation/PreservationListDeleteSingle.do?file_list_id=${fileList.id}"
               deletionType="filelist">
  <bean:message key="preservation_edit.jsp.toolbar"/>
</rhn:toolbar>

<bean:message key="preservation_edit.jsp.summary"/>

<h2><bean:message key="preservation_edit.jsp.header2"/></h2>

<div>
    <html:form action="/systems/provisioning/preservation/PreservationListEdit" method="POST">
    <%@ include file="preservation-form.jspf" %>
    <hr /><table align="right">
          <tr>
             <td></td>
             <html:hidden property="submitted" value="true"/>
             <html:hidden property="file_list_id" value="${fileList.id}"/>
             <td align="right"><html:submit><bean:message key="preservationlist.jsp.updatelist"/></html:submit></td>
         </tr>
         </table>
    </html:form>
</div>

</body>
</html>

