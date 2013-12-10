<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>

<html>
    <body>
        <rhn:toolbar base="h1" icon="header-channel">
            <bean:message key="channel.delete.jsp.toolbar" arg0="${channel.name}"/>
        </rhn:toolbar>
        <rhn:dialogmenu mindepth="0" maxdepth="1"
                        definition="/WEB-INF/nav/manage_channel.xml"
                        renderer="com.redhat.rhn.frontend.nav.DialognavRenderer"/>
            <html:form action="/channels/manage/Delete" styleClass="form-horizontal">
                <rhn:csrf />
                <h2><bean:message key="channel.delete.jsp.channelheader"/></h2>
                <p><bean:message key="channel.delete.jsp.introparagraph"/></p>

                <div class="form-group">
                    <label class="col-lg-3 control-label">
                        <bean:message key="channel.edit.jsp.name"/>:
                    </label>
                    <div class="col-lg-6">
                        <div class="well well-sm">
                            <strong><c:out value="${channel.name}"/></strong> (<c:out value="${channel.label}"/>)
                        </div>
                    </div>
                </div>
                <div class="form-group">
                    <label class="col-lg-3 control-label">
                        <bean:message key="channel.edit.jsp.parent"/>:
                    </label>
                    <div class="col-lg-6">
                            <c:choose>
                                <c:when test="${channel.parentChannel eq null}">
                                    <span class="no-details"><bean:message key="none.message"/></span>
                                </c:when>
                                <c:otherwise>
                                    <c:out value="${channel.parentChannel.name}"/>
                                </c:otherwise>
                            </c:choose>
                    </div>
                </div>

                <!-- Architecture -->
                <div class="form-group">
                    <label class="col-lg-3 control-label">
                        <bean:message key="channel.delete.jsp.arch"/>
                    </label>
                    <div class="col-lg-6">
                        <div class="well well-sm">
                            <c:out value="${channel.channelArch.name}"/>
                        </div>
                    </div>
                </div>

                <!-- Total Packages -->
                <div class="form-group">
                    <label class="col-lg-3 control-label">
                        <bean:message key="channel.delete.jsp.totalpackages"/>
                    </label>
                    <div class="col-lg-6">
                        <div class="well well-sm">
                            <c:out value="${channel.packageCount}"/>
                        </div>
                    </div>
                </div>

                <!-- Subscribed Systems -->
                <div class="form-group">
                    <label class="col-lg-3 control-label">
                        <bean:message key="channel.delete.jsp.systemssubscribed"/>
                    </label>
                    <div class="col-lg-6">
                        <div class="well well-sm">
                            <c:out value="${subscribedSystemsCount}"/>
                        </div>
                    </div>
                </div>

                <!-- Summary -->
                <div class="form-group">
                    <label class="col-lg-3 control-label">
                        <bean:message key="channel.edit.jsp.summary"/>:
                    </label>
                    <div class="col-lg-6">
                        <div class="well well-sm">
                            <c:out value="${channel.summary}"/>
                        </div>
                    </div>
                </div>

                <!-- Description -->
                <div class="form-group">
                    <label class="col-lg-3 control-label">
                        <bean:message key="channel.edit.jsp.description"/>:
                    </label>
                    <div class="col-lg-6">
                        <div class="well well-sm">
                        <c:choose>
                            <c:when test="${channel.description eq null}">
                                <span class="no-details"><bean:message key="none.message"/></span>
                            </c:when>
                            <c:otherwise>
                                <c:out value="${channel.description}"/>
                            </c:otherwise>
                        </c:choose>
                        </div>
                    </div>
                </div>

                <!-- Trusted Organizations -->
                <h2><bean:message key="channel.delete.jsp.orgsheader"/></h2>
                <p><bean:message key="channel.delete.jsp.orgsparagraph" arg0="<strong>${channel.name}</strong>"/></p>

                    <!-- Organizations Affected -->
                <div class="form-group">
                    <label class="col-lg-3 control-label">
                        <bean:message key="channel.delete.jsp.orgsaffected"/>
                    </label>
                    <div class="col-lg-6">
                        <div class="well well-sm">
                            <c:out value="${channel.trustedOrgsCount}"/>
                        </div>
                    </div>
                </div>

                    <!-- Trusted Systems Affected -->
                <div class="form-group">
                    <label class="col-lg-3 control-label">
                        <bean:message key="channel.delete.jsp.systemssubscribed"/>
                    </label>
                    <div class="col-lg-6">
                        <div class="well well-sm">
                            <c:out value="${trustedSystemsCount}"/>
                        </div>
                    </div>
                </div>

                <!-- Unsubscribe Option -->
                <h2><bean:message key="channel.delete.jsp.unsubheader"/></h2>
                <p><bean:message key="channel.delete.jsp.unsubparagraph" arg0="<strong>${channel.name}</strong>"/></p>

                    <!-- Unsubscribe option -->
                <div class="form-group">
                    <div class="col-lg-offset-3 col-lg-6">
                        <div class="checkbox">
                            <label>
                                <input type="checkbox" name="unsubscribeSystems"/>
                                <bean:message key="channel.delete.jsp.unsubheader"/>
                            </label>
                        </div>
                    </div>
                </div>
                <div class="form-group">
                    <div class="col-lg-offset-3 col-lg-6">
                        <c:choose>
                            <c:when test="${empty requestScope.disableDelete}">
                                <html:submit property="delete_button" styleClass="btn btn-success">
                                    <bean:message key="channel.delete.jsp.channelheader"/>
                                </html:submit>
                            </c:when>
                            <c:otherwise>
                                <html:submit property="delete_button" disabled="true" styleClass="btn">
                                    <bean:message key="channel.delete.jsp.channelheader"/>
                                </html:submit>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
                <html:hidden property="submitted" value="true"/>
                <c:if test='${not empty param.cid}'>
                    <html:hidden property="cid" value="${param.cid}"/>
                </c:if>
            </html:form>
    </body>
</html>

