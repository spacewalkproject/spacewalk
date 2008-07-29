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
      <img src="/img/rhn-icon-packages.gif" />
      <bean:message key="installconfirm.jsp.header" />
    </h2>
    <rhn:systemtimemessage server="${system}" />

    <html:form method="POST" action="/systems/details/packages/InstallConfirmSubmit.do?sid=${system.id}">
       <rhn:list pageList="${requestScope.pageList}" noDataText="packagelist.jsp.nopackages">
       <rhn:listdisplay filterBy="packagelist.jsp.packagename">
          <rhn:column header="packagelist.jsp.packagename" width="95%"
                url="/rhn/software/packages/Details.do?sid=${param.sid}&id_combo=${current.idCombo}">
            ${current.nvre}
          </rhn:column>
      </rhn:listdisplay>
      </rhn:list>
          
      <div align="right">
        <rhn:require mixins="com.redhat.rhn.common.security.acl.SystemAclHandler" acl="system_feature(ftr_remote_command); client_capable(script.run)">
          <hr />
          <html:submit property="dispatch">
          <bean:message key="installconfirm.jsp.runremotecommand"/>
          </html:submit>
        </rhn:require>
      
        <div align="left"> 
          <p><bean:message key="installconfirm.jsp.widgetsummary"/></p>
        </div>
        
        <table class="schedule-action-interface" align="center">
          <tr>
            <td><html:radio property="use_date" value="false" /></td>
            <th><bean:message key="confirm.jsp.now"/></th>
          </tr>
          <tr>
            <td><html:radio property="use_date" value="true" /></td>
            <th><bean:message key="confirm.jsp.than"/></th>
          </tr>
          <tr>
            <th><img src="/img/rhn-icon-schedule.gif" alt="<bean:message key="confirm.jsp.selection"/>"
                                                    title="<bean:message key="confirm.jsp.selection"/>"/>
            </th>
            <td>
              <jsp:include page="/WEB-INF/pages/common/fragments/date-picker.jsp">
                <jsp:param name="widget" value="date"/>
              </jsp:include>
            </td>
          </tr>
        </table>
      
        <hr />    
        <html:submit property="dispatch">
          <bean:message key="installconfirm.jsp.confirm"/>
        </html:submit>
      </div>
      
    <input type="hidden" name="sid" value="${param.sid}" />

    </html:form>
    
</body>
</html>
