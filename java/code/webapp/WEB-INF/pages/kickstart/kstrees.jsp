<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<html:xhtml/>
<html>
<body>
<div class="toolbar-h1">
  <div class="toolbar">
    <span class="toolbar">
      <a href="TreeCreate.do"><img src="/img/action-add.gif" alt="<bean:message key="kickstart.kickstartable_distro_create_new.jsp" />" title="<bean:message key="kickstart.kickstartable_distro_create_new.jsp" />" /><bean:message key="kickstart.kickstartable_distro_create_new.jsp" /></a>
     </span>
   </div><img alt="<bean:message key="kickstarts.alt.img"/>" src="/img/rhn-kickstart_profile.gif" />
  <bean:message key="kickstart.kickstartable_distributions.jsp" />
</div>


<div class="page-summary">
  <p>
    <bean:message key="kickstart.kickstartable_distributions_text.jsp" />
  </p>
  <div>
      <rl:listset name="ksDistros">
	<rl:list emptykey="kickstart.distributions.jsp.nolists"
      			alphabarcolumn="label">      			
      		<rl:decorator name="PageSizeDecorator"/>
		<rl:column
			bound="false"
			headerkey="kickstart.jsp.label"
			sortattr="label"
          		defaultsort="asc"
          		filterattr="label"
          		styleclass="first-column">
          		            <a href="/rhn/kickstart/TreeEdit.do?kstid=${current.id}">${current.label}</a>
		</rl:column>
      		<rl:column bound="false" headerkey="softwareedit.jsp.basechannel"  sortattr="channel">
				${current.channel.name}
      		</rl:column>
            <rl:column headertext="${rhn:localize('kickstart.distro.is-valid.jsp')}?*" sortattr="valid" styleclass="last-column">
            	<c:choose>
                    <c:when test="${current.valid}">
                    	<img src="/img/rhn-listicon-checked.gif">
                    </c:when>
					<c:otherwise>
						<img src="/img/rhn-listicon-error.gif">
                	</c:otherwise>
                </c:choose>
            </rl:column>
	     </rl:list>
      </rl:listset>
</div>
  <p><rhn:tooltip>*-<bean:message key="kickstarts.distro.is-valid.tooltip"/></rhn:tooltip></p>
</body>
</html>
