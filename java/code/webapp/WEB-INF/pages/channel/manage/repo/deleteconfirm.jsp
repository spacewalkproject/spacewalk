<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>


<html>
<body>
<rhn:toolbar base="h1" icon="header-info" imgAlt="info.alt.img">
        <c:out value="${requestScope.label}"/>
</rhn:toolbar>

<h2><bean:message key="repos.jsp.delete.header2"/></h2>
<p><bean:message key="repos.jsp.delete.summary"/></p>
<p><rhn:warning key= "repos.jsp.delete.warning"/></p>
<form method="post" class="form-horizontal" action="/rhn/channels/manage/repos/RepoDelete.do">
    <rhn:csrf />
    <h2><bean:message key="repos.jsp.delete.info.header"/></h2>
    <div class="form-group">
        <label class="col-lg-3 control-label"><bean:message key="repos.jsp.create.label"/></label>
        <div class="col-lg-6"><c:out value="${label}"/></div>
    </div>
    <div class="form-group">
        <label class="col-lg-3 control-label"><bean:message key="repos.jsp.create.url"/></label>
        <div class="col-lg-6"><c:out value="${url}"/></div>
    </div>
    <rhn:submitted/>
    <rhn:hidden name="id" value="${requestScope.id}"/>
    <div class="form-group">
        <div class="col-md-offset-3 col-md-6">
            <input type="submit" class="btn btn-danger" name="dispatch"
                   value="${rhn:localize('repos.jsp.delete.submit')}"/>
        </div>
    </div>
</form>

</body>
</html>
