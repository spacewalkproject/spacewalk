<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>

<html:html>
    <body>
        <c:choose>
            <c:when test="${empty dcm}">
                <rhn:toolbar base="h1" img="/img/rhn-icon-subscribe_replace.png" imgAlt="info.alt.img">
                    <bean:message key="distchannelmap.jsp.create"/>
                </rhn:toolbar>
                <h2><bean:message key="distchannelmap.jsp.create"/></h2>
            </c:when>
            <c:otherwise>
                <rhn:toolbar base="h1" img="/img/rhn-icon-subscribe_replace.png" imgAlt="info.alt.img"
                             deletionUrl="DistChannelMapDelete.do?dcm=${dcm}"
                             deletionType="distchannelmap">
                    <bean:message key="distchannelmap.jsp.update"/>
                </rhn:toolbar>
                <h2><bean:message key="distchannelmap.jsp.update"/></h2>
            </c:otherwise>
        </c:choose>
        <div class="page-summary">
            <p><bean:message key="distchannelmap.jsp.edit.summary"/></p>
        </div>
        <html:form action="/channels/manage/DistChannelMapEdit"
                   styleClass="form-horizontal">
            <rhn:csrf />
            <rhn:submitted/>
            <div class="form-group">
                <label for="os" class="col-lg-3 control-label">
                    <rhn:required-field key = "Operating System"/>
                </label>
                <div class="col-lg-6">
                    <html:text property="os" styleId="os" styleClass="form-control" />
                </div>
            </div>
            <div class="form-group">
                <label for="release" class="col-lg-3 control-label">
                    <rhn:required-field key = "column.release"/>
                </label>
                <div class="col-lg-6">
                    <c:choose>
                        <c:when test="${empty dcm}">
                                <html:text property="release" styleId="release"
                                           styleClass="form-control"
                                           disabled="${not empty dcm}"/>
                        </c:when>
                        <c:otherwise>
                            <input class="form-control" type="text" disabled value="<c:out value="${release}"/>" />
                            <html:hidden property="release" value="${release}"/>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
            <div class="form-group">
                <label class="col-lg-3 control-label">
                    <rhn:required-field key = "column.architecture"/>
                </label>
                <div class="col-lg-6">
                    <c:choose>
                        <c:when test="${empty dcm}">
                            <html:select property="architecture" styleClass="form-control">
                                <html:options collection="channelArches"
                                              property="value" labelProperty="label" />
                            </html:select>
                        </c:when>
                        <c:otherwise>
                            <div class="form-control">
                                <c:out value="${architecture}"/>
                            </div>
                                <html:hidden property="architecture" value="${architecture}"/>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
            <div class="form-group">
                <label class="col-lg-3 control-label">
                    <rhn:required-field key = "channel.edit.jsp.label"/>
                </label>
                <div class="col-lg-6">
                    <html:select property="channel_label" styleClass="form-control">
                        <html:options collection="channels"
                                      property="value" labelProperty="label" />
                    </html:select>
                </div>
            </div>
            <div class="form-group">
                <div class="col-lg-offset-3 col-lg-6">
                    <c:choose>
                        <c:when test="${empty dcm}">
                            <html:submit styleClass="btn btn-success">
                                <bean:message key="distchannelmap.jsp.create.submit"/>
                            </html:submit>
                        </c:when>
                        <c:otherwise>
                            <html:submit styleClass="btn btn-success">
                                <bean:message key="distchannelmap.jsp.update.submit"/>
                            </html:submit>
                        </c:otherwise>
                    </c:choose>
                </div>
                <html:hidden property="dcm" value="${dcm}" />
            </div>
        </html:form>
    </body>
</html:html>
