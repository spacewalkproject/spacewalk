<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>


<html:html >
<body>
<rhn:toolbar base="h1" icon="fa-rocket"
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
      <rhn:csrf />
      <rhn:submitted />
	<rl:list dataset="pageList" name="ksList" emptykey="kickstart.jsp.nokickstarts"
      			alphabarcolumn="label"
                filter="com.redhat.rhn.frontend.action.kickstart.KickstartProfileFilter">
        	<rl:decorator name="ElaborationDecorator"/>
      		<rl:decorator name="PageSizeDecorator"/>
			<rl:column
			bound="false"
			headerkey="kickstart.jsp.label"
			sortattr="label"
          		defaultsort="asc">
          			<c:choose>
          				<c:when test="${current.advancedMode}">
          					<a href="/rhn/kickstart/AdvancedModeEdit.do?ksid=${current.id}"><c:out value="${current.label}" escapeXml="true" /></a>
          				</c:when>
          				<c:when test="${current.cobbler}">
          					<c:out value="${current.label}" escapeXml="true" />
          				</c:when>
          				<c:otherwise>
          					<a href="/rhn/kickstart/KickstartDetailsEdit.do?ksid=${current.id}"><c:out value="${current.label}" escapeXml="true" /></a>
          				</c:otherwise>
          			</c:choose>

					<c:if test="${current.orgDefault}">
		            **
		          </c:if>
		</rl:column>
      		<rl:column  bound="false" headerkey="kickstart.jsp.active"  sortattr="active">
	      		<c:if test="${current.active}">
	            <i class="fa fa-check text-success" title="<bean:message key='kickstart.jsp.active'/>"></i>
	          </c:if>
	         <c:if test="${not current.active}">
	            <i class="fa fa-times-circle text-danger" title="<bean:message key='kickstart.jsp.inactive'/>"></i>
	          </c:if>
      		</rl:column>
                <rl:column headerkey="kickstart.distro.label.jsp" sortattr="treeLabel">
                    <c:out value="${current.treeLabel}"/>
                </rl:column>
            <rl:column headerkey="kickstart.distro.sw_managed.jsp" sortattr="cobbler">
            	<c:choose>
                    <c:when test="${current.cobbler}">
                    	<i class="fa fa-times-circle text-danger"></i>
                    </c:when>
					<c:otherwise>
						<i class="fa fa-check text-success"></i>
                	</c:otherwise>
                </c:choose>
            </rl:column>
         </rl:list>

      </rl:listset>
</div>
  <p><rhn:tooltip>* - <bean:message key="kickstarts.distro.cobbler-only.tooltip"/></rhn:tooltip></p>
  <c:if test="${not empty requestScope.orgDefaultExists}">
  	<p><rhn:tooltip>** - <bean:message key="kickstart.list.jsp.orgdefault"/></rhn:tooltip></p>
  </c:if>
</body>
</html:html>

