<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>


<html>
<head>
    <meta name="name" value="System Details" />
</head>
<body>

<%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>

<h2>
  <img src="/img/rhn-icon-bug-ex.gif"
       alt="<bean:message key='crashes.jsp.crashes' />" />
  <bean:message key="crashes.jsp.crashes"/>
</h2>

  <div class="page-summary">
    <p>
    <bean:message key="crashes.jsp.summary"/>
    </p>
  </div>

<rl:listset name="crashesList">
    <rhn:csrf />

    <rl:list
         width="100%"
         styleclass="list"
         emptykey="crashes.jsp.nocrashes"
         alphabarcolumn="component">

        <rl:decorator name="PageSizeDecorator"/>
        <rl:decorator name="SelectableDecorator"/>

        <rl:selectablecolumn value="${current.selectionKey}"
            selected="${current.selected}"/>

        <rl:column headerkey="crashes.jsp.crash" bound="false"
            sortattr="crash"
            sortable="true">
            <a href="/rhn/systems/details/SoftwareCrashDetail.do?crid=${current.id}&sid=${sid}">
                ${current.crash}
            </a>
        </rl:column>

        <rl:column headerkey="crashes.jsp.crashcount" bound="false"
            sortattr="count"
            sortable="true">
            ${current.count}
        </rl:column>

        <rl:column headerkey="crashes.jsp.component" bound="false"
            sortattr="component"
            sortable="true"
            filterattr="component">
            ${current.component}
        </rl:column>

        <rl:column headerkey="lastModified" bound="false"
			styleclass="thin-column"
            sortattr="modifiedObject"
            sortable="true"
			defaultsort="desc">
            ${current.modified}
        </rl:column>
    </rl:list>

    <html:hidden property="sid" value="${sid}"/>
    <rl:csv
        name="crashesList"
        exportColumns="crash,count,component,modified"
        header="${system.name}"/>

    <div class="text-right">
        <hr />
        <html:submit property="dispatch">
            <bean:message key="crashes.jsp.delete.button"/>
        </html:submit>
    </div>
    <rhn:submitted/>
</rl:listset>

</body>
</html>
