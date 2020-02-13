<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>

<html>
    <body>
        <rhn:toolbar base="h1" icon="header-channel">
            <bean:message key="channel.clone.header"/>
        </rhn:toolbar>

        <div class="page-summary">
            <p><bean:message key="channel.clone.summary"/></p>
            <ul>
                <li>
                    <p><bean:message key="channel.clone.current"/></p>
                    <p><bean:message key="channel.clone.current.summary"/></p>
                </li>
                <li>
                    <p><bean:message key="channel.clone.original"/></p>
                    <p><bean:message key="channel.clone.original.summary"/></p>
                </li>
                <li>
                    <p><bean:message key="channel.clone.select"/></p>
                    <p><bean:message key="channel.clone.select.summary"/></p>
                </li>
            </ul>
        </div>

        <html:form action="/channels/manage/Clone" styleClass="form-horizontal">
            <rhn:csrf />
            <rhn:submitted />
            <c:choose>
                <c:when test="${not empty channels}">
                    <div class="form-group">
                        <label for="original_id" class="col-lg-3 control-label">
                            <bean:message key="channel.clone.clonefrom"/>:
                        </label>
                        <div class="col-lg-6">
                            <html:select property="original_id"
                                         styleClass="form-control">
                                <html:options collection="channels"
                                              property="value"
                                              filter="false"
                                              labelProperty="label" />
                            </html:select>
                        </div>
                    </div>
                    <div class="form-group">
                        <label for="clone_type" class="col-lg-3 control-label">
                            <bean:message key="channel.clone.clone"/>:
                        </label>
                        <div class="col-lg-6">
                            <div class="radio">
                                <label>
                                    <html:radio property="clone_type" value="current" />
                                    <bean:message key="channel.clone.current"/>
                                </label>
                            </div>
                            <div class="radio">
                                <label>
                                    <html:radio property="clone_type" value="original" />
                                    <bean:message key="channel.clone.original"/>
                                </label>
                            </div>
                            <div class="radio">
                                <label>
                                    <html:radio property="clone_type" value="select" />
                                    <bean:message key="channel.clone.select"/>
                                </label>
                            </div>
                        </div>
                    </div>
                    <div class="text-right">
                        <html:submit property="button" styleClass="btn btn-success">
                            <bean:message key="channel.clone.button"/>
                        </html:submit>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="alert alert-warning">
                        <bean:message key="channel.clone.noavailable"/>
                    </div>
                </c:otherwise>
            </c:choose>
        </html:form>
    </body>
</html>

