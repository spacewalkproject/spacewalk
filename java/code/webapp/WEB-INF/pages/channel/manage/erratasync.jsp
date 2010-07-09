<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>

<html:xhtml/>
<html>
<head>
    <meta name="page-decorator" content="none" />
</head>
<body>
<%@ include file="/WEB-INF/pages/common/fragments/channel/manage/manage_channel_header.jspf" %>
     <h2>
      <img src="/img/rhn-icon-errata.gif" alt="erratum" /> <bean:message key="header.jsp.errata.sync"/>
    </h2>

  <bean:message key="channel.jsp.errata.sync.message"/>

  <rl:listset name="errata_list_set">
		  <input type="hidden" name="cid" value="${cid}">

		  <rl:list
					decorator="SelectableDecorator"
					emptykey="channel.jsp.errata.sync.listempty"
					alphabarcolumn="advisorySynopsis" >

				<rl:decorator name="ElaborationDecorator"/>
				<rl:decorator name="PageSizeDecorator"/>

				<rl:selectablecolumn value="${current.selectionKey}"
					selected="${current.selected}"
					styleclass="first-column"/>





                 <rl:column sortable="true"
                                   bound="false"
                           headerkey="erratalist.jsp.type"
                           headerclass="thin-column"
                           sortattr="advisoryType">
                        <c:if test="${current.advisoryType == 'Product Enhancement Advisory'}">
				 <img src="/img/wrh-product.gif" alt="Product Enhancement Advisory" title="Product Enhancement Advisory" />
                        </c:if>
                       <c:if test="${current.advisoryType == 'Security Advisory'}">
				 <img src="/img/wrh-security.gif" alt="Security Advisory" title="Security Advisory" />
                        </c:if>
                       <c:if test="${current.advisoryType == 'Bug Fix Advisory'}">
				  <img src="/img/wrh-bug.gif" alt="Bug Fix Advisory" title="Bug Fix Advisory" />
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
                           styleclass="last-column"
                           sortattr="updateDateObj"
                           defaultsort="desc"
                          >
                        ${current.updateDate}
                </rl:column>


			</rl:list>


	<rhn:tooltip key="channel.jsp.errata.sync.note"/>

			<p align="right">
			<input type="submit" name="dispatch"  value="<bean:message key="header.jsp.errata.sync"/>">
			</p>
     <rhn:submitted/>


</rl:listset>


</body>
</html>
