<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>

<html:xhtml/>
<html>
<body>

<%@ include file="/WEB-INF/pages/common/fragments/scheduledactions/action-header.jspf" %>

<h2><bean:message key="failedsystems.jsp.failedsystems"/></h2>

    <div class="page-summary">
      <p><bean:message key="failedsystems.jsp.summary"/></p>
    </div>


<form method="POST" name="rhn_list" action="/rhn/schedule/FailedSystemsSubmit.do">

<rhn:list pageList="${requestScope.pageList}"
          noDataText="failedsystems.jsp.nosystems">
	  <rhn:listdisplay button="failedsystems.jsp.rescheduleactions"
	                   buttonsAttr="canEdit:true">
    <rhn:column header="actions.jsp.system"
                url="/network/systems/details/history/event.pxt?sid=${current.id}&hid=${action.id}">
        ${current.serverName}
    </rhn:column>

    <rhn:column header="failedsystems.jsp.failed">
        ${current.displayDate}
    </rhn:column>

    <rhn:column header="failedsystems.jsp.message">
        ${current.message}
    </rhn:column>
  </rhn:listdisplay>

  <input type="hidden" name="aid" value="${action.id}" />
  <input type="hidden" name="formvars" value="aid" />

</rhn:list>
	
</form>
</body>
</html>
