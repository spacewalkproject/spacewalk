<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>

<html:xhtml/>
<html>
<body>

<html:errors />
<html:messages id="message" message="true">
  <rhn:messages><c:out escapeXml="false" value="${message}" /></rhn:messages>
</html:messages>

<rhn:toolbar base="h1" img="/img/rhn-kickstart_profile.gif" imgAlt="kickstarts.alt.img">
	<bean:message key="snippetdelete.jsp.toolbar"/>
</rhn:toolbar>

<bean:message key="snippetdelete.jsp.summary"/>

<h2><bean:message key="snippetdelete.jsp.header2"/></h2>

<div>
    <html:form action="/kickstart/cobbler/CobblerSnippetDelete" enctype="multipart/form-data">
    <table class="details">
    <tr>
        <th>
            <bean:message key="snippetcreate.jsp.name"/><span class="required-form-field">*</span>
        </th>
        <td>
            <html:text property="name" maxlength="40" size="20" disabled="true"/>
        </td>
    </tr>
    <tr>    
        <th>
            <bean:message key="snippetcreate.jsp.contents"/>
        </th>
        <td>
            <textarea name="contents" rows="24" cols="80" id="contents" disabled="true">${cobblerSnippet.contents}</textarea><br />
        </td>
    </tr>
    <tr>
      <td></td>
      <html:hidden property="submitted" value="true"/>
      <html:hidden property="name" value="${cobblerSnippet.name}"/>
      <html:hidden property="contents" />
      
      <td align="right"><html:submit><bean:message key="snippetdelete.jsp.deletesnippet"/></html:submit></td>
    </tr>
    </table>
    </html:form>
</div>

</body>
</html>

