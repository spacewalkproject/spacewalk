<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>

<html:xhtml/>
<html>
<body>
<%@ include file="/WEB-INF/pages/common/fragments/ssm/header.jspf" %>
<h2>
    <bean:message key="ssm.package.install.selectchannel.header"/>
</h2>

<div class="page-summary">
    <p><bean:message key="ssm.package.install.selectchannel.summary"/></p>
</div>

<rl:listset name="groupSet">

    <rl:list dataset="pageList"
             width="100%"
             name="groupList"
             styleclass="list"
             emptykey="channels.overview.nochannels">

        <rl:column headerkey="channels.overview.name" bound="false"
                   sortattr="name" sortable="true" styleclass="first-column last-column">
            <c:choose>
                <c:when test="${current.depth > 1}">
                    <img style="margin-left: 4px;"
                         src="/img/channel_child_node.gif"
                         alt="<bean:message key='channels.childchannel.alt' />"/>
                    <a href="/rhn/ssm/PackageList.do?cid=${current.id}">${current.name}</a>
                </c:when>
                <c:otherwise>
                    <a href="/rhn/ssm/PackageList.do?cid=${current.id}">${current.name}</a>
                </c:otherwise>
            </c:choose>

        </rl:column>

    </rl:list>

</rl:listset>

</body>
</html>
