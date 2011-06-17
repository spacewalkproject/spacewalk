<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>

<html:xhtml/>
<html>
<body>
<rhn:toolbar base="h1" img="/img/rhn-icon-info.gif" imgAlt="system.common.kickstartAlt"
	 	deletionUrl="/rhn/keys/CryptoKeyDelete.do?key_id=${cryptoKey.id}"
     	deletionType="CryptoKeyDelete">
  	<bean:message key="keyedit.jsp.toolbar"/>
</rhn:toolbar>

<bean:message key="keycreate.jsp.summary"/>

<h2><bean:message key="keyedit.jsp.header2"/></h2>

<div>
    <html:form action="/keys/CryptoKeyEdit?csrf_token=${csrfToken}" enctype="multipart/form-data">
    <rhn:csrf />
    <%@ include file="key-form.jspf" %>
    <hr /><table align="right">
    	  <tr>
      		<td></td>
      		<html:hidden property="submitted" value="true"/>
      		<html:hidden property="key_id" value="${cryptoKey.id}"/>
      		<td align="right"><html:submit><bean:message key="keyedit.jsp.submit"/></html:submit></td>
    	  </tr>
          </table>
    </html:form>
</div>

</body>
</html>

