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
      <img src="/img/rhn-icon-errata.gif" alt="erratum" /> <bean:message key="header.jsp.errata"/>
    </h2>

  <bean:message key="channel.jsp.errata.remove.confirmmessage"/>

  <rl:listset name="errata_list_set">

		  <rl:list
					emptykey="channel.jsp.errata.listempty"
					alphabarcolumn="advisory" >

				<rl:decorator name="ElaborationDecorator"/>
				<rl:decorator name="PageSizeDecorator"/>


                 <rl:column sortable="true"
                                   bound="false"
                           headerkey="erratalist.jsp.advisory"
                           sortattr="advisory"
                           styleclass="first-column">

                        <a href="/rhn/errata/manage/Edit.do?eid=${current.id}">${current.advisory}</a>
                </rl:column>


                 <rl:column sortable="false"
                                   bound="false"
                                   filterattr="advisorySynopsis"
                           headerkey="erratalist.jsp.synopsis" >
                        ${current.advisorySynopsis}
                </rl:column>


                <%--
                 <rl:column sortable="true"
                                   bound="false"
                           headerkey="lastModified"
                           sortattr="lastModifiedObject">
                        ${current.lastModified}
                </rl:column>
                --%>

                 <rl:column sortable="true"
                                   bound="false"
                           headerkey="erratalist.jsp.updated"
                           styleclass="last-column"
                           sortattr="updateDateObj"
                           defaultsort="desc" >
                        ${current.updateDate}
                </rl:column>


			</rl:list>

			<p align="right">
			<input type="submit" name="dispatch"  value="<bean:message key="channel.jsp.errata.confirmremove"/>">
			</p>
     <rhn:submitted/>
     <input type="hidden" name="cid" value="${cid}">

</rl:listset>


</body>
</html>
