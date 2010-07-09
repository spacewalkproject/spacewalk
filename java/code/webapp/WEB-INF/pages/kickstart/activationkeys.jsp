<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>

<html:html xhtml="true">
<body>
<%@ include file="/WEB-INF/pages/common/fragments/kickstart/kickstart-toolbar.jspf" %>

<rhn:dialogmenu mindepth="0" maxdepth="1"
    definition="/WEB-INF/nav/kickstart_details.xml"
    renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />

<h2><bean:message key="kickstartdetails.jsp.header2"/></h2>



<div>
  <p>
    <bean:message key="kickstart.activationkeys.jsp.summary" arg0="${ksdata.id}"/>
  </p>
<c:set var="pageList" value="${requestScope.pageList}" />
    <form method="post" name="rhn_list" action="/rhn/kickstart/ActivationKeysSubmit.do">
      <rhn:submitted />
      <rhn:list pageList="${requestScope.pageList}" noDataText="kickstart.activationkeys.jsp.nokeys">

  <rhn:listdisplay   set="${requestScope.set}" hiddenvars="${requestScope.newset}">

	    <rhn:set value="${current.id}" />
        <rhn:column header="kickstart.activationkeys.jsp.description">
			<rhn:require acl="user_role(activation_key_admin)">
            	<a href="/rhn/activationkeys/Edit.do?tid=${current.id}">${current.note}</a>
   			</rhn:require>
   			<rhn:require acl="not user_role(activation_key_admin)">
   				${current.note}
			</rhn:require>
        </rhn:column>
        <rhn:column header="kickstart.activationkeys.jsp.key">
            ${current.token}
        </rhn:column>
        <rhn:column header="kickstart.activationkeys.jsp.usagelimit">
          <c:if test="${current.usageLimit != null}">
            ${current.systemCount}/${current.usageLimit}
          </c:if>
          <c:if test="${current.usageLimit == null}">
            <bean:message key="kickstart.activationkeys.jsp.nousagelimit"/>
          </c:if>
        </rhn:column>

      </rhn:listdisplay>
      </rhn:list>

  <p>
    <bean:message key="kickstart.activationkeys.jsp.note" arg0="${ksdata.id}"/>
  </p>

  <p>
    <bean:message key="kickstart.activationkeys.jsp.warning" arg0="${ksdata.id}"/>
  </p>

<hr />
<input type="hidden" name="ksid" value="<c:out value="${param.ksid}"/>" />
<input type="hidden" name="returnvisit" value="<c:out value="${param.returnvisit}"/>"/>
<div align="right">
  <html:submit property="dispatch">
    <bean:message key="kickstart.activationkeys.jsp.submit"/>
  </html:submit>
</div>

    </form>
</div>

</body>
</html:html>

