<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn"%>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean"
	prefix="bean"%>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html"
	prefix="html"%>

<html:xhtml/>
<html>
<body>
<rhn:toolbar base="h1" img="/img/rhn-config_management.gif"
	creationUrl="ProbeSuiteProbeCreate.do?suite_id=${probeSuite.id}"
	creationType="probe"
	helpUrl="/rhn/help/reference/en-US/s1-sm-monitor.jsp#s2-sm-monitor-psuites">
	<bean:message key="probes.jsp.header1" arg0="${probeSuite.suiteName}" />
</rhn:toolbar>

<rhn:dialogmenu mindepth="0" maxdepth="1"
	definition="/WEB-INF/nav/probesuite_detail_edit.xml"
	renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />

<h2><bean:message key="probes.jsp.header2" /></h2>

<div>
<form method="POST" name="rhn_list"
	action="/rhn/monitoring/config/ProbeSuiteListProbesSubmit.do"><rhn:list
	pageList="${requestScope.pageList}" noDataText="probes.jsp.noprobes">
	<rhn:listdisplay   set="${requestScope.set}"
		hiddenvars="${requestScope.newset}" button="probes.jsp.deleteprobe">
		<rhn:set value="${current.id}" />
		<rhn:column header="probes.jsp.probe_description">
			<A
				HREF="ProbeSuiteProbeEdit.do?suite_id=${probeSuite.id}&probe_id=${current.id}">${current.description}</A>
		</rhn:column>
		<rhn:column header="probes.jsp.command_description">
            ${current.cmd_description}
        </rhn:column>
	</rhn:listdisplay>
</rhn:list> <html:hidden property="suite_id" value="${probeSuite.id}" />
</form>


</p>
</div>


</body>
</html>

