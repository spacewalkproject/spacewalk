<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<html:xhtml/>
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
<script type="text/javascript" src="/javascript/scriptaculous.js"></script>
<script type="text/javascript" src="/rhn/dwr/engine.js"></script>
<script type="text/javascript" src="/javascript/render.js"></script>
</head>
<body>
<rhn:toolbar base="h1" img="/img/rhn-icon-your_rhn.gif" imgAlt="yourrhn.jsp.toolbar.img.alt"
             helpUrl="/rhn/help/reference/en-US/s1-sm-your-rhn.jsp">
  <bean:message key="yourrhn.jsp.toolbar"/>
</rhn:toolbar>

<rhn:require acl="is(yourrhn.debug.enabled);">
<a href="/rhn/YourRhnClips.do"> YourRhn Clips Debug Link</a>
</rhn:require>

<c:choose>
    <c:when test="${requestScope.anyListsSelected == 'true'}">
  	    <c:if test="${requestScope.tasks == 'y'}">
  	        <div class="half-table half-table-left" id="tasks-pane" >
  	            <script type="text/javascript">
  	     	        TasksRenderer.renderAsync(makeAjaxCallback('tasks-pane', false));
  	            </script>
  	        </div>
  	    </c:if>
  	    <c:if test="${requestScope.inactiveSystems == 'y'}">
  	        <div class="half-table half-table-right" id="inactive-systems-pane" >
	            <script type="text/javascript">
  	                InactiveSystemsRenderer.renderAsync(makeAjaxCallback("inactive-systems-pane", false));
  	            </script>
  	        </div>
  	    </c:if>

  	    <c:if test="${requestScope.criticalSystems == 'y'}">
            <div style="clear: both; padding-top: 10px;">
  		        <div id="critical-systems-pane" >
  		
  		            <script type="text/javascript">
  		                CriticalSystemsRenderer.renderAsync(makeAjaxCallback("critical-systems-pane", false));
  		            </script>
  		        </div>
        </c:if>

        <c:if test="${requestScope.criticalProbes == 'y'}">
            <div id="critical-probes-pane" >
                <script type="text/javascript">
                    CriticalProbesRenderer.renderAsync(makeAjaxCallback("critical-probes-pane", false));
                </script>
            </div>
        </c:if>

        <c:if test="${requestScope.warningProbes == 'y'}">
            <div id="warning-probes-pane" >
                <script type="text/javascript">
                    WarningProbesRenderer.renderAsync(makeAjaxCallback("warning-probes-pane", false));
                </script>
            </div>
        </c:if>

        <div style="clear: both;">
            <c:if test="${requestScope.pendingActions =='y'}">
                <div id="pending-actions-pane" class="full-width-wrapper">
                    <script type="text/javascript">
      	                PendingActionsRenderer.renderAsync(makeAjaxCallback("pending-actions-pane", false));
                    </script>
                </div>
            </c:if>
            <c:if test="${requestScope.latestErrata == 'y'}">
    	        <div id="latest-errata-pane" class="full-width-wrapper">
    	            <script type="text/javascript">
    	  	            LatestErrataRenderer.renderAsync(makeAjaxCallback("latest-errata-pane", false));    	
    	            </script>
    	        </div>
            </c:if>
            <c:if test="${requestScope.systemGroupsWidget == 'y'}">
                <div id="systems-groups-pane" class="full-width-wrapper">
                    <script type="text/javascript">
                        SystemGroupsRenderer.renderAsync(makeAjaxCallback("systems-groups-pane", false));
                    </script>
                </div>
            </c:if>
            <c:if test="${requestScope.recentlyRegisteredSystems == 'y'}">
                <div id="recently-registered-pane" class="full-width-wrapper">
                    <script>
                        RecentSystemsRenderer.renderAsync(makeAjaxCallback("recently-registered-pane", false));
                    </script>
                </div>
            </c:if>
        </div>
    </c:when>

    <c:otherwise>
  	    <bean:message key="yourrhn.jsp.nolists" />
    </c:otherwise>
</c:choose>

</body>
</html>
