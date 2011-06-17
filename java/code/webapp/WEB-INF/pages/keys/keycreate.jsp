<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>

<html:html xhtml="true">
<body>
<rhn:toolbar base="h1" img="/img/rhn-icon-info.gif" imgAlt="info.alt.img">
  <bean:message key="keycreate.jsp.toolbar"/>
</rhn:toolbar>

<bean:message key="keycreate.jsp.summary"/>

<h2><bean:message key="keycreate.jsp.header2"/></h2>

<div>
    <html:form action="/keys/CryptoKeyCreate?csrf_token=${csrfToken}" enctype="multipart/form-data">
    <rhn:csrf />
    <html:hidden property="submitted" value="true"/>
    <html:hidden property="key_id" value="${cryptoKey.id}"/>
    <%@ include file="key-form.jspf" %>
    <hr /><table align="right">
    	  <tr>
      		<td></td>
      		<td align="right"><html:submit><bean:message key="keycreate.jsp.submit"/></html:submit></td>
    	  </tr>
          </table>
    </html:form>
</div>

</body>
</html:html>

