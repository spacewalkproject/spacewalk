<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
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
//<![CDATA[
    var resultFilter = {
        "ANOM_ABEND": [
            { "gid": 0 },
            { "pid": 0 },
            { "ses": 0 }
        ],
        "ANOM_PROMISCUOUS": [
            { "gid": 0 },
            { "old_prom": 0 },
            { "ses": 0 }
        ],
        "AVC": [
            { "pid": 0 }
        ],
        "CONFIG_CHANGE": [
            { "auid": 0 },
            { "subj": 0 }
        ],
        "CRED_ACQ": [
            { "auid": 0 },
            { "pid": 0 },
            { "ses": 0 },
            { "subj": 0 }
        ],
        "CRED_DISP": [
            { "pid": 0 },
            { "ses": 0 },
            { "subj": 0 }
        ],
        "CRED_REFR": [
            { "pid": 0 },
            { "ses": 0 },
            { "subj": 0 }
        ],
        "DAEMON_END": [
            { "auid": 0 },
            { "pid": 0 },
            { "subj": 0 }
        ],
        "DAEMON_START": [
            { "auid": 0 },
            { "pid": 0 },
            { "subj": 0 }
        ],
        "LOGIN": [
            { "pid": 0 },
            { "ses": 0 }
        ],
        "MAC_CONFIG_CHANGE": [
            { "ses": 0 }
        ],
        "MAC_POLICY_LOAD": [
            { "ses": 0 }
        ],
        "MAC_STATUS": [
            { "ses": 0 }
        ],
        "SYSCALL": [
            { "arch": 0 },
            { "egid": 0, "euid": 0 },
            { "fsgid": 0, "fsuid": 0 },
            { "items": 0 },
            { "key": 0 },
            { "pid": 0, "ppid": 0 },
            { "ses": 0 },
            { "sgid": 0, "suid": 0 }
        ],
        "USER_ACCT": [
            { "auid": 0 },
            { "pid": 0 },
            { "ses": 0 },
            { "subj": 0 }
        ],
        "USER_AUTH": [
            { "auid": 0 },
            { "pid": 0 },
            { "ses": 0 },
            { "subj": 0 }
        ],
        "USER_AVC": [
            { "auid": 0 },
            { "pid": 0 },
            { "seqno": 0 },
            { "ses": 0 },
            { "subj": 0 }
        ],
        "USER_CHAUTHTOK": [
            { "pid": 0 },
            { "ses": 0 },
            { "subj": 0 }
        ],
        "USER_CMD": [
            { "pid": 0 },
            { "ses": 0 }
        ],
        "USER_END": [
            { "pid": 0 },
            { "ses": 0 },
            { "subj": 0 }
        ],
        "USER_ERR": [
            { "auid": 0 },
            { "pid": 0 },
            { "ses": 0 },
            { "subj": 0 }
        ],
        "USER_LOGIN": [
            { "pid": 0 },
            { "ses": 0 },
            { "subj": 0 }
        ],
        "USER_ROLE_CHANGE": [
            { "default-context": 0 },
            { "new-range": 0, "old-range": 0 },
            { "new-role": 0, "old-role": 0 },
            { "new-seuser": 0, "old-seuser": 0 },
            { "pid": 0 },
            { "selected-context": 0 },
            { "ses": 0 },
            { "subj": 0 }
        ],
        "USER_START": [
            { "pid": 0 },
            { "ses": 0 },
            { "subj": 0 }
        ]
    };

    document.observe("dom:loaded", function() {
        for(var autype in resultFilter) {
            // the '<' below is okay because of the ![CDATA[ above
            for(var idx = 0; idx < resultFilter[autype].length; idx++) {
                for(var key in resultFilter[autype][idx]) {
                    if (!resultFilter[autype][idx][key]) {
                        $$("div[name=kv_" + autype + "_" + key + "]").each(function(node) {
                            node.style.borderBottom = "thin dashed black";
                            node.style.borderRight = "thin dashed black";
                            //node.style.textDecoration = "underline";
                            //node.style.fontStyle = "italic";
                            node.writeAttribute("hideme", "true");
                            node.hide();
                        });
                    }
                }
            }
        }

        var hideStr = "[-] Hide";
        var showStr = "[+] Show all";

        function toggleKV(event) {
            if (this.innerHTML == showStr) { // show all elements!
                this.update(hideStr);
                this.siblings().invoke("show");
            }
            else { // hide the previously hidden ones
                this.update(showStr);
                this.siblings().findAll(function(s) {
                    return s.readAttribute("hideme") == "true";
                }).invoke("hide");
            }
            event.stop();
        }

        $$("span[name=audit_kv]").each(function(node) {
            var aElem = new Element("a", { href: "#" }).update(showStr);
            Event.observe(aElem, "click", toggleKV);
            Element.insert(node, aElem);
        });
    });
