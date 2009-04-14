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

  <html:messages id="message" message="true">
    <rhn:messages><c:out escapeXml="false" value="${message}" /></rhn:messages>
  </html:messages>
	
  <rhn:toolbar base="h1" img="/img/rhn-icon-errata.gif" imgAlt="errata.common.errataAlt"
	           helpUrl="/rhn/help/channel-mgmt/en-US/channel-mgmt-Custom_Errata_Management-Creating_and_Editing_Errata.jsp">
    <bean:message key="erratalist.jsp.erratamgmt"/>
  </rhn:toolbar>

  <h2><bean:message key="errata.create.jsp.createerrata" /></h2>

  <div class="page-summary">
    <p><bean:message key="errata.create.jsp.instructions" /></p>
  </div>


  <html:errors />
  <html:form action="/errata/manage/CreateSubmit">

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
        <bean:message key="errata.create.jsp.id"/>
        <html:text property="buglistId" size="6" />
        <bean:message key="errata.create.jsp.summary"/>
        <html:text property="buglistSummary" size="60" />
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


  <input type="hidden" name="eid" value="0" />
  <div align="right">
    <hr />
    <html:submit>
      <bean:message key="errata.create.jsp.createerrata"/>
    </html:submit>
  </div>

  </html:form>

</body>
</html>
