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

<h2><img src="/img/rhn-icon-packages.gif" />
<bean:message key="compare.jsp.compareto" arg0="${requestScope.systemname}" />
</h2>

<form method="POST" name="rhn_list" action="/rhn/systems/details/packages/profiles/CompareSystemsSubmit.do">
    <div class="page-summary">
    <bean:message key="systemcompare.jsp.pagesummary" />
    </div>

    <rhn:list pageList="${requestScope.pageList}" noDataText="compare.jsp.nodifferences">
      <rhn:listdisplay filterBy="compare.jsp.package" set="${requestScope.set}" hiddenvars="${requestScope.newset}">
         <rhn:set value="${current.nameId}" />
         <rhn:column header="compare.jsp.package">
             ${current.name}
         </rhn:column>
         <rhn:column header="compare.jsp.thissystem">
             ${current.system.evra}
         </rhn:column>
         <rhn:column header="dynamic" arg0="${requestScope.systemname}">
             ${current.other.evra}
         </rhn:column>
         <rhn:column header="compare.jsp.difference">
             ${current.comparison}
         </rhn:column>
      </rhn:listdisplay>
      <rhn:require acl="system_feature(ftr_delta_action)"
                   mixins="com.redhat.rhn.common.security.acl.SystemAclHandler">
        <div align="right">
          <hr />
          <html:submit property="dispatch">
            <bean:message key="compare.jsp.syncpackageto" arg0="${requestScope.systemname}"/>
          </html:submit>
        </div>
      </rhn:require>
      <rhn:require acl="not system_feature(ftr_delta_action)"
                   mixins="com.redhat.rhn.common.security.acl.SystemAclHandler">
        <div align="left">
          <hr />
            <strong><bean:message key="compare.jsp.noprovisioning" 
                arg0="${system.name}" arg1="${param.sid}"/></strong>
        </div>
      </rhn:require>
      
      <html:hidden property="sid" value="${param.sid}" />
      <html:hidden property="sid_1" value="${param.sid_1}" />
    </rhn:list>
</form>
</body>
</html>
