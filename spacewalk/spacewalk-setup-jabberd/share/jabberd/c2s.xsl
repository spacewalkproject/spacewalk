<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" indent="yes" omit-xml-declaration="yes" />

<xsl:template match="@*|node()">
  <xsl:copy>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="/c2s/router/ip">
    <xsl:copy>
      <xsl:text>@localhost@</xsl:text>
    </xsl:copy>
</xsl:template>

<xsl:template match="/c2s/local/ip">
    <xsl:copy>
      <xsl:text>@ipaddress@</xsl:text>
    </xsl:copy>
</xsl:template>

<xsl:template match="/c2s/local/id">
  <xsl:copy>
    <xsl:attribute name="require-starttls">false</xsl:attribute>
    <xsl:attribute name="pemfile">@server_pem@</xsl:attribute>
    <xsl:attribute name="realm"></xsl:attribute>
    <xsl:attribute name="register-enable">true</xsl:attribute>
    <xsl:text>@hostname@</xsl:text>
  </xsl:copy>
</xsl:template>

<xsl:template match="/c2s/authreg/module">
  <xsl:copy>
  <xsl:text>sqlite</xsl:text>
  </xsl:copy>
</xsl:template>

<xsl:template match="/c2s/io/check/interval[node() = 0]">
  <xsl:copy>
  <xsl:text>60</xsl:text>
  </xsl:copy>
</xsl:template>

<xsl:template match="/c2s/io/check/keepalive[node() = 0]">
  <xsl:copy>
  <xsl:text>60</xsl:text>
  </xsl:copy>
</xsl:template>

</xsl:stylesheet>
