<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>

<html:xhtml/>
<html>
<head>
    <meta name="page-decorator" content="none" />
</head>
<body>
<rhn:toolbar base="h1" img="/img/rhn-icon-errata.gif" imgAlt="errata.common.errataAlt"
	           helpUrl="/rhn/help/channel-mgmt/en-US/channel-mgmt-Custom_Errata_Management-Managed_Errata_Details.jsp"
	           deletionUrl="/rhn/errata/manage/Delete.do?eid=${param.eid}"
               deletionType="errata">
    <bean:message key="errata.edit.toolbar"/> <c:out value="${advisory}" />
  </rhn:toolbar>

  <rhn:dialogmenu mindepth="0" maxdepth="1" definition="/WEB-INF/nav/manage_errata.xml"
                  renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />


<%-- Publish or Send notification --%>
  <html:form action="/errata/manage/Edit">
  <input type="hidden" name="eid" value="<c:out value="${param.eid}"/>" />
  <c:if test="${isPublished == true}">
      <h2><bean:message key="errata.edit.senderratamail"/></h2>
      <div class="page-summary">
        <p><bean:message key="errata.edit.youmaynotify" /></p>
      </div>
      <div align="right">
        <html:submit property="dispatch">
          <bean:message key="errata.edit.sendnotification" />
        </html:submit>
      </div>
  </c:if>

  <c:if test="${isPublished == false}">
      <h2><bean:message key="errata.edit.publisherrata"/></h2>
      <div class="page-summary">
        <p><bean:message key="errata.edit.youmaypublish" /></p>
      </div>
      <div align="right">
        <html:submit property="dispatch">
          <bean:message key="errata.edit.publisherrata" />
        </html:submit>
      </div>
  </c:if>
  </html:form>

  <html:form action="/errata/manage/Edit">
<%-- Edit the errata details --%>
  <h2><bean:message key="errata.edit.editerrata" /></h2>

  <div class="page-summary">
    <p><bean:message key="errata.edit.instructions" /></p>
  </div>
<table class="details">
    <tr>
      <th nowrap="nowrap">
        <bean:message key="errata.create.jsp.synopsis"/>
      </th>
      <td class="small-form">
        <html:text property="synopsis" size="60" maxlength="4000" />
      </td>
    </tr>

    <tr>
      <th nowrap="nowrap">
        <bean:message key="errata.create.jsp.advisory"/>
      </th>
      <td class="small-form">
        <html:text property="advisoryName" size="25" maxlength="32" />
      </td>
    </tr>

    <tr>
      <th nowrap="nowrap">
        <bean:message key="errata.create.jsp.advisoryrelease"/>
      </th>
      <td class="small-form">
        <html:text property="advisoryRelease" size="4" maxlength="4"/>
      </td>
    </tr>

    <tr>
      <th nowrap="nowrap">
        <bean:message key="errata.create.jsp.advisorytype"/>
      </th>
      <td class="small-form">
        <html:select property="advisoryType">
          <html:options name="advisoryTypes" labelProperty="advisoryTypeLabels"/>
        </html:select>
      </td>
    </tr>

    <tr>
      <th nowrap="nowrap">
        <bean:message key="errata.create.jsp.product"/>
      </th>
      <td class="small-form">
        <html:text property="product" size="30" maxlength="64" />
      </td>
    </tr>

    <tr>
      <th nowrap="nowrap">
        <bean:message key="errata.create.jsp.topic"/>
      </th>
      <td class="small-form">
        <html:textarea property="topic" cols="80" rows="6"/>
      </td>
    </tr>

    <tr>
      <th nowrap="nowrap">
        <bean:message key="errata.create.jsp.description"/>
      </th>
      <td class="small-form">
        <html:textarea property="description" cols="80" rows="6"/>
      </td>
    </tr>

    <tr>
      <th nowrap="nowrap">
        <bean:message key="errata.create.jsp.solution"/>
      </th>
      <td class="small-form">
        <html:textarea property="solution" cols="80" rows="6"/>
      </td>
    </tr>

    <tr>
      <th nowrap="nowrap">
        <bean:message key="errata.create.jsp.bugs"/>
      </th>
      <td class="small-form">

        <c:forEach items="${bugs}" var="bug">
          <table cellpadding="3">
            <tr>
              <td><bean:message key="errata.create.jsp.id"/></td>
              <td><html:text property="buglistId${bug.id}" size="6"
                       value="${bug.id}" /></td>
            </tr>
            <tr>
              <td><bean:message key="errata.create.jsp.summary"/></td>
              <td><html:text property="buglistSummary${bug.id}" size="60"
                       value="${bug.summary}" />

            &nbsp;&nbsp;
            <a href="/rhn/errata/manage/DeleteBug.do?eid=<c:out value="${param.eid}"/>&amp;bid=<c:out value="${bug.id}"/>">
              <img src="/img/action-del.gif" alt="<bean:message key="errata.edit.deletebug"/>" />
            </a>
            </td>
          </table>
          <hr />
        </c:forEach>

        <%-- Display an empty bug shell for input --%>
          <table>
            <tr>
              <td><bean:message key="errata.create.jsp.id"/></td>
              <td><html:text property="buglistIdNew" value="" size="6"/></td>
            </tr>
            <tr>
              <td><bean:message key="errata.create.jsp.summary"/></td>
              <td><html:text property="buglistSummaryNew" value="" size="60"/></td>
            </tr>
          </table>
      </td>
    </tr>

    <tr>
      <th nowrap="nowrap">
        <bean:message key="errata.create.jsp.keywords"/> <br />
        <bean:message key="errata.edit.commadelimited"/>
      </th>
      <td class="small-form">
        <html:text property="keywords" size="40"/>
      </td>
    </tr>

    <tr>
      <th nowrap="nowrap">
        <bean:message key="errata.create.jsp.references"/>
      </th>
      <td class="small-form">
        <html:textarea property="refersTo" cols="40" rows="6"/>
      </td>
    </tr>

    <tr>
      <th nowrap="nowrap">
        <bean:message key="errata.create.jsp.notes"/>
      </th>
      <td class="small-form">
        <html:textarea property="notes" cols="40" rows="6"/>
      </td>
    </tr>

  </table>


  <input type="hidden" name="eid" value="<c:out value="${param.eid}"/>" />
  <div align="right">
    <hr />
    <html:submit property="dispatch">
      <bean:message key="errata.edit.updateerrata"/>
    </html:submit>
  </div>

  </html:form>

</body>
</html>
