<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>

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
                <bean:message key="activation-key.childchannels.jsp.blurb" arg0="${baseChannel}"/>
            </c:if>
            <div class="form-group">
                <div class="col-lg-offset-3 col-lg-6">
                <select multiple="multiple" name="childChannels" size="20" styleClass="form-control">
                    <c:set var="first" scope="session" value="yes"/>
                    <c:forEach items="${channels}" var="channel" varStatus="loop">
                        <c:choose>
                            <c:when test="${first == 'yes'}">
                                <c:set var="first" scope="session" value="no"/>
                                <c:set var="last_parent" scope="session" value="${channel.parent}"/>
                                <c:if test="${empty baseChannel}">
                                    <optgroup label="${channel.parent}">
                                </c:if>
                            </c:when>
                            <c:otherwise>
                                <c:if test="${(channel.parent != last_parent) && empty baseChannel}">
                                    </optgroup>
                                    <optgroup label="${channel.parent}">
                                </c:if>
                            </c:otherwise>
                        </c:choose>
                        <option value="${channel.id}" ${channel.s}>${channel.name}</option>
                        <c:set var="last_parent" scope="session" value="${channel.parent}"/>
                    </c:forEach>
                    <c:if test="${empty baseChannel}">
                        </optgroup>
                    </c:if>
                </select>
                </div>
            </div>
            <div class="form-group">
                <div class="col-lg-offset-3 col-lg-6">
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
