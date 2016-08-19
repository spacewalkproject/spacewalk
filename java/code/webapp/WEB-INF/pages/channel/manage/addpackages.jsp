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
<BR>

<rl:listset name="packageSet">
<rhn:csrf />
<rhn:hidden name="cid" value="${cid}"/>
<bean:message key="channel.jsp.package.addmessage"/>
<h2><rhn:icon type="header-package" /> <bean:message key="channel.jsp.package.addtitle"/></h2>

<jsp:include page="/WEB-INF/pages/common/fragments/channel/manage/channel_selector.jspf">
    <jsp:param name="title" value="channel.jsp.manage.package.channel"/>
    <jsp:param name="option_no_packages" value="false"/>
    <jsp:param name="option_all_packages" value="true"/>
    <jsp:param name="option_orphan_packages" value="true"/>
    <jsp:param name="option_source_packages" value="false"/>
</jsp:include>

                  <rl:list dataset="pageList" name="packageList"
                  decorator="SelectableDecorator"
                                        emptykey="channel.jsp.package.addemptylist"
                                        alphabarcolumn="nvrea"
                                         filter="com.redhat.rhn.frontend.taglibs.list.filters.PackageFilter"
                                        >

                                <rl:decorator name="ElaborationDecorator"/>
                                <rl:decorator name="PageSizeDecorator"/>

                                <rl:selectablecolumn value="${current.selectionKey}"
                                        selected="${current.selected}"/>


                 <rl:column sortable="true"
                                   bound="false"
                           headerkey="download.jsp.package"
                           sortattr="nvrea"
                                        defaultsort="asc"
                           >

                        <a href="/rhn/software/packages/Details.do?pid=${current.id}">${current.nvrea}</a>
                </rl:column>


                 <rl:column sortable="false"
                                   bound="false"
                           headerkey="packagesearch.jsp.summary"
                          >
                        ${current.summary}
                </rl:column>

                 <rl:column sortable="false"
                                   bound="false"
                           headerkey="package.jsp.provider"
                          >
                        ${current.provider}
                </rl:column>



                          </rl:list>


                        <div class="text-right">
                            <hr />
                            <input type="submit" name="confirm" class="btn btn-default"  value="<bean:message key='channel.jsp.package.addbutton'/>" ${empty pageList ? 'disabled' : 'btn btn-default'} >
                        </div>
     <rhn:submitted/>
</rl:listset>
</body>
</html>

