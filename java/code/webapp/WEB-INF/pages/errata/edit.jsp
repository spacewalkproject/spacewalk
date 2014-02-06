<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>


<html>
    <head>
    </head>
    <body>
        <rhn:toolbar base="h1" icon="header-errata" iconAlt="errata.common.errataAlt"
                     helpUrl="/rhn/help/getting-started/en-US/chap-Getting_Started_Guide-Errata_Management.jsp#sect-Getting_Started_Guide-Errata_Management-Creating_and_Editing_Errata"
                     deletionUrl="/rhn/errata/manage/Delete.do?eid=${param.eid}"
                     deletionType="errata">
            <bean:message key="errata.edit.toolbar"/> <c:out value="${advisory}" />
        </rhn:toolbar>

        <rhn:dialogmenu mindepth="0" maxdepth="1" definition="/WEB-INF/nav/manage_errata.xml"
                        renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />


        <%-- Publish or Send notification --%>
        <html:form action="/errata/manage/Edit" styleClass="form-horizontal">
            <rhn:csrf />
            <rhn:submitted />
            <input type="hidden" name="eid" value="<c:out value="${param.eid}"/>" />

            <c:if test="${isPublished == true}">
                <h2><bean:message key="errata.edit.senderratamail"/></h2>
                <p><bean:message key="errata.edit.youmaynotify" /></p>
                <div class="form-group">
                    <div class="col-lg-offset-3 col-lg-6">
                        <html:submit property="dispatch" styleClass="btn btn-success">
                            <bean:message key="errata.edit.sendnotification" />
                        </html:submit>
                    </div>
                </div>
            </c:if>

            <c:if test="${isPublished == false}">
                <h2><bean:message key="errata.edit.publisherrata"/></h2>
                <p><bean:message key="errata.edit.youmaypublish" /></p>
                <div class="form-group">
                    <div class="col-lg-offset-3 col-lg-6">
                        <html:submit property="dispatch">
                            <bean:message key="errata.edit.publisherrata" />
                        </html:submit>
                    </div>
                </div>
            </c:if>
        </html:form>

        <html:form action="/errata/manage/Edit" styleClass="form-horizontal">
            <rhn:csrf />
            <rhn:submitted />
            <%-- Edit the errata details --%>
            <h2><bean:message key="errata.edit.editerrata" /></h2>
            <p><bean:message key="errata.edit.instructions" /></p>
            <div class="form-group">
                <label class="col-lg-3 control-label">
                    <bean:message key="errata.create.jsp.synopsis"/>
                </label>
                <div class="col-lg-6">
                    <html:text property="synopsis" size="60" maxlength="4000" styleClass="form-control"/>
                </div>
            </div>

            <div class="form-group">
                <label class="col-lg-3 control-label">
                    <bean:message key="errata.create.jsp.advisory"/>
                </label>
                <div class="col-lg-6">
                    <html:text property="advisoryName" size="25" maxlength="32" styleClass="form-control"/>
                </div>
            </div>
            <div class="form-group">
                <label class="col-lg-3 control-label">
                    <bean:message key="errata.create.jsp.advisoryrelease"/>
                </label>
                <div class="col-lg-6">
                    <html:text property="advisoryRelease" size="4" maxlength="4" styleClass="form-control"/>
                </div>
            </div>
            <div class="form-group">
                <label class="col-lg-3 control-label">
                    <bean:message key="errata.create.jsp.advisorytype"/>
                </label>
                <div class="col-lg-6">
                    <html:select property="advisoryType" styleClass="form-control">
                        <html:options name="advisoryTypes" labelProperty="advisoryTypeLabels"/>
                    </html:select>
                </div>
            </div>
            <div class="form-group">
                <label class="col-lg-3 control-label">
                    <bean:message key="errata.create.jsp.product"/>
                </label>
                <div class="col-lg-6">
                    <html:text property="product" size="30" maxlength="64" styleClass="form-control"/>
                </div>
            </div>
            <div class="form-group">
                <label class="col-lg-3 control-label">
                    <bean:message key="errata.create.jsp.from"/>
                </label>
                <div class="col-lg-6">
                    <html:text property="errataFrom" size="30" maxlength="127" styleClass="form-control"/>
                </div>
            </div>
            <div class="form-group">
                <label class="col-lg-3 control-label">
                    <bean:message key="errata.create.jsp.topic"/>
                </label>
                <div class="col-lg-6">
                    <html:textarea property="topic" cols="80" rows="6" styleClass="form-control"/>
                </div>
            </div>
            <div class="form-group">
                <label class="col-lg-3 control-label">
                    <bean:message key="errata.create.jsp.description"/>
                </label>
                <div class="col-lg-6">
                    <html:textarea property="description" cols="80" rows="6" styleClass="form-control"/>
                </div>
            </div>
            <div class="form-group">
                <label class="col-lg-3 control-label">
                    <bean:message key="errata.create.jsp.solution"/>
                </label>
                <div class="col-lg-6">
                    <html:textarea property="solution" cols="80" rows="6" styleClass="form-control"/>
                </div>
            </div>
            <div class="form-group">
                <div class="col-lg-offset-3 col-lg-6">
                    <h3><bean:message key="errata.create.jsp.bugs"/></h3>
                </div>
            </div>

            <c:forEach items="${bugs}" var="bug">
                <div class="form-group">
                    <div class="well well-sm">
                            <div class="form-group">
                                <label class="col-lg-3 control-label">
                                    <bean:message key="errata.create.jsp.id"/>
                                </label>
                                <div class="col-lg-2">
                                    <html:text property="buglistId${bug.id}"
                                               styleClass="form-control"
                                               size="6" value="${bug.id}" />
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-lg-3 control-label">
                                    <bean:message key="errata.create.jsp.summary"/>
                                </label>
                                <div class="col-lg-6">
                                    <html:text property="buglistSummary${bug.id}"
                                               size="60" styleClass="form-control"
                                               value="${bug.summary}" />
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-lg-3 control-label">
                                    <bean:message key="errata.create.jsp.bugurl"/>
                                </label>
                                <div class="col-lg-6">
                                    <html:text property="buglistUrl${bug.id}" size="60"
                                               styleClass="form-control"
                                               value="${bug.url}" />
                                </div>
                            </div>
                            <div class="form-group">
                                <div class="col-lg-offset-3 col-lg-6">
                                    <a class="btn btn-danger"
                                       href="/rhn/errata/manage/DeleteBug.do?eid=<c:out value="${param.eid}"/>&amp;bid=<c:out value="${bug.id}"/>">
                                        <bean:message key="errata.edit.deletebug"/>
                                    </a>
                                </div>
                            </div>
                    </div>
                </div>
            </c:forEach>

            <%-- Display an empty bug shell for input --%>
            <div class="form-group">
                <div class="col-lg-offset-3 col-lg-6">
                    <h3><bean:message key="errata.create.jsp.newbug"/></h3>
                </div>
            </div>
            <div class="form-group">
                <div class="panel panel-default">
                    <div class="panel-body">
                        <div class="form-group">
                            <label class="col-lg-3 control-label">
                                <bean:message key="errata.create.jsp.id"/>
                            </label>
                            <div class="col-lg-2">
                                <html:text property="buglistIdNew" value="" size="6" styleClass="form-control"/>
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="col-lg-3 control-label">
                                <bean:message key="errata.create.jsp.summary"/>
                            </label>
                            <div class="col-lg-6">
                                <html:text property="buglistSummaryNew" value="" size="60" styleClass="form-control"/>
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="col-lg-3 control-label">
                                <bean:message key="errata.create.jsp.bugurl"/>
                            </label>
                            <div class="col-lg-6">
                                <html:text property="buglistUrlNew" value="" size="60" styleClass="form-control"/>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="form-group">
                <label class="col-lg-3 control-label">
                    <bean:message key="errata.create.jsp.keywords"/>
                </label>
                <div class="col-lg-6">
                    <html:text property="keywords" size="40" styleClass="form-control"/>
                    <span class="help-block">
                        <bean:message key="errata.edit.commadelimited"/>
                    </span>
                </div>
            </div>
            <div class="form-group">
                <label class="col-lg-3 control-label">
                    <bean:message key="errata.create.jsp.references"/>
                </label>
                <div class="col-lg-6">
                    <html:textarea property="refersTo" cols="40" rows="6" styleClass="form-control"/>
                </div>
            </div>
            <div class="form-group">
                <label class="col-lg-3 control-label">
                    <bean:message key="errata.create.jsp.notes"/>
                </label>
                <div class="col-lg-6">
                    <html:textarea property="notes" cols="40" rows="6" styleClass="form-control"/>
                </div>
            </div>
            <input type="hidden" name="eid" value="<c:out value="${param.eid}"/>" />
            <div class="form-group">
                <div class="col-lg-offset-3 col-lg-6">
                    <html:submit property="dispatch" styleClass="btn btn-success">
                        <bean:message key="errata.edit.updateerrata"/>
                    </html:submit>
                </div>
            </div>
        </html:form>
    </body>
</html>
