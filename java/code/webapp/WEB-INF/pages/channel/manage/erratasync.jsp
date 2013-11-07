<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>


<html>
<head>
    <meta name="page-decorator" content="none" />
</head>
<body>
<%@ include file="/WEB-INF/pages/common/fragments/channel/manage/manage_channel_header.jspf" %>
     <h2>
      <i class="fa spacewalk-icon-patches" title="erratum"></i> <bean:message key="header.jsp.errata.sync"/>
    </h2>

  <bean:message key="channel.jsp.errata.sync.message"/>

  <rl:listset name="errata_list_set">
          <rhn:csrf />
		  <input type="hidden" name="cid" value="${cid}">

		  <rl:list
					decorator="SelectableDecorator"
					emptykey="channel.jsp.errata.sync.listempty"
					alphabarcolumn="advisorySynopsis" >

				<rl:decorator name="ElaborationDecorator"/>
				<rl:decorator name="PageSizeDecorator"/>

				<rl:selectablecolumn value="${current.selectionKey}"
					selected="${current.selected}"/>





                 <rl:column sortable="true"
                                   bound="false"
                           headerkey="erratalist.jsp.type"
                           headerclass="thin-column"
                           sortattr="advisoryType">
                        <c:if test="${current.advisoryType == 'Product Enhancement Advisory'}">
				 <i class="fa  spacewalk-icon-enhancement" title="Product Enhancement Advisory"></i>
                        </c:if>
                       <c:if test="${current.advisoryType == 'Security Advisory'}">
				 <i class="fa fa-lock" title="Security Advisory"></i>
                        </c:if>
                       <c:if test="${current.advisoryType == 'Bug Fix Advisory'}">
				  <i class="fa fa-bug" title="Bug Fix Advisory"></i>
                        </c:if>

                </rl:column>


                 <rl:column sortable="true"
                                   bound="false"
                           headerkey="erratalist.jsp.advisory"
                           sortattr="advisory"
                           >

                        <a href="/rhn/errata/manage/Edit.do?eid=${current.id}">${current.advisoryName}</a>
                </rl:column>


                 <rl:column sortable="false"
                                   bound="false"
                                   filterattr="advisorySynopsis"
                           headerkey="erratalist.jsp.synopsis"
                          >
                        ${current.advisorySynopsis}
                </rl:column>


                 <rl:column sortable="true"
                                   bound="false"
                           headerkey="erratalist.jsp.updated"
                           sortattr="updateDateObj"
                           defaultsort="desc"
                          >
                        ${current.updateDate}
                </rl:column>


			</rl:list>


	<rhn:tooltip key="channel.jsp.errata.sync.note"/>

			<p align="right">
			<input type="submit" name="dispatch"  value="<bean:message key='header.jsp.errata.sync'/>">
			</p>
     <rhn:submitted/>


</rl:listset>


</body>
</html>
