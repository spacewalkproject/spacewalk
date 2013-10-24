<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

    <div class="${requestScope.inactiveSystemsClass}">
	  <form method="post" name="rhn_list" action="/YourRhn.do">

	    <rhn:list pageList="${requestScope.inactiveSystemList}"
                  noDataText="${requestScope.inactiveSystemsEmpty}"
                  formatMessage="false">
		  <rhn:listdisplay set="${requestScope.set}"
                           type="half-table"
                           title="inactivelist.jsp.header"
                           paging="false"
                           reflink="/rhn/systems/Inactive.do"
                           reflinkkey="yourrhn.jsp.allinactivesystems"
                           reflinkkeyarg0="${pageList.size}"
                           domainClass="systems">
	        <rhn:column header="probesuitesystemsedit.jsp.systemname"
              url="/rhn/systems/details/Overview.do?sid=${current.id}">
	          <i class="icon-question-sign"></i>
		      <c:out value="${current.name}" escapeXml="true" />
	        </rhn:column>

	        <rhn:column header="emptyspace.jsp">
	        ${current.lastCheckinString}
	        </rhn:column>

	    </rhn:listdisplay>
	  </rhn:list>

	  </form>
    </div>
