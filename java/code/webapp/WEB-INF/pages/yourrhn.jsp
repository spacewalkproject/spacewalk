<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>

<html>
<head>
<c:if test="${requestScope.inactiveSystems == 'y'}">
	<script type="text/javascript" src="/rhn/dwr/interface/InactiveSystemsRenderer.js"></script>
</c:if>
<c:if test="${requestScope.tasks == 'y'}">
	<script type="text/javascript" src="/rhn/dwr/interface/TasksRenderer.js"></script>
</c:if>
<c:if test="${requestScope.recentlyRegisteredSystems == 'y'}">
	<script type="text/javascript" src="/rhn/dwr/interface/RecentSystemsRenderer.js"></script>
</c:if>
<c:if test="${requestScope.latestErrata == 'y'}">
	<script type="text/javascript" src="/rhn/dwr/interface/LatestErrataRenderer.js"></script>
</c:if>
<c:if test="${requestScope.criticalSystems == 'y'}">
	<script type="text/javascript" src="/rhn/dwr/interface/CriticalSystemsRenderer.js"></script>
</c:if>
<c:if test="${requestScope.criticalProbes == 'y'}">
	<script type="text/javascript" src="/rhn/dwr/interface/CriticalProbesRenderer.js"></script>
</c:if>
<c:if test="${requestScope.warningProbes == 'y'}">
	<script type="text/javascript" src="/rhn/dwr/interface/WarningProbesRenderer.js"></script>
</c:if>
<c:if test="${requestScope.pendingActions =='y'}">
	<script type="text/javascript" src="/rhn/dwr/interface/PendingActionsRenderer.js"></script>
</c:if>
<c:if test="${requestScope.systemGroupsWidget == 'y'}">
	<script type="text/javascript" src="/rhn/dwr/interface/SystemGroupsRenderer.js"></script>
</c:if>

</head>
<body>
<rhn:toolbar base="h1" icon="fa-tachometer" imgAlt="yourrhn.jsp.toolbar.img.alt"
             helpUrl="/rhn/help/reference/en-US/s1-sm-your-rhn.jsp">
  <bean:message key="yourrhn.jsp.toolbar"/>
</rhn:toolbar>

<rhn:require acl="is(yourrhn.debug.enabled);">
<a href="/rhn/YourRhnClips.do"> YourRhn Clips Debug Link</a>
</rhn:require>

<c:choose>
    <c:when test="${requestScope.anyListsSelected == 'true'}">
      <div class="row-0">
        <c:if test="${requestScope.tasks == 'y'}">
            <div class="col-md-auto" id="tasks-pane" >
                <script type="text/javascript">
                  TasksRenderer.renderAsync(makeAjaxCallback('tasks-pane', false));
                </script>
            </div>
        </c:if>
        <c:if test="${requestScope.inactiveSystems == 'y'}">
            <div class="col-md-auto" id="inactive-systems-pane" >
              <script type="text/javascript">
                    InactiveSystemsRenderer.renderAsync(makeAjaxCallback("inactive-systems-pane", false));
                </script>
            </div>
        </c:if>
      </div>
  	    <c:if test="${requestScope.criticalSystems == 'y'}">
  		        <div id="critical-systems-pane" class="row">
  		            <script type="text/javascript">
  		                CriticalSystemsRenderer.renderAsync(makeAjaxCallback("critical-systems-pane", false));
  		            </script>
  		        </div>
        </c:if>

        <c:if test="${requestScope.criticalProbes == 'y'}">
            <div id="critical-probes-pane" class="row">
                <script type="text/javascript">
                    CriticalProbesRenderer.renderAsync(makeAjaxCallback("critical-probes-pane", false));
                </script>
            </div>
        </c:if>

        <c:if test="${requestScope.warningProbes == 'y'}">
            <div id="warning-probes-pane" class="row">
                <script type="text/javascript">
                    WarningProbesRenderer.renderAsync(makeAjaxCallback("warning-probes-pane", false));
                </script>
            </div>
        </c:if>
        <c:if test="${requestScope.pendingActions =='y'}">
            <div id="pending-actions-pane" class="row">
                <script type="text/javascript">
  	                PendingActionsRenderer.renderAsync(makeAjaxCallback("pending-actions-pane", false));
                </script>
            </div>
        </c:if>
        <c:if test="${requestScope.latestErrata == 'y'}">
	        <div id="latest-errata-pane" class="row">
	            <script type="text/javascript">
	  	            LatestErrataRenderer.renderAsync(makeAjaxCallback("latest-errata-pane", false));    	
	            </script>
	        </div>
        </c:if>
        <c:if test="${requestScope.systemGroupsWidget == 'y'}">
            <div id="systems-groups-pane" class="row">
                <script type="text/javascript">
                    SystemGroupsRenderer.renderAsync(makeAjaxCallback("systems-groups-pane", false));
                </script>
            </div>
        </c:if>
        <c:if test="${requestScope.recentlyRegisteredSystems == 'y'}">
            <div id="recently-registered-pane" class="row">
                <script>
                    RecentSystemsRenderer.renderAsync(makeAjaxCallback("recently-registered-pane", false));
                </script>
            </div>
        </c:if>
    </c:when>

    <c:otherwise>
  	    <bean:message key="yourrhn.jsp.nolists" />
    </c:otherwise>
</c:choose>

</body>
</html>
