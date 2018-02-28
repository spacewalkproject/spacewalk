<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<script>
    function greyOut() {
        var type = document.getElementById('errata_type').getElementsByTagName('select');
        var severity = document.getElementById('errata_severity')
                .getElementsByTagName('select');
        var disabled = (type[0].value != "Security Advisory");
        severity[0].disabled = disabled;
    }
</script>
<html>
    <head>
    </head>
    <body>
        <rhn:toolbar base="h1" icon="header-errata" iconAlt="errata.common.errataAlt"
                     helpUrl="">
            <bean:message key="erratalist.jsp.erratamgmt"/>
        </rhn:toolbar>

        <h2><bean:message key="errata.create.jsp.createerrata" /></h2>
        <p><bean:message key="errata.create.jsp.instructions" /></p>
        <html:form action="/errata/manage/CreateSubmit"
                   styleClass="form-horizontal">
            <rhn:csrf />
            <div class="form-group">
                <label class="col-lg-3 control-label">
                    <bean:message key="errata.create.jsp.synopsis"/>
                </label>
                <div class="col-lg-6">
                    <html:text property="synopsis" size="60"
                               styleClass="form-control" maxlength="4000" />
                </div>
            </div>
            <div class="form-group">
                <label class="col-lg-3 control-label">
                    <bean:message key="errata.create.jsp.advisory"/>
                </label>
                <div class="col-lg-6">
                    <html:text property="advisoryName" styleClass="form-control"
                               size="25" maxlength="32" />
                </div>
            </div>
            <div class="form-group">
                <label class="col-lg-3 control-label">
                    <bean:message key="errata.create.jsp.advisoryrelease"/>
                </label>
                <div class="col-lg-6">
                    <html:text property="advisoryRelease" styleClass="form-control" size="4" maxlength="4"/>
                </div>
            </div>
            <div class="form-group" id="errata_type">
                <label class="col-lg-3 control-label">
                    <bean:message key="errata.create.jsp.advisorytype"/>
                </label>
                <div class="col-lg-6">
                    <html:select property="advisoryType" styleClass="form-control"
                                 onchange="greyOut()">
                        <html:options name="advisoryTypes" labelProperty="advisoryTypeLabels"/>
                    </html:select>
                </div>
            </div>
            <div class="form-group" id="errata_severity">
                <label class="col-lg-3 control-label">
                    <bean:message key="errata.create.jsp.advisoryseverity"/>
                </label>
                <div class="col-lg-6">
                    <html:select property="advisorySeverity" styleClass="form-control"
                                 disabled="true">
                        <html:options name="advisorySeverity"
                                      labelProperty="advisorySeverityLabels"/>
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
            <div class="form-group">
                <label class="col-lg-3 control-label">
                    <bean:message key="errata.create.jsp.id"/>
                </label>
                <div class="col-lg-6">
                    <html:text property="buglistId" size="6" styleClass="form-control"/>
                </div>
            </div>
            <div class="form-group">
                <label class="col-lg-3 control-label">
                    <bean:message key="errata.create.jsp.summary"/>
                </label>
                <div class="col-lg-6">
                    <html:text property="buglistSummary" size="60" styleClass="form-control"/>
                </div>
            </div>
            <div class="form-group">
                <label class="col-lg-3 control-label">
                    <bean:message key="errata.create.jsp.bugurl"/>
                </label>
                <div class="col-lg-6">
                    <html:text property="buglistUrl" size="60" styleClass="form-control"/>
                </div>
            </div>
            <div class="form-group">
                <label class="col-lg-3 control-label">
                    <bean:message key="errata.create.jsp.keywords"/>
                </label>
                <div class="col-lg-6">
                    <html:text property="keywords" size="40" styleClass="form-control"/>
                    <span class="help-block"><bean:message key="errata.edit.commadelimited"/></span>
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
            <rhn:hidden name="eid" value="0" />
            <div class="form-group">
                <div class="col-lg-offset-3 col-lg-6">
                    <html:submit styleClass="btn btn-success">
                        <bean:message key="errata.create.jsp.createerrata"/>
                    </html:submit>
                </div>
            </div>
        </html:form>
    </body>
</html>