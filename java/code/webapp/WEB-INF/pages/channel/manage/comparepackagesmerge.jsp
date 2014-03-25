<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>


<html>
<head>
</head>
<body>
<%@ include file="/WEB-INF/pages/common/fragments/channel/manage/manage_channel_header.jspf" %>
    <br />

    <rl:listset name="packageSet">
    <rhn:csrf />
    <input type="hidden" name="cid" value="${cid}">
    <input type="hidden" name="other_id" value="${other_id}">
    <input type="hidden" name="sync_type" value="${sync_type}">
    <p><bean:message key="channel.jsp.package.comparemergemessage1" arg0="<strong>${channel_name}</strong>"/></p>
    <p><bean:message key="channel.jsp.package.comparemergemessage2" /></p>
    <h2>
        <rhn:icon type="header-channel" />
        <bean:message key="channel.jsp.package.syncchannels" />
    </h2>

    <rl:list dataset="pageList" name="packageList"
             decorator="SelectableDecorator"
             emptykey="channel.jsp.package.addemptylist" alphabarcolumn="nvrea"
             filter="com.redhat.rhn.frontend.taglibs.list.filters.PackageFilter">
        <rl:decorator name="ElaborationDecorator" />
        <rl:decorator name="PageSizeDecorator" />


        <rl:selectablecolumn value="${current.selectionKey}"
                             selected="${current.selected}"/>

        <rl:column sortable="true" bound="false" headerkey="download.jsp.package"
                   sortattr="nvrea" defaultsort="asc">
            <a href="/rhn/software/packages/Details.do?pid=${current.id}">${current.nvrea}</a>
        </rl:column>

        <rl:column sortable="false" bound="false" headerkey="channel.jsp.package.action" sortattr="action">
            <c:choose>
                <c:when test="${current.action == 1}">
                    <bean:message key="channel.jsp.package.actionadd" />
                </c:when>
                <c:when test="${current.action == -1}">
                    <bean:message key="channel.jsp.package.actionremove" />
                </c:when>
            </c:choose>
        </rl:column>

    </rl:list>

    <div class="form-group">
        <div class="col-lg-offset-3 col-lg-6">
            <html:submit property="dispatch" styleClass="btn btn-success" disabled="${empty pageList}">
                <bean:message key="channel.jsp.package.mergebutton" />
            </html:submit>
        </div>
    </div>
    <rhn:submitted />
</rl:listset>
</body>
</html>
