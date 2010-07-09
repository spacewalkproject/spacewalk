<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>

<html:xhtml/>
<html>
<head>
    <meta name="name" value="sdc.config.jsp.header" />
</head>
<body>
<%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>

<table>
<tr valign="top">
	<td>
		<h2><bean:message key="sdc.config.header.overview"/></h2>

		<table class="details">
		  <tr>
		    <th><bean:message key="sdc.config.centrally-managed"/>:</th>
		    <td>
				<b> <bean:message key="sdc.config.files.total"/>:</b> <br/>
				${requestScope.centralFiles}
					 <br/><br/>
				<b><bean:message key="sdc.config.files.deployable"/>:</b><br/>
					${requestScope.deployableFiles}
		    </td>
		  </tr>
		  <tr>
		    <th><bean:message key="sdc.config.locally-managed"/>:</th>
		    <td>
				<b> <bean:message key="sdc.config.files.total"/>:</b> <br/>
					${requestScope.localFiles}
				 <br/>
		    </td>
		  </tr>
		  <tr>
		    <th><bean:message key="sdc.config.sandbox.files" />:</th>
			    <td>${requestScope.sandboxFiles}</td>
		  </tr>
		  <tr>
		    <th><bean:message key="sdc.config.central-channel.subscriptions"/>:</th>
		    <td>${requestScope.globalConfigChannels}.&nbsp;[<a href="/rhn/systems/details/configuration/SubscriptionsSetup.do?sid=${param.sid}"><bean:message key="sdc.config.subscribe_to_channels"/></a>]</td>
		  </tr>
		</table>
		<!-- Adding recent events -->
		<h2><bean:message key="sdc.config.header.recent-events"/></h2>
		
		<table class="details">
		  <tr>
		    <th><bean:message key="sdc.config.last-config.deployment"/>:</th>
		
		    <td><c:if test="${requestScope.deploymentTimeMessage}">
			    ${requestScope.deploymentTimeMessage}
		        <br /><br />
		    </c:if>
		        ${requestScope.deploymentDetailsMessage}
		    </td>
		  </tr>
		  <tr>
		    <th><bean:message key="sdc.config.last-rhn.comparison"/>:</th>
		    <td>${requestScope.diffTimeMessage}
		
		        ${requestScope.diffActionMessage}
		
		        <c:if test="${not empty requestScope.diffActionMessage}">
			        ${requestScope.diffDetailsMessage}
		        </c:if>
		    </td>
		
		  </tr>
		</table>		
		
	</td>
	<td style="width: 45%">
	    <h2><bean:message key="sdc.config.header.actions"/></h2>
	    <c:choose>
	    <c:when test="${requestScope.configEnabled}">
		<rhn:require mixins="com.redhat.rhn.common.security.acl.SystemAclHandler"
									 acl="client_capable(configfiles.deploy)">
			<table cellspacing="0" cellpadding="0" align="center" class="half-table">
			    <thead>
				    <tr class="list-row-odd">
				      <th><bean:message key="sdc.config.deploy.files"/></th>
				    </tr>
			    </thead>


			    <tr class="list-row-odd">
			      <td class="first-column"><img src="/img/rhn-bullet.gif"/>&nbsp;<bean:message key="sdc.config.deploy.managed-files"
                           arg0 ="/rhn/systems/details/configuration/DeployFileConfirm.do?selectall=true&sid=${param.sid}" />
                  </td>

				  <td class="last-column"></td>
			    </tr>
			    <tr class="list-row-odd">
			      <td class="first-column"><img src="/img/rhn-bullet.gif"/>&nbsp;<bean:message key="sdc.config.deploy.selected-files"
							       arg0="/rhn/systems/details/configuration/DeployFile.do?sid=${param.sid}"/></td>
				  <td class="last-column"></td>
			    </tr>
			</table>
			<br />
	   </rhn:require>
		<rhn:require mixins="com.redhat.rhn.common.security.acl.SystemAclHandler"
													 acl="client_capable(configfiles.diff)">	   			
			<table cellspacing="0" cellpadding="0" align="center" class="half-table">
			    <thead>
			    <tr class="list-row-odd">
			      <th><bean:message key="sdc.config.compare.files"/></th>
			    </tr>
			    </thead>
			    <tr class="list-row-odd">
			      <td class="first-column"><img src="/img/rhn-bullet.gif"/>&nbsp;<bean:message key="sdc.config.compare.managed-files"
			      		arg0="/rhn/systems/details/configuration/DiffFileConfirm.do?selectall=true&sid=${param.sid}"/></td>
				  <td class="last-column"></td>
			    </tr>
			    <tr class="list-row-odd">
			      <td class="first-column"><img src="/img/rhn-bullet.gif"/>&nbsp;<bean:message key="sdc.config.compare.selected-files"
			      			 arg0="/rhn/systems/details/configuration/DiffFile.do?sid=${param.sid}"/></td>
				  <td class="last-column"></td>
			    </tr>
			</table>
			<br />
		</rhn:require>	
			<table cellspacing="0" cellpadding="0" align="center" class="half-table">
			    <thead>
				    <tr class="list-row-odd">
				      <th><bean:message key="sdc.config.add-create.files"/></th>
				    </tr>
			    </thead>
			    <tr class="list-row-odd">
			      <td class="first-column"><img src="/img/rhn-bullet.gif"/>&nbsp;<bean:message key="sdc.config.add-create.new-files"
					      arg0 = "/rhn/systems/details/configuration/addfiles/CreateFile.do?sid=${param.sid}"/></td>
				  <td class="last-column"></td>
			    </tr>
			    <tr class="list-row-odd">
			      <td class="first-column"><img src="/img/rhn-bullet.gif"/>&nbsp;<bean:message key="sdc.config.add-create.upload-files"
      					arg0 = "/rhn/systems/details/configuration//addfiles/UploadFile.do?sid=${param.sid}"/></td>
			      <td class="last-column"></td>
			    </tr>
				<rhn:require mixins="com.redhat.rhn.common.security.acl.SystemAclHandler"
													 acl="client_capable(configfiles.upload)">
			    <tr class="list-row-odd">
			      <td class="first-column"><img src="/img/rhn-bullet.gif"/>&nbsp;<bean:message key="sdc.config.add-create.import-all-files"
					      arg0 = "/rhn/systems/details/configuration/addfiles/ImportFileConfirm.do?selectall=true&sid=${param.sid}"/></td>
			      <td class="last-column"></td>
			    </tr>

			    <tr class="list-row-odd">
			      <td class="first-column"><img src="/img/rhn-bullet.gif"/>&nbsp;<bean:message key="sdc.config.add-create.import-selected-files"
			 	      	arg0="/rhn/systems/details/configuration/addfiles/ImportFile.do?sid=${param.sid}"/></td>
				  <td class="last-column"></td>
			    </tr>
			    </rhn:require>
			</table>
	      </c:when>
	      <c:otherwise>
	            <p><bean:message key="system.sdc.missing.config_deploy1"/></p>
	            <p><bean:message key="system.sdc.missing.config_deploy2"
	            		arg0="/rhn/configuration/system/TargetSystems.do"
	            		arg1="${rhn:localize('targetsystems.jsp.toolbar')}"
	            		arg2="${rhn:localize('targetsystems.jsp.enable')}"/></p>	            		
			</c:otherwise>
		</c:choose>
	 </td>
</tr>
</table>
</body>
</html>
