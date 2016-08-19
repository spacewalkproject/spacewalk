<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>


<html>
<head>
</head>
<body>


 <%@ include file="/WEB-INF/pages/common/fragments/channel/channel_header.jspf" %>
<BR>
  <h2>
      <rhn:icon type="header-system-physical" title="system.common.systemAlt" />
          <bean:message key="channeltarget.confirm.jsp.header1"/>
    </h2>


 <bean:message key="channeltarget.confirm.jsp.header2"/>
<rl:listset name="systemset">
<rhn:csrf />

<rhn:hidden name="cid" value="${cid}" />

        <rl:list
                        emptykey="systemlist.jsp.nosystems"
                        alphabarcolumn="name"
                        filter="com.redhat.rhn.frontend.taglibs.list.filters.SystemOverviewFilter" >

                        <rl:decorator name="PageSizeDecorator"/>
                 <rl:column sortable="true"
                                   bound="false"
                           headerkey="actions.jsp.system"
                           sortattr="name"
                                                        defaultsort="asc"
                           >
                        <a href="/rhn/systems/details/Overview.do?sid=${current.id}">
                                <c:out value="${current.name}" />
                        </a>
                </rl:column>



                </rl:list>
                <rhn:submitted/>

                        <div class="text-right">
                                <hr />
                                <input class="btn btn-default" type="submit" name="dispatch"  value="<bean:message key='ssmchildsubs.jsp.subscribe'/>" </input>
                        </div>


</rl:listset>

</body>
</html>
