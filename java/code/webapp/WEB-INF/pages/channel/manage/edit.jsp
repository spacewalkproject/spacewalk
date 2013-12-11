<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>

<html>
    <body>
        <script type="text/javascript">
            function setChildChannelArchChecksum() {
                var baseChannelArches = {};
            <c:forEach items="${parentChannelArches}" var="parentChannel">
                    baseChannelArches["<c:out value="${parentChannel.key}" />"] = "<c:out value="${parentChannel.value}"/>";
            </c:forEach>
                    var baseChannelChecksums = {};
            <c:forEach items="${parentChannelChecksums}" var="parentChannel">
                    baseChannelChecksums["<c:out value="${parentChannel.key}" />"] = "<c:out value="${parentChannel.value}"/>";
            </c:forEach>
                    document.getElementById("parentarch").value = baseChannelArches[document.getElementById("parent").value];
                    document.getElementById("checksum").value = baseChannelChecksums[document.getElementById("parent").value];
                }
        </script>
        <rhn:toolbar base="h1" icon="header-channel"
                     deletionUrl="/rhn/channels/manage/Delete.do?cid=${param.cid}"
                     deletionAcl="user_role(channel_admin); formvar_exists(cid)"
                     deletionType="software.channel">
            <bean:message key="channel.edit.jsp.toolbar" arg0="${channel_name}"/>
        </rhn:toolbar>
        <rhn:dialogmenu mindepth="0" maxdepth="1"
                        definition="/WEB-INF/nav/manage_channel.xml"
                        renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />
        <html:form action="/channels/manage/Edit" styleClass="form-horizontal">
            <rhn:csrf />
            <h2><bean:message key="channel.edit.jsp.basicchanneldetails"/></h2>
            <div class="page-summary">
                <bean:message key="channel.edit.jsp.introparagraph"/>
            </div>
            <div class="form-group">
                <label for="name" class="col-lg-3 control-label">
                    <rhn:required-field key="channel.edit.jsp.name"/>:
                </label>
                <div class="col-lg-6">
                    <html:text property="name" maxlength="256"
                               styleClass="form-control"
                               size="48" styleId="name"/>
                </div>
            </div>
            <div class="form-group">
                <label for="label" class="col-lg-3 control-label">
                    <rhn:required-field key="channel.edit.jsp.label"/>:
                </label>
                <div class="col-lg-6">
                    <c:choose>
                        <c:when test='${empty param.cid}'>
                            <html:text property="label" maxlength="128"
                                       styleClass="form-control"
                                       size="32" styleId="label" />
                        </c:when>
                        <c:otherwise>
                            <div class="form-control">
                                <c:out value="${channel_label}"/>
                            </div>
                            <html:hidden property="label" value="${channel_label}" />
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
            <div class="form-group">
                <label for="parent" class="col-lg-3 control-label">
                    <bean:message key="channel.edit.jsp.parent"/>:
                </label>
                <div class="col-lg-6">
                    <c:choose>
                        <c:when test='${empty param.cid}'>
                            <html:select property="parent" styleId="parent"
                                         styleClass="form-control"
                                         onchange="setChildChannelArchChecksum()">
                                <html:options collection="parentChannels"
                                              property="value"
                                              labelProperty="label" />
                            </html:select>
                        </c:when>
                        <c:otherwise>
                            <div class="form-control">
                                <c:out value="${parent_name}"/>
                            </div>
                            <html:hidden property="parent" value="${parent_id}"/>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
            <div class="form-group">
                <label for="parentarch" class="col-lg-3 control-label">
                    <bean:message key="packagelist.jsp.packagearch"/>:
                </label>
                <div class="col-lg-6">
                    <c:choose>
                        <c:when test='${empty param.cid}'>
                            <html:select property="arch"
                                         styleClass="form-control"
                                         styleId="parentarch">
                                <html:options collection="channelArches"
                                              property="value"
                                              labelProperty="label" />
                            </html:select>
                        </c:when>
                        <c:otherwise>
                            <div class="form-control">
                                <c:out value="${channel_arch}"/>
                            </div>
                            <html:hidden property="arch" value="${channel_arch_label}" />
                            <html:hidden property="arch_name" value="${channel_arch}" />
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
            <div class="form-group">
                <label class="col-lg-3 control-label" for="checksum">
                    <bean:message key="channel.edit.jsp.checksum"/>:
                </label>
                <div class="col-lg-6">
                    <html:select property="checksum"
                                 styleId="checksum"
                                 styleClass="form-control">
                        <html:options collection="checksums"
                                      property="value"
                                      labelProperty="label" />
                    </html:select>
                    <span class="help-block">
                        <bean:message key="channel.edit.jsp.checksumtip"/>
                    </span>
                </div>
            </div>
            <div class="form-group">
                <label for="summary" class="col-lg-3 control-label">
                    <rhn:required-field key="channel.edit.jsp.summary"/>:
                </label>
                <div class="col-lg-6">
                    <html:text property="summary"
                               maxlength="500" size="40"
                               styleClass="form-control"
                               styleId="summary" />
                </div>
            </div>
            <div class="form-group">
                <label for="description" class="col-lg-3 control-label">
                    <bean:message key="channel.edit.jsp.description"/>:
                </label>
                <div class="col-lg-6">
                    <html:textarea property="description"
                                   styleClass="form-control"
                                   cols="40" rows="6" styleId="description"/>
                </div>
            </div>
            <c:if test='${not empty param.cid}'>
                <div class="form-group">
                    <label class="col-lg-3 control-label">
                        <bean:message key="channel.edit.jsp.lastsynced"/>:
                    </label>
                    <div class="col-lg-6">
                        <c:if test='${not empty log_url}'>
                            <a class="btn btn-info" href='${log_url}'><c:out value='${last_sync}'/></a>
                        </c:if>
                        <c:if test='${empty log_url}'>
                            <div class="form-control">
                                <c:out value='${last_sync}'/>
                            </div>
                        </c:if>
                    </div>
                </div>
            </c:if>
            <h2><bean:message key="channel.edit.jsp.contactsupportinfo"/></h2>
            <div class="form-group">
                <label class="col-lg-3 control-label" for="maintainer_name">
                    <bean:message key="channel.edit.jsp.maintainername"/>:
                </label>
                <div class="col-lg-6">
                    <html:text property="maintainer_name"
                               maxlength="128" size="40"
                               styleClass="form-control"
                               styleId="maintainer_name"/>
                </div>
            </div>
            <div class="form-group">
                <label class="col-lg-3 control-label">
                    <bean:message key="channel.edit.jsp.maintainercontactinfo"/>:
                </label>
                <div class="col-lg-6">
                    <div class="input-group">
                        <span class="input-group-addon"><bean:message key="channel.edit.jsp.emailaddress"/>:</span>
                        <html:text property="maintainer_email" size="20"
                                   styleClass="form-control"
                                   styleId="maintainer_email"/>
                    </div>
                </div>
            </div>
            <div class="form-group">
                <div class="col-lg-offset-3 col-lg-6">
                    <div class="input-group">
                        <span class="input-group-addon"><bean:message key="channel.edit.jsp.phonenumber"/>:</span>
                        <html:text property="maintainer_phone" size="20"
                                   styleClass="form-control"
                                   styleId="maintainer_phone"/>
                    </div>
                </div>
            </div>
            <div class="form-group">
                <label class="col-lg-3 control-label" for="support_policy">
                    <bean:message key="channel.edit.jsp.supportpolicy"/>:
                </label>
                <div class="col-lg-6">
                    <html:textarea property="support_policy"
                                   cols="40" rows="6"
                                   styleClass="form-control"
                                   styleId="support_policy"/>
                </div>
            </div>
            <h2><bean:message key="channel.edit.jsp.channelaccesscontrol"/></h2>
            <div class="form-group">
                <label class="col-lg-3 control-label">
                    <bean:message key="channel.edit.jsp.perusersub"/>:
                </label>
                <div class="col-lg-6">
                    <div class="radio">
                        <label>
                            <html:radio property="per_user_subscriptions" value="all" styleId="allusers" />
                            <bean:message key="channel.edit.jsp.allusers"/>
                        </label>
                    </div>
                </div>
            </div>
            <div class="form-group">
                <div class="col-lg-offset-3 col-lg-6">
                    <div class="radio">
                        <label>
                            <html:radio property="per_user_subscriptions" value="selected" styleId="selectedusers" />
                            <bean:message key="channel.edit.jsp.selectedusers"/>
                        </label>
                    </div>
                </div>
            </div>
            <div class="form-group">
                <label class="col-lg-3 control-label">
                    <bean:message key="channel.edit.jsp.orgsharing"/>:
                </label>
                <div class="col-lg-6">
                    <div class="radio">
                        <label>
                            <html:radio property="org_sharing" value="private" styleId="private"/>
                            <bean:message key="channel.edit.jsp.private"
                                          arg0="/rhn/multiorg/Organizations.do"/>
                        </label>
                    </div>
                </div>
            </div>
            <div class="form-group">
                <div class="col-lg-offset-3 col-lg-6">
                    <div class="radio">
                        <label>
                            <html:radio property="org_sharing" value="protected" styleId="protected" />
                            <bean:message key="channel.edit.jsp.protected"
                                          arg0="/rhn/multiorg/Organizations.do"/>
                        </label>
                    </div>
                </div>
            </div>
            <div class="form-group">
                <div class="col-lg-offset-3 col-lg-6">
                    <div class="radio">
                        <label>
                            <html:radio property="org_sharing" value="public" styleId="public"/>
                            <bean:message key="channel.edit.jsp.public"
                                          arg0="/rhn/multiorg/Organizations.do"/>
                        </label>
                    </div>
                </div>
            </div>
            <h2><bean:message key="channel.edit.jsp.security.gpg"/></h2>
            <div class="form-group">
                <label for="gpgkeyurl" class="col-lg-3 control-label">
                    <bean:message key="channel.edit.jsp.gpgkeyurl"/>:
                </label>
                <div class="col-lg-6">
                    <html:text property="gpg_key_url" maxlength="256" size="40"
                               styleClass="form-control"
                               styleId="gpgkeyurl"/>
                </div>
            </div>
            <div class="form-group">
                <label for="gpgkeyid" class="col-lg-3 control-label">
                    <bean:message key="channel.edit.jsp.gpgkeyid"/>:
                </label>
                <div class="col-lg-6">
                    <html:text property="gpg_key_id" maxlength="8" size="8"
                               styleClass="form-control"
                               styleId="gpgkeyid"/>
                    <span class="help-block">Example: DB42A60E</span>
                </div>
            </div>
            <div class="form-group">
                <label class="col-lg-3 control-label" for="gpgkeyfingerprint">
                    <bean:message key="channel.edit.jsp.gpgkeyfingerprint"/>:
                </label>
                <div class="col-lg-6">
                    <html:text property="gpg_key_fingerprint" maxlength="50" size="60"
                               styleClass="form-control"
                               styleId="gpgkeyfingerprint"/>
                    <span class="help-block">Example: CA20 8686 2BD6 9DFC 65F6  ECC4 2191 80CD DB42 A60E</span>
                </div>
            </div>
            <div class="form-group">
                <div class="col-lg-offset-3 col-lg-6">
                    <c:choose>
                        <c:when test='${empty param.cid}'>
                            <html:submit property="create_button" styleClass="btn btn-success">
                                <bean:message key="channel.edit.jsp.createchannel"/>
                            </html:submit>
                        </c:when>
                        <c:otherwise>
                            <html:submit property="edit_button" styleClass="btn btn-success">
                                <bean:message key="channel.edit.jsp.editchannel"/>
                            </html:submit>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
            <html:hidden property="submitted" value="true" />
            <c:if test='${not empty param.cid}'>
                <html:hidden property="cid" value="${param.cid}" />
            </c:if>
        </html:form>
    </body>
</html>

