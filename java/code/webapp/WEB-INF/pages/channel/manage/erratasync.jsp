<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>


<html>
<head>
</head>
<body>
<%@ include file="/WEB-INF/pages/common/fragments/channel/manage/manage_channel_header.jspf" %>
     <h2>
      <rhn:icon type="header-errata" title="errata.common.errataAlt" /> <bean:message key="header.jsp.errata.sync"/>
    </h2>

  <bean:message key="channel.jsp.errata.sync.message"/>

  <rl:listset name="errata_list_set">
          <rhn:csrf />
                  <rhn:hidden name="cid" value="${cid}" />

                  <%@ include file="/WEB-INF/pages/common/fragments/errata/selectableerratalist.jspf" %>

        <rhn:tooltip key="channel.jsp.errata.sync.note"/>

                        <div class="text-right">
                        <hr />
                        <input class="btn btn-default" type="submit" name="dispatch"  value="<bean:message key='header.jsp.errata.sync'/>">
                        </div>
     <rhn:submitted/>


</rl:listset>


</body>
</html>
