<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:choose>
  <c:when test="${requestScope.showErrata == 'true'}">
<form method="post" name="rhn_list" action="/YourRhn.do">
    <rhn:list pageList="${requestScope.errataSecurityfixList}"
    		  noDataText="${requestScope.errataEmpty}"
    		  formatMessage="false">
  <rhn:listdisplay 	set="${requestScope.set}"
					paging="false"
  					type="list"
  					description="yourrhn.jsp.relevanterrata.description">

    <rhn:column header="yourrhn.jsp.securityerrata">
        <img src="/img/wrh-security.gif" alt="<bean:message key="errata-legend.jsp.security"/>"/>
            <a href="/rhn/errata/details/Details.do?eid=${current.id}">${current.advisoryName}</a>
    </rhn:column>

    <rhn:column header="emptyspace.jsp">
      ${current.advisorySynopsis}
    </rhn:column>

    <rhn:column header="erratalist.jsp.systems" style="text-align: center;"
                url="/rhn/errata/details/SystemsAffected.do?eid=${current.id}">
        ${current.affectedSystemCount}
    </rhn:column>

    <rhn:column header="erratalist.jsp.updated" style="text-align: center;">
      ${current.updateDate}
    </rhn:column>

  </rhn:listdisplay>
  <span class="full-width-note-right">
    <a href="/rhn/errata/AllErrata.do" >
      	<bean:message key="yourrhn.jsp.allerrata" />
    </a>  |  <a href="/rhn/errata/RelevantErrata.do" >
    	<bean:message key="yourrhn.jsp.allrelevanterrata" />
    </a>
  </span>

</rhn:list>
</form>
</c:when>
</c:choose>
