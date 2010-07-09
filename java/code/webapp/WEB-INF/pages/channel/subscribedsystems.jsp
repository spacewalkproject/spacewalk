<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>

<html:xhtml/>
<html>
<head>
    <meta name="page-decorator" content="none" />
</head>
<body>


 <%@ include file="/WEB-INF/pages/common/fragments/channel/channel_header.jspf" %>
<BR>
  <h2>
      <img src="/img/rhn-icon-system.gif" alt="system" />
          <bean:message key="channelsystems.jsp.header2"/>
    </h2>



<rl:listset name="systemSet" legend="system-group">

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
								disabled="${not current.selectable}"
								styleclass="first-column"/>



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
                                   styleclass="last-column"
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