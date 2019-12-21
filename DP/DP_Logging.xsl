<xsl:stylesheet version="1.0" exclude-result-prefixes="dp dpconfig"
	extension-element-prefixes="dp dpconfig" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:dp="http://www.datapower.com/extensions" xmlns:dpconfig="http://www.datapower.com/param/config"
	xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:date="http://exslt.org/dates-and-times"
	xmlns:regexp="http://exslt.org/regular-expressions" xmlns:dyn="http://exslt.org/dynamic"
	xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
	<xsl:output method="xml" version="1.0" encoding="UTF-8"
		indent="yes" omit-xml-declaration="yes" cdata-section-elements="PayloadDataDisplay" />

	<!--Stylesheet parameter for Logging Queue -->

	<xsl:param name="dpconfig:CEFLogFlag" select="'Y'" />
	<dp:param name="dpconfig:CEFLogFlag">
		<display>Enable CEF Logging</display>
		<description>Send Event for CEF Logging</description>
	</dp:param>

	<xsl:template match="/">

		<xsl:variable select="document('local:///Disk/REM_TEST_SERVICE/Test_Service_Config.xml')/ESBMessageHeader " name="ESBMessageHeader" />
	
		<xsl:variable name="TransactionType" select="dp:variable('var://service/transaction-rule-type')" />
	
		<xsl:variable select="/*[local-name()='Envelope']/*[local-name()='Body']/*[1]" name="ServiceName" />
<dp:set-variable name="'var://context/ServiceName'" value="$ServiceName" /> 
		<xsl:variable name="MessageDetails">
			<xsl:value-of select="concat('$ESBMessageHeader/$ServiceName/',$TransactionType)" />
		</xsl:variable>
		
		
		<xsl:variable name="MessageDetails1" select="dyn:evaluate($MessageDetails)" />

