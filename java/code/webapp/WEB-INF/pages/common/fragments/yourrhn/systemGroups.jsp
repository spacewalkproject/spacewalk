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
            	<a href="/network/systems/groups/errata_list.pxt?sgid=${current.id}">
		      		<c:choose>
                                        <c:when test="${current.mostSevereErrata == 'Security Advisory'}">
				<i class="fa fa-exclamation-triangle fa-1-5x text-danger" title="<bean:message key="grouplist.jsp.security"/>"></i>
	        			</c:when>
                                        <c:when test="${current.mostSevereErrata == 'Bug Fix Advisory' or current.mostSevereErrata == 'Product Enhancement Advisory'}">
					<i class="fa fa-exclamation-circle fa-1-5x text-warning" title="<bean:message key="grouplist.jsp.updates"/>"></i>
	    	    		</c:when>
	        			<c:otherwise>
	          			<i class="fa fa-check-circle fa-1-5x text-success" title="<bean:message key="grouplist.jsp.noerrata"/>"></i>
		        		</c:otherwise>
	   				</c:choose>
	   			</a>
        	</rl:column>

        	<%@ include file="/WEB-INF/pages/common/fragments/systems/monitoring_status_groups.jspf" %>

			<rl:column headerkey="yourrhn.jsp.systemgroups">
                <a href="/network/systems/groups/details.pxt?sgid=${current.id}">
                <c:out value="${current.name}"/></a>
            </rl:column>
        	
        	<rl:column headerkey="grouplist.jsp.systems">
                <a href="/network/systems/groups/details.pxt?sgid=${current.id}">
                <c:out value="${current.serverCount}"/></a>
        	</rl:column>
 		
  		</rl:list>

		  <a href="/rhn/systems/SystemGroupList.do">
  			<div class="btn btn-default spacewalk-btn-margin-vertical"><i class="spacewalk-icon-system-groups"></i><bean:message key="yourrhn.jsp.allgroups" /></div>
  		</a>
  		
	</rl:listset>
