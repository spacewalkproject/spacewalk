<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>

<html>
<body>
<c:choose>
<c:when test="${param.oid != 1}">
<rhn:toolbar base="h1" img="/img/rhn-icon-org.gif"
    miscUrl="${url}"
    miscAcl="user_role(org_admin)"
    miscText="${text}"
    miscImg="${img}"
    miscAlt="${text}"
    deletionUrl="/rhn/admin/multiorg/DeleteOrg.do?oid=${param.oid}"
    deletionAcl="user_role(satellite_admin)"
    deletionType="org"
    imgAlt="users.jsp.imgAlt">
    <c:out escapeXml="true" value="${org.name}" />
</rhn:toolbar>
</c:when>
<c:otherwise>
<rhn:toolbar base="h1" img="/img/rhn-icon-org.gif"
    miscUrl="${url}"
    miscAcl="user_role(org_admin)"
    miscText="${text}"
    miscImg="${img}"
    miscAlt="${text}"
    imgAlt="users.jsp.imgAlt">
    <c:out escapeXml="true" value="${org.name}" />
</rhn:toolbar>
</c:otherwise>
</c:choose>
<rhn:dialogmenu mindepth="0" maxdepth="3" definition="/WEB-INF/nav/org_tabs.xml" renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />

<h2><bean:message key="orgsoftwaresubs.jsp.header2"/></h2>

<bean:message key="orgsoftwaresubs.jsp.description" arg0="${org.name}"/>


<div>
<rl:listset name="entitlementSet">
	<rhn:submitted/>
	<input type="hidden" name="oid" value="${param.oid}"/>
	 <!-- Hack to get around the problem with form submitting when doing 
 	pagination. See javascript attached to the submit button below. -->
	
	<input type="hidden" name="updateOrganizations" value="0"/>
	
    <rl:list dataset="pageList"
         width="100%"
         name="userList"         
         styleclass="list"
         emptykey="orgsoftwaresubs.jsp.nochannelfams">
         
        <rl:column bound="false" 
               sortable="false" 
               headerkey="entitlements.jsp.channel" styleclass="first-column">
            <a href="/rhn/admin/multiorg/SoftwareEntitlementDetails.do?cfid=${current.id}"><c:out value="${current.name}" /></a>
        </rl:column>
        <rl:column bound="false" 
               sortable="false" 
               headerkey="orgsystemsubs.jsp.total">
            <c:out value="${current.maxMembers}" />
        </rl:column>        
        <rl:column bound="false" 
               sortable="false" 
               headerkey="orgsystemsubs.jsp.usage">            
            <c:out value="${current.currentMembers}" />            
        </rl:column>
        <rl:column bound="false" 
               sortable="false" 
               headerkey="orgsystemsubs.jsp.proposed_total" styleclass="last-column">
            <c:choose>
                  <c:when test="${param.oid != 1}">                               
                    <input name="${current.id}" value="${current.maxMembers}" type="text" 
                    onkeydown="return blockEnter(event)">
                    <br>
                    <span class="small-text"><bean:message key="orgsystemsubs.jsp.possible_vals" 
                      arg0="0" arg1="${current.satelliteMaxMembers - current.satelliteCurrentMembers + current.maxMembers}"/></span>
                  </c:when>
                  <c:otherwise>
                    ${current.maxMembers}
                  </c:otherwise>
            </c:choose>                 
        </rl:column>
        
    </rl:list>      
<c:if test="${param.oid != 1}"> 
 <div align="right">
   <hr/>
   <input type="submit" name="dispatch" value="${rhn:localize('orgdetails.jsp.submit')}"
   							 onclick="this.form.updateOrganizations.value = '1';return true;">
 </div>
</c:if> 
</rl:listset>
</div>


</body>
</html>