<dp:set-variable name="'var://context/MessageDetails1'" value="$MessageDetails1" /> 
		<!-- <xsl:param name="dpconfig:Message" select="$MessageDetails1/Message" 
			/> <dp:param name="dpconfig:Message"> <display>Message</display> <description>Message 
			of Audit</description> </dp:param> <xsl:param name="dpconfig:Priority" select="$MessageDetails1/Priority" 
			/> <dp:param name="dpconfig:Priority"> <display>Priority</display> <description>Priority 
			of Audit</description> </dp:param> <xsl:param name="dpconfig:Sequence" select="$TransactionType" 
			/> <dp:param name="dpconfig:Sequence"> <display>Sequence</display> <description>Sequence 
			of Audit</description> </dp:param> <xsl:param name="dpconfig:Severity" select="$MessageDetails1/Severity" 
			/> <dp:param name="dpconfig:Severity"> <display>Severity</display> <description>Severity 
			of Audit</description> </dp:param> <xsl:param name="dpconfig:Status" select="$MessageDetails1/Status" 
			/> <dp:param name="dpconfig:Status"> <display>Status</display> <description>Status 
			of Audit</description> </dp:param> <xsl:param name="dpconfig:LoggingQueue" 
			select="$MessageDetails1/LoggingQueue" /> <dp:param name="dpconfig:LoggingQueue"> 
			<display>Logging Queue</display> <description>Logging Service Queue</description> 
			</dp:param> <xsl:param name="dpconfig:LoggingQMgrObj" select="$MessageDetails1/LoggingQMgrObj" 
			/> <dp:param name="dpconfig:LoggingQMgrObj"> <display>Logging Queue Manager 
			Object</display> <description>Logging Service Queue Manager Object</description> 
			</dp:param> -->









		<xsl:variable name="CEFLogFlag" select="$dpconfig:CEFLogFlag" />
		<xsl:if test="$CEFLogFlag ='Y'">
			<xsl:variable name="Payload" select="." />
			<xsl:variable name="serializedPayload">
				<dp:serialize select="$Payload" omit-xml-decl="no" />
			</xsl:variable>
			<xsl:variable name="log_q" select="$MessageDetails1/LoggingQueue" />
			<!-- <dp:set-variable name="'var://context/ESBMessageHeader'" value="$MessageDetails1" 
				/> -->
			<!-- <xsl:variable name="ESBMessageHeader" select="dp:variable('var://context/Request/ESBMessageHeader')" 
				/> -->
			<xsl:variable name="logqmgr_obj" select="$MessageDetails1/LoggingQMgrObj" />
			<xsl:variable name="log-url"
				select="concat('dpmq://',$logqmgr_obj,'/?RequestQueue=',$log_q)" />

			<!-- <xsl:variable name="ESBMessageHeader" select="dp:variable('var://context/Request/ESBMessageHeader')" 
				/> -->

			<!-- <xsl:variable name="TransactionType" select="dp:variable('var://service/transaction-rule-type')" 
				/> -->
			<xsl:variable name="UniqueID" select="dp:generate-uuid()" />
			<!--<xsl:variable name="UniqueID" select="substring(dp:generate-uuid(),1,4)"/> -->
			<xsl:variable name="Uniquereqid" select="substring($UniqueID,1,4)" />
			<xsl:variable name="Uniqueresid" select="substring($UniqueID,1,5)" />
			<xsl:variable name="ID">
				<xsl:choose>
					<xsl:when test="$TransactionType='request'">
						<xsl:value-of
							select="concat(dp:variable('var://service/transaction-id'),$Uniquereqid)" />
						<!--<xsl:value-of select="concat(dp:variable('var://service/transaction-id'), 
							$UniqueID)"/> -->
					</xsl:when>
				</xsl:choose>
				<xsl:choose>
					<xsl:when test="$TransactionType='response'">
						<xsl:value-of
							select="concat(dp:variable('var://service/transaction-id'),$Uniqueresid)" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="dp:variable('var://service/transaction-id')" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<dp:set-variable name="'var://context/notifyFault/ID'"
				value="$ID" />
			<xsl:variable name="mqmd">
				<MQMD>
					<MsgType>
						<xsl:value-of select="'8'" />
					</MsgType>
					<Format>
						<xsl:value-of select="'STRING'" />
					</Format>
					<Report>
						<xsl:value-of select="'128'" />
					</Report>
					<Priority>
						<xsl:value-of select="'2'" />
					</Priority>
				</MQMD>
			</xsl:variable>
			<xsl:variable name="mqmd-str">
				<dp:serialize select="$mqmd" omit-xml-decl="yes" />
			</xsl:variable>
			<xsl:variable name="headers">
				<header name="MQMD">
					<xsl:value-of select="$mqmd-str" />
				</header>
			</xsl:variable>
			<xsl:variable name="vCommonEvent">
				<CommonEvent>
					<Version>
						<xsl:value-of select="$MessageDetails1/Version" />
					</Version>
					<ID>
						<xsl:value-of select="dp:variable('var://context/notifyFault/ID')" />
					</ID>
					<Sequence>
						<xsl:value-of select="$TransactionType" />
					</Sequence>
					<xsl:variable name="CurrentMillis" select="dp:time-value()" />
					<xsl:variable name="CurrentSeconds" select="$CurrentMillis div 1000" />
					<xsl:variable name="CurrentDuration" select="date:duration($CurrentSeconds)" />
					<xsl:variable name="CurrentLongDateTime"
						select="date:add('1970-01-01T00:00:00Z',$CurrentDuration)" />
					<xsl:variable name="CurrentDateTimeEST"
						select="date:add($CurrentLongDateTime,'-PT5H')" />
					<xsl:variable name="CurrentDateTime23"
						select="substring($CurrentDateTimeEST,1,23)" />
					<xsl:variable name="TimeZone"
						select="regexp:replace($CurrentDateTime23,'T','',' ')" />
					<CreationTime>
						<!--<xsl:value-of select="date:format-date(date:date-time(),'yyyy-MM-dd 
							hh:mm:ss')"/> -->
						<xsl:value-of select="$TimeZone" />
					</CreationTime>
					<SourceSystem>
						<!--xsl:value-of select="$source-app"/ -->
						<!--xsl:value-of select="dp:variable('var://context/Request/Source')"/ -->
						<xsl:value-of select="$MessageDetails1/AppID" />
					</SourceSystem>
					<Service>
						<xsl:value-of select="$MessageDetails1/ServiceName" />
					</Service>
					<Operation>
						<xsl:value-of select="$MessageDetails1/OperationName" />
					</Operation>
					<Type>Audit</Type>
					<BusinessID>
						<xsl:value-of select="$MessageDetails1/TransactionID " />
					</BusinessID>
					<Status>
						<xsl:value-of select="$MessageDetails1/Status" />
					</Status>
					<Message>
						<xsl:value-of select="$MessageDetails1/Message" />
					</Message>
					<PayloadType>
						<xsl:value-of select="$MessageDetails1/TransactionType" />
					</PayloadType>
					<Severity>
						<xsl:value-of select="$MessageDetails1/Severity" />
					</Severity>
					<Priority>
						<xsl:value-of select="$MessageDetails1/Priority" />
					</Priority>
					<ComponentName>
						<xsl:value-of select="dp:variable('var://service/domain-name')" />
					</ComponentName>
					<ComponentType>Datapower</ComponentType>
					<SubComponentName>
						<xsl:value-of select="dp:variable('var://service/processor-name')" />
					</SubComponentName>
					<SubComponentType>
						<xsl:value-of select="dp:variable('var://service/processor-type')" />
					</SubComponentType>
					<PayloadDataDisplay>
						<xsl:text disable-output-escaping="yes">&lt;![CDATA[</xsl:text>
						<xsl:copy-of select="$Payload" />
						<xsl:text disable-output-escaping="yes">]]&gt;</xsl:text>
					</PayloadDataDisplay>
					<TechnicalProperties>
						<Property>
							<Name>HostName</Name>
							<Value>Coach.com</Value>
							<Type>String</Type>
						</Property>
					</TechnicalProperties>
				</CommonEvent>
			</xsl:variable>
			<xsl:variable name="LoggingFlag"
				select="dp:variable('var://context/Error/LoggingFlag')" />
			<xsl:if test="not(contains($LoggingFlag, 'false'))">
				<xsl:variable name="mq-resp">
					<dp:url-open target="{$log-url}" http-headers="$headers"
						response="responsecode-ignore">
						<xsl:copy-of select="$vCommonEvent" />
					</dp:url-open>
				</xsl:variable>
			</xsl:if>
		</xsl:if>
	</xsl:template>
	<xsl:template match="text()">
		<xsl:value-of select="." />
	</xsl:template>
	<xsl:template match="*" mode="remove-namespace">
		<xsl:element name="{local-name()}">
			<xsl:apply-templates select="node()" mode="remove-namespace" />
		</xsl:element>
	</xsl:template>
</xsl:stylesheet>