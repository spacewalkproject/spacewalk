<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>

<html:html xhtml="true">
<body>
<%@ include file="/WEB-INF/pages/common/fragments/kickstart/kickstart-toolbar.jspf" %>
<rhn:dialogmenu mindepth="0" maxdepth="1"
    definition="/WEB-INF/nav/kickstart_details.xml"
    renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />

<h2><bean:message key="kickstart.partition.jsp.header"/></h2>

<%--
<%@ include file="/WEB-INF/pages/common/fragments/kickstart/kickstart-toolbar.jspf" %>
--%>
<div>
  <p>
    <bean:message key="kickstart.partition.jsp.summary"/>
  </p>
    <html:form method="post" action="/kickstart/KickstartPartitionEdit.do">
      <table class="details">
          <tr>
              <th>
                  <rhn:required-field key="kickstart.partition.jsp.partitiondetails"/>:
              </th>
              <td>
                  <html:textarea rows="6" cols="80" property="partitions"/>
              </td>
          </tr>
          <tr>
            <td align="right" colspan="2"><html:submit><bean:message key="kickstart.partition.jsp.update"/></html:submit></td>
          </tr>
      </table>
	  <html:hidden property="ksid" value="${ksdata.id}"/>
      <html:hidden property="submitted" value="true"/>
    </html:form>
</div>
</body>
</html:html>

