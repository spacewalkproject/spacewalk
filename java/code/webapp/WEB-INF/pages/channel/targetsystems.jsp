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
          <bean:message key="channeltarget.jsp.header1"/>
    </h2>


 <bean:message key="channeltarget.jsp.header2"/>
<rl:listset name="systemset">

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
			           styleclass="last-column center"
			           headerclass="thin-column">       		           
	                      <c:out value="${current.entitlementLevel}" escapeXml="false"/>
			</rl:column>	                
	                
	
		</rl:list>
		<rhn:submitted/>
		
		  	<p align="right">
				<input type="submit" name="dispatch"  value="<bean:message key="confirm"/>" </input>
			</p>


</rl:listset>

</body>
</html>