<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>

<html:html xhtml="true">

<head>
<meta http-equiv="Pragma" content="no-cache" />

<script language="javascript" src="/javascript/refresh.js"></script>
</head>

<body>
<rhn:toolbar base="h1" img="/img/rhn-kickstart_profile.gif"
			 deletionUrl="/rhn/kickstart/TreeDelete.do?kstid=${kstree.id}"
             deletionType="deleteTree"
             imgAlt="kickstarts.alt.img">
  <bean:message key="treeedit.jsp.toolbar"/>
</rhn:toolbar>


	  <rhn:dialogmenu mindepth="0" maxdepth="1"
	    definition="/WEB-INF/nav/kickstart_tree_details.xml"
	    renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />




<h2><bean:message key="treeedit.jsp.header2"/></h2>
<bean:message key="treecreate.jsp.header1"/>


<div>
    <html:form method="post" action="/kickstart/TreeEdit.do" styleId="dist-tree-form">
      <%@ include file="tree-form.jspf" %>
      <hr/><table align="right">
           <c:if test="${requestScope.hidesubmit != 'true'}">
            <tr>
               <td><html:submit><bean:message key="edittree.jsp.submit"/></html:submit></td>
            </tr>
          </c:if>
		 </table>
      <html:hidden property="submitted" value="true"/>
      <html:hidden property="kstid" value="${kstid}"/>
    </html:form>
</div>
</body>
</html:html>

