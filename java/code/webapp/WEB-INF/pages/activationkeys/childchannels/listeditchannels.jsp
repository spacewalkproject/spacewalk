<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<html>
    <head>
        <meta name="name" value="activationkeys.jsp.header" />
    </head>
    <body>
        <%@ include file="/WEB-INF/pages/common/fragments/activationkeys/common-header.jspf" %>
        <html:form action="/activationkeys/channels/ChildChannels" styleClass="form-horizontal">
            <rhn:csrf />
            <p><bean:message key="activation-key.childchannels.jsp.summary"/></p>
            <c:if test='${not empty baseChannel}'>
                <p><bean:message key="activation-key.childchannels.jsp.blurb" arg0="${fn:escapeXml(baseChannel)}"/></p>
            </c:if>
            <div class="form-group">
                <div class="col-md-6">
                <table class="table">
                    <c:set var="first" scope="session" value="yes"/>
                    <c:set var="last_parent" scope="session" value=""/>
                    <c:forEach items="${channels}" var="channel" varStatus="loop">
                        <c:set var="first" scope="session" value="no"/>
                        <c:if test="${(channel.parent != last_parent || first == 'yes') && empty baseChannel}">
                            <tr>
                                <td><h4>${channel.parent}</h4></td>
                            </tr>
                        </c:if>
                        <tr class="${channel.s == 'selected' ? 'success' : ''}">
                            <td>
                                <label><input type="checkbox" name="childChannels" value="${channel.id}" ${channel.s == 'selected' ? 'checked' : ''}/> ${channel.name}</label>
                            </td>
                        </tr>
                        <c:set var="last_parent" scope="session" value="${channel.parent}"/>
                    </c:forEach>
                </table>
                </div>
            </div>
            <div class="form-group text-right">
                <div class="col-md-6">
                    <rhn:submitted/>
                    <input type="submit" name ="dispatch" class="btn btn-success"
                           value='<bean:message key="keyedit.jsp.submit"/>'/>
                </div>
            </div>
            <html:hidden property="submitted" value="true" />
            <c:if test='${not empty param.tid}'>
                <html:hidden property="tid" value="${param.tid}" />
            </c:if>
        </html:form>
    </body>
</html>
