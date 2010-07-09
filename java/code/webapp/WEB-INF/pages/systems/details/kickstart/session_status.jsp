<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<html:xhtml/>
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
<div class="page-summary">
<h2><bean:message key="kickstartdetails.jsp.header2"/></h2>

<table class="details">
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
<div class="page-summary">
<h2><bean:message key="kickstart.session_status.jsp.header2"/></h2>
<p>
<bean:message key="kickstart.session_status.jsp.summary2"/>
</p>
<c:if test="${kswarning != null}">
    <p>
    <table class="warning">
        <tr>
            <td>
                <strong>
                    <bean:message key="kickstart.session_status.jsp.warning"/>
                </strong>
            </td>
        </tr>
        <tr>
            <td>
                ${kswarning}
            </td>
        </tr>
    </table>
   </p>
</c:if>
<table>
  <tr>
    <td>

<table class="details">
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
  <c:if test="${not failed}">
  <tr>
    <th><bean:message key="kickstart.session_status.jsp.cancel_cancel" /></th>
    <td>
      <a href="/rhn/systems/details/kickstart/SessionCancel.do?sid=${system.id}"><bean:message key="kickstart.session_cancel.jsp.cancel"/></a>
    </td>
  </tr>
  </c:if>
</table>

    </td>
    <td>

<!-- SIDEBAR STATUS TABLE -->
<table cellspacing="0"  cellpadding="0" class="half-table">
<thead>
<tr>
  <th colspan="2" style="text-align: left;"><bean:message key="kickstart.session_status.jsp.progress" /></th></tr>
</thead>
<tr class="list-row-odd">
  <td class="first-column">
    <c:if test="${created}">
      <img src="/img/rhn-listicon-ok.gif"/>
    </c:if>
  </td>
  <td style="text-align: left;" class="last-column">
    <bean:message key="kickstart.session_status.jsp.status_initiate" />
  </tr>
</tr>
<tr class="list-row-even">
  <td class="first-column">
    <c:if test="${restarted}">
      <img src="/img/rhn-listicon-ok.gif"/>
    </c:if>
  </td>
  <td style="text-align: left;" class="last-column">
    <bean:message key="kickstart.session_status.jsp.status_reboot" />
  </tr>
</tr>
<tr class="list-row-odd">
  <td class="first-column">
    <c:if test="${registered}">
      <img src="/img/rhn-listicon-ok.gif"/>
    </c:if>
  </td>
  <td style="text-align: left;" class="last-column">
    <bean:message key="kickstart.session_status.jsp.status_register" />
  </tr>
</tr>
<c:if test="${ksession.serverProfile != null}">
  <tr class="list-row-even">
    <td class="first-column">
      <c:if test="${package_synch}">
        <img src="/img/rhn-listicon-ok.gif"/>
      </c:if>
    </td>
    <td style="text-align: left;" class="last-column">
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
  <td class="first-column">
    <c:if test="${configuration_deploy}">
      <img src="/img/rhn-listicon-ok.gif"/>
    </c:if>
  </td>
  <td style="text-align: left;" class="last-column">
    <bean:message key="kickstart.session_status.jsp.status_config" />
  </tr>
</tr>
<c:if test="${not failed}">
  <tr class="${nextstyle2}">
    <td class="first-column">
      <c:if test="${complete}">
        <img src="/img/rhn-listicon-ok.gif"/>
      </c:if>
    </td>
    <td style="text-align: left;" class="last-column">
      <bean:message key="kickstart.session_status.jsp.status_complete" />
    </tr>
  </tr>
</c:if>
<c:if test="${failed}">
  <tr class="${nextstyle1}">
    <td class="first-column">
        <img src="/img/rhn-listicon-error.gif"/>

    </td>
    <td style="text-align: left;" class="last-column">
      <bean:message key="kickstart.session_status.jsp.status_failed" />
    </tr>
  </tr>
</c:if>
</table>
<!-- END SIDE STATUS TABLE -->

    </td>
  </tr>
</table>
</div>
<form id="saveScrollPosition" method="POST" action="/rhn/systems/details/kickstart/SessionStatus.do?sid=${requestScope.sid}">
	<input id="scrollPosX" type="hidden" name="xPosition" value="${requestScope.scrollX}" />
	<input id="scrollPosY" type="hidden" name="yPosition" value="${requestScope.scrollY}" />
</form>

</body>
</html>
