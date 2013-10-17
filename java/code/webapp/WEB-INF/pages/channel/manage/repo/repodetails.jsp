<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>

<html:html xhtml="true">
<body>
<c:choose>
	<c:when test = "${not empty requestScope.create_mode}">
      <rhn:toolbar base="h1" icon="icon-info-sign" imgAlt="info.alt.img">
        <bean:message key="repos.jsp.toolbar"/>
      </rhn:toolbar>
      <h2><bean:message key="repos.jsp.header2"/></h2>
	</c:when>
	<c:otherwise>
      <rhn:toolbar base="h1" icon="icon-info-sign" imgAlt="info.alt.img"
		           deletionUrl="RepoDelete.do?id=${requestScope.repo.id}"
                   deletionType="repos">
	    <c:out value="${requestScope.repo.label}"/>
      </rhn:toolbar>
      <h2><bean:message key="repos.jsp.details.header2"/></h2>
	</c:otherwise>
</c:choose>

<c:choose>
	<c:when test="${empty requestScope.create_mode}">
		<c:set var="url" value ="/channels/manage/repos/RepoEdit"/>
	</c:when>
	<c:otherwise>
		<c:set var="url" value ="/channels/manage/repos/RepoCreate"/>
	</c:otherwise>
</c:choose>

<div>
    <html:form action="${url}">
    <rhn:csrf />
    <rhn:submitted/>
    <html:hidden property="id" value="${repo.id}"/>
	<table class="details">
    <tr>
        <th>
		<rhn:required-field key = "repos.jsp.create.label"/>
        </th>
        <td>
			<html:text property="label"/>

            <c:if  test = "${empty requestScope.create_mode}">
		<html:hidden property="sourceid"/>
            </c:if>
        </td>
    </tr>
    <tr>
        <th>
		<rhn:required-field key = "repos.jsp.create.url"/>
        </th>
        <td>
			<html:text property="url"/>
        </td>
    </tr>
    <tr>
        <th>
		<bean:message key = "repos.jsp.ssl.ca"/>
        </th>
        <td>
            <html:select property="sslcacert">
                <html:options collection="sslcryptokeys" labelProperty="label" property="value" />
            </html:select>
        </td>
    </tr>
    <tr>
        <th>
		<bean:message key = "repos.jsp.ssl.clientcert"/>
        </th>
        <td>
            <html:select property="sslclientcert">
                <html:options collection="sslcryptokeys" labelProperty="label" property="value" />
            </html:select>
        </td>
    </tr>
    <tr>
        <th>
		<bean:message key = "repos.jsp.ssl.clientkey"/>
        </th>
        <td>
            <html:select property="sslclientkey">
                <html:options collection="sslcryptokeys" labelProperty="label" property="value" />
            </html:select>
        </td>
    </tr>
    </table>

    <hr />

    <table align="right">
	  <tr>
		<td></td>
		<c:choose>
		<c:when test = "${empty requestScope.create_mode}">
			<td align="right"><html:submit><bean:message key="repos.jsp.update.submit"/></html:submit></td>
		</c:when>
		<c:otherwise>
			<td align="right"><html:submit><bean:message key="repos.jsp.create.submit"/></html:submit></td>
		</c:otherwise>
		</c:choose>
	  </tr>
	</table>

    </html:form>
</div>

</body>
</html:html>
