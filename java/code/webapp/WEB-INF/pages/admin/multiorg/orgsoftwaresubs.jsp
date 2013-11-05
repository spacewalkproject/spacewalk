<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>

<html>
<body>
<c:choose>
<c:when test="${param.oid != 1}">
<rhn:toolbar base="h1" icon="fa-group"
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
<rhn:toolbar base="h1" icon="fa-group"
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

<p class="margin-bottom-md"><bean:message key="orgsoftwaresubs.jsp.description" arg0="${org.name}"/></p>

<rl:listset name="entitlementSet">
    <rhn:csrf />
	<rhn:submitted/>
	<input type="hidden" name="oid" value="${param.oid}"/>
	
    <rl:list dataset="pageList"
			name="entitlement"
	alphabarcolumn="name"
         styleclass="list"
         emptykey="orgsoftwaresubs.jsp.nochannelfams">
                     <rl:decorator name="PageSizeDecorator"/>
        <rl:column
               filterattr="name"
               sortattr = "name"
               headerkey="entitlements.jsp.channel">
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
		                    <p><small><bean:message key="orgsystemsubs.jsp.possible_vals"
		                      arg0="0" arg1="${current.maxAvailable}"/></small></p>
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
               headerkey="Flex Proposed Total">
	       	<c:choose>
	       		<c:when test = "${current.maxAvailableFlex == 0}">
	       			<bean:message key="No Entitlements Available"/>
	       		</c:when>
	       		<c:otherwise>
		            <c:choose>
		                  <c:when test="${param.oid != 1}">
		                    <input name="${current.flexKey}" value="${requestScope.subscriptions[current.flexKey]}" type="text" size = "13"
		                    onkeydown="return blockEnter(event)">
		                    
		                    <p><small><bean:message key="orgsystemsubs.jsp.possible_vals"
		                      arg0="0" arg1="${current.maxAvailableFlex}"/></small></p>
		                  </c:when>
		                  <c:otherwise>
		                    ${current.maxAvailableFlex}
		                  </c:otherwise>
		            </c:choose>
	            </c:otherwise>
			</c:choose>
        </rl:column>
    </rl:list>
	<rl:csv dataset="pageList"
			name="entitlement"
			exportColumns="name,currentMembers,maxMembers,maxAvailable,currentFlex,maxFlex,maxAvailableFlex" />
<p><small><rhn:tooltip>*-<bean:message key = "Used/Allotted.tip"/></rhn:tooltip></small></p>
<c:if test="${param.oid != 1}">
 <div class="text-right">
   <hr/>
   <input type="submit" name="dispatch" class="btn btn-default" value="${rhn:localize('orgdetails.jsp.submit')}"/>
 </div>
</c:if>
</rl:listset>

</body>
</html>

