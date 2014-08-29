<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>


<html:html >
<body>
<%@ include file="/WEB-INF/pages/common/fragments/package/package_header.jspf" %>

<h2>
<bean:message key="filelist.jsp.title"/>
</h2>

<p><bean:message key="filelist.jsp.message"/></p>

<div>

<rhn:list pageList="${requestScope.pageList}" noDataText="filelist.jsp.nofiles">
  <rhn:listdisplay>
    <rhn:column header="filelist.jsp.filename">
            ${current.name}
    </rhn:column>

    <rhn:column header="filelist.jsp.checksum">
            ${current.formattedChecksum}
    </rhn:column>

    <rhn:column header="filelist.jsp.lastmodified">
            ${current.mtime}
    </rhn:column>

    <rhn:column header="filelist.jsp.size">
            ${current.formattedSize}
    </rhn:column>
  </rhn:listdisplay>
</rhn:list>

</div>

</body>
</html:html>
