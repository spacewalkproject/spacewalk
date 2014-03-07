<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>


<html>
<body>
<rhn:toolbar base="h1" icon="header-kickstart" imgAlt="kickstarts.alt.img">
	<c:out value="${requestScope.snippet.displayName}"/>
</rhn:toolbar>
<h2><bean:message key="cobbler.snippet.delete"/></h2>
<p><bean:message key="snippetdelete.jsp.summary"/></p>
<div class="alert alert-danger"><rhn:warning key= "snippetdelete.jsp.warning"/></div>
<div>
	<form method="post" action="/rhn/kickstart/cobbler/CobblerSnippetDelete.do">
    <rhn:csrf />
<h2><bean:message key="snippetcreate.jsp.contents.header"/></h2>

      <textarea style="resize:none" class="form-control col-sm-12" rows="24" disabled><c:out value="${contents}"/></textarea>

      <hr />
      <rhn:submitted/>
      <input type="hidden" name="name" value="${requestScope.name}"/>
      <div class="pull-right"><input type=submit class="btn btn-danger" name="dispatch"
       value="${rhn:localize('snippetdelete.jsp.deletesnippet')}"/></div>

    </form>
</div>

</body>
</html>

