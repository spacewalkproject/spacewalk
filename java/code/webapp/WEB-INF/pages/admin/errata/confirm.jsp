<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>


<html>
<head>
    <meta name="name" value="Systems Affected" />
</head>
<body>

<%@ include file="/WEB-INF/pages/common/fragments/errata/errata-header.jspf" %>
<h2><bean:message key="confirm.jsp.header"/> ${errata.advisoryName}</h2>

  <div class="page-summary">
    <p>
    <bean:message key="confirm.jsp.summary" arg0="${errata.advisoryName}" />
    </p>
  </div>

<c:set var="pageList" value="${requestScope.pageList}" />
<html:form method="POST" action="errata/details/ErrataConfirmSubmit.do">
<rhn:csrf />
<rhn:list pageList="${requestScope.pageList}" noDataText="nosystems.message">
  <rhn:listdisplay>
    <rhn:column header="actions.jsp.system">
	  ${current.name}
    </rhn:column>
    <rhn:column header="actions.jsp.basechannel">
      ${current.channelLabels}
    </rhn:column>
  </rhn:listdisplay>



<p><bean:message key="applyerrata.disclaimer" /></p>

<table class="schedule-action-interface" align="center">
  <tr>
    <td><html:radio property="use_date" value="false" /></td>
    <th><bean:message key="syncprofile.jsp.now"/></th>
  </tr>
  <tr>
    <td><html:radio property="use_date" value="true" /></td>
    <th><bean:message key="syncprofile.jsp.than"/></th>
  </tr>
  <tr>
    <th><img src="/img/rhn-icon-schedule.gif" alt="<bean:message key="syncprofile.jsp.selection"/>"
             title="<bean:message key="syncprofile.jsp.selection"/>"/>
    </th>
    <td>
      <jsp:include page="/WEB-INF/pages/common/fragments/date-picker.jsp">
        <jsp:param name="widget" value="date"/>
      </jsp:include>
    </td>
  </tr>
</table>

<div class="text-right">
  <hr />
  <html:submit property="dispatch">
    <bean:message key="confirm.jsp.confirm"/>
  </html:submit>
</div>

<html:hidden property="eid" value="${param.eid}"/>

</rhn:list>
</html:form>

</body>
</html>
