<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>

<head>
<%@ include file="/WEB-INF/pages/common/fragments/editarea.jspf" %>
</head>

<html:xhtml/>
<html>
<body>

<html:errors />
<html:messages id="message" message="true">
  <rhn:messages><c:out escapeXml="false" value="${message}" /></rhn:messages>
</html:messages>

<rhn:toolbar base="h1" img="/img/rhn-icon-info.gif" imgAlt="system.common.kickstartAlt"
	 	deletionUrl="/rhn/kickstart/cobbler/CobblerSnippetDelete.do?name=${cobblerSnippet.name}"
     	deletionType="CobblerSnippetDelete">
  	<bean:message key="snippets.jsp.toolbar"/>
</rhn:toolbar>

<bean:message key="snippetcreate.jsp.summary"/>

<h2><bean:message key="snippetedit.jsp.header2"/></h2>

<div>
    <html:form action="/kickstart/cobbler/CobblerSnippetEdit" enctype="multipart/form-data">
    <table class="details">
     <tr>
         <th>
             <bean:message key="snippetcreate.jsp.name"/><span class="required-form-field"></span>
         </th>
         <td>
             /var/lib/cobbler/snippets/${cobblerSnippet.name}
         </td>
     </tr>
     <tr>    
         <th>
             <bean:message key="snippetcreate.jsp.contents"/>
                 <span class="required-form-field">*</span>
         </th>
             <td>
             <textarea name="contents" rows="24" cols="80" id="contents">${cobblerSnippet.contents}</textarea><br />
         </td>
     </tr>
    </table>
    <hr /><table align="right">
    	  <tr>
      		<td></td>
      		<html:hidden property="submitted" value="true"/>
      		<html:hidden property="name" value="${cobblerSnippet.name}"/>
      		<td align="right"><html:submit><bean:message key="snippetcreate.jsp.submit"/></html:submit></td>
    	  </tr>
          </table>
    </html:form>
</div>

</body>
</html>

