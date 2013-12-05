<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>


<html>
<body>
<rhn:toolbar base="h1" icon="fa-rocket" imgAlt="kickstarts.alt.img">
	<c:out value="${requestScope.snippet.displayName}"/>
</rhn:toolbar>
<h2><bean:message key="cobbler.snippet.delete"/></h2>
<p><bean:message key="snippetdelete.jsp.summary"/></p>
<p><rhn:warning key= "snippetdelete.jsp.warning"/></p>
<div>
	<form method="post" action="/rhn/kickstart/cobbler/CobblerSnippetDelete.do">
    <rhn:csrf />
<h2><bean:message key="snippetcreate.jsp.contents.header"/></h2>
    <table class="details">
    <tr>
        <th>
         <bean:message key="snippetcreate.jsp.contents"/>
        </th>
        <td>
   			<pre  class="file-display"><c:out value="${contents}"/></pre>
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

