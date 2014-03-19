<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>

<html:html >
    <body>
        <c:choose>
            <c:when test="${empty gid}">
                <rhn:toolbar base="h1" icon="header-channel-mapping" iconAlt="info.alt.img">
                    <bean:message key="extgroup.jsp.create"/>
                </rhn:toolbar>
            </c:when>
            <c:otherwise>
                <rhn:toolbar base="h1" icon="header-channel-mapping" iconAlt="info.alt.img"
                             deletionUrl="ExtAuthSgDelete.do?gid=${gid}"
                             deletionType="extgroup">
                    <bean:message key="extgroup.jsp.update" arg0="${group.label}"/>
                </rhn:toolbar>
            </c:otherwise>
        </c:choose>

        <rhn:dialogmenu mindepth="0" maxdepth="2" definition="/WEB-INF/nav/systemgroup_config.xml" renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />

        <div class="page-summary">
            <p><bean:message key="extorggroups.jsp.summary"/></p>
            <p><bean:message key="extorggroup.jsp.summary"/></p>
        </div>
        <div class="panel-heading">
            <h4><bean:message key="extorggroup.jsp.header"/></h4>
        </div>

            <html:form method="post" action="/users/ExtAuthSgDetails.do?gid=${gid}" styleClass="form-horizontal">
                <rhn:submitted/>
                <rhn:csrf />
                <div class="form-group">
                    <label class="col-lg-3 control-label"><bean:message key="extgrouplist.jsp.name"/>:</label>
                       <div class="col-lg-6">
                          <input type="text" class="form-control" name="extGroupLabel" value="${group.label}" />
                    </div>
                </div>
                <div class="form-group">
                    <label class="col-lg-3 control-label"><bean:message key="System Groups"/>:</label>
                       <div class="col-lg-6">
                            <c:forEach items="${extOrgGroupForm.map.sgs}" var="sg">
                              <div class="checkbox">
                                <label>
                                    <html:multibox property="selected_sgs" value="${sg.label}"/>
                                    ${sg.label}
                                </label>
                              </div>
                            </c:forEach>
                    </div>
                </div>
                <div class="form-group">
                    <div class="col-lg-offset-3 col-lg-6">
                        <button type="submit" class="btn btn-success">
                            <c:choose>
                                <c:when test="${empty gid}">
                                    <bean:message key="button.create"/>
                                </c:when>
                                <c:otherwise>
                                    <bean:message key="button.update"/>
                            </c:otherwise>
                        </c:choose>
                        </button>
                    </div>
                </div>
            </html:form>
    </body>
</html:html>
