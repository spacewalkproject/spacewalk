<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<html:xhtml/>
<html>
<head>
    <meta name="page-decorator" content="none"/>
</head>
<body>
<rhn:toolbar base="h1" icon="fa-desktop" imgAlt="overview.jsp.alt">
  <bean:message key="systementitlements.jsp.header"/>
</rhn:toolbar>

<p><bean:message key="systementitlements.jsp.para1" /></p>
<p><bean:message key="systementitlements.jsp.para2" /></p>


<html:form action="/systems/SystemEntitlementsSubmit">
    <rhn:csrf />
    <rhn:submitted />

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
    	<hr/>		
    	<div class="panel panel-default">
		  <table class="table">
			<!--  Base Entitlement Section -->
			<tr>
		          <th><bean:message key="systementitlements.jsp.baseentitlement" /></th>
		    	  <td class="text-right">
				          <c:if test="${requestScope.showUpdateAspects}">
						        <html:submit styleClass="btn btn-default" property="dispatch">
						          <bean:message key="systementitlements.jsp.set_to_update_entitled" />
						        </html:submit>
						  </c:if>
				          <c:if test="${requestScope.showManagementAspects}">
					        	<html:submit styleClass="btn btn-default" property="dispatch">
				    	      		<bean:message key="systementitlements.jsp.set_to_manage_entitled" />
				        		</html:submit>
						  </c:if>
	
				          <c:if test="${requestScope.showUnentitled}">
						        <html:submit styleClass="btn btn-default" property="dispatch">
	  					            <bean:message key="systementitlements.jsp.set_to_unentitled" />
						        </html:submit>
						  </c:if>			
				  </td>
			</tr>
			<!--  Add On Entitlement Section -->
		      <c:if test="${requestScope.showAddOnAspects}">
			    	<tr>
			              <th><bean:message key="systementitlements.jsp.addonentitlement" /></th>
			        	  <td class="text-right">
				              <html:select property="addOnEntitlement">
				                  <html:optionsCollection name="addOnEntitlements"/>
				              </html:select>
					        <html:submit styleClass="btn btn-default" property="dispatch">
					          <bean:message key="systementitlements.jsp.add_entitlement" />
					        </html:submit>
					        <html:submit styleClass="btn btn-default" property="dispatch">
					          <bean:message key="systementitlements.jsp.remove_entitlement" />
					        </html:submit>
						  </td>
			    	</tr>
			  </c:if>
		  </table>
		</div>
     </c:if>

<!--  Entitlement Counts Section -->
       <h2><bean:message key="systementitlements.jsp.entitlement_counts" /></h2>

<!--  Base Entitlement Counts Section -->
	<div class="panel panel-default">
		<div class="panel-heading">
			<h5><bean:message key="systementitlements.jsp.base_entitlements"/></h5>
		</div>
		<table class="table">
	    	<tr>
	            <td><bean:message key="Spacewalk Update Entitled Servers"/>:</td>
	        	<td>${requestScope.updateCountsMessage}</td>
	    	</tr>
	    	<tr>
                <td><bean:message key="Spacewalk Management Entitled Servers"/>:</td>
            	<td>${requestScope.managementCountsMessage}</td>
	    	</tr>
       </table>
	</div>

<!--  Add - On Entitlement Counts Section -->
	<div class="panel panel-default">
		<div class="panel-heading">
			<h5><bean:message key="systementitlements.jsp.addonentitlement"/></h5>
		</div>
       <table class="table">
	    	<tr>
	              <td><bean:message key="provisioning_entitled"/>:</td>
	        	  <td>${requestScope.provisioningCountsMessage}</td>
	    	</tr>
		   <c:if test="${requestScope.showMonitoring}">
		    	<tr>
		              <td><bean:message key="monitoring_entitled"/>:</td>
		        	  <td>${requestScope.monitoringCountsMessage}</td>
		    	</tr>
	    	</c:if>
	    	<tr>
	    		<td><bean:message key="virtualization_host"/>:</td>
	       		<td>${requestScope.virtualizationCountsMessage}</td>
	    	</tr>
	    	<tr>
	    		<td><bean:message key="virtualization_host_platform"/>:</td>
	       		<td>${requestScope.virtualizationPlatformCountsMessage}</td>
	    	</tr>
       </table>
	</div>

<!--  Foot Note -->

</html:form>
</body>
</html>
