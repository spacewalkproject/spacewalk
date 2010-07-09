<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

  	<rl:listset name="systemGroupsSet">
  		<rl:list dataset="systemGroupList"
                 width="100%"
                 name="systemsGroupList"
                 title="${rhn:localize('yourrhn.jsp.systemgroups')}"
                 styleclass="list list-doubleheader"
                 hidepagenums="true"
                 emptykey="yourrhn.jsp.systemgroups.none">

        	<rl:column headerkey="grouplist.jsp.status" styleclass="first-column">
            	<a href="/network/systems/groups/errata_list.pxt?sgid=${current.id}">
		      		<c:choose>
		        		<c:when test="${current.securityErrata > 0}">
				<img src="/img/icon_crit_update.gif" border="0"
						alt="<bean:message key="grouplist.jsp.security"/>"
           					title="<bean:message key="grouplist.jsp.security"/>" />
	        			</c:when>
	        			<c:when test="${current.bugErrata > 0 or current.enhancementErrata > 0}">
					<img src="/img/icon_reg_update.gif" border="0"
						alt="<bean:message key="grouplist.jsp.updates"/>"
    	       				title="<bean:message key="grouplist.jsp.updates"/>" />
	    	    		</c:when>
	        			<c:otherwise>
	          			<img src="/img/icon_up2date.gif" border="0"
           					alt="<bean:message key="grouplist.jsp.noerrata"/>"
	           				title="<bean:message key="grouplist.jsp.noerrata"/>" />
		        		</c:otherwise>
	   				</c:choose>
	   			</a>
        	</rl:column>

        	<%@ include file="/WEB-INF/pages/common/fragments/systems/monitoring_status_groups.jspf" %>

			<rl:column headerkey="yourrhn.jsp.systemgroups">
                <a href="/network/systems/groups/details.pxt?sgid=${current.id}">
                <c:out value="${current.name}"/></a>
            </rl:column>
        	
        	<rl:column headerkey="grouplist.jsp.systems" styleclass="last-column">
                <a href="/network/systems/groups/details.pxt?sgid=${current.id}">
                <c:out value="${current.serverCount}"/></a>
        	</rl:column>
 		
  		</rl:list>

  		<span class="full-width-note-right">
		<a href="/rhn/systems/SystemGroupList.do">
  			<bean:message key="yourrhn.jsp.allgroups" />
  		</a>
  		</span>
  		
	</rl:listset>
