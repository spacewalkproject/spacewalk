<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>

<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <title><bean:message key="guestlimited.jsp.title" /></title>
  </head>

  <body>
    <rhn:toolbar base="h1" img="/img/rhn-icon-system.gif" imgAlt="system.common.systemAlt">
      <bean:message key="virtualentitlements.toolbar" />
    </rhn:toolbar>
    <p/>
    <rhn:dialogmenu mindepth="0"
                    maxdepth="1"
                    definition="/WEB-INF/nav/virt_entitlements.xml"
                    renderer="com.redhat.rhn.frontend.nav.DialognavRenderer"/>

    <div style="clear: both; width: 65%; float: left;">
      <h2><bean:message key="guestlimited.jsp.header2" /></h2>
      <p>
        <bean:message key="guestlimited.jsp.para1" />
      </p>

      <c:set var="pageList" value="${requestScope.pageList}" />
      <rl:listset name="systemSet">
        <rl:list name="hostList"
                 dataset="pageList"
                 emptykey="guestlimited.jsp.nosystems"
                 width="100%">
      	  <rl:column bound="false" sortable="false" headerkey="guestlimited.jsp.hostsystem">
		    <a href="/rhn/systems/details/Overview.do?sid=${current.hostId}">${current.hostName}</a>
	      </rl:column>
      	  <rl:column bound="false" sortable="false" headerkey="guestlimited.jsp.guest">
		    <a href="/rhn/systems/details/Overview.do?sid=${current.hostId}">${current.numberOfGuests}</a>
	      </rl:column>
        </rl:list>
      </rl:listset>
    </div>
  </body>
</html>
