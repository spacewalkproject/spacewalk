<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>

<html:html xhtml="true">
<script language="javascript" src="/javascript/refresh.js"></script>
<head>
<meta http-equiv="Pragma" content="no-cache" />


</head>

<body>
<rhn:toolbar base="h1" img="/img/rhn-icon-info.gif" imgAlt="info.alt.img">
  <bean:message key="treecreate.jsp.toolbar"/>
</rhn:toolbar>

<bean:message key="treecreate.jsp.header1"/>

<h2><bean:message key="treecreate.jsp.header2"/></h2>

<div>
    <html:form method="post" action="/kickstart/TreeCreate.do" styleId="dist-tree-form">
      <%@ include file="tree-form.jspf" %>
      <hr/><table align="right">
          <c:if test="${requestScope.hidesubmit != 'true'}">
          <tr>
            <td><html:submit><bean:message key="createtree.jsp.submit"/></html:submit></td>
          </tr>
          </c:if>
		</table>
        <html:hidden property="submitted" value="true"/>
    </html:form>
</div>

</body>
</html:html>

