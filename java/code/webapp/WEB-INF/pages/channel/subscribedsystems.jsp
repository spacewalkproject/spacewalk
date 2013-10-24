<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>

<html:xhtml/>
<html>
<head>
    <meta name="page-decorator" content="none" />
</head>
<body>

 <%@ include file="/WEB-INF/pages/common/fragments/channel/channel_header.jspf" %>
  <h2>
      <i class="icon-desktop"></i>
      <bean:message key="channelsystems.jsp.header2"/>
  </h2>

<rl:listset name="systemSet" legend="system-group">
<rhn:csrf />

<input type="hidden" name="cid" value="${cid}" />

	<rl:list dataset="pageList"
			name="systemList"
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


                 <rl:column sortable="false"
                                   bound="false"
                           headerkey="systemlist.jsp.entitlement"
                          >
                        <c:out value="${current.entitlementLevel}" />
                </rl:column>


	</rl:list>
	<rl:csv dataset="pageList"
		        name="systemList"
		        exportColumns="id, name,entitlementLevel" />

		<rhn:submitted/>


</rl:listset>

</body>
</html>
