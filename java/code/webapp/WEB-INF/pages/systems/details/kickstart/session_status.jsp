<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>


<html>
<head>
    <meta name="name" value="System Details" />
    <style type="text/css">
	    .details td, .details th { white-space: nowrap; }
    </style>
    <c:if test="${not failed and not complete}">
	<script type="text/javascript" src="/javascript/rememberScroll.js"> </script>
    </c:if>
</head>
<body>

<%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>

<p>
<bean:message key="kickstart.session_status.jsp.summary2"/>
</p>

<div class="row-0">
  <div class="col-md-6">
    <div class="panel panel-default">
      <div class="panel-heading">
        <h4><bean:message key="kickstart.session_status.jsp.header2"/></h4>
      </div>

<table class="table">
  <tr>
    <th><bean:message key="kickstart.session_status.jsp.next_action" /></th>
    <td>
      <c:if test="${ksession.action != null}">
        ${ksession.action.name}
      </c:if>
      <c:if test="${ksession.action == null}">
        <bean:message key="kickstart.session_status.jsp.none" />
      </c:if>
    </td>
  </tr>
  <tr>
    <th><bean:message key="kickstart.session_status.jsp.description" /></th>
    <td style="white-space: normal;">${statedescription}
        <c:if test="${ksession.mostRecentHistory != null}">
            (${ksession.mostRecentHistory})
        </c:if>
    </td>
  </tr>
  <tr>
    <th><bean:message key="kickstart.session_status.jsp.time" /></th>
    <td><fmt:formatDate value="${ksession.lastAction}" type="both" dateStyle="short" timeStyle="long"/></td>
  </tr>
  <tr>
    <th><bean:message key="kickstart.session_status.jsp.last_file" /></th>
    <td>
      <c:if test="${ksession.lastFileRequest != null}">
        ${ksession.lastFileRequest}
      </c:if>
      <c:if test="${ksession.lastFileRequest == null}">
        <bean:message key="kickstart.session_status.jsp.none" />
      </c:if>
    </td>
  </tr>
  <tr>
    <th><bean:message key="kickstart.session_status.jsp.total_packages" /></th>
    <td  style="white-space: normal;">
        ${ksession.packageFetchCount}
    </td>
  </tr>
  <c:if test="${not failed and not complete}">
  <tr>
    <th><bean:message key="kickstart.session_status.jsp.cancel_cancel" /></th>
    <td>
      <a href="/rhn/systems/details/kickstart/SessionCancel.do?sid=${system.id}"><bean:message key="kickstart.session_cancel.jsp.cancel"/></a>
    </td>
  </tr>
  </c:if>
</table>

    </div>
  </div>
  <div class="col-md-6">
    <div class="panel panel-default">
      <div class="panel-heading">
        <h4><bean:message key="kickstartdetails.jsp.header2"/></h4>
      </div>

<table class="table">
  <tr>
    <th><bean:message key="kickstartdetails.jsp.label" /></th>
    <td><a href="/rhn/kickstart/KickstartDetailsEdit.do?ksid=${ksdata.id}">${ksdata.label}</td>
  </tr>
  <tr>
    <th><bean:message key="kickstart.session_status.jsp.activation" /></th>
    <td>
    <c:if test="${ksession.serverProfile != null}">
        <bean:message key="kickstart.session_status.jsp.activation2" /><a href="/rhn/kickstart/KickstartDetailsEdit.do?ksid=${ksdata.id}">${ksession.serverProfile.name}</a>
    </c:if>
    <c:if test="${ksession.serverProfile == null}">
        <bean:message key="kickstart.session_status.jsp.activation_none" />
    </c:if>
    </td>
  </tr>

</table>

    </div>

    <div class="panel panel-default">
      <div class="panel-heading">
        <h4><bean:message key="kickstart.session_status.jsp.progress"/></h4>
      </div>

<!-- SIDEBAR STATUS TABLE -->
<table class="table">
<tr class="list-row-odd">
  <td class="text-right">
    <c:if test="${created}">
      <rhn:icon type="system-ok" />
    </c:if>
  </td>
  <td>
    <bean:message key="kickstart.session_status.jsp.status_initiate" />
  </tr>
</tr>
<tr class="list-row-even">
  <td class="text-right">
    <c:if test="${restarted}">
      <rhn:icon type="system-ok" />
    </c:if>
  </td>
  <td>
    <bean:message key="kickstart.session_status.jsp.status_reboot" />
  </tr>
</tr>
<tr class="list-row-odd">
  <td class="text-right">
    <c:if test="${registered}">
      <rhn:icon type="system-ok" />
    </c:if>
  </td>
  <td>
    <bean:message key="kickstart.session_status.jsp.status_register" />
  </tr>
</tr>
<c:if test="${ksession.serverProfile != null}">
  <tr class="list-row-even">
    <td class="text-right">
      <c:if test="${package_synch_scheduled}">
        <rhn:icon type="system-ok" />
      </c:if>
    </td>
    <td>
      <bean:message key="kickstart.session_status.jsp.status_profile" arg0="${ksession.serverProfile.id}" />
    </tr>
  </tr>
</c:if>
<c:choose>
  <c:when test="${ksession.serverProfile == null}">
    <c:set var="nextstyle1" value="list-row-even"/>
    <c:set var="nextstyle2" value="list-row-odd"/>
  </c:when>
  <c:otherwise>
    <c:set var="nextstyle1" value="list-row-odd" />
    <c:set var="nextstyle2" value="list-row-even"/>
  </c:otherwise>
</c:choose>
<tr class="${nextstyle1}">
  <td class="text-right">
    <c:if test="${configuration_deploy}">
      <rhn:icon type="system-ok" />
    </c:if>
  </td>
  <td>
    <bean:message key="kickstart.session_status.jsp.status_config" />
  </tr>
</tr>
<c:if test="${not failed}">
  <tr class="${nextstyle2}">
    <td class="text-right">
      <c:if test="${complete}">
        <rhn:icon type="system-ok" />
      </c:if>
    </td>
    <td>
      <bean:message key="kickstart.session_status.jsp.status_complete" />
    </tr>
  </tr>
</c:if>
<c:if test="${failed}">
  <tr class="${nextstyle1}">
    <td class="text-right">
        <rhn:icon type="system-crit" />
    </td>
    <td>
      <bean:message key="kickstart.session_status.jsp.status_failed" />
    </tr>
  </tr>
</c:if>
</table>
<!-- END SIDE STATUS TABLE -->

    </div>

  </div>
</div>
<form id="saveScrollPosition" method="POST" action="/rhn/systems/details/kickstart/SessionStatus.do?sid=${requestScope.sid}">
    <rhn:csrf />
    <rhn:submitted />
	<input id="scrollPosX" type="hidden" name="xPosition" value="${requestScope.scrollX}" />
	<input id="scrollPosY" type="hidden" name="yPosition" value="${requestScope.scrollY}" />
</form>

</body>
</html>
