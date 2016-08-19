<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>



<html>
<body>

  <rhn:toolbar base="h1" icon="header-action"
                           imgAlt="actions.jsp.imgAlt"
               helpUrl="">
    <bean:message key="archivedactions.jsp.archived_actions"/>
  </rhn:toolbar>

    <p>
    <bean:message key="archivedactions.jsp.summary"/>
    </p>
    <p>
      <span class="small-text"><bean:message key="actions.jsp.totalnote"/></span>
    </p>

        <rl:listset name="failedList">
        <rhn:csrf />
                <rl:list emptykey="archivedactions.jsp.nogroups" styleclass="list">

                        <%@ include file="/WEB-INF/pages/common/fragments/scheduledactions/listdisplay-new.jspf" %>

                </rl:list>
                <rhn:submitted/>
                 <div class="text-right">
                     <input type="submit"
               name="dispatch"
               class="btn btn-default"
               value='<bean:message key="actions.jsp.deleteactions"/>'/>
         </div>
        </rl:listset>

</body>
</html>
