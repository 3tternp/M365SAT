# Date: 25-1-2023
# Version: 1.0
# Benchmark: CIS Microsoft 365 v3.1.0
# Product Family: Microsoft Exchange
# Purpose: Ensure that DKIM is enabled for all Exchange Online Domains
# Author: Leonardo van de Weteringh

# New Error Handler Will be Called here
Import-Module PoShLog

# Determine OutPath
$path = @($OutPath)

function Build-CISMEx219($findings)
{
	#Actual Inspector Object that will be returned. All object values are required to be filled in.
	$inspectorobject = New-Object PSObject -Property @{
		ID			     = "CISMEx219"
		FindingName	     = "CIS MEx 2.1.9 - Ensure that DKIM is enabled for all Exchange Online Domains"
		ProductFamily    = "Microsoft Exchange"
		RiskScore	     = "9"
		Description	     = "By enabling DKIM with Office 365, messages that are sent from Exchange Online will be cryptographically signed. This will allow the receiving email system to validate that the messages were generated by a server that the organization authorized and not being spoofed."
		Remediation	     = "DKIM rollout can be a very involved process, for which there is a complete reference in the 'Use DKIM to validate the outbound email sent from your custom domain' guide in the References section below. This finding refers specifically to enabling the DKIM signing configuration within O365 itself, which can be done using the Set-DkimSigningConfig PowerShell function or the Security and Compliance Center in the O365 administration portal."
		PowerShellScript = 'Set-DkimSigningConfig -Identity < domainName > -Enabled $True'
		DefaultValue	 = "False on all custom domains"
		ExpectedValue    = "None"
		ReturnedValue    = $findings
		Impact		     = "3"
		Likelihood	     = "3"
		RiskRating	     = "Medium"
		Priority		 = "High"
		References	     = @(@{ 'Name' = 'Use DKIM to validate outbound email sent from your custom domain'; 'URL' = "https://docs.microsoft.com/en-us/microsoft-365/security/office-365-security/use-dkim-to-validate-outbound-email?view=o365-worldwide" },
			@{ 'Name' = 'DKIM Configuration'; 'URL' = "https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/email-authentication-dkim-configure?view=o365-worldwide" },
			@{ 'Name' = 'DKIM FAQ'; 'URL' = "http://dkim.org/info/dkim-faq.html" },
			@{ 'Name' = 'Set up DKIM to sign mail from your Microsoft 365 domain'; 'URL' = "https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/email-authentication-dkim-configure?view=o365-worldwide" })
	}
	return $inspectorobject
}

function Inspect-CISMEx219
{
	Try
	{
		
		$domains_without_dkim = (Get-DkimSigningConfig | Where-Object { (!$_.Enabled) -and ($_.Domain -notlike "*.onmicrosoft.com") }).Domain
		
		If ($domains_without_dkim.Count -igt 0)
		{
			$domains_without_dkim | Format-Table -AutoSize | Out-File "$path\CISMEx219-DomainsWithoutDKIM.txt"
			$endobject = Build-CISMEx219($domains_without_dkim)
			Return $endobject
		}
		
		Return $null
		
	}
	catch
	{
		Write-WarningLog 'The Inspector: {inspector} was terminated!' -PropertyValues $_.InvocationInfo.ScriptName
		Write-ErrorLog 'An error occured on line {line} char {char} : {error}' -ErrorRecord $_ -PropertyValues $_.InvocationInfo.ScriptLineNumber, $_.InvocationInfo.OffsetInLine, $_.InvocationInfo.Line
	}
	
}

return Inspect-CISMEx219


