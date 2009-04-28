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
	<c:out value="${requestScope.snippet.displayName}"/>
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
	<table class="details">
    <tr>
        <th>
            <bean:message key="cobbler.snippet.name"/><span class="required-form-field">*</span>
        </th>
        <td>
        		<html:text property="name"/><br/>
            	<rhn:tooltip key="snippetcreate.jsp.tip1"/><br/>
            <c:if  test = "${empty requestScope.create_mode}">	
            	<rhn:warning key="snippetcreate.jsp.warning.tip"/>
            	<html:hidden property="oldName"/>
            </c:if>
        </td>
     </tr>
	<c:if  test = "${empty requestScope.create_mode}">
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
     </c:if>
     <tr>
        <th>
            <bean:message key="cobbler.snippet.type"/>:
        </th>
        <td>
				<bean:message key="cobbler.snippet.custom"/><br/>
            <rhn:tooltip><bean:message key="cobbler.snippet.custom.tip" 
            			arg0="${requestScope.org}"/></rhn:tooltip>	
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

