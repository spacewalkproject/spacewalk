<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<html:html>
<head>
<meta http-equiv="Pragma" content="no-cache" />

<script language="javascript" type="text/javascript">

function swapValues(fromCtlId, toCtlId) {
   var fromCtl = document.getElementById(fromCtlId);
   var toCtl = document.getElementById(toCtlId);
   toCtl.value = fromCtl.value;
}

function moveNext() {
   var form = $("form[name='kickstartCreateWizardForm']");
   swapValues("wizard-nextstep", "wizard-curstep");
   form.submit();
}

function refresh() {
   var form = $("form[name='kickstartCreateWizardForm']");
   form.submit();
}

function toggleKSTree(what) {
   var form = $("form[name='kickstartCreateWizardForm']");
   var select = form.find("select[name='kstreeId']");
   if(what.checked) {
       select.prop("disabled", "disabled");
   } else {
       select.prop("disabled", false);
   }
}

function clickNewestRHTree() {
   var form = $("form[name='kickstartCreateWizardForm']");
   var treeCheckbox = form.find("input[name='useNewestTree']")
   var rhTreeCheckbox = form.find("input[name='useNewestRHTree']")
   if(rhTreeCheckbox.is(':checked')) {
       treeCheckbox.attr('checked', false);
   }
}

function clickNewestTree() {
   var form = $("form[name='kickstartCreateWizardForm']");
   var treeCheckbox = form.find("input[name='useNewestTree']")
   var rhTreeCheckbox = form.find("input[name='useNewestRHTree']")
   if(treeCheckbox.is(':checked')) {
       rhTreeCheckbox.attr('checked', false);
   }
}
</script>
</head>

<body>
    <html:form method="post" action="/kickstart/CreateProfileWizard.do" styleClass="form-horizontal">
        <rhn:csrf />
        <rhn:submitted />
        <html:hidden property="wizardStep" styleId="wizard-curstep" />
        <html:hidden property="nextStep" styleId="wizard-nextstep" />
        <html:hidden property="previousChannelId" />
        <rhn:toolbar base="h1" icon="header-kickstart"><bean:message key="kickstart.jsp.create.wizard.step.one"/></rhn:toolbar>
        <p><bean:message key="kickstart.jsp.create.wizard.first.heading1" /></p>

        <div class="panel panel-default">
      <ul class="list-group">
        <div class="row">
          <div class="col-sm-2">
            <rhn:required-field key="kickstart.jsp.create.wizard.kickstart.profile.label"/>:
          </div>
          <div class="col-sm-10">
            <html:text property="kickstartLabel" size="40" maxlength="80" styleClass="form-control"/>
          </div>
        </div>
      </ul>
      <ul class="list-group">
        <div class="row">
          <div class="col-sm-2">
            <rhn:required-field key="softwareedit.jsp.basechannel"/>:
          </div>
          <div class="col-sm-10">
            <c:choose>
              <c:when test="${nochannels == null}">
                <html:select property="currentChannelId" onchange="refresh();" styleClass="form-control">
                  <html:optionsCollection property="channels" label="name" value="id" />
                </html:select>
              </c:when>
              <c:otherwise>
                <b><bean:message key="tree-form.jspf.nochannels" /></b>
              </c:otherwise>
            </c:choose>
          </div>
        </div>
      </ul>
      <ul class="list-group">
        <div class="row">
          <div class="col-sm-2">
            <rhn:required-field key="kickstart.jsp.create.wizard.kstree.label"/>:
          </div>
          <div class="col-sm-10">
            <c:choose>
              <c:when test="${notrees == null}">
                <html:select property="kstreeId" styleClass="form-control">
                  <html:optionsCollection property="kstrees" label="label" value="id" />
                </html:select>
                <c:if test="${redHatTreesAvailable != null}">
                  <br />
                  <label>
                    <input type="checkbox" name="useNewestRHTree" value="0"
                      onclick="toggleKSTree(this); clickNewestRHTree()" />
                    <bean:message key="kickstart.jsp.create.wizard.kstree.always_new_RH"/>
                  </label>
                </c:if>
                <br />
                <label>
                  <input type="checkbox" name="useNewestTree" value="0"
                    onclick="toggleKSTree(this); clickNewestTree()" />
                  <bean:message key="kickstart.jsp.create.wizard.kstree.always_new"/>
                </label>
              </c:when>
              <c:otherwise>
                <b><bean:message key="kickstart.edit.software.notrees.jsp" /></b>
              </c:otherwise>
            </c:choose>
          </div>
        </div>
      </ul>
      <ul class="list-group">
        <div class="row">
          <div class="col-sm-2">
            <bean:message key="kickstart.jsp.create.wizard.virtualization.label" />
          </div>
          <div class="col-sm-10">
            <html:select property="virtualizationTypeLabel" styleClass="form-control">
              <html:optionsCollection property="virtualizationTypes" label="formattedName" value="label" />
            </html:select>
          </div>
        </div>
      </ul>
    </div>

    <div align="right">
     <input type="button" value="<bean:message key='wizard.jsp.next.step'/>" onclick="moveNext();" class="btn btn-default"/>
    </div>
    </html:form>
</body>
</html:html>

