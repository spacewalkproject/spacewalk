<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>


<html:html xhtml="true">
<body>
<%@ include file="/WEB-INF/pages/common/fragments/channel/channel_header.jspf" %>
<BR>




<div>
  <h2><img src="/img/rhn-icon-errata.gif"> <bean:message key="header.jsp.errata"/></h2>
    <bean:message key="channel.jsp.errata.listtitle"/>



    <rl:listset name="errataSet">

    <input type="hidden" name="cid" value="${cid}" />

    	<rl:list dataset="pageList"
    	         name="errataList"
                emptykey="channel.jsp.errata.emptylist"
                filter="com.redhat.rhn.frontend.action.channel.manage.ErrataFilter">


                 <rl:column sortable="false"
                                   bound="false"
                           headerkey="erratalist.jsp.type"
                           styleclass="first-column">

							<c:if test="${current.securityAdvisory}">
					            <img src="/img/wrh-security.gif"
					                 alt="<bean:message key='erratalist.jsp.securityadvisory' />"
					                 title="<bean:message key='erratalist.jsp.securityadvisory' />" />
					        </c:if>
					        <c:if test="${current.bugFix}">
					            <img src="/img/wrh-bug.gif"
					                 alt="<bean:message key='erratalist.jsp.bugadvisory' />"
					                 title="<bean:message key='erratalist.jsp.bugadvisory' />" />
					        </c:if>
					        <c:if test="${current.productEnhancement}">
					            <img src="/img/wrh-product.gif"
					                 alt="<bean:message key='erratalist.jsp.productenhancementadvisory' />"
					                 title="<bean:message key='erratalist.jsp.productenhancementadvisory' />" />
					        </c:if>

                </rl:column>

                 <rl:column sortable="true"
                                   bound="false"
                                   sortattr="advisory"
                           headerkey="erratalist.jsp.advisory"
                          >
                        <a href="/rhn/errata/details/Details.do?eid=${current.id}">
                        	<c:out value="${current.advisory}" />
                        </a>
                </rl:column>


                 <rl:column sortable="false"
                                   bound="false"
                           headerkey="erratalist.jsp.synopsis"
                          >
                          <c:out value="${current.advisorySynopsis}" />
                </rl:column>


                 <rl:column sortable="true"
                                   bound="false"
                           headerkey="erratalist.jsp.updated"
                           styleclass="last-column"
                           sortattr="updateDateObj"
                           defaultsort="desc"
                          >
                        ${current.updateDate}
                </rl:column>


        </rl:list>

	<rl:csv dataset="pageList"
		        name="packageList"
		        exportColumns="id, advisory, advisoryType, advisorySynopsis, updateDate" />

    </rl:listset>
    	
    		

</div>

</body>
</html:html>

