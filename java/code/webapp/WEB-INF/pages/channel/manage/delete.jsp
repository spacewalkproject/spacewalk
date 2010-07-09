<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>

<html>
<body>
<rhn:toolbar base="h1" img="/img/rhn-icon-channels.gif">
    <bean:message key="channel.delete.jsp.toolbar" arg0="${channel.name}"/>
</rhn:toolbar>

<rhn:dialogmenu mindepth="0" maxdepth="1"
                definition="/WEB-INF/nav/manage_channel.xml"
                renderer="com.redhat.rhn.frontend.nav.DialognavRenderer"/>

<div>
    <html:form action="/channels/manage/Delete">

        <!--
            Channel Details
        -->

        <h2><bean:message key="channel.delete.jsp.channelheader"/></h2>

        <div class="page-summary">
            <p><bean:message key="channel.delete.jsp.introparagraph"/></p>
        </div>

        <table class="details">
            <!-- Channel Name -->
            <tr>
                <th nowrap="nowrap">
                    <bean:message key="channel.edit.jsp.name"/>:
                </th>
                <td class="small-form">
                    <strong><c:out value="${channel.name}"/></strong> (<c:out value="${channel.label}"/>)
                </td>
            </tr>

            <!-- Parent Channel -->
            <tr>
                <th nowrap="nowrap">
                    <bean:message key="channel.edit.jsp.parent"/>:
                </th>
                <td class="small-form">
                    <c:choose>
                        <c:when test="${channel.parentChannel eq null}">
                            <span class="no-details"><bean:message key="none.message"/></span>
                        </c:when>
                        <c:otherwise>
                            <c:out value="${channel.parentChannel.name}"/>
                        </c:otherwise>
                    </c:choose>
                </td>
            </tr>

            <!-- Architecture -->
            <tr>
                <th nowrap="nowrap">
                    <bean:message key="channel.delete.jsp.arch"/>
                </th>
                <td class="small-form">
                    <c:out value="${channel.channelArch.name}"/>
                </td>
            </tr>

            <!-- Total Packages -->
            <tr>
                <th nowrap="nowrap">
                    <bean:message key="channel.delete.jsp.totalpackages"/>
                </th>
                <td class="small-form">
                    <c:out value="${channel.packageCount}"/>
                </td>
            </tr>

            <!-- Subscribed Systems -->
            <tr>
                <th nowrap="nowrap">
                    <bean:message key="channel.delete.jsp.systemssubscribed"/>
                </th>
                <td class="small-form">
                    <c:out value="${subscribedSystemsCount}"/>
                </td>
            </tr>

            <!-- Summary -->
            <tr>
                <th nowrap="nowrap">
                    <bean:message key="channel.edit.jsp.summary"/>:
                </th>
                <td class="small-form">
                    <c:out value="${channel.summary}"/>
                </td>
            </tr>

            <!-- Description -->
            <tr>
                <th nowrap="nowrap">
                    <bean:message key="channel.edit.jsp.description"/>:
                </th>
                <td class="small-form">
                    <c:choose>
                        <c:when test="${channel.description eq null}">
                            <span class="no-details"><bean:message key="none.message"/></span>
                        </c:when>
                        <c:otherwise>
                            <c:out value="${channel.description}"/>
                        </c:otherwise>
                    </c:choose>
                </td>
            </tr>

        </table>

        <!--
            Trusted Organizations
        -->

        <h2><bean:message key="channel.delete.jsp.orgsheader"/></h2>

        <div class="page-summary">
            <p><bean:message key="channel.delete.jsp.orgsparagraph" arg0="<strong>${channel.name}</strong>"/></p>
        </div>

        <table class="details">

            <!-- Organizations Affected -->
            <tr>
                <th nowrap="nowrap">
                    <bean:message key="channel.delete.jsp.orgsaffected"/>
                </th>
                <td class="small-form">
                    <c:out value="${channel.trustedOrgsCount}"/>
                </td>
            </tr>

            <!-- Trusted Systems Affected -->
            <tr>
                <th nowrap="nowrap">
                    <bean:message key="channel.delete.jsp.systemssubscribed"/>
                </th>
                <td class="small-form">
                    <c:out value="${trustedSystemsCount}"/>
                </td>
            </tr>

        </table>

        <!--
            Unsubscribe Option
        -->

        <h2><bean:message key="channel.delete.jsp.unsubheader"/></h2>

        <div class="page-summary">
            <p><bean:message key="channel.delete.jsp.unsubparagraph" arg0="<strong>${channel.name}</strong>"/></p>
        </div>

        <table class="details">

            <!-- Unsubscribe option -->
            <tr>
                <th nowrap="nowrap">
                    <bean:message key="channel.delete.jsp.unsubheader"/>:
                </th>
                <td class="small-form">
                    <input type="checkbox" name="unsubscribeSystems"/>
                </td>
            </tr>

        </table>

        <div align="right">
            <hr/>
	<c:choose>
	<c:when test="${empty requestScope.disableDelete}">
            <html:submit property="delete_button">
                <bean:message key="channel.delete.jsp.channelheader"/>
            </html:submit>
	</c:when>
	<c:otherwise>
            <html:submit property="delete_button" disabled="true">
                <bean:message key="channel.delete.jsp.channelheader"/>
            </html:submit>	
	</c:otherwise>
	</c:choose>

        </div>
        <html:hidden property="submitted" value="true"/>
        <c:if test='${not empty param.cid}'>
            <html:hidden property="cid" value="${param.cid}"/>
        </c:if>
    </html:form>
</div>

</body>
</html>

