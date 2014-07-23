<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>

<html:html>
    <head>
    </head>
    <body>
    <rhn:toolbar base="h1" icon="header-organisation"
            creationUrl="ExtAuthSgDetails.do"
            creationType="extgroup"
            iconAlt="info.alt.img">
        <bean:message key="org.sg.title" />
    </rhn:toolbar>

    <rhn:dialogmenu mindepth="0" maxdepth="2" definition="/WEB-INF/nav/systemgroup_config.xml" renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />

<div class="panel-heading">
    <h4><bean:message key="extorggroup.jsp.header"/></h4>
</div>
<div class="panel-body">
    <p><bean:message key="extorggroups.jsp.summary"/></p>
</div>

<rl:listset name="groupSystemGroupsSet">
<rhn:csrf />
<rhn:submitted />

  <rl:list width="100%"
         styleclass="list"
         emptykey="extauth.jsp.noGroups" >

    <rl:column bound="false"
               sortable="true"
               headerkey="extgrouplist.jsp.name"
               attr="label"
               filterattr="label">
        <a href="/rhn/users/ExtAuthSgDetails.do?gid=${current.id}">
            <c:out value="${current.label}" escapeXml="true" />
        </a>
    </rl:column>

    <rl:column attr="serverGroupsName"
               bound="true"
               headerkey="org.system.groups.jsp" />
  </rl:list>
</rl:listset>


</body>
</html:html>
