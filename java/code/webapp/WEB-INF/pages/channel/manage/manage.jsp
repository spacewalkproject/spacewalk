<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>

<html>
<body>
<rhn:toolbar base="h1" icon="header-channel"
             imgAlt="channels.overview.toolbar.imgAlt"
             creationUrl="/rhn/channels/manage/Edit.do"
             creationType="channel"
             creationAcl="user_role(channel_admin)"
             cloneUrl="/rhn/channels/manage/Clone.do"
             cloneType="channel"
             cloneAcl="user_role(channel_admin)"
             helpUrl=""
        >
    <bean:message key="channels.manage.jsp.toolbar"/>
</rhn:toolbar>

<p><bean:message key="channels.manage.jsp.header1"/></p>
<p><bean:message key="channels.manage.jsp.header2"/></p>

<rl:listset name="groupSet">
    <rhn:csrf />
    <rhn:submitted />

    <rl:list emptykey="channels.overview.nochannels">

        <rl:decorator name="PageSizeDecorator"/>

        <rl:column
                   headerkey="channel.edit.jsp.name"
                   filterattr="name">
            <c:choose>
                <c:when test="${current.depth > 1}">
                    <img style="margin-left: 4px;"
                         src="/img/channel_child_node.gif"
                         alt="<bean:message
                         key='channels.childchannel.alt' />"/>
                    <c:if test="${current.orgId != null}">
                    <html:link href="/rhn/channels/manage/Edit.do?cid=${current.id}">
                        ${current.name}
                    </html:link>
                    </c:if>
                    <c:if test="${current.orgId eq null}">
                        ${current.name}
                    </c:if>
                </c:when>
                <c:otherwise>
                    <c:if test="${current.orgId != null}">
                    <html:link href="/rhn/channels/manage/Edit.do?cid=${current.id}">
                        ${current.name}
                    </html:link>
                    </c:if>
                    <c:if test="${current.orgId eq null}">
                        ${current.name}
                    </c:if>

                </c:otherwise>
            </c:choose>
        </rl:column>

        <rl:column
                   headerkey="channels.overview.packages">
            <c:if test="${current.orgId != null}">
            <html:link href="/rhn/channels/manage/ChannelPackages.do?cid=${current.id}">
                ${current.packageCount}
            </html:link>
            </c:if>
            <c:if test="${current.orgId eq null}">
                ${current.packageCount}
            </c:if>

        </rl:column>


    </rl:list>
</rl:listset>


</body>
</html>
