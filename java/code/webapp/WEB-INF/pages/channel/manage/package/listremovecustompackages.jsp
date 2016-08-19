<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>


<html>
<head>
</head>
<body>
<rhn:toolbar base="h1" icon="header-package" iconAlt="overview.jsp.alt"
 helpUrl="">
   <bean:message key="channel.jsp.manage.package.title"/>
</rhn:toolbar>

<rl:listset name="packageSet">
<rhn:csrf />
<bean:message key="channel.jsp.manage.package.message"/>
<h2><bean:message key="channel.jsp.manage.package.subtitle"/></h2>

<jsp:include page="/WEB-INF/pages/common/fragments/channel/manage/channel_selector.jspf">
    <jsp:param name="title" value="channel.jsp.manage.package.channel"/>
    <jsp:param name="option_no_packages" value="false"/>
    <jsp:param name="option_all_packages" value="true"/>
    <jsp:param name="option_orphan_packages" value="true"/>
    <jsp:param name="option_source_packages" value="true"/>
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

  <c:if test="${not source_checked}">
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
               headerkey="channel.jsp.manage.package.channels"
               >
      <c:if test="${empty current.packageChannels}">
        (<bean:message key="channel.jsp.manage.package.none"/>)
      </c:if>

      <c:forEach var="channel" items="${current.packageChannels}">
        ${channel}
        <br/>
      </c:forEach>

    </rl:column>

    <rl:column sortable="false"
               bound="false"
               headerkey="package.jsp.provider"
               >
      ${current.provider}
    </rl:column>
  </c:if>

  <c:if test="${source_checked}">
    <rl:column sortable="true"
               bound="false"
               headerkey="download.jsp.package"
               sortattr="nvrea"
               defaultsort="asc"
               >
      ${current.nvrea}
    </rl:column>
  </c:if>

</rl:list>

                        <div class="text-right">
                            <input type="submit" name="confirm" value="<bean:message key='channel.jsp.manage.package.delete'/>" ${empty pageList ? 'class="btn" disabled' : 'class="btn btn-default"'} >
                        </div>
     <rhn:submitted/>
</rl:listset>

</body>
</html>

