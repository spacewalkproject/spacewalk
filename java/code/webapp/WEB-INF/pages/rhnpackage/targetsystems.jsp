<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>


<html:html >
<body>
<%@ include file="/WEB-INF/pages/common/fragments/package/package_header.jspf" %>

<h2>
<bean:message key="targetsystems.jsp.title"/>
</h2>

<p><bean:message key="targetsystems.jsp.description"/></p>

<div>

<rl:listset name="systemSet" legend="system">
<rhn:csrf />
  <%@ include file="/WEB-INF/pages/common/fragments/systems/system_listdisplay.jspf" %>
    <rhn:submitted/>
    <div class="form-horizontal">
        <div class="form-group">
            <div class="col-md-12">
                <input type="submit" class="btn btn-success" name="dispatch" value='<bean:message key="targetsystems.jsp.installpackage"/>'/>
            </div>
        </div>
    </div>

</rl:listset>

</div>

</body>
</html:html>
