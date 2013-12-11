<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>


<html>
<body>
<rhn:toolbar base="h1" icon="header-system" imgAlt="system.common.systemAlt"
 helpUrl="/rhn/help/reference/en-US/s1-sm-systems.jsp#s3-sm-system-list-ood">
  <bean:message key="duplicates.jsp.header"/>
</rhn:toolbar>

<h2>
  <bean:message key="ssm.delete.systems.header" />
</h2>
<p><bean:message key="ssm.delete.systems.summary" /></p>

<rl:listset name="DupesListSet" legend="system">

<rhn:csrf />

<rl:list emptykey="nosystems.message">

    <rl:decorator name="ElaborationDecorator"/>
    <rl:decorator name="PageSizeDecorator"/>

	<!-- Name Column -->
	<rl:column sortable="true"
        bound="false"
		headerkey="systemlist.jsp.system"
		sortattr="name"
		defaultsort="asc">
            <a href="/rhn/systems/details/Overview.do?sid=${current.id}">
                <c:out value="${current.name}" escapeXml="true" />
            </a>
	</rl:column>
	<rl:column sortable="false"
		attr="lastCheckin"
		bound="true"
		headerkey="systemlist.jsp.last_checked_in"
 />
</rl:list>

  <div class="text-right">

    <hr />
    <html:submit property="dispatch">
        <bean:message key="ssm.delete.systems.confirmbutton"/>
    </html:submit>

  </div>
<rhn:submitted/>

</rl:listset>


</body>
</html>
