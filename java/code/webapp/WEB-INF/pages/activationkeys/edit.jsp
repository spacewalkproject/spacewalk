<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<html:html xhtml="true">
<body>

<html:errors />
<html:messages id="message" message="true">
  <rhn:messages><c:out escapeXml="false" value="${message}" /></rhn:messages>
</html:messages>


<rhn:toolbar base="h1" img="/img/rhn-icon-keyring.gif" 
			imgAlt="activation-keys.common.alt"
			helpUrl="/rhn/help/reference/en/s2-sm-systems-activation-keys.jsp"

			deletionUrl="/rhn/activationkeys/Delete.do?tid=${param.tid}" 
 			deletionType="activationkeys"
 			deletionAcl = "user_role(activation_key_admin)"			
			>
  <c:out value="${activationKeyForm.map.description}"/>
</rhn:toolbar>

<rhn:dialogmenu mindepth="0" maxdepth="1" 
	definition="/WEB-INF/nav/activation_key.xml" 
	renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />

<div class="page-summary">
    <p>
        <bean:message key="activation-key.jsp.summary"/>
    </p>
</div>

<hr/>

<c:import url="/WEB-INF/pages/common/fragments/activationkeys/details.jspf">
	<c:param name = "url" value="/activationkeys/Edit.do?tid=${param.tid}"/>
	<c:param name = "tid" value="${param.tid}"/>
	<c:param name = "submit" value="activation-key.jsp.edit-key"/>
</c:import>
</body>
</html:html>
