<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" indent="yes" omit-xml-declaration="yes" />

<xsl:template match="@*|node()">
  <xsl:copy>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="/c2s/local/id">
  <xsl:copy>
    <xsl:attribute name="require-starttls">false</xsl:attribute>
    <xsl:attribute name="pemfile">/etc/pki/spacewalk/jabberd/server.pem</xsl:attribute>
    <xsl:attribute name="realm"></xsl:attribute>
    <xsl:attribute name="register-enable">true</xsl:attribute>
    <xsl:text>@hostname@</xsl:text>
  </xsl:copy>
</xsl:template>

<xsl:template match="/c2s/authreg/module">
  <xsl:copy>
  <xsl:text>db</xsl:text>
  </xsl:copy>
</xsl:template>

</xsl:stylesheet>
