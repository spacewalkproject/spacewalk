<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>


<html>
<head>
    <meta name="name" value="System Details" />
</head>
<body>

<%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>

<h2>
  <rhn:icon type="header-errata" title="errata.common.errataAlt" />
  <bean:message key="errata.jsp.header"/>
</h2>

  <div class="page-summary">
    <p>
    <bean:message key="errata.jsp.summary"/>
    </p>
  </div>

<c:set var="pageList" value="${requestScope.pageList}" />

<rl:listset name="errataListSet" legend="errata">
<rhn:csrf />
<rhn:submitted />

        <br/>
        <select name="type">
                <c:forEach items="${combo}" var="item">
                        <option id="${item.id}"
                                <c:if test="${item['default']}"> selected</c:if>
                                >  <bean:message key="${item.name}"/>
                        </option>
                </c:forEach>
        </select>
        <html:submit styleClass="btn btn-default" property="show">
                <bean:message key="system.errata.show"/>
        </html:submit>
        <br/>


        <rl:list
         width="100%"
         name="errataList"
         styleclass="list"
         emptykey="erratalist.jsp.norelevanterrata"
         alphabarcolumn="advisorySynopsis">

        <rl:decorator name="ElaborationDecorator"/>
                <rl:decorator name="PageSizeDecorator"/>

                <c:if test="${requestScope.showApplyErrata == 'false'}">
                        <rl:column headerkey="emptyspace.jsp"  styleclass="text-align: center;">
                        <rhn:icon type="action-pending" />
            </rl:column>
                </c:if>

                <c:if test="${requestScope.showApplyErrata == 'true'}">
                        <rl:decorator name="SelectableDecorator"/>
                        <rl:selectablecolumn value="${current.id}"
                                selected="${current.selected}"
                                disabled="${not current.selectable}"/>
                </c:if>

                  <rl:column headerkey="erratalist.jsp.type" styleclass="text-align: center;"
                        bound="false">
                      <c:if test="${current.securityAdvisory}">
                          <c:choose>
                              <c:when test="${current.severityid=='0'}">
                                  <rhn:icon type="errata-security-critical"
                                            title="erratalist.jsp.securityadvisory" />
                              </c:when>
                              <c:when test="${current.severityid=='1'}">
                                  <rhn:icon type="errata-security-important"
                                            title="erratalist.jsp.securityadvisory" />
                              </c:when>
                              <c:when test="${current.severityid=='2'}">
                                  <rhn:icon type="errata-security-moderate"
                                            title="erratalist.jsp.securityadvisory" />
                              </c:when>
                              <c:when test="${current.severityid=='3'}">
                                  <rhn:icon type="errata-security-low"
                                            title="erratalist.jsp.securityadvisory" />
                              </c:when>
                              <c:otherwise>
                                  <rhn:icon type="errata-security"
                                            title="erratalist.jsp.securityadvisory" />
                              </c:otherwise>
                          </c:choose>
                      </c:if>
                      <c:if test="${current.bugFix}">
                        <rhn:icon type="errata-bugfix" />
                      </c:if>
                      <c:if test="${current.productEnhancement}">
                        <rhn:icon type="errata-enhance" />
                      </c:if>
                  </rl:column>

                  <rl:column headerkey="erratalist.jsp.advisory" bound="false"
                        sortattr="advisoryName"
                        sortable="true">
                      <a href="/rhn/errata/details/Details.do?eid=${current.id}">
                        ${current.advisoryName}</a>
                  </rl:column>

                  <rl:column headerkey="erratalist.jsp.synopsis" bound="false"
                        sortattr="advisorySynopsis"
                        sortable="true"
                        filterattr="advisorySynopsis">
                      ${current.advisorySynopsis}
                  </rl:column>

                  <rl:column headerkey="errata.jsp.status" bound="false"
                        sortattr="currentStatusAndActionId[0]"
                        sortable="true">
                      <c:if test="${not empty current.status}">
                         <c:if test="${current.currentStatusAndActionId[0] == 'Queued'}">
                            <a href="/rhn/schedule/ActionDetails.do?aid=${current.currentStatusAndActionId[1]}">
                              <bean:message key="affectedsystems.jsp.pending"/></a>
                         </c:if>
                         <c:if test="${current.currentStatusAndActionId[0] == 'Failed'}">
                            <a href="/rhn/systems/details/history/Event.do?sid=${param.sid}&aid=${current.currentStatusAndActionId[1]}">
                              <bean:message key="actions.jsp.failed"/></a>
                         </c:if>
                         <c:if test="${current.currentStatusAndActionId[0] == 'Picked Up'}">
                            <a href="/rhn/systems/details/history/Event.do?sid=${param.sid}&aid=${current.currentStatusAndActionId[1]}">
                              <bean:message key="actions.jsp.pickedup"/></a>
                         </c:if>
                      </c:if>
                      <c:if test="${empty current.status}">
                            <bean:message key="affectedsystems.jsp.none"/>
                      </c:if>
                  </rl:column>

                  <rl:column headerkey="erratalist.jsp.updated" bound="false"
                        sortattr="updateDateObj"
                        sortable="true"
                        defaultsort="desc">
                      ${current.updateDate}
                  </rl:column>

        </rl:list>

        <c:if test="${requestScope.showApplyErrata == 'true'}">
                <div class="text-right">
                <hr />
                <html:submit styleClass="btn btn-success" property="dispatch">
                        <bean:message key="errata.jsp.apply"/>
                </html:submit>
                </div>
        </c:if>


        <c:if test="${requestScope.showApplyErrata == 'true'}">
                <rl:csv
                        name="errataList"
                        exportColumns="associatedSystem,errataAdvisoryType,advisoryName,advisorySynopsis,errataStatus,updateDate"
                        header="${system.name}"/>
        </c:if>
        <rhn:submitted/>
</rl:listset>


</body>
</html>
