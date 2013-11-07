<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>

<html>
<body>

<rhn:toolbar base="h1" miscIcon="fa-plus"
    miscText="kickstart.kickstartable_distro_create_new.jsp"
    miscUrl="TreeCreate.do"
    icon="fa-rocket"
    iconAlt="kickstarts.alt.img">
<bean:message key="kickstart.kickstartable_distributions.jsp" />
</rhn:toolbar>

<div class="page-summary">
  <p>
    <bean:message key="kickstart.kickstartable_distributions_text.jsp" />
  </p>
  <div>
      <rl:listset name="ksDistros">
      <rhn:csrf />
      <rhn:submitted />
	<rl:list emptykey="kickstart.distributions.jsp.nolists"
      			alphabarcolumn="label">      			
      		<rl:decorator name="PageSizeDecorator"/>
		<rl:column
			bound="false"
			headerkey="kickstart.jsp.label"
			sortattr="label"
          		defaultsort="asc"
          		filterattr="label">
          		            <a href="/rhn/kickstart/TreeEdit.do?kstid=${current.id}">${current.label}</a>
		</rl:column>
      		<rl:column bound="false" headerkey="softwareedit.jsp.basechannel"  sortattr="channel">
				${current.channel.name}
      		</rl:column>
            <rl:column headertext="${rhn:localize('kickstart.distro.is-valid.jsp')}?*" sortattr="valid">
            	<c:choose>
                    <c:when test="${current.valid}">
                    	<i class="fa fa-check text-success"></i>
                    </c:when>
					<c:otherwise>
						<i class="fa fa-times-circle text-danger"></i>
                	</c:otherwise>
                </c:choose>
            </rl:column>
	     </rl:list>
      </rl:listset>
</div>
  <p><rhn:tooltip>*-<bean:message key="kickstarts.distro.is-valid.tooltip"/></rhn:tooltip></p>
</body>
</html>
