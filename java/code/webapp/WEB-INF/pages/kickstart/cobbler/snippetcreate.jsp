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

<c:choose>
	<c:when test = "${not empty requestScope.create_mode}">
<rhn:toolbar base="h1" img="/img/rhn-icon-info.gif" imgAlt="info.alt.img">
  <bean:message key="snippetcreate.jsp.toolbar"/>
</rhn:toolbar>
	</c:when>
	<c:otherwise>
<rhn:toolbar base="h1" img="/img/rhn-icon-info.gif" imgAlt="info.alt.img"
		               deletionUrl="CobblerSnippetDelete.do?name=${cobblerSnippetsForm.map.name}"
               deletionType="snippets">
	${requestScope.prefix}/${cobblerSnippetsForm.map.name}
</rhn:toolbar>
	</c:otherwise>
</c:choose>	

<h2><bean:message key="snippetcreate.jsp.header2"/></h2>
<c:choose>
	<c:when test="${empty requestScope.create_mode}">
		<c:set var="url" value ="/kickstart/cobbler/CobblerSnippetEdit"/>
	</c:when>
	<c:otherwise> 
		<c:set var="url" value ="/kickstart/cobbler/CobblerSnippetCreate"/>
	</c:otherwise>
</c:choose>


<div>
    <html:form action="${url}" enctype="multipart/form-data">
    <rhn:submitted/>
    <c:if  test = "${empty requestScope.create_mode}">
    	<html:hidden property="name" value="${cobblerSnippetsForm.map.name}"/>
    </c:if>
    <c:if  test = "${not empty requestScope.create_mode}">
    <table class="details">

    <tr>
        <th>
            <bean:message key="cobbler.snippet.name"/><span class="required-form-field">*</span>
        </th>
        <td>
        		<html:text property="name" maxlength="40" size="20" /><br/>
            	<rhn:tooltip key="snippetcreate.jsp.tip1"/>
        </td>
     </tr>

    </table>
    </c:if>
    <h2><bean:message key="snippetcreate.jsp.contents.header"/></h2>
    
    <table  class="details"> 
    <tr>    
        <th>
            <bean:message key="snippetcreate.jsp.contents"/><span class="required-form-field">*</span>
        </th>
        <td>
         	<html:textarea property="contents" rows="24" cols="80" styleId="contents"/>
        </td>
    </tr>
    </table>
    
    <hr />

    <table align="right">
    	  <tr>
      		<td></td>
      		<td align="right"><html:submit><bean:message key="snippetcreate.jsp.submit"/></html:submit></td>
    	  </tr>
	</table>

    </html:form>
</div>

</body>
</html:html>

