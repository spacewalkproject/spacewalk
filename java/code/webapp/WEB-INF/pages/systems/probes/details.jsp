<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<html>
    <head>
    </head>
    <body>
        <%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>

        <c:if test="${is_suite_probe}">
            <rhn:toolbar base="h2" icon="header-system"
                         miscAlt="probedetails.jsp.editsuiteprobe"
                         miscIcon="item-edit"
                         miscUrl="/rhn/monitoring/config/ProbeSuiteProbeEdit.do?suite_id=${probe.templateProbe.probeSuite.id}&amp;probe_id=${probe.templateProbe.id}"
                         miscText="probedetails.jsp.editsuiteprobe"
                         creationUrl="/rhn/systems/details/probes/ProbeCreate.do?sid=${system.id}"
                         creationType="probe">
                <bean:message key="probedetails.jsp.currentstate" />
            </rhn:toolbar>
        </c:if>
        <c:if test="${not is_suite_probe}">
            <rhn:toolbar base="h2" icon="header-system"
                         deletionUrl="/rhn/systems/details/probes/ProbeDelete.do?probe_id=${probe.id}&amp;sid=${system.id}"
                         deletionType="probe"
                         miscAlt="probedetails.jsp.editthisprobe"
                         miscIcon="item-edit"
                         miscUrl="ProbeEdit.do?probe_id=${probe.id}&amp;sid=${system.id}"
                         miscText="probedetails.jsp.editthisprobe"
                         creationUrl="/rhn/systems/details/probes/ProbeCreate.do?sid=${system.id}"
                         creationType="probe">
                <bean:message key="probedetails.jsp.currentstate" />
            </rhn:toolbar>
        </c:if>

        <html:form action="/systems/details/probes/ProbeDetails"
                   styleClass="form-horizontal"
                   method="get">

            <div class="form-group">
                <label class="col-lg-3 control-label">
                        <bean:message key="probedetails.jsp.probe" />
                </label>
                <div class="col-lg-6 text">
                        ${probe.description}
                </div>
            </div>
            <div class="form-group">
                <label class="col-lg-3 control-label">
                        <bean:message key="probeedit.jsp.satclusterdesc" />
                </label>
                <div class="col-lg-6 text">
                        ${probe.satCluster.description}
                </div>
            </div>
            <div class="form-group">
                <label class="col-lg-3 control-label">
                        <bean:message key="probedetails.jsp.status" />
                </label>
                <div class="col-lg-6 text">
                        <span class=${status_class}>${status}</span>
                </div>
            </div>
            <div class="form-group">
                <label class="col-lg-3 control-label">
                        <bean:message key="probedetails.jsp.last_update" />
                </label>
                <div class="col-lg-6 text">
                        <fmt:formatDate value="${probe.state.lastCheck}" type="both" dateStyle="short" timeStyle="long"/>
                </div>
            </div>

            <!-- For some reason we cant render date picker during export. -->
            <c:if test="${param.lde != 1}">
                <div class="form-group">
                    <label class="col-lg-3 control-label">
                        <bean:message key="probedetails.jsp.start_date" />
                    </label>
                    <div class="col-lg-6">
                        <jsp:include page="../../common/fragments/date-picker.jsp">
                            <jsp:param name="widget" value="start"/>
                        </jsp:include>
                    </div>
                </div>
                <div class="form-group">
                    <label class="col-lg-3 control-label">
                        <bean:message key="probedetails.jsp.end_date" />
                    </label>
                    <div class="col-lg-6">
                        <jsp:include page="../../common/fragments/date-picker.jsp">
                            <jsp:param name="widget" value="end"/>
                        </jsp:include>
                    </div>
                </div>
            </c:if>
            <c:if test="${not empty metrics}">
                <div class="form-group">
                    <label class="col-lg-3 control-label">
                        <bean:message key="probedetails.jsp.metrics" />
                    </label>
                    <div class="col-lg-6">
                        <html:select size="3" multiple="true" property="selected_metrics" styleClass="form-control">
                            <html:options collection="metrics"
                                          property="value"
                                          labelProperty="label" />
                        </html:select>
                    </div>
                </div>
                <div class="form-group">
                    <label class="col-lg-3 control-label">
                        <bean:message key="probedetails.jsp.show_graph" />
                    </label>
                    <div class="col-lg-6">
                        <span class="checkbox"><html:checkbox property="show_graph" /></span>
                    </div>
                </div>
            </c:if>
            <div class="form-group">
                <label class="col-lg-3 control-label">
                    <bean:message key="probedetails.jsp.show_event_log" />
                </label>
                <div class="col-lg-6">
                    <span class="checkbox"><html:checkbox property="show_log" /></span>
                </div>
            </div>
            <div class="form-group">
                <div class="col-lg-offset-3 col-lg-6">
                    <html:submit styleClass="btn btn-success">
                        <bean:message key="probedetails.jsp.generate_report"/>
                    </html:submit>
                </div>
            </div>
            <html:hidden property="sid" value="${param.sid}"/>
            <html:hidden property="probe_id" value="${probe.id}"/>
            <html:hidden property="submitted" value="true"/>
        </html:form>

        <c:if test="${requestScope.show_graph}">
            <h2><bean:message key="probedetails.jsp.graph"/></h2>
            <img src="/rhn/systems/details/probes/ProbeGraph.do?${requestScope.l10ned_selected_metrics_string}${requestScope.selected_metrics_string}startts=${requestScope.startts}&amp;endts=${requestScope.endts}&amp;sid=${system.id}&amp;probe_id=${probe.id}"/>
            <br /><a href="/rhn/systems/details/probes/ProbeGraph.do?lde=1&${requestScope.l10ned_selected_metrics_string}${requestScope.selected_metrics_string}startts=${requestScope.startts}&amp;endts=${requestScope.endts}&amp;sid=${system.id}&amp;probe_id=${probe.id}"><rhn:icon type="item-download-csv" /><bean:message key="listdisplay.csv"/></a>
            </c:if>
            <c:if test="${requestScope.show_log}">
            <h2><bean:message key="probedetails.jsp.eventlog"/></h2>
            <rl:listset name="probeSet">
                <rhn:csrf />
                <rhn:submitted />
                <!-- Start of active probes list -->
                <rl:list width="100%"
                         emptykey="probedetails.jsp.noevents">
                    <!-- Timestamp column -->
                    <rl:column bound="true"
                               attr="entryDate"
                               headerkey="probedetails.jsp.timestamp"/>
                    <!-- state column -->
                    <rl:column bound="true"
                               attr="state"
                               headerkey="probedetails.jsp.state"/>
                    <!-- message column -->
                    <rl:column bound="true"
                               attr="htmlifiedMessage"
                               headerkey="probedetails.jsp.message"/>
                </rl:list>
                    <rl:csv	exportColumns="entryDate,state,message"/>
            </rl:listset>
        </c:if>
        <c:if test="${requestScope.show_graph  ne true && requestScope.show_log ne true}">
            <bean:message key="probedetails.jsp.noselection"/>
        </c:if>
    </body>
</html>
