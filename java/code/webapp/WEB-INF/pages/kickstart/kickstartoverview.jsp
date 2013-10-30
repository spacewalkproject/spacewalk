<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>


<html>
<body>
<rhn:toolbar base="h1" icon="fa-rocket"
               creationUrl="/rhn/kickstart/CreateProfileWizard.do"
               creationType="kickstart"
               imgAlt="kickstarts.alt.img"
               uploadUrl="/rhn/kickstart/AdvancedModeCreate.do"
               uploadType="kickstart"
               uploadAcl="org_entitlement(rhn_provisioning); user_role(config_admin)">
   <bean:message key="kickstart.jsp.overview"/>
</rhn:toolbar>

<rl:listset name="ksSet">
<rhn:csrf />
<rhn:submitted />
<div class="half-table half-table-left">
<%@ include file="/WEB-INF/pages/common/fragments/kickstart/kickstart-overview-summary.jspf" %>
</div>
<div class="half-table half-table-right">
<%@ include file="/WEB-INF/pages/common/fragments/kickstart/kickstart-overview-actions.jspf" %>
</div>
<%@ include file="/WEB-INF/pages/common/fragments/kickstart/currently-kickstarted-systems.jspf" %>
<br><br>
<%@ include file="/WEB-INF/pages/common/fragments/kickstart/systems-tobe-kickstarted.jspf" %>

</rl:listset>
</body>
</html>
