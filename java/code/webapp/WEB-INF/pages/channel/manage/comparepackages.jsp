<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>


<html>
<head>
    <!-- disables the enter key from submitting the form -->
    <script type="text/javascript" language="JavaScript">
        $(document).ready(disableEnterKey);
    </script>
</head>
<body>
<%@ include file="/WEB-INF/pages/common/fragments/channel/manage/manage_channel_header.jspf" %>
    <br />

    <rl:listset name="packageSet">
    <rhn:csrf />
    <input type="hidden" name="cid" value="${cid}">
    <bean:message key="channel.jsp.package.comparemessage" />
    <h2>
        <rhn:icon type="header-package" />
        <bean:message key="channel.jsp.package.comparetitle" />
    </h2>

    <jsp:include page="/WEB-INF/pages/common/fragments/channel/manage/channel_selector.jspf">
        <jsp:param name="title" value="channel.jsp.package.compareto" />
        <jsp:param name="option_no_packages" value="true" />
        <jsp:param name="option_all_packages" value="false" />
        <jsp:param name="option_orphan_packages" value="false" />
    </jsp:include>

    <rl:list dataset="pageList" name="packageList"
             emptykey="channel.jsp.package.addemptylist" alphabarcolumn="package_name"
             filter="com.redhat.rhn.frontend.taglibs.list.filters.PackageNameFilter">
        <rl:decorator name="ElaborationDecorator" />
        <rl:decorator name="PageSizeDecorator" />

        <rl:column sortable="true" bound="false" headerkey="packagelist.jsp.packagename"
                   sortattr="package_name" defaultsort="asc">
            ${current.package_name}
        </rl:column>

        <rl:column headerkey="packagelist.jsp.packagearch" bound="false">
            ${current.arch}
        </rl:column>

        <rl:column sortable="false" bound="false" headerkey="packagelist.jsp.thischannel">
            <c:if test="${not empty current.left_id}">
                <a href="/rhn/software/packages/Details.do?pid=${current.left_id}">${current.left_nvrea}</a>
            </c:if>
        </rl:column>

        <rl:column sortable="false" bound="false" headertext="${other_channel}">
            <c:if test="${not empty current.right_id}">
                <a href="/rhn/software/packages/Details.do?pid=${current.right_id}">${current.right_nvrea}</a>
            </c:if>
        </rl:column>

        <rl:column sortable="false" bound="false" headerkey="compare.jsp.difference" sortattr="comparison">
            <c:choose>
                <c:when test="${current.comparison == 2}">
                    <bean:message key="channel.jsp.package.thisonly" />
                </c:when>
                <c:when test="${current.comparison == 1}">
                    <bean:message key="channel.jsp.package.thisnewer" />
                </c:when>
                <c:when test="${current.comparison == -1}">
                    <bean:message key="channel.jsp.package.othernewer" arg0="${other_channel}" />
                </c:when>
                <c:when test="${current.comparison == -2}">
                    <bean:message key="channel.jsp.package.otheronly" arg0="${other_channel}" />
                </c:when>
            </c:choose>
        </rl:column>

    </rl:list>

    <div class="form-group">
        <label class="col-lg-3 control-label">
            <bean:message key="channel.jsp.package.synclabel" />
        </label>
        <div class="col-lg-6">
            <div class="radio">
                <label>
                    <input type="radio" name="sync_type" value="full" ${empty sync_type || sync_type == "full" ? ' checked="1"' : ''}  />
                    <bean:message key="channel.jsp.package.full_sync_descr" arg0="<strong>${channel_name}</strong>" />
                </label>
            </div>
            <div class="radio">
                <label>
                    <input type="radio" name="sync_type" value="add" ${sync_type == "add" ? ' checked="1"' : ''} />
                    <bean:message key="channel.jsp.package.add_only_descr" arg0="<strong>${channel_name}</strong>" />
                </label>
            </div>
            <div class="radio">
                <label>
                    <input type="radio" name="sync_type" value="remove" ${sync_type == "remove" ? ' checked="1"' : ''}/>
                    <bean:message key="channel.jsp.package.remove_only_descr" arg0="<strong>${channel_name}</strong>" />
                </label>
            </div>
        </div>
    </div>

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
