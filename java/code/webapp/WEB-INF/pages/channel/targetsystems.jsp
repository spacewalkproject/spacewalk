<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>


<html>
<head>
    <meta name="page-decorator" content="none" />
</head>
<body>


 <%@ include file="/WEB-INF/pages/common/fragments/channel/channel_header.jspf" %>
<BR>
  <h2>
      <rhn:icon type="header-system-physical" title="system" />
          <bean:message key="channeltarget.jsp.header1"/>
    </h2>


 <bean:message key="channeltarget.jsp.header2"/>
<rl:listset name="systemset">
<rhn:csrf />

<input type="hidden" name="cid" value="${cid}" />

	<rl:list
			decorator="SelectableDecorator"
			emptykey="systemlist.jsp.nosystems"
			alphabarcolumn="name"
			filter="com.redhat.rhn.frontend.taglibs.list.filters.SystemOverviewFilter" >

			<rl:decorator name="ElaborationDecorator"/>
			<rl:decorator name="PageSizeDecorator"/>

		    <rl:selectablecolumn value="${current.id}"
								selected="${current.selected}"
								disabled="${not current.selectable}"/>



                 <rl:column sortable="true"
                                   bound="false"
                           headerkey="actions.jsp.system"
                           sortattr="name"
							defaultsort="asc"
                           >
                        <a href="/rhn/systems/details/Overview.do?sid=${current.id}">
                        	<c:out value="${current.name}" />
                        </a>
                </rl:column>

			<!-- Base Channel Column -->
			<rl:column sortable="false"
					   bound="false"
			           headerkey="systemlist.jsp.channel"  >
	           <%@ include file="/WEB-INF/pages/common/fragments/channel/channel_list_fragment.jspf" %>
			</rl:column>

			<!-- Entitlement Column -->
			<rl:column sortable="false"
					   bound="false"
			           headerkey="systemlist.jsp.entitlement"
			           styleclass="center"
			           headerclass="thin-column">
	                      <c:out value="${current.entitlementLevel}" escapeXml="false"/>
			</rl:column>


		</rl:list>
		<rhn:submitted/>

		  	<p align="right">
				<input type="submit" name="dispatch"  value="<bean:message key='confirm'/>" </input>
			</p>


</rl:listset>

</body>
</html>
