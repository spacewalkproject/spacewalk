<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>

<html:xhtml/>
<html>
<head>
    <meta name="page-decorator" content="none" />

    <style type="text/css">
        .fixedwidth { font-family: Courier, Monospace; }
    </style>
</head>
<body>

<rhn:toolbar base="h1" img="/img/rhn-icon-system.gif" imgAlt="audit.jsp.alt"
 helpUrl="/rhn/help/reference/en-US/s2-sm-system-overview.jsp">
  <bean:message key="auditsearch.jsp.header"/>
</rhn:toolbar>

<script type="text/javascript">
<c:out escapeXml="false" value="//<![CDATA[" />
    var typeSets = new Hash(
        <c:out escapeXml="false" value="${auJsonTypes}" />
    );

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

        typeSets.get(setName).each(function(typeName) {
            var cbox = $("type_" + typeName);

            if (cbox) {
                cbox.checked = "checked";
            }
        });
    }

    function check_set_from_option(ev) {
        check_set(this.innerHTML);
        ev.stop();
    }

    // set all checkboxes to val
    function set_checkboxes(val) {
        $$("input[type=checkbox]").each(function(cbox) {
            cbox.checked = val;
        });
    }

    function init() {
        check_defaults();

        Event.observe('check_all_button', 'click', check_all);
        Event.observe('uncheck_all_button', 'click', uncheck_all);

        // create the 'set selector' dropdown
        var setChooser = new Element('select');
        setChooser.insert(new Element('option').update('Check [set]'));

        typeSets.keys().each(function(key) {
            setChooser.insert(
                new Element('option')
                    .observe('click', check_set_from_option)
                    .update(key)
            );
        });

        $('checkboxControls').insert(setChooser);
    }

    document.observe("dom:loaded", init);
<c:out escapeXml="false" value="//]]>" />
</script>

<html:form action="/audit/Search.do">
<rhn:csrf />
<rhn:submitted />

<div class="search-choices">
    <div class="search-choices-group">
        <table class="details">
            <tr>
                <th colspan="3">Machine / Time range</th>
            </tr>
            <tr style="text-align: center;">
                <td style="text-align: center; vertical-align: middle;">
                    <html:select property="machine">
                        <html:options collection="machines" property="name" />
                    </html:select>
                </td>
                <td colspan="2">
                    <c:choose>
                        <c:when test="${startDisp == '<<' || endDisp == '>>'}">
                            <jsp:include page="/WEB-INF/pages/common/fragments/date-picker.jsp">
                                <jsp:param name="widget" value="start" />
                            </jsp:include>
                            <br />
                            <jsp:include page="/WEB-INF/pages/common/fragments/date-picker.jsp">
                                <jsp:param name="widget" value="end" />
                            </jsp:include>

                            <input type="hidden" name="parseDates" value="true" />
                        </c:when>

                        <c:otherwise>
                            <span style="padding: 0 10px"><c:out value="${startDisp}" /></span>
                            <br />
                            <span style="padding: 0 10px"><c:out value="${endDisp}" /></span>
                        </c:otherwise>
                    </c:choose>

                    <html:hidden property="startMilli" />
                    <html:hidden property="endMilli" />
                </td>
            </tr>
            <tr>
                <th colspan="3">Audit Types</th>
            </tr>
            <tr>
                <td id="checkboxControls" colspan="3">
                    <button type="button" id="check_all_button">Check all</button>
                    <button type="button" id="uncheck_all_button">Uncheck all</button>
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
            <tr>
                <td>&nbsp;</td><td>&nbsp;</td>
                <td style="text-align: right;"><html:submit><bean:message key="button.search" /></html:submit></td>
            </tr>
        </table>
    </div>
</div>

</html:form>

</body>
</html>

