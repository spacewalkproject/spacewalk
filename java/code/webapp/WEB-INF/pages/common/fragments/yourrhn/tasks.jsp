<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<form method="post" name="rhn_list" action="/YourRhn.do">
<table cellspacing="0"  cellpadding="0" class="half-table">

<thead>
<tr>
  <th style="text-align: left;"><bean:message key="yourrhn.jsp.task.title" /></th></tr>
</thead>

<rhn:require acl="not user_role(satellite_admin)">
<rhn:require acl="user_role(org_admin)">
<tr class="list-row-odd">
<td style="text-align: left;" class="first-column last-column"><img style="margin-left: 4px;" src="/img/parent_node.gif"
									alt="<bean:message key="yourrhn.jsp.bullet.alttag"/>" /> <a href="/rhn/systems/SystemEntitlements.do">
    	<bean:message key="yourrhn.jsp.tasks.subscriptions" />
    </a></td></tr>
</rhn:require>
</rhn:require>

<rhn:require acl="user_role(satellite_admin)">
<rhn:require acl="user_role(org_admin)">
<tr class="list-row-odd">
<td style="text-align: left;" class="first-column last-column"><img style="margin-left: 4px;" src="/img/parent_node.gif"
									alt="<bean:message key="yourrhn.jsp.bullet.alttag"/>" /> <bean:message key="yourrhn.jsp.task.manage_subscriptions" />
    <br> &ensp; &ensp;<a href="/rhn/systems/SystemEntitlements.do">
    	<bean:message key="header.jsp.my_organization" /></a> <strong>|</strong> <a href="/rhn/admin/multiorg/SoftwareEntitlements.do"><bean:message key="header.jsp.satellite_wide" />
    </a></td></tr>
</rhn:require>
</rhn:require>

<rhn:require acl="user_role(satellite_admin)">
<rhn:require acl="not user_role(org_admin)">
<tr class="list-row-odd">
<td style="text-align: left;" class="first-column last-column"><img style="margin-left: 4px;" src="/img/parent_node.gif"
									alt="<bean:message key="yourrhn.jsp.bullet.alttag"/>" /> <a href="/rhn/admin/multiorg/SoftwareEntitlements.do">
    	<bean:message key="yourrhn.jsp.tasks.subscriptions" />
    </a></td></tr>
</rhn:require>
</rhn:require>

<tr class="list-row-odd">
<td style="text-align: left;" class="first-column last-column"><img style="margin-left: 4px;" src="/img/parent_node.gif"
									alt="<bean:message key="yourrhn.jsp.bullet.alttag"/>" /> <a href="/rhn/help/client-config/en-US/index.jsp">
    	<bean:message key="yourrhn.jsp.tasks.registersystem" />
    </a></td></tr>


<rhn:require acl="org_entitlement(sw_mgr_enterprise); user_role(activation_key_admin)">
<tr class="list-row-odd">
<td style="text-align: left;" class="first-column last-column"><img style="margin-left: 4px;" src="/img/parent_node.gif"
				alt="<bean:message key="yourrhn.jsp.bullet.alttag"/>" /> <a href="/rhn/activationkeys/List.do">
    	<bean:message key="yourrhn.jsp.tasks.activationkeys" />
    </a></td></tr>

</rhn:require>

<rhn:require acl="org_entitlement(rhn_provisioning); user_role(config_admin)">
<tr class="list-row-odd">
<td style="text-align: left;" class="first-column last-column"><img style="margin-left: 4px;" src="/img/parent_node.gif"
									alt="<bean:message key="yourrhn.jsp.bullet.alttag"/>" /> <a href="/rhn/kickstart/KickstartOverview.do">
    	<bean:message key="yourrhn.jsp.tasks.kickstart" />
    </a></td></tr>

<tr class="list-row-odd">
<td style="text-align: left;" class="first-column last-column"><img style="margin-left: 4px;" src="/img/parent_node.gif"
									alt="<bean:message key="yourrhn.jsp.bullet.alttag"/>" /> <a href="/rhn/configuration/file/GlobalConfigFileList.do">
    	<bean:message key="yourrhn.jsp.tasks.configuration" />
    </a></td></tr>

<rhn:require	acl="show_monitoring();"
				mixins="com.redhat.rhn.common.security.acl.MonitoringAclHandler">
<tr class="list-row-odd">
<td style="text-align: left;" class="first-column last-column"><img style="margin-left: 4px;" src="/img/parent_node.gif"
									alt="<bean:message key="yourrhn.jsp.bullet.alttag"/>" /> <a href="/rhn/monitoring/ProbeList.do">
    	<bean:message key="yourrhn.jsp.tasks.monitoring" />
    </a></td></tr>
</rhn:require>

<rhn:require acl="user_role(satellite_admin)">
<tr class="list-row-odd">
<td style="text-align: left;" class="first-column last-column"><img style="margin-left: 4px;" src="/img/parent_node.gif"
									alt="<bean:message key="yourrhn.jsp.bullet.alttag"/>" /> <a href="/rhn/admin/multiorg/Organizations.do">
    	<bean:message key="yourrhn.jsp.tasks.manage_sat_orgs" />
    </a></td></tr>
</rhn:require>

</rhn:require>

<rhn:require acl="user_role(satellite_admin)">
<tr class="list-row-odd">
<td style="text-align: left;" class="first-column last-column"><img style="margin-left: 4px;" src="/img/parent_node.gif"
									alt="<bean:message key="yourrhn.jsp.bullet.alttag"/>" /> <a href="/rhn/admin/config/GeneralConfig.do">
    	<bean:message key="yourrhn.jsp.tasks.config_sat" />
    </a></td></tr>
</rhn:require>

</table>
</form>
