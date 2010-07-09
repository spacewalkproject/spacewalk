<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>

<head>
<%@ include file="/WEB-INF/pages/common/fragments/editarea.jspf" %>
</head>

<html:html xhtml="true">
<body>
<rhn:toolbar base="h1" img="/img/rhn-icon-info.gif" imgAlt="info.alt.img">
  ${requestScope.snippet.displayName}
</rhn:toolbar>

<h2><bean:message key="snippetdetails.jsp.header2"/></h2>

<div>
    <table class="details">
    <tr>
        <th>
            <bean:message key="cobbler.snippet.path"/>:
        </th>
        <td>
        		<c:out value="${requestScope.snippet.displayPath}"/> <br/>
    				<rhn:tooltip key="cobbler.snippet.path.tip"/>
        </td>
     </tr>
     <tr>
        <th>
            <bean:message key="cobbler.snippet.macro"/>:
        </th>
        <td>
        		<c:out value="${requestScope.snippet.fragment}"/> <br/>
        		<rhn:tooltip key="cobbler.snippet.copy-paste-snippet-tip"/>
        </td>
     </tr>

     <tr>
        <th>
            <bean:message key="cobbler.snippet.type"/>:
        </th>
        <td>
				<bean:message key="cobbler.snippet.default"/><br/>
            <rhn:tooltip key ="cobbler.snippet.default.tip"/>	
        </td>
     </tr>
     </table>
    <h2><bean:message key="snippetcreate.jsp.contents.header"/></h2>

    <table  class="details">
    <tr>
        <th>
            <bean:message key="snippetcreate.jsp.contents"/>
        </th>
        <td>
   			<pre  class="file-display">${data}</pre>
       </td>
    </tr>
    </table>
</div>

</body>
</html:html>

