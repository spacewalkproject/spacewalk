<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>


<html:html >
<body>
<%@ include file="/WEB-INF/pages/common/fragments/channel/channel_header.jspf" %>

  <h2><rhn:icon type="header-errata" /> <bean:message key="header.jsp.errata"/></h2>
    <bean:message key="channel.jsp.errata.listtitle"/>

    <rl:listset name="errataSet">
    <rhn:csrf />
    <rhn:submitted />

    <rhn:hidden name="cid" value="${cid}" />

        <rl:list dataset="pageList"
                 name="errataList"
                emptykey="channel.jsp.errata.emptylist"
                filter="com.redhat.rhn.frontend.action.channel.manage.ErrataFilter">


            <rl:column sortable="false"
                       bound="false"
                       headerkey="erratalist.jsp.type">

                <c:if test="${current.securityAdvisory}">
                    <c:choose>
                        <c:when test="${current.severityid=='0'}">
                            <rhn:icon type="errata-security-critical"
                                      title="erratalist.jsp.securityadvisory"/>
                        </c:when>
                        <c:when test="${current.severityid=='1'}">
                            <rhn:icon type="errata-security-important"
                                      title="erratalist.jsp.securityadvisory"/>
                        </c:when>
                        <c:when test="${current.severityid=='2'}">
                            <rhn:icon type="errata-security-moderate"
                                      title="erratalist.jsp.securityadvisory"/>
                        </c:when>
                        <c:when test="${current.severityid=='3'}">
                            <rhn:icon type="errata-security-low"
                                      title="erratalist.jsp.securityadvisory"/>
                        </c:when>
                        <c:otherwise>
                            <rhn:icon type="errata-security"
                                      title="erratalist.jsp.securityadvisory"/>
                        </c:otherwise>
                    </c:choose>
                </c:if>
                <c:if test="${current.bugFix}">
                    <rhn:icon type="errata-bugfix" title="erratalist.jsp.bugadvisory"/>
                </c:if>
                <c:if test="${current.productEnhancement}">
                    <rhn:icon type="errata-enhance"
                              title="erratalist.jsp.productenhancementadvisory"/>
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

</body>
</html:html>

