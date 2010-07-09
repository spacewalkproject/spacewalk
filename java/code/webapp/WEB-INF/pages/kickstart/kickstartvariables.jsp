<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>

<html:html xhtml="true">
<body>
<rhn:require acl="is_ks_raw(${ksid})" mixins="com.redhat.rhn.common.security.acl.KickstartAclHandler">
	<%@ include file="/WEB-INF/pages/common/fragments/kickstart/advanced/header.jspf"%>
 </rhn:require>



  <rhn:require acl="is_ks_not_raw(${ksid})" mixins="com.redhat.rhn.common.security.acl.KickstartAclHandler">
<%@ include file="/WEB-INF/pages/common/fragments/kickstart/kickstart-toolbar.jspf" %>

	  <rhn:dialogmenu mindepth="0" maxdepth="1"
	    definition="/WEB-INF/nav/kickstart_details.xml"
	    renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />
	
  </rhn:require>
<c:import url="/WEB-INF/pages/common/fragments/kickstart/cobbler-variables.jspf">
	<c:param name = "post_url" value="/kickstart/EditVariables.do"/>
	<c:param name = "name" value="ksid"/>
	<c:param name = "value" value="${param.ksid}"/>
</c:import>
</body>
</html:html>

