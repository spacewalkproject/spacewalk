<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>

<html:html >
    <body>
        <rhn:toolbar base="h1" icon="header-activation-key"
        helpUrl="/rhn/help/reference/en-US/s1-sm-systems.jsp#s2-sm-system-cust-info"
        deletionUrl="/rhn/systems/customdata/DeleteCustomKey.do?cikid=${cikid}"
        deletionType="customkey">
            <bean:message key="system.jsp.customkey.updatetitle"/>
        </rhn:toolbar>

        <div class="page-summary">
            <p><bean:message key="system.jsp.customkey.updatemsg"/></p>
        </div>

        <rl:listset name="systemListSet" legend="system">
            <rhn:csrf />
            <rhn:submitted/>

            <div class="form-horizontal">
                <div class="form-group">
                    <label class="col-lg-3 control-label">
                        <bean:message key="system.jsp.customkey.keylabel"/>:
                    </label>
                    <div class="col-lg-6">${label}</div>
                </div>

                <div class="form-group">
                    <label class="col-lg-3 control-label">
                        <bean:message key="system.jsp.customkey.description"/>:
                    </label>
                    <div class="col-lg-6">
                        <textarea wrap="virtual" rows="6" cols="50"
                                  class="form-control"
                                  name="description"><c:out value="${description}" /></textarea>
                    </div>
                </div>

                <div class="form-group">
                    <label class="col-lg-3 control-label">
                        <bean:message key="system.jsp.customkey.created"/>:
                    </label>
                    <div class="col-lg-6">${created} by ${creator}</div>
                </div>

                <div class="form-group">
                    <label class="col-lg-3 control-label">
                        <bean:message key="system.jsp.customkey.modified"/>:
                    </label>
                    <div class="col-lg-6">${modified} by ${modifier}</div>
                </div>

                <div class="form-group">
                    <div class="col-lg-offset-3 col-lg-6">
                        <input type="submit" name="dispatch" class="btn btn-success"
                               value="${rhn:localize('system.jsp.customkey.updatebutton')}" />
                        <input type="hidden" name="cikid" value="${param.cikid}" />
                    </div>
                </div>
            </div>

        <h2><bean:message key="system.jsp.customkey.updateheader"/></h2>
        <rl:list
            emptykey="system.jsp.customkey.noservers"
            alphabarcolumn="name">
            <rl:decorator name="PageSizeDecorator"/>

            <!-- Name Column -->
            <rl:column sortable="true"
                       bound="false"
                       headerkey="systemlist.jsp.system"
                       sortattr="name"
                       filterattr="name"
                       defaultsort="asc">
                <a href="/rhn/systems/details/Overview.do?sid=${current.id}">
                    <c:out value="${current.name}" escapeXml="true" />
                </a>
            </rl:column>

            <!-- Values Column -->
            <rl:column sortable="false"
                       bound="false"
                       headerkey="system.jsp.customkey.value">
                <c:out value="${current.value}" />
            </rl:column>

            <!-- Last Checkin Column -->
            <rl:column sortable="false"
                       bound="false"
                       headerkey="system.jsp.customkey.last_checkin">
                <c:out value="${current.last_checkin}" />
            </rl:column>
        </rl:list>
        </rl:listset>
    </body>
</html:html>
