<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>

<html:html>
<script language="javascript" src="/javascript/refresh.js"></script>
<head>
    <meta http-equiv="Pragma" content="no-cache" />
</head>
<body>
    <rhn:toolbar base="h1" icon="header-info" imgAlt="info.alt.img">
        <bean:message key="treecreate.jsp.toolbar"/>
    </rhn:toolbar>
    <bean:message key="treecreate.jsp.header1"/>
    <h2><bean:message key="treecreate.jsp.header2"/></h2>
    <html:form method="post" action="/kickstart/TreeCreate.do" styleClass="form-horizontal">
        <rhn:csrf />
        <%@ include file="tree-form.jspf" %>
        <div class="form-group">
            <div class="col-lg-offset-3 col-lg-6">
                <button type="submit"
                   <c:choose>
                      <c:when test="${requestScope.hidesubmit == 'true'}">
                          disabled class="btn"
                      </c:when>
                      <c:otherwise>
                          class="btn btn-success"
                      </c:otherwise>
                   </c:choose>
                >
                    <bean:message key="createtree.jsp.submit"/>
                </button>
            </div>
        </div>
        <html:hidden property="submitted" value="true"/>
    </html:form>
</body>
</html:html>

