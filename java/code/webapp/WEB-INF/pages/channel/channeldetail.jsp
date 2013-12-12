<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>


<html:html>
    <body>
        <%@ include file="/WEB-INF/pages/common/fragments/channel/channel_header.jspf" %>
        <html:form action="/channels/ChannelDetail" styleClass="form-horizontal">
        <rhn:csrf />
        <div class="panel panel-default">
            <div class="panel-heading">
                <h2><bean:message key="channel.edit.jsp.basicchanneldetails"/></h2>
            </div>
            <div class="panel-body">
                <div class="form-group">
                    <label class="col-lg-3 control-label">
                        <bean:message key="channel.edit.jsp.name"/>
                    </label>
                    <div class="col-lg-6">
                        <c:out value="${channel.name}" />
                    </div>
                </div>
                <div class="form-group">
                    <label class="col-lg-3 control-label">
                        <bean:message key="channel.edit.jsp.label"/>
                    </label>
                    <div class="col-lg-6">
                        <c:out value="${channel.label}"/>
                    </div>
                </div>
                <div class="form-group">
                    <label class="col-lg-3 control-label">
                        <bean:message key="channel.jsp.parentchannel"/>
                    </label>
                    <div class="col-lg-6">
                        <c:if test="${empty channel.parentChannel}">
                            (none)
                        </c:if>
                        <c:if test="${!empty channel.parentChannel}">
                            <a class="btn btn-info" href="/rhn/channels/ChannelDetail.do?cid=${channel.parentChannel.id}">
                                <c:out value="${channel.parentChannel.name}" /> <rhn:icon type="nav-right" />
                            </a>
                        </c:if>
                    </div>
                </div>
                <div class="form-group">
                    <label class="col-lg-3 control-label">
                        <bean:message key="channel.edit.jsp.checksum"/>
                    </label>
                    <div class="col-lg-6">
                        <c:if test="${empty channel.checksumType}">
                            (none)
                        </c:if>
                        <c:if test="${!empty channel.checksumType}">
                            <c:out value="${channel.checksumType}" />
                        </c:if>
                    </div>
                </div>
                <div class="form-group">
                    <label class="col-lg-3 control-label">
                        <bean:message key="packagelist.jsp.packagearch"/>
                    </label>
                    <div class="col-lg-6">
                        <c:out value="${channel.channelArch.name}" />
                    </div>
                </div>
                <div class="form-group">
                    <label class="col-lg-3 control-label">
                        <bean:message key="channel.jsp.summary"/>
                    </label>
                    <div class="col-lg-6">
                        <c:out value="${channel.summary}" />
                    </div>
                </div>
                <div class="form-group">
                    <label class="col-lg-3 control-label">
                        <bean:message key="details.jsp.description"/>
                    </label>
                    <div class="col-lg-6">
                        <c:if test="${empty channel.description}">
                            (none)
                        </c:if>
                        <c:if test="${!empty channel.description}">
                            <c:out value="${channel.description}" />
                        </c:if>
                    </div>
                </div>
                <div class="form-group">
                    <label class="col-lg-3 control-label">
                        <bean:message key="channel.jsp.chanent"/>
                    </label>
                    <div class="col-lg-6">
                        <c:out value="${channel.channelFamily.name}" />
                    </div>
                </div>
                <div class="form-group">
                    <label class="col-lg-3 control-label">
                        <bean:message key="channelfiles.jsp.lastmod"/>
                    </label>
                    <div class="col-lg-6">
                        <c:out value="${channel_last_modified}" />
                    </div>
                </div>
                <div class="form-group">
                    <label class="col-lg-3 control-label">
                        <bean:message key="channel.jsp.repolastbuild"/>
                    </label>
                    <div class="col-lg-6">
                        <c:choose>
                            <c:when test="${repo_last_build != null}">
                                <c:out value="${repo_last_build}" />
                            </c:when>
                            <c:otherwise>
                                (none)
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
                <div class="form-group">
                    <label class="col-lg-3 control-label">
                        <bean:message key="channel.jsp.repodata"/>
                    </label>
                    <div class="col-lg-6">
                        <c:choose>
                            <c:when test="${repo_status ==  null}">
                                (none)
                            </c:when>
                            <c:when test="${repo_status == true}">
                                <bean:message key="channel.jsp.repodata.inProgress"/>
                            </c:when>
                            <c:when test="${repo_status == false && repo_last_build != null}">
                                <bean:message key="channel.jsp.repodata.completed"/>
                            </c:when>
                            <c:otherwise>
                                (none)
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
                <div class="form-group">
                    <label class="col-lg-3 control-label">
                        <bean:message key="header.jsp.packages"/>
                    </label>
                    <div class="col-lg-6">
                        <a class="btn btn-info" href="/rhn/channels/ChannelPackages.do?cid=${channel.id}">
                            ${pack_size} <rhn:icon type="nav-right" />
                        </a>
                    </div>
                </div>
                <div class="form-group">
                    <label class="col-lg-3 control-label">
                        <bean:message key="channel.edit.jsp.perusersub"/>
                    </label>
                    <div class="col-lg-6">
                        <div class="checkbox">
                            <label>
                                <c:choose>
                                    <c:when test="${has_access}">
                                        <html:radio property="global" value="all" />
                                    </c:when>
                                    <c:otherwise>
                                        <html:radio property="global" value="all" disabled="true"/>
                                    </c:otherwise>
                                </c:choose>
                                <bean:message key="channel.edit.jsp.allusers"/>
                            </label>
                        </div>
                    </div>
                </div>
                <div class="form-group">
                    <div class="col-lg-offset-3 col-lg-6">
                        <div class="checkbox">
                            <label>
                                <c:choose>
                                    <c:when test="${has_access == true}">
                                        <html:radio property="global" value="selected" />
                                    </c:when>
                                    <c:otherwise>
                                        <html:radio property="global" value="selected" disabled="true"/>
                                    </c:otherwise>
                                </c:choose>
                                <bean:message key="channel.edit.jsp.selectedusers"/>
                            </label>
                        </div>
                    </div>
                </div>
                <div class="form-group">
                    <label class="col-lg-3 control-label">
                        <bean:message key="channel.jsp.systemssubsribed"/>
                    </label>
                    <div class="col-lg-6">
                        <a class="btn btn-info" href="/rhn/channels/ChannelSubscribers.do?cid=${channel.id}">
                            ${systems_subscribed} <rhn:icon type="nav-right" />
                        </a>
                    </div>
                </div>
            </div>
        </div>
        <div class="panel panel-default">
            <div class="panel-heading">
                <h2><bean:message key="channel.edit.jsp.contactsupportinfo"/></h2>
            </div>
            <div class="panel-body">
                <div class="form-group">
                    <label class="col-lg-3 control-label">
                            <bean:message key="channel.edit.jsp.maintainername"/>
                    </label>
                    <div class="col-lg-6">
                        <c:out value="${channel.maintainerName}" />
                    </div>
                </div>
                <div class="form-group">
                    <label class="col-lg-3 control-label">
                        <bean:message key="channel.edit.jsp.maintainercontactinfo"/>
                    </label>
                    <div class="col-lg-6">
                        <div class="input-group">
                            <span class="input-group-addon">
                                <bean:message key="channel.edit.jsp.emailaddress"/>
                            </span>
                            <div class="form-control">
                                <c:out value="${channel.maintainerEmail}" />
                            </div>
                        </div>
                    </div>
                </div>
                <div class="form-group">
                    <div class="col-lg-offset-3 col-lg-6">
                        <div class="input-group">
                            <span class="input-group-addon">
                                <bean:message key="channel.edit.jsp.phonenumber"/>
                            </span>
                            <div class="form-control">
                                <c:out value="${channel.maintainerPhone}" />
                            </div>
                        </div>
                    </div>
                </div>
                <div class="form-group">
                    <label class="col-lg-3 control-label">
                        <bean:message key="channel.edit.jsp.supportpolicy"/>
                    </label>
                    <div class="col-lg-6">
                        <c:out value="${channel.supportPolicy}" />
                    </div>
                </div>
            </div>
        </div>

        <div class="panel panel-default">
            <div class="panel-heading">
                <h2><bean:message key="channel.edit.jsp.security.gpg"/></h2>
            </div>
            <div class="panel-body">
                <div class="form-group">
                    <label class="col-lg-3 control-label">
                        <bean:message key="channel.edit.jsp.gpgkeyurl"/>
                    </label>
                    <div class="col-lg-6">
                        <c:choose>
                            <c:when test="${channel.GPGKeyUrl !=  null}">
                                <c:out value="${channel.GPGKeyUrl}" />
                            </c:when>
                            <c:otherwise>
                                (none entered)
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
                <div class="form-group">
                    <label class="col-lg-3 control-label">
                        <bean:message key="channel.edit.jsp.gpgkeyid"/>
                    </label>
                    <div class="col-lg-6">
                        <c:choose>
                            <c:when test="${channel.GPGKeyId !=  null}">
                                <c:out value="${channel.GPGKeyId}" />
                            </c:when>
                            <c:otherwise>
                                (none entered)
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
                <div class="form-group">
                    <label class="col-lg-3 control-label">
                        <bean:message key="channel.edit.jsp.gpgkeyfingerprint"/>
                    </label>
                    <div class="col-lg-6">
                        <c:choose>
                            <c:when test="${channel.GPGKeyFp !=  null}">
                                <c:out value="${channel.GPGKeyFp}" />
                            </c:when>
                            <c:otherwise>
                                (none entered)
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>
        </div>

        <c:if test="${has_access}">
            <div class="form-group">
                <div class="col-lg-offset-3 col-lg-6">
                    <html:submit property="Update" styleClass="btn btn-success">
                        <bean:message key="message.Update"/>
                    </html:submit>
                </div>
            </div>
        </c:if>
        <rhn:submitted/>
        <html:hidden property="cid" value="${channel.id}" />
        </html:form>
    </body>
</html:html>
