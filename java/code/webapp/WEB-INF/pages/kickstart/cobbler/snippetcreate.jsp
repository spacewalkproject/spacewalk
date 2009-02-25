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
  <bean:message key="snippetcreate.jsp.toolbar"/>
</rhn:toolbar>

<bean:message key="snippetcreate.jsp.summary"/>

<h2><bean:message key="snippetcreate.jsp.header2"/></h2>

<div>
    <html:form action="/kickstart/cobbler/CobblerSnippetCreate" enctype="multipart/form-data">
    <html:hidden property="submitted" value="true"/>
    <html:hidden property="snippet_path" value="snippet"/>
    <table class="details">
     <tr>
        <th>
            <bean:message key="snippetcreate.jsp.name"/><span class="required-form-field">*</span>
            </br>
            <bean:message key="snippetcreate.jsp.tip1"/>
        </th>
        <td>
            /var/lib/cobbler/snippets/<html:text property="name" maxlength="40" size="20" />
        </td>
     </tr>
    <tr>    
        <th>
            <bean:message key="snippetcreate.jsp.contents"/>
                <span class="required-form-field">*</span>
        </th>
            <td>
            <textarea name="contents" rows="24" cols="80" id="contents"><bean:write name="cobblerSnippetsForm" property="contents" /></textarea><br />
        </td>
    </tr>
    </table>
    <hr /><table align="right">
    	  <tr>
      		<td></td>
      		<td align="right"><html:submit><bean:message key="snippetcreate.jsp.submit"/></html:submit></td>
    	  </tr>
          </table>
    </html:form>
</div>

</body>
</html:html>

