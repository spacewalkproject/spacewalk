<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>

<html:xhtml/>
<html>

<body>

<html:messages id="message" message="true">
    <rhn:messages><c:out escapeXml="false" value="${message}" /></rhn:messages>
</html:messages>

<%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>
    <h2>
      <img src="/img/rhn-icon-packages.gif" />
      <bean:message key="verifyconfirm.jsp.header" />
    </h2>
    <rhn:systemtimemessage server="${system}" />

    <form method="POST" name="rhn_list" action="/rhn/systems/details/packages/VerifyConfirmSubmit.do">
       <rhn:list pageList="${requestScope.pageList}" noDataText="packagelist.jsp.nopackages">
       <rhn:listdisplay filterBy="packagelist.jsp.packagename">
          <rhn:column header="packagelist.jsp.packagename" width="95%"
                url="/network/software/packages/details.pxt?sid=${param.sid}&id_combo=${current.idCombo}">
            ${current.nvre}
          </rhn:column>
      </rhn:listdisplay>
      </rhn:list>
          <div align="right">
      <hr />
      
      <html:submit property="dispatch">
      <bean:message key="verifyconfirm.jsp.confirm"/>
      </html:submit>
    </div>
    <input type="hidden" name="sid" value="${param.sid}" />
    </form>
</body>
</html>
