<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>

<html:xhtml/>
<html>
<body>
<%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>

<rhn:toolbar base="h2" img="/img/rhn-icon-packages.gif"
    deletionUrl="/rhn/systems/details/packages/profiles/DeleteProfile.do?sid=${param.sid}&prid=${param.prid}"
    deletionType="profile">
  <bean:message key="compare.jsp.compareto" arg0="${requestScope.profilename}" />
</rhn:toolbar>

    <div class="page-summary">
    <bean:message key="compare.jsp.pagesummary" />
    </div>

    <rl:listset name="compareListSet">
    
	    <rl:list dataset="pageList"
            width="100%"        
            name="compareList"
            emptykey="compare.jsp.nodifferences">
            
            <rl:decorator name="SelectableDecorator"/>
            <rl:selectablecolumn value="${current.selectionKey}"
	 			selected="${current.selected}"
	 			disabled="${not current.selectable}"
	 			styleclass="first-column"/>

            <rl:column headerkey="compare.jsp.package" bound="false" filterattr="name">
                ${current.name}
            </rl:column>

            <rl:column headerkey="packagelist.jsp.packagearch" bound="false">
                ${current.arch}
            </rl:column>
            
            <rl:column headerkey="compare.jsp.thissystem" bound="false">
                ${current.system.evr}
            </rl:column>
            
            <rl:column headertext="${requestScope.profilename}" bound="false">
                ${current.other.evr}
            </rl:column>
                        
            <rl:column headerkey="compare.jsp.difference" bound="false">
                ${current.comparison}
            </rl:column>
        </rl:list>

        <c:if test="${not empty requestScope.pageList}">
            <rhn:require acl="system_feature(ftr_delta_action)"
                mixins="com.redhat.rhn.common.security.acl.SystemAclHandler">
                <div align="right">
                    <rhn:submitted/>
                    <hr />
                    <input type="submit" name="dispatch" 
                        value="<bean:message key="compare.jsp.syncpackageto" arg0="${requestScope.profilename}"/>" /> 
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
        </c:if>

        <html:hidden property="sid" value="${param.sid}" />
        <html:hidden property="prid" value="${param.prid}" />
    </rl:listset>
</body>
</html>
