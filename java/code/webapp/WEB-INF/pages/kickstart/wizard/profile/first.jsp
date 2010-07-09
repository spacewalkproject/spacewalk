<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<html:html xhtml="true">

<head>
<meta http-equiv="Pragma" content="no-cache" />

<script language="javascript" type="text/javascript">

function swapValues(fromCtlId, toCtlId) {
   var fromCtl = document.getElementById(fromCtlId);
   var toCtl = document.getElementById(toCtlId);
   toCtl.value = fromCtl.value;
}

function moveNext() {
   var form = document.getElementById("wizard-form");
   swapValues("wizard-nextstep", "wizard-curstep");
   form.submit();
}

function refresh() {
   var form = document.getElementById("wizard-form");
   form.submit();
}
</script>
</head>

<body>
<br />
<div>
  <html:form styleId="wizard-form" method="post" action="/kickstart/CreateProfileWizard.do">
    <html:hidden property="wizardStep" styleId="wizard-curstep" />
    <html:hidden property="nextStep" styleId="wizard-nextstep" />
    <html:hidden property="previousChannelId" />
    <h1><bean:message key="kickstart.jsp.create.wizard.step.one"/></h1>
    <table class="details" width="80%">
        <tr>
            <td colspan="2"><bean:message key="kickstart.jsp.create.wizard.first.heading1" /></td>
        </tr>
        <tr>
            <th width="10%"><rhn:required-field key="kickstart.jsp.create.wizard.kickstart.profile.label"/>:</th>
            <td><html:text property="kickstartLabel" size="40" maxlength="80" /></td>
        </tr>
        <tr>
            <th width="10%"><rhn:required-field key="softwareedit.jsp.basechannel"/>:</th>
            <td>
                <c:choose>
                  <c:when test="${nochannels == null}">
                   <html:select property="currentChannelId" onchange="refresh();">
                     <html:optionsCollection property="channels" label="name" value="id" />
                   </html:select>
                  </c:when>
                  <c:otherwise>
                    <b><bean:message key="tree-form.jspf.nochannels" /></b>
                  </c:otherwise>
                </c:choose>
            </td>
        </tr>
        <tr>
            <th width="10%"><rhn:required-field key="kickstart.jsp.create.wizard.kstree.label"/>:</th>
            <td>
                  <c:choose>
                    <c:when test="${notrees == null}">
                      <html:select property="kstreeId">
                       <html:optionsCollection property="kstrees" label="label" value="id" />
                      </html:select>
                    </c:when>
                    <c:otherwise>
                      <b><bean:message key="kickstart.edit.software.notrees.jsp" /></b>
                    </c:otherwise>
                  </c:choose>

            </td>
        </tr>
        <tr>
        <tr>
            <th width="10%"><bean:message key="kickstart.jsp.create.wizard.virtualization.label" /></th>
            <td colspan="2" align="left">
              <html:select property="virtualizationTypeLabel">
                <html:optionsCollection property="virtualizationTypes" label="formattedName" value="label" />
              </html:select>
            </td>
        </tr>
        <tr>
            <td colspan="2" align="right">
                <input type="button" value="<bean:message key="wizard.jsp.next.step" />" onclick="moveNext();" />
            </td>
        </tr>
    </table>

  </html:form>
</div>
</body>
</html:html>

