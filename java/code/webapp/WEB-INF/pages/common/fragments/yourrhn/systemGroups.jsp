<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

  	<rl:listset name="systemGroupsSet">
        <rhn:csrf />
  		<rl:list dataset="systemGroupList"
                 width="100%"
                 name="systemsGroupList"
                 title="${rhn:localize('yourrhn.jsp.systemgroups')}"
                 styleclass="list list-doubleheader"
                 hidepagenums="true"
                 emptykey="yourrhn.jsp.systemgroups.none">

        	<rl:column headerkey="grouplist.jsp.status">
                <a href="/rhn/groups/ListErrata.do?sgid=${current.id}">
		      		<c:choose>
                                        <c:when test="${current.mostSevereErrata == 'Security Advisory'}">
                                        <rhn:icon type="system-crit" title="<bean:message key='grouplist.jsp.security' />" />
	        			</c:when>
                                        <c:when test="${current.mostSevereErrata == 'Bug Fix Advisory' or current.mostSevereErrata == 'Product Enhancement Advisory'}">
                                        <rhn:icon type="system-warn" title="<bean:message key='grouplist.jsp.updates' />" />
	    	    		</c:when>
	        			<c:otherwise>
                                        <rhn:icon type="system-ok" title="<bean:message key='grouplist.jsp.noerrata'/>" />
		        		</c:otherwise>
	   				</c:choose>
	   			</a>
        	</rl:column>

        	<%@ include file="/WEB-INF/pages/common/fragments/systems/monitoring_status_groups.jspf" %>

			<rl:column headerkey="yourrhn.jsp.systemgroups">
                <a href="/rhn/groups/GroupDetail.do?sgid=${current.id}">
                <c:out value="${current.name}"/></a>
            </rl:column>

        	<rl:column headerkey="grouplist.jsp.systems">
                <a href="/rhn/groups/GroupDetail.do?sgid=${current.id}">
                <c:out value="${current.serverCount}"/></a>
        	</rl:column>

  		</rl:list>

		  <a href="/rhn/systems/SystemGroupList.do">
                        <div class="btn btn-default spacewalk-btn-margin-vertical"><rhn:icon type="header-system-groups" /><bean:message key="yourrhn.jsp.allgroups" /></div>
  		</a>

	</rl:listset>
