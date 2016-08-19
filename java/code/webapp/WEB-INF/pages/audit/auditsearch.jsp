<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>


<html>
<head>
</head>
<body>

<rhn:toolbar base="h1" icon="header-system"
 helpUrl="">
  <bean:message key="auditsearch.jsp.header"/>
</rhn:toolbar>

<script type="text/javascript">
<c:out escapeXml="false" value="//<![CDATA[" />
    var typeSets = <c:out escapeXml="false" value="${auJsonTypes}" />;

    function check_defaults() {
        check_set("default");
    }

    function check_all() {
        set_checkboxes("checked");
    }

    function uncheck_all() {
        set_checkboxes("");
    }

    // check a specified set of checkboxes
    function check_set(setName) {
        uncheck_all();

        $.each(typeSets[setName], function(index, typeName) {
            $("#type_" + typeName).prop('checked', 'checked');
        });
    }

    function check_set_from_option(ev) {
        check_set(this.innerHTML);
        ev.stopPropagation();
    }

    // set all checkboxes to val
    function set_checkboxes(val) {
        $("input[type=checkbox]").prop('checked', val);
    }

    $(document).ready(function() {
        check_defaults();

        $('#check_all_button').click(check_all);
        $('#uncheck_all_button').click(uncheck_all);

        // create the 'set selector' dropdown
        var setChooser = $(document.createElement('select'));
        setChooser.append(
            $(document.createElement('option')).html('Check [set]')
        );

        $.each(typeSets, function(key, typeName) {
            setChooser.append(
              $(document.createElement('option'))
              .click(check_set_from_option)
              .html(key)
            );
        });

        $('#checkboxControls').append(setChooser);
    });

<c:out escapeXml="false" value="//]]>" />
</script>
<div class="panel panel-default">
    <div class="panel-body">
        <html:form action="/audit/Search.do">
        <rhn:csrf />
        <rhn:submitted />
        <div class="text-right form-group">
            <button type="submit" class="btn btn-success">
                <rhn:icon type="header-search" />
                <bean:message key="button.search"/>
            </button>
        </div>
        <div class="panel panel-default">
            <div class="panel-heading">
                <h4>Machine / Time range</h4>
            </div>
            <div class="panel-body">
                <div class="col-md-4">
                    <html:select property="machine">
                        <html:options collection="machines" property="name" />
                    </html:select>
                </div>
                <div class="col-md-8">
                    <c:choose>
                        <c:when test="${startDisp == '<<' || endDisp == '>>'}">
                            <jsp:include page="/WEB-INF/pages/common/fragments/date-picker.jsp">
                                <jsp:param name="widget" value="start" />
                            </jsp:include>
                            <br />
                            <jsp:include page="/WEB-INF/pages/common/fragments/date-picker.jsp">
                                <jsp:param name="widget" value="end" />
                            </jsp:include>

                            <rhn:hidden name="parseDates" value="true" />
                        </c:when>

                        <c:otherwise>
                            <span style="padding: 0 10px"><c:out value="${startDisp}" /></span>
                            <br />
                            <span style="padding: 0 10px"><c:out value="${endDisp}" /></span>
                        </c:otherwise>
                    </c:choose>

                    <html:hidden property="startMilli" />
                    <html:hidden property="endMilli" />
                </div>
            </div>
        </div>

        <div class="panel panel-default">
            <div class="panel-heading">
                <h4>Audit Types</h4>
            </div>
            <div class="panel-body">
<table class="table">
                    <tr>
                        <td id="checkboxControls" colspan="3">
                            <button type="button" class="btn btn-default" id="check_all_button">Check all</button>
                            <button type="button" class="btn btn-default" id="uncheck_all_button">Uncheck all</button>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <ul style="list-style-type: none; padding-left: 0; margin-top: 0;">
                                <c:forEach var="autype" items="${types}" begin="0" step="3">
                                    <li>
                                        <html:multibox property="autypes" value="${autype}" styleId="type_${autype}" />
                                        <label for="type_${autype}"><c:out value="${autype}" /></label>
                                    </li>
                                </c:forEach>
                            </ul>
                        </td>
                        <td>
                            <ul style="list-style-type: none; padding-left: 0; margin-top: 0;">
                                <c:forEach var="autype" items="${types}" begin="1" step="3">
                                    <li>
                                        <html:multibox property="autypes" value="${autype}" styleId="type_${autype}" />
                                        <label for="type_${autype}"><c:out value="${autype}" /></label>
                                    </li>
                                </c:forEach>
                            </ul>
                        </td>
                        <td>
                            <ul style="list-style-type: none; padding-left: 0; margin-top: 0;">
                                <c:forEach var="autype" items="${types}" begin="2" step="3">
                                    <li>
                                        <html:multibox property="autypes" value="${autype}" styleId="type_${autype}" />
                                        <label for="type_${autype}"><c:out value="${autype}" /></label>
                                    </li>
                                </c:forEach>
                            </ul>
                        </td>
                    </tr>
                </table>
            </div>
        </div>
        <div class="text-right">
            <button type="submit" class="btn btn-success">
                <rhn:icon type="header-search" />
                <bean:message key="button.search"/>
            </button>
        </div>
        </html:form>
    </div>
</div>
</body>
</html>

