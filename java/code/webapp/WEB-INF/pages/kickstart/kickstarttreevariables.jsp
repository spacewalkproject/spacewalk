<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>

<html:html xhtml="true">
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

<c:import url="/WEB-INF/pages/common/fragments/kickstart/cobbler-variables.jspf">
	<c:param name = "summary" value = "kickstarttree.variable.jsp.summary"/>
	<c:param name = "post_url" value="/kickstart/tree/EditVariables.do"/>
	<c:param name = "name" value="kstid"/>
	<c:param name = "value" value="${param.kstid}"/>
</c:import>
</body>
</html:html>

