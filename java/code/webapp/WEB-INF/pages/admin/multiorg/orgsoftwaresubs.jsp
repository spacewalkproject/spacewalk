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
	
    <rl:list
    	alphabarcolumn="name" 
         styleclass="list"
         emptykey="orgsoftwaresubs.jsp.nochannelfams">
                     <rl:decorator name="PageSizeDecorator"/>
        <rl:column 
               filterattr="name" 
               sortattr = "name"
               headerkey="entitlements.jsp.channel" styleclass="first-column">
            <a href="/rhn/admin/multiorg/SoftwareEntitlementDetails.do?cfid=${current.id}" tabindex="-1"><c:out value="${current.name}" /></a>
        </rl:column>
        <rl:column   styleclass="center"
               headertext="${rhn:localize('Regular Usage')} <br/>(${rhn:localize('Used/Allotted')})*">
            <c:choose>
            	<c:when test="${empty current.maxMembers or current.maxMembers == 0}">
            		<bean:message key="None Allocated"/>
            	</c:when>
            	<c:otherwise>
          			<c:out value="${current.currentMembers} / ${current.maxMembers}" />
            	</c:otherwise>            	
            </c:choose>
        </rl:column>            
        
        <rl:column 
               headerkey="Regular Proposed Total">
	       	<c:choose>
	       		<c:when test = "${current.maxAvailable == 0}">
	       			<bean:message key="No Entitlements Available"/>
	       		</c:when>
	       		<c:otherwise>
		            <c:choose>
		                  <c:when test="${param.oid != 1}">                               
		                    <input name="${current.key}" value="${requestScope.subscriptions[current.key]}" type="text" size = "13"
		                    onkeydown="return blockEnter(event)">
		                    <br>
		                    <span class="small-text"><bean:message key="orgsystemsubs.jsp.possible_vals" 
		                      arg0="0" arg1="${current.maxAvailable}"/></span>
		                  </c:when>
		                  <c:otherwise>
		                    ${current.maxAvailable}
		                  </c:otherwise>
		            </c:choose>
	            </c:otherwise>
			</c:choose>
        </rl:column>
        <rl:column   styleclass="center"
               headertext="${rhn:localize('Flex Usage')} <br/>(${rhn:localize('Used/Allotted')})*">
               
            <c:choose>
            	<c:when test="${empty current.maxFlex or current.maxFlex == 0}">
            		<bean:message key="None Allocated"/>
            	</c:when>
            	<c:otherwise>
         	 	<c:out value="${current.currentFlex} / ${current.maxFlex}" />
            	</c:otherwise>            	
            </c:choose>               
               
            
        </rl:column>
        
        <rl:column bound="false" 
               sortable="false" 
               headerkey="Flex Proposed Total" styleclass="last-column">
	       	<c:choose>
	       		<c:when test = "${current.maxAvailableFlex == 0}">
	       			<bean:message key="No Entitlements Available"/>
	       		</c:when>
	       		<c:otherwise>
		            <c:choose>
		                  <c:when test="${param.oid != 1}">                               
		                    <input name="${current.flexKey}" value="${requestScope.subscriptions[current.flexKey]}" type="text" size = "13"
		                    onkeydown="return blockEnter(event)">
		                    <br>
		                    <span class="small-text"><bean:message key="orgsystemsubs.jsp.possible_vals" 
		                      arg0="0" arg1="${current.maxAvailableFlex}"/></span>
		                  </c:when>
		                  <c:otherwise>
		                    ${current.maxAvailableFlex}
		                  </c:otherwise>
		            </c:choose>
	            </c:otherwise>
			</c:choose>               
        </rl:column>        
    </rl:list>
<p><rhn:tooltip>*-<bean:message key = "Used/Allotted.tip"/></rhn:tooltip></p>          
<c:if test="${param.oid != 1}"> 
 <div align="right">
   <hr/>
   <input type="submit" name="dispatch" value="${rhn:localize('orgdetails.jsp.submit')}"/>
 </div>
</c:if> 
</rl:listset>
</div>


</body>
</html>

