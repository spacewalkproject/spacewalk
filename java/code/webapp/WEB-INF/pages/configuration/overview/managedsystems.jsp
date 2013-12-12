<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>


<html>
<head>
    <meta name="page-decorator" content="none" />
</head>
<body>
<rhn:toolbar base="h1" icon="header-system"
 helpUrl="/rhn/help/reference/en-US/s1-sm-configuration.jsp#config-systems" >
  <bean:message key="managedsystems.jsp.toolbar"/>
</rhn:toolbar>
<!-- no create button (these have to be created according to specific systems)-->

    <p>
    <bean:message key="managedsystems.jsp.summary"/>
    </p>

<form method="post" role="form" name="rhn_list" action="/rhn/configuration/system/ManagedSystems.do">
  <rhn:csrf />
  <rhn:submitted />

  <rhn:list pageList="${requestScope.pageList}" noDataText="managedsystems.jsp.noSystems">
    <rhn:listdisplay filterBy="system.common.systemName">
      <rhn:column header="system.common.systemName"
                  url="/rhn/systems/details/configuration/Overview.do?sid=${current.id}">
        <rhn:icon type="header-system-physical" title="<bean:message key='system.common.systemAlt' />" />
        <c:out value="${current.name}" />
      </rhn:column>

      <rhn:column header="managedsystems.jsp.localfiles">
        <c:set var="locfiles" scope="request" >
          <c:if test="${current.localFileCount == 1}">
            <bean:message key="managedsystems.jsp.onefile" />
          </c:if>
          <c:if test="${current.localFileCount != 1}">
            <bean:message key="managedsystems.jsp.numfiles" arg0="${current.globalFileCount}" />
          </c:if>
        </c:set>
        <c:set var="overs" scope="request" >
          <c:if test="${current.overriddenCount == 1}">
            <bean:message key="managedsystems.jsp.oneoverride" />
          </c:if>
          <c:if test="${current.overriddenCount != 1}">
            <bean:message key="managedsystems.jsp.numoverrides" arg0="${current.overriddenCount}" />
          </c:if>
        </c:set>

        <c:choose>
        	<c:when test="${current.overriddenCount == 0}">
        	  <bean:message key="none.message"/>
        	</c:when>
        	<c:otherwise>
		  <bean:message key="managedsystems.jsp.local"
                      arg0="/rhn/systems/details/configuration/ViewModifyLocalPaths.do?sid=${current.id}"
                      arg1="${requestScope.locfiles}" arg2="${requestScope.overs}"/>
            </c:otherwise>
         </c:choose>
      </rhn:column>

      <rhn:column header="managedsystems.jsp.globalfiles">
        <c:set var="globfiles" scope="request" >
          <c:if test="${current.globalFileCount == 1}">
            <bean:message key="managedsystems.jsp.onefile" />
          </c:if>
          <c:if test="${current.globalFileCount != 1}">
            <bean:message key="managedsystems.jsp.numfiles" arg0="${current.globalFileCount}" />
          </c:if>
        </c:set>
        <c:set var="confchan" scope="request" >
          <c:if test="${current.configChannelCount == 1}">
            <bean:message key="managedsystems.jsp.onechannel" />
          </c:if>
          <c:if test="${current.configChannelCount != 1}">
            <bean:message key="managedsystems.jsp.numchannels" arg0="${current.configChannelCount}" />
          </c:if>
        </c:set>
        <c:choose>
        	<c:when test="${current.globalFileCount == 0}">
        	  <bean:message key="none.message"/>
        	</c:when>
        	<c:otherwise>
		  <bean:message key="managedsystems.jsp.global"
                      arg0="${requestScope.globfiles}"
                      arg1="/rhn/systems/details/configuration/ConfigChannelList.do?sid=${current.id}"
                      arg2="${requestScope.confchan}"/>
           </c:otherwise>
         </c:choose>
      </rhn:column>
    </rhn:listdisplay>
  </rhn:list>

</form>

</body>
</html>
