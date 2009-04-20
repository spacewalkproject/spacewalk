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
	${requestScope.prefix}/${requestScope.name}
</rhn:toolbar>

<bean:message key="snippetdelete.jsp.summary"/>

<h2><bean:message key="snippetdelete.jsp.header2"/></h2>

<div>
	<form method="post" action="/rhn/kickstart/cobbler/CobblerSnippetDelete.do">
    <table class="details">
    <tr>    
        <th>
         <bean:message key="snippetcreate.jsp.contents"/>
        </th>
        <td>
   			<pre style="overflow: scroll; width: 800px; height: 800px">${contents}</pre>
       </td>
    </tr>
    </table>
    <hr />
    <table align="right">
    <tr>
      <td></td>
      <rhn:submitted/>
      <input type="hidden" name="name" value="${requestScope.name}"/>
      <td align="right"><input type=submit name="dispatch"  
       value="${rhn:localize('snippetdelete.jsp.deletesnippet')}"/></td>
    </tr>
        </table>
    </form>
</div>

</body>
</html>

