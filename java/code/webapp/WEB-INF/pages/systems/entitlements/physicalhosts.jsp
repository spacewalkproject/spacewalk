<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>

<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <title><bean:message key="physicalhosts.jsp.title" /></title>
  </head>

  <body>
    <rhn:toolbar base="h1" icon="icon-desktop">
      <bean:message key="virtualentitlements.toolbar" />
    </rhn:toolbar>

    <rhn:dialogmenu mindepth="0"
                    maxdepth="1"
                    definition="/WEB-INF/nav/virt_entitlements.xml"
                    renderer="com.redhat.rhn.frontend.nav.DialognavRenderer"/>

      <h2><bean:message key="physicalhosts.jsp.header2" /></h2>
      <p>
        <bean:message key="physicalhosts.jsp.para1" />
      </p>

      <c:set var="pageList" value="${requestScope.pageList}" />
      <rl:listset name="systemSet">
        <rhn:csrf />
        <rhn:submitted />
        <rl:list name="hostList"
            dataset="pageList" emptykey="physicalhosts.jsp.nosystems"  width="100%">
	  <rl:column bound="false"
	             sortable="false"
	             headerkey="physicalhosts.jsp.guestsystem">
          <a href="/rhn/systems/details/Overview.do?sid=${current.guestId}">
            <c:out value="${current.guestName}" escapeXml="true" />
          </a>
	  </rl:column>
        <rl:column bound="false" sortable="false" headerkey="guestslimited.jsp.hostsystem">
	      <c:choose>
	        <c:when test="${empty current.hostId}">unknown</c:when>
	        <c:otherwise>
              <a href="/rhn/systems/details/Overview.do?sid=${current.hostId}">
                <c:out value="${current.hostName}" escapeXml="true" />
              </a>
	        </c:otherwise>
          </c:choose>
	  </rl:column>
        </rl:list>
      </rl:listset>
      <h2><bean:message key="physicalhosts.jsp.header3" /></h2>
      <p>
        <bean:message key="physicalhosts.jsp.para2" />
      </p>
      <br>

      <strong><bean:message key="physicalhosts.jsp.guestsofknown" /></strong><br>
      <p>
          <ul>
            <li><bean:message key="physicalhosts.jsp.knownnote" /></li>
            <li><bean:message key="physicalhosts.jsp.note3" /></li>
          </ul>
      </p>
      <strong><bean:message key="physicalhosts.jsp.guestsofunknown" /></strong><br>
      <p>
          <bean:message key="physicalhosts.jsp.unknownnote" />
          <ul>
            <li><bean:message key="physicalhosts.jsp.unknownnote2" /></li>
            <li><bean:message key="physicalhosts.jsp.note3" /></li>
          </ul>
      </p>
      <strong><bean:message key="physicalhosts.jsp.guestsofnonredhat" /></strong><br>
      <p>
          <bean:message key="physicalhosts.jsp.nonredhatnote" />
      </p>

  </body>
</html>
