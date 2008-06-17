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
<bean:message key="schedulesync.jsp.profilesync" />
</h2>

<html:form method="POST" action="/systems/details/packages/profiles/SyncSystemsSubmit">
    <div class="page-summary">
        <bean:message key="schedulesync.jsp.pagesummary"
                      arg0="${requestScope.system.name}"
                      arg1="${requestScope.system1.name}" />
    </div>

    <rhn:list pageList="${requestScope.pageList}" noDataText="schedulesync.jsp.nopackagesselected">
      <rhn:listdisplay>
         <rhn:column header="schedulesync.jsp.package" width="30%">
             ${current.name}
         </rhn:column>
         <rhn:column header="schedulesync.jsp.action">
             ${current.actionStatus}
         </rhn:column>
      </rhn:listdisplay>
      
      <p><bean:message key="schedulesync.jsp.disclaimer" /></p>
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
      
      <rhn:require acl="system_feature(ftr_delta_action)"
                   mixins="com.redhat.rhn.common.security.acl.SystemAclHandler">
        <div align="right">
          <hr />
          <html:submit property="dispatch">
            <bean:message key="schedulesync.jsp.schedulesync" />
          </html:submit>
        </div>
      </rhn:require>

      <html:hidden property="sid" value="${param.sid}" />
      <html:hidden property="sid_1" value="${param.sid_1}" />
      <html:hidden property="set_label" value="packages_for_system_sync" />
    </rhn:list>
</html:form>
</body>
</html>