//]]>
</script>

<div style="font-weight: bold; text-align: center;">
    <c:out value="${machine}" />
    (<c:out value="${startDisp}" />
    - <c:out value="${endDisp}" />)
</div>

<c:set var="resultList" value="${requestScope.result}" />
<rl:listset name="auditList">
    <rl:list dataset="resultList" emptykey="auditview.jsp.norecords">
        <rl:column sortable="false"
                   bound="false"
                   headertext="Serial#"
                   styleclass="first-column fixedwidth">
            <c:out value="${current.serial}" escapeXml="true" />
        </rl:column>

        <rl:column sortable="false"
                   bound="false"
                   headertext="Date/Time"
                   styleclass="fixedwidth">
            <c:out value="${current.time}" escapeXml="true" />
        </rl:column>

        <rl:column sortable="false"
                   bound="false"
                   headertext="Type"
                   styleclass="fixedwidth">
            <c:out value="${current.type}" escapeXml="true" />
        </rl:column>

        <rl:column sortable="false"
                   bound="false"
                   headertext="Misc."
                   styleclass="last-column fixedwidth">
            <span name="audit_kv">
                <c:forEach var="item" items="${current.kvmap}">
                    <div name="kv_${current.type}_${item.key}">
                        <c:out value="${item.key}" escapeXml="true" />:
                        <c:out value="${item.value}" escapeXml="true" />
                    </div>
                </c:forEach>
            </span>
        </rl:column>
    </rl:list>

    <c:if test="${unreviewable == 'true'}">
        <input type="hidden" name="unreviewable" value="${unreviewable}" />
    </c:if>

    <input type="hidden" name="machine" value="${machine}" />
    <input type="hidden" name="startMilli" value="${startMilli}" />
    <input type="hidden" name="endMilli" value="${endMilli}" />

    <c:forEach var="saved_type" items="${autypes}">
        <input type="hidden" name="autypes" value="${saved_type}" />
    </c:forEach>
</rl:listset>

<c:choose>
    <c:when test="${reviewedBy != null}">
        <div style="text-align: center;">
            Reviewed by <c:out value="${reviewedBy}" /> on <c:out value="${reviewedOn}" />
        </div>
    </c:when>

    <c:when test="${startDisp == '<<' || endDisp == '>>' || unreviewable == 'true'}">
        <%-- do nothing --%>
    </c:when>

    <c:otherwise>
        <form action="/rhn/audit/Machine.do" method="post">
            <input type="hidden" name="machine" value="${machine}" />
            <input type="hidden" name="startMilli" value="${startMilli}" />
            <input type="hidden" name="endMilli" value="${endMilli}" />

            <div style="text-align: center;">
                <input type="checkbox" name="reviewed" />
                <span>I, <c:out value="${user.firstNames}" />, certify I have reviewed these audit logs.</span>
                <br />
                <input type="submit" value="Mark reviewed" />
            </div>
        </form>
    </c:otherwise>
</c:choose>

</body>
</html>

