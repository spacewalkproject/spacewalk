<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>


<html:html xhtml="true">
<body>

<html:errors />
<html:messages id="message" message="true">
  <rhn:messages><c:out escapeXml="false" value="${message}" /></rhn:messages>
</html:messages>

<rhn:toolbar base="h1" img="/img/rhn-kickstart_profile.gif"
               creationUrl="/rhn/kickstart/CreateProfileWizard.do"
               creationType="kickstart"
               imgAlt="kickstarts.alt.img"
               uploadUrl="/rhn/kickstart/AdvancedModeCreate.do"
               uploadType="kickstart"
               uploadAcl="org_entitlement(rhn_provisioning); user_role(config_admin)"
               >
  <bean:message key="kickstarts.jsp.toolbar"/>
</rhn:toolbar>
 
<div>
    <bean:message key="kickstart.jsp.summary"/>
      <rl:listset name="ksSet">
      	<rl:list dataset="pageList" name="ksList" emptykey="kickstart.jsp.nokickstarts" 
      			alphabarcolumn="label"
                filter="com.redhat.rhn.frontend.action.kickstart.KickstartProfileFilter">      			
                     
        	<rl:decorator name="ElaborationDecorator"/>
      		<rl:decorator name="PageSizeDecorator"/>
            		

          	<rl:column sortable="true" 
          		bound="false" 
          		headerkey="kickstart.jsp.label" 
          		sortattr="label" 
          		defaultsort="asc"
          		styleclass="first-column">
          			<c:choose>
          				<c:when test="${current.advancedMode}">
          					<a href="/rhn/kickstart/AdvancedModeEdit.do?ksid=${current.id}"><c:out value="${current.name}" escapeXml="true" /></a>
          				</c:when>
          				<c:otherwise>
          					<a href="/rhn/kickstart/KickstartDetailsEdit.do?ksid=${current.id}"><c:out value="${current.name}" escapeXml="true" /></a>
          				</c:otherwise>
          			</c:choose>
					 
					<c:if test="${current.isOrgDefault == 'Y'}">
		            *
		          </c:if>
      		</rl:column>  	      
      		
          	<rl:column sortable="true" bound="false" headerkey="kickstart.jsp.bootimage" sortattr="bootImage" >
					${current.bootImage}
      		</rl:column>  	      	      		
      		
      		
      		<rl:column sortable="true" bound="false" headerkey="kickstart.jsp.active"  sortattr="active" styleclass="last-column">
	      		<c:if test="${current.active}">
	            <img src="/img/rhn-listicon-ok.gif" alt="<bean:message key="kickstart.jsp.active"/>" 
	            									title="<bean:message key="kickstart.jsp.active"/>"/>
	          </c:if>
	         <c:if test="${not current.active}">
	            <img src="/img/rhn-listicon-error.gif" alt="<bean:message key="kickstart.jsp.inactive"/>" 
	            									   title="<bean:message key="kickstart.jsp.inactive"/>"/>
	          </c:if>          
      		</rl:column>      		
      		
       </rl:list>
      </rl:listset>
</div>
  <bean:message key="kickstart.list.jsp.orgdefault"/>
</body>
</html:html>

