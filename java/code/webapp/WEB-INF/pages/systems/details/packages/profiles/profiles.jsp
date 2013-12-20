<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>


<html>

<body>
<%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>

<h2>
  <rhn:icon type="header-package" title="errata.common.packageAlt" />
  <bean:message key="profile.jsp.comparetostoredprofile"/>
</h2>

<html:form action="/systems/details/packages/profiles/ShowProfiles">
    <rhn:csrf />
    <div class="page-summary">
        <p>
        <c:choose>
        <c:when test="${!empty requestScope.profiles}">
            <bean:message key="profile.jsp.storedprofiles" />:
            <html:select property="profile">
               <html:options collection="profiles" property="value" labelProperty="label"/>
            </html:select>
            <html:submit property="compareProfilesBtn">
                <bean:message key="profile.jsp.compare"/>
            </html:submit>
        </c:when>
        <c:when test="${empty requestScope.profiles}">
            <bean:message key="profile.jsp.nocompatibleprofiles" />
        </c:when>
        </c:choose>
        </p>
    </div>
    <h2>
      <rhn:icon type="header-package" title="errata.common.packageAlt" />
      <bean:message key="profile.jsp.comparetosystem"/>
    </h2>
    <div class="page-summary">
        <p>
        <c:choose>
        <c:when test="${!empty requestScope.servers}">
            <bean:message key="profile.jsp.compareanothersystem" />:
            <html:select property="server">
               <html:options collection="servers" property="value" labelProperty="label"/>
            </html:select>
            <html:submit property="compareSystemsBtn">
                <bean:message key="profile.jsp.compare"/>
            </html:submit>
        </c:when>
        <c:when test="${empty requestScope.servers}">
            <bean:message key="profile.jsp.nocompatiblesystems" />
        </c:when>
        </c:choose>
        </p>
    </div>
    <div class="text-right">
    <hr />
    <html:submit property="createBtn">
        <bean:message key="profile.jsp.createsystemprofile"/>
    </html:submit>

    </div>
    <html:hidden property="sid" value="${param.sid}" />
    <html:hidden property="submitted" value="true" />
</html:form>
</body>
</html>
