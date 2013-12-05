<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>


<html>
<body>

  <%@ include file="/WEB-INF/pages/common/fragments/scheduledactions/action-header.jspf" %>

  <h2><bean:message key="failedsystems.jsp.failedsystems"/></h2>

  <p><bean:message key="failedsystems.jsp.summary"/></p>

  <form method="POST" role="form" name="rhn_list" action="/rhn/schedule/FailedSystemsSubmit.do">
    <rhn:csrf />

    <rhn:list pageList="${requestScope.pageList}"
              noDataText="failedsystems.jsp.nosystems">
    	  <rhn:listdisplay button="failedsystems.jsp.rescheduleactions"
    	                   buttonsAttr="canEdit:true">
        <rhn:column header="actions.jsp.system"
                    url="/network/systems/details/history/event.pxt?sid=${current.id}&hid=${action.id}">
            <c:out value="${current.serverName}" escapeXml="true" />
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
