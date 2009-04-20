<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>

<head>
<%@ include file="/WEB-INF/pages/common/fragments/editarea.jspf" %>
</head>

<html:html xhtml="true">
<body>

<html:errors />
<html:messages id="message" message="true">
  <rhn:messages><c:out escapeXml="false" value="${message}" /></rhn:messages>
</html:messages>

<rhn:toolbar base="h1" img="/img/rhn-icon-info.gif" imgAlt="info.alt.img">
  ${path}
</rhn:toolbar>

<bean:message key="snippetcreate.jsp.summary"/>

<h2><bean:message key="snippetcreate.jsp.header2"/></h2>

<div>
    <table class="details">
    <tr>    
        <th>
         <bean:message key="snippetcreate.jsp.contents"/>
        </th>
        <td>
   			<pre style="overflow: scroll; width: 800px; height: 800px">${data}</pre>
       </td>
    </tr>
    </table>
    <hr />
</div>

</body>
</html:html>

