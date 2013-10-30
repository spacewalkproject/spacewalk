<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html"%>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean"%>

<html>
    <head>
    </head>
    <body>
        <%@ include file="/WEB-INF/pages/common/fragments/configuration/channel/details-header.jspf"%>
        <div class="row-0">
            <div class="col-md-6">
                <%@ include file="/WEB-INF/pages/common/fragments/configuration/channel/properties.jspf"%>
                <%@ include file="/WEB-INF/pages/common/fragments/configuration/channel/summary.jspf"%>
            </div>
            <div class="col-md-6">
                <%@ include file="/WEB-INF/pages/common/fragments/configuration/channel/tasks.jspf"%>
            </div>
        </div>
    </body>
</html>

