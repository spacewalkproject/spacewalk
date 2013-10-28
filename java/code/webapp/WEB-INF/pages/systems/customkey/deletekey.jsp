<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>

<html:html xhtml="true">
<body>
<br>

<div>

  <div class="toolbar-h1">
    <div class="toolbar"></div>
      <img src="/img/rhn-icon-keyring.gif" alt="" />
        <bean:message key="system.jsp.customkey.deletetitle"/>

        <a href="/rhn/help/reference/en-US/s1-sm-systems.jsp#s2-sm-system-cust-info"
		target="_new" class="help-title">
          <img src="/img/rhn-icon-help.gif" alt="Help Icon" />
        </a>
      </div>

      <div class="page-summary">
        <p><bean:message key="system.jsp.customkey.deletemsg"/></p>
      </div>

      <hr />

      <form action="/rhn/systems/customdata/DeleteCustomKey.do?cikid=${cikid}" name="edit_token" method="post">
        <rhn:csrf />
        <table class="details">
          <tr>
            <th><bean:message key="system.jsp.customkey.keylabel"/>:</th>
            <td><input disabled="true" type="text" name="label" length="64" size="30" value="<c:out value="${label}" />"/>
            </td>
          </tr>

          <tr>
            <th><bean:message key="system.jsp.customkey.description"/>:</th>
            <td>
              <textarea disabled="true" wrap="virtual" rows="6" cols="50" name="description"><c:out value="${description}" /></textarea>
            </td>
          </tr>
        </table>

        <div class="text-right">
          <hr />

          <input type="submit" name="DeleteKey" value="Delete Key" />

          <rhn:submitted/>
        </div>
      </form>

    </div>

  </body>
</html:html>
