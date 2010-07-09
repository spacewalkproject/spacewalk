<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
    <div class="${requestScope.inactiveSystemsClass}">
	  <form method="post" name="rhn_list" action="/YourRhn.do">
	    <rhn:list pageList="${requestScope.inactiveSystemList}"
	              noDataText="${requestScope.inactiveSystemsEmpty}"
	              formatMessage="false">
		<rhn:listdisplay	set="${requestScope.set}"
							paging="false"
	  				   		type="half-table"
	  				  		reflink="/rhn/systems/Inactive.do"
							reflinkkey="yourrhn.jsp.allinactivesystems"
	  				   		reflinkkeyarg0="${pageList.size}">
	  		

	    <rhn:column header="inactivelist.jsp.header"
	    			url="/rhn/systems/details/Overview.do?sid=${current.id}">
	    	<img src="/img/icon_checkin.gif" alt="<bean:message key="system-legend.jsp.notcheckingin"/>" />
	    	${current.name}
	    </rhn:column>

	    <rhn:column header="emptyspace.jsp">
	    ${current.lastCheckinString}		
	    </rhn:column>
	
	  </rhn:listdisplay>
	</rhn:list>
	</form>
  </div>
