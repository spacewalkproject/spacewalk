<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<html:xhtml/>
<html>
<head>
    <meta name="page-decorator" content="none"/>
</head>
<body>
<rhn:toolbar base="h1" img="/img/rhn-icon-system.gif" imgAlt="overview.jsp.alt">
  <bean:message key="systementitlements.jsp.header"/>
</rhn:toolbar>

<p><bean:message key="systementitlements.jsp.para1" /></p>
<p><bean:message key="systementitlements.jsp.para2" /></p>


<html:form action="/systems/SystemEntitlementsSubmit">

    <rhn:list pageList="${requestScope.pageList}"
    		  noDataText="systementitlements.jsp.nodata"
              legend="system">

      <rhn:listdisplay  set="${requestScope.set}"
	 filterBy="systemlist.jsp.system"
      	 domainClass="systems"
      	 >
        <rhn:set value="${current.id}"/>
	    <rhn:column header="systemlist.jsp.status"
	                style="text-align: center;">
	        ${current.statusDisplay}
	    </rhn:column>
	    <rhn:column header="systemlist.jsp.system"
	                url="/rhn/systems/details/Overview.do?sid=${current.id}">
	        ${fn:escapeXml(current.serverName)}
	    </rhn:column>

	    <rhn:column header="systementitlements.jsp.baseentitlement">
	        ${current.baseEntitlementLevel}
	    </rhn:column>

	    <rhn:column header="systementitlements.jsp.addonentitlement">
	        ${current.addOnEntitlementLevel}
	    </rhn:column>

	    <rhn:column header="systemlist.jsp.channel">		
	    <c:choose>
    		<c:when test="${current.channelId == null}">
        		<bean:message key="none.message"/>
        	</c:when>
        	<c:otherwise>
        		<a href="/rhn/channels/ChannelDetail.do?cid=${current.channelId}">
        			${fn:escapeXml(current.channelLabels)}
        		</a>
        	</c:otherwise>
        </c:choose>
	    </rhn:column>
      </rhn:listdisplay>
    </rhn:list>

<!--  Entitlements Section -->
    <c:if test="${requestScope.showCommands}">
		  <table class="entitle-bar">
			<!--  Base Entitlement Section -->
			<tr>
		          <th><bean:message key="systementitlements.jsp.baseentitlement" /></th>
		    	  <td align="right">
				          <c:if test="${requestScope.showUpdateAspects}">
						        <html:submit property="dispatch">
						          <bean:message key="systementitlements.jsp.set_to_update_entitled" />
						        </html:submit>
						  </c:if>
				          <c:if test="${requestScope.showManagementAspects}">
					        	<html:submit property="dispatch">
				    	      		<bean:message key="systementitlements.jsp.set_to_manage_entitled" />
				        		</html:submit>
						  </c:if>
	
				          <c:if test="${requestScope.showUnentitled}">
						        <html:submit property="dispatch">
	  					            <bean:message key="systementitlements.jsp.set_to_unentitled" />
						        </html:submit>
						  </c:if>			
				  </td>
			</tr>
			<!--  Add On Entitlement Section -->
		      <c:if test="${requestScope.showAddOnAspects}">
			    	<tr>
			              <th><bean:message key="systementitlements.jsp.addonentitlement" /></th>
			        	  <td align="right">
				              <html:select property="addOnEntitlement">
				                  <html:optionsCollection name="addOnEntitlements"/>
				              </html:select>
					        <html:submit property="dispatch">
					          <bean:message key="systementitlements.jsp.add_entitlement" />
					        </html:submit>
					        <html:submit property="dispatch">
					          <bean:message key="systementitlements.jsp.remove_entitlement" />
					        </html:submit>
						  </td>
			    	</tr>
			  </c:if>
		  </table>
     </c:if>

<!--  Entitlement Counts Section -->
       <h2><bean:message key="systementitlements.jsp.entitlement_counts" /></h2>

<!--  Base Entitlement Counts Section -->
       <h3><bean:message key="systementitlements.jsp.base_entitlements"/></h3>
       <table class="details">
	    	<tr>
	              <th><bean:message key="Spacewalk Update Entitled Servers"/>:</th>
	        	  <td>${requestScope.updateCountsMessage}</td>
	    	</tr>

	    	<tr>
                  <th><bean:message key="Spacewalk Management Entitled Servers"/>:</th>
            	  <td>${requestScope.managementCountsMessage}</td>
	    	</tr>
       </table>


<!--  Add - On Entitlement Counts Section -->
       <h3><bean:message key="systementitlements.jsp.addonentitlement"/></h3>
       <table class="details">
	    	<tr>
	              <th><bean:message key="provisioning_entitled"/>:</th>
	        	  <td>${requestScope.provisioningCountsMessage}</td>
	    	</tr>
		   <c:if test="${requestScope.showMonitoring}">
		    	<tr>
		              <th><bean:message key="monitoring_entitled"/>:</th>
		        	  <td>${requestScope.monitoringCountsMessage}</td>
		    	</tr>
	    	</c:if>
	    	<tr>
	    		<th><bean:message key="virtualization_host"/>:</th>
	       		<td>${requestScope.virtualizationCountsMessage}</td>
	    	</tr>
	    	<tr>
	    		<th><bean:message key="virtualization_host_platform"/>:</th>
	       		<td>${requestScope.virtualizationPlatformCountsMessage}</td>
	    	</tr>
       </table>
<!--  Foot Note -->

</html:form>
</body>
</html>
