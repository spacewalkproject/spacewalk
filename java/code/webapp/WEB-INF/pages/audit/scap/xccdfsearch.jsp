<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>

<html:xhtml/>
<html>
<head>
  <script language="javascript">
    Event.observe(window, 'load', function() {
        scanDateSearchOptions();
        });
    function scanDateSearchOptions() {
      if ($("scanDateOptionsCheckBox").checked) {
        Element.show("scanDateOptions");
      } else {
        Element.hide("scanDateOptions");
      }
    }
  </script>
</head>

<body>

<rhn:toolbar base="h1" img="/img/rhn-icon-search.gif" imgAlt="search.alt.img">
  <bean:message key="scapsearch.jsp.toolbar"/>
</rhn:toolbar>

<p><bean:message key="scapsearch.jsp.summary"/></p>
<p><bean:message key="scapsearch.jsp.instructions"/></p>

<html:form action="/audit/scap/Search.do">
  <rhn:csrf/>
  <div class="search-choises">
    <div class="search-choices-group">
      <table class="details">
        <tr><th><bean:message key="scapsearch.jsp.searchfor"/>:</th>
          <td>
            <html:text property="search_string" name="search_string"
                value="${search_string}" maxlength="100" accesskey="4"/>
            <html:submit>
              <bean:message key="button.search" />
            </html:submit>
            <br/>
            <span class="small-text">
              <bean:message key="scapsearch.jsp.whatsearch.tip"/>
            </span>
          </td>
        </tr>
        <tr><th><bean:message key="scapsearch.jsp.withresult"/>:</th>
          <td>
            <html:select property="result_filter">
              <html:options collection="allResults" property="label" labelProperty="label"/>
            </html:select>
          </td>
        </tr>
        <tr><th><bean:message key="systemsearch.jsp.wheretosearch"/></th>
          <td>
            <div style="text-align: left">
              <html:radio property="whereToSearch" value="all" styleId="whereToSearch-all"/>
              <label for="whereToSearch-all"><bean:message key="systemsearch.jsp.searchallsystems"/></label>
            </div>
            <div style="text-align: left">
              <html:radio property="whereToSearch" value="system_list" styleId="whereToSearch-system_list"/>
              <label for="whereToSearch-system_list"><bean:message key="systemsearch.jsp.searchSSM"/></label>
            </div>
          </td>
        </tr>
        <tr><th><bean:message key="scapsearch.jsp.scan_date"/>:</th>
          <td>
            <html:checkbox styleId="scanDateOptionsCheckBox" property="optionScanDateSearch" onclick="javascript:scanDateSearchOptions()">
              <label for="scanDateOptionsCheckBox">
                <bean:message key="scapsearch.jsp.search_by_scan_dates"/>
              </label>
            </html:checkbox>
            </br>
            <div id="scanDateOptions" class="indent">
              <table>
                <tr><td><bean:message key="scapsearch.jsp.start_date"/>:</td>
                  <td><jsp:include page="/WEB-INF/pages/common/fragments/date-picker.jsp">
                      <jsp:param name="widget" value="start"/>
                    </jsp:include>
                  </td>
                </tr>
                <tr><td><bean:message key="scapsearch.jsp.end_date"/>:</td>
                  <td><jsp:include page="/WEB-INF/pages/common/fragments/date-picker.jsp">
                      <jsp:param name="widget" value="end"/>
                    </jsp:include>
                  </td>
                <tr>
              </table>
            </div>
          </td>
        </tr>
        <tr><th><bean:message key="scapsearch.jsp.show_as"/>:</th>
          <td>
            <div style="text-align: left">
              <html:radio property="show_as" value="rr" styleId="show_as-rr"/>
              <label for="show_as-rr"><bean:message key="scapsearch.jsp.list_rr"/></label>
            </div>
            <div style="text-align: left">
              <html:radio property="show_as" value="tr" styleId="show_as-tr"/>
              <label for="show_as-tr"><bean:message key="scapsearch.jsp.list_tr"/></label>
            </div>
          </td>
        </tr>
      </table>
    </div> <!-- search-choices-group -->
  </div> <!-- search-choices -->
  <input type="hidden" name="submitted" value="true"/>
</html:form>

<c:if test="${(search_string != null && search_string != '')}">
  <c:set var="pageList" value="${requestScope.pageList}"/>
  <hr/>

  <rl:listset name="searchSet" legend="xccdf">
    <rhn:csrf/>
    <c:choose>
      <c:when test="${param.show_as == 'tr'}">
        <rl:list emptykey="generic.jsp.none" name="searchResults" dataset="pageList">
          <%@ include file="/WEB-INF/pages/common/fragments/audit/xccdf-easy-list.jspf" %>
        </rl:list>
        <rl:csv dataset="pageList" name="searchResults"
          exportColumns="id,sid,serverName,profile,satisfied,dissatisfied,satisfactionUnknown"/>
      </c:when>

      <c:otherwise>
        <rl:list emptykey="generic.jsp.none" name="searchResults" dataset="pageList">
          <rl:decorator name="PageSizeDecorator"/>
          <%@ include file="/WEB-INF/pages/common/fragments/audit/rule-common-columns.jspf" %>
        </rl:list>
        <rl:csv dataset="pageList" name="searchResults"
          exportColumns="id,documentIdref,identsString,evaluationResult"/>
      </c:otherwise>
    </c:choose>

    <!-- there are two forms here, need to keep the formvars around for pagination -->
    <input type="hidden" name="submitted" value="true"/>
    <input type="hidden" name="search_string" value="${search_string}"/>
    <input type="hidden" name="whereToSearch" value="${param.whereToSearch}"/>
    <input type="hidden" name="show_as" value="${param.show_as}"/>
    <input type="hidden" name="result_filter" value="${param.result_filter}"/>
    <input type="hidden" name="optionScanDateSearch" value="${param.optionScanDateSearch}"/>
    <input type="hidden" name="start_year" value="${param.start_year}"/>
    <input type="hidden" name="start_month" value="${param.start_month}"/>
    <input type="hidden" name="start_day" value="${param.start_day}"/>
    <input type="hidden" name="start_hour" value="${param.start_hour}"/>
    <input type="hidden" name="start_minute" value="${param.start_minute}"/>
    <input type="hidden" name="start_am_pm" value="${param.start_am_pm}"/>
    <input type="hidden" name="end_year" value="${param.end_year}"/>
    <input type="hidden" name="end_month" value="${param.end_month}"/>
    <input type="hidden" name="end_day" value="${param.end_day}"/>
    <input type="hidden" name="end_hour" value="${param.end_hour}"/>
    <input type="hidden" name="end_minute" value="${param.end_minute}"/>
    <input type="hidden" name="end_am_pm" value="${param.end_am_pm}"/>
  </rl:listset>
</c:if>

</body>
</html>
