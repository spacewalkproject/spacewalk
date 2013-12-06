<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>

<html:html >
    <body>
        <%@ include file="/WEB-INF/pages/common/fragments/kickstart/kickstart-toolbar.jspf" %>
        <rhn:dialogmenu mindepth="0" maxdepth="1"
                        definition="/WEB-INF/nav/kickstart_details.xml"
                        renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />
        <h2><bean:message key="kickstart.partition.jsp.header"/></h2>        
        <p><bean:message key="kickstart.partition.jsp.summary"/></p>

        <html:form method="post" styleClass="form-horizontal" action="/kickstart/KickstartPartitionEdit.do">
            <rhn:csrf />
            <div class="form-group">
                <label class="col-md-3 control-label">
                    <rhn:required-field key="kickstart.partition.jsp.partitiondetails"/>:
                </label>
                <div class="col-md-6">
                    <html:textarea styleClass="form-control" rows="6" cols="80" property="partitions"/>
                </div>
            </div>
            <div class="form-group">
                <div class="col-md-offset-3 col-md-6">
                    <html:submit styleClass="btn btn-success">
                        <bean:message key="kickstart.partition.jsp.update"/>
                    </html:submit>
                </div>
            </div>
        <html:hidden property="ksid" value="${ksdata.id}"/>
        <html:hidden property="submitted" value="true"/>
    </html:form>
</body>
</html:html>

