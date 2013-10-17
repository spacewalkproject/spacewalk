<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<html:xhtml/>
<html>
<body>

<rhn:toolbar base="h1" icon="icon-dashboard"
	         helpUrl="">
    <bean:message key="bunch.edit.jsp.toolbar" arg0="${label}"/>
</rhn:toolbar>

<rl:listset name="runList">

    <div>
       <h2><bean:message key="bunch.edit.jsp.bunchdescription"/></h2>
       <div class="page-summary">
          <c:out value="${bunchdescription}"/>
       </div>
       <div align="right">
          <input type="submit" name="dispatch"
            value="<bean:message key="bunch.edit.jsp.button-schedule"/>" />
            <rhn:csrf/>
          <rhn:submitted/>
       </div>
       <hr />
       <br/>
       <div class="page-summary">
          <bean:message key="bunch.jsp.generaldescription"/>
       </div>
    </div>
    <br/>
    <rl:list
        emptykey="schedule.jsp.noruns"
        dataset="dataset" >
                <rl:decorator name="PageSizeDecorator"/>

                <rl:column sortable="true"
                           bound="false"
                           headerkey="task.edit.jsp.name"
                           sortattr="task" >
                        <c:out value="${current.task}" />
                </rl:column>

                <rl:column bound="false"
                           headerkey="task.edit.jsp.stattime"
                           sortattr="start_time" >
                        <a href="/rhn/admin/ScheduleDetail.do?schid=${current.schedule_id}">
                          <fmt:formatDate pattern="yyyy-MM-dd HH:mm:ss z" value="${current.start_time}"/>
                        </a>
                </rl:column>

                <rl:column bound="false"
                           headerkey="task.edit.jsp.endtime"
                           sortattr="end_time" >
                           <fmt:formatDate pattern="yyyy-MM-dd HH:mm:ss z" value="${current.end_time}"/>
                </rl:column>

                <rl:column bound="false"
                           headerkey="kickstart.jsp.status"
                           sortattr="status"
 >
                        <c:out value="${current.status}" />
                </rl:column>

</rl:list>
</rl:listset>

</body>
</html>
