<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" indent="yes" omit-xml-declaration="yes" />

<xsl:template match="@*|node()">
  <xsl:copy>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="/s2s/router/ip">
  <xsl:copy>
    <xsl:text>@localhost@</xsl:text>
  </xsl:copy>
</xsl:template>

<xsl:template match="/s2s/local/ip">
  <xsl:copy>
     <xsl:text>@ipaddress@</xsl:text>
  </xsl:copy>
</xsl:template>

<xsl:template match="/s2s/check/interval">
  <xsl:copy>3</xsl:copy>
</xsl:template>

</xsl:stylesheet>
