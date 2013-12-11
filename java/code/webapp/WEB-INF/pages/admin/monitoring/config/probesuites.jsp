<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>




<html>
<body>
<rhn:toolbar base="h1" icon="header-system-groups"
	           creationUrl="ProbeSuiteCreate.do"
               creationType="probesuite"
               helpUrl="/rhn/help/reference/en-US/s1-sm-monitor.jsp#s2-sm-monitor-psuites">
    <bean:message key="probesuites.jsp.header1"/>
  </rhn:toolbar>

<h2><bean:message key="probesuites.jsp.header2"/></h2>

<div>
  <p>
    <bean:message key="probesuites.jsp.summary"/>
  </p>
  <c:if test="${containsNonSelectable}">
  <p>
    <bean:message key="probesuites.jsp.access"/>
  </p>
  </c:if>



 <rl:listset name="suitSet">
   <rhn:csrf />

   <rl:list emptykey="probesuites.jsp.nosuites">
		<rl:decorator name="ElaborationDecorator"/>
		<rl:decorator name="PageSizeDecorator"/>
		<rl:selectablecolumn value="${current.id}"
							selected="${current.selected}"/>

                <rl:column sortable="true"
                           bound="false"
                           headerkey="probesuites.jsp.name"
                           sortattr="suiteName"
                           defaultsort="asc"
                           filterattr="suiteName">
                    <c:if test="${current.selectable}">
		              <a href="ProbeSuiteEdit.do?suite_id=${current.id}"><c:out value="${current.suiteName}"/></a>
		            </c:if>
		            <c:if test="${not current.selectable}">
				<c:out value="${current.suiteName}"/>
		            </c:if>
                </rl:column>

                <rl:column sortable="true"
                                   bound="false"
                           headerkey="probesuites.jsp.description"
                           sortattr="name" >
						<c:out value="${current.description}"/>
              </rl:column>


                <rl:column sortable="true"
                                   bound="false"
                           headerkey="probesuites.jsp.system_count"
                           sortattr="systemCount">
		            <c:if test="${current.selectable}">
		              <A HREF="ProbeSuiteSystems.do?suite_id=${current.id}">${current.systemCount}</A>
		            </c:if>
		            <c:if test="${not current.selectable}">
		              &mdash;
		            </c:if>
              </rl:column>



  </rl:list>


  <rl:csv dataset="dataset"
    exportColumns="id,suiteName,description,systemCount"/>


  <div class="text-right">
   <rhn:submitted/>
   <hr/>

    <input type="submit"
	name ="dispatch"
	    value='<bean:message key="probesuites.jsp.deleteprobesuites"/>'/>
	</div>

</rl:listset>



  </p>
</div>


</body>
</html>

