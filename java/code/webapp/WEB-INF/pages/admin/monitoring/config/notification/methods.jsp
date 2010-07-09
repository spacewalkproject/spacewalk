<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>

<html:xhtml/>
<html>
<body>
<rhn:toolbar base="h1" img="/img/rhn-icon-info.gif">
  <bean:message key="methods.jsp.toolbar"/>
</rhn:toolbar>

<h2><bean:message key="methods.jsp.header2"/></h2>

<div>
    <bean:message key="methods.jsp.summary"/>
    <rhn:list pageList="${requestScope.pageList}" noDataText="methods.jsp.nomethods">
      <rhn:listdisplay   set="${requestScope.set}"
        hiddenvars="${requestScope.newset}">
        <rhn:column header="methods.jsp.methodname" sortProperty="methodName">
            <a title="<bean:message key='methods.jsp.nametitle'/>"
                href="/network/users/details/contact_methods/edit.pxt?cmid=${current.recid}">
                ${current.methodName}</a>
        </rhn:column>
        <rhn:column header="username.nopunc.displayname" sortProperty="login">
            <a title="<bean:message key='methods.jsp.logintitle'/>"
                href="/network/users/details/contact_methods/index.pxt?uid=${current.userId}">
                ${current.login}</a>
        </rhn:column>
        <rhn:column header="methods.jsp.target" sortProperty="methodTarget">
            ${current.methodTarget}
        </rhn:column>
        <rhn:column header="methods.jsp.type" sortProperty="methodType">
            ${current.methodType}
        </rhn:column>
      </rhn:listdisplay>
    </rhn:list>
</div>

</body>
</html>

