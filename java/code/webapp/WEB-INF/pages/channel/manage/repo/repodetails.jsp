<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>

<html:html>
    <body>
        <c:choose>
            <c:when test = "${not empty requestScope.create_mode}">
                <rhn:toolbar base="h1" icon="icon-info-sign" imgAlt="info.alt.img">
                    <bean:message key="repos.jsp.toolbar"/>
                </rhn:toolbar>
                <h2><bean:message key="repos.jsp.header2"/></h2>
            </c:when>
            <c:otherwise>
                <rhn:toolbar base="h1" icon="icon-info-sign" imgAlt="info.alt.img"
                             deletionUrl="RepoDelete.do?id=${requestScope.repo.id}"
                             deletionType="repos">
                    <c:out value="${requestScope.repo.label}"/>
                </rhn:toolbar>
                <h2><bean:message key="repos.jsp.details.header2"/></h2>
            </c:otherwise>
        </c:choose>
        <c:choose>
            <c:when test="${empty requestScope.create_mode}">
                <c:set var="url" value ="/channels/manage/repos/RepoEdit"/>
            </c:when>
            <c:otherwise>
                <c:set var="url" value ="/channels/manage/repos/RepoCreate"/>
            </c:otherwise>
        </c:choose>
        <html:form action="${url}" styleClass="form-horizontal">
            <rhn:csrf />
            <rhn:submitted/>
            <html:hidden property="id" value="${repo.id}"/>
            <div class="form-group">
                <label class="col-lg-3 control-label">
                    <rhn:required-field key = "repos.jsp.create.label"/>:
                </label>
                <div class="col-lg-6">
                    <html:text property="label" styleClass="form-control"/>
                    <c:if  test = "${empty requestScope.create_mode}">
                        <html:hidden property="sourceid"/>
                    </c:if>
                </div>
            </div>
            <div class="form-group">
                <label class="col-lg-3 control-label">
                    <rhn:required-field key = "repos.jsp.create.url"/>:
                </label>
                <div class="col-lg-6">
                    <html:text property="url" styleClass="form-control"/>
                </div>
            </div>
            <div class="form-group">
                <label class="col-lg-3 control-label">
                    <bean:message key = "repos.jsp.ssl.ca"/>:
                </label>
                <div class="col-lg-6">
                    <html:select property="sslcacert" styleClass="form-control">
                        <html:options collection="sslcryptokeys" labelProperty="label" property="value" />
                    </html:select>
                </div>
            </div>
            <div class="form-group">
                <label class="col-lg-3 control-label">
                    <bean:message key = "repos.jsp.ssl.clientcert"/>:
                </label>
                <div class="col-lg-6">
                    <html:select property="sslclientcert" styleClass="form-control">
                        <html:options collection="sslcryptokeys" labelProperty="label" property="value" />
                    </html:select>
                </div>
            </div>
            <div class="form-group">
                <label class="col-lg-3 control-label">
                    <bean:message key = "repos.jsp.ssl.clientkey"/>:
                </label>
                <div class="col-lg-6">
                    <html:select property="sslclientkey" styleClass="form-control">
                        <html:options collection="sslcryptokeys" labelProperty="label" property="value" />
                    </html:select>
                </div>
            </div>
            <div class="form-group">
                <div class="col-lg-offset-3 col-lg-6">
                    <c:choose>
                        <c:when test = "${empty requestScope.create_mode}">
                            <html:submit styleClass="btn btn-success">
                                <bean:message key="repos.jsp.update.submit"/>
                            </html:submit>
                        </c:when>
                        <c:otherwise>
                            <html:submit styleClass="btn btn-success">
                                <bean:message key="repos.jsp.create.submit"/>
                            </html:submit>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </html:form>
    </body>
</html:html>
