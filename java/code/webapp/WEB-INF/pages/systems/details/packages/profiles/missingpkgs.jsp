<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>

<html:xhtml/>
<html>

<body>

<html:messages id="message" message="true">
    <rhn:messages><c:out escapeXml="false" value="${message}" /></rhn:messages>
</html:messages>

<%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>


<h2>
<bean:message key="missingpkgs.jsp.missingpackages" />
</h2>

<form name="rhn_list" method="POST"
      action="/rhn/systems/details/packages/profiles/MissingPackageSubmit.do?date=${time}">

    <div class="page-summary">
        <bean:message key="missingpkgs.jsp.pagesummary" />
    </div>

    <rhn:list pageList="${requestScope.pageList}" noDataText="">
      <rhn:listdisplay>
         <rhn:column header="missingpkgs.jsp.package" width="30%">
             ${current.name}
         </rhn:column>
         <rhn:column header="missingpkgs.jsp.channels">
         
	       <c:choose>
             <c:when test="${empty current.channels}">
               <bean:message key="missingpkgs.jsp.none" />
             </c:when>
             <c:when test="${!empty current.channels}">
              <c:forEach items="${current.channels}" var="item">
                 ${item.name}<br />
              </c:forEach>
             </c:when>
           </c:choose>
         </rhn:column>

      </rhn:listdisplay>
      <div align="right">
        <hr />
        <html:submit property="dispatch">
          <bean:message key="missingpkgs.jsp.selectnewpackageprofile" />
        </html:submit>
        <html:submit property="dispatch">
          <bean:message key="missingpkgs.jsp.removelistedpackagesfromsync" />
        </html:submit>
        <html:submit property="dispatch">
          <bean:message key="missingpkgs.jsp.subscribetochannels" />
        </html:submit>
      </div>

      <html:hidden property="sid" value="${param.sid}" />
      <html:hidden property="sid_1" value="${param.sid_1}" />
      <html:hidden property="prid" value="${param.prid}" />
      <html:hidden property="sync" value="${param.sync}" />
      <html:hidden property="set_label" value="packages_for_system_sync" />
    </rhn:list>
</form>
</body>
</html>
