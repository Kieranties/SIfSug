SIF Workshop Prerequisites
=========================

This document details the requirements for installing and running Sitecore
on premise.
For further guidance please review the [Sitecore Installation Guide][1].

Sitecore Requirements
--------------------

+ OS - Windows 8.1/10 or Windows Server 2012R2/2016.
+ IIS - 8.5/10.
+ .Net Framework - 4.6.2 or later.
+ [Microsoft Visual C++ 2015 Redistributable][2].

Database Requirements
--------------------

+ SQL Server - 2016 SP1.  This is the only version that fully supports XM _and_
xDB databases.

> When installing using the WDPs you must [enable contained databases.][8]

Search Indexing Requirements
---------------------------

+ Solr - 6.6.2.

Solr should be configured to run under [SSL][6].

Sitecore Install Framework Requirements
--------------------------------------

+ PowerShell 5.1 - For Windows 10/Server 2016 ensure you have updated to the Anniversary
Edition or above.  For Windows 8.1/Server 2012 install via the [Windows Management
Framework][3].
+ WebAdministration Module - This is installed alongside IIS.
+ Web Deploy 3.6 for Hosting Servers - You can install this via [Web Platform Installer][4].
This is required to support installs via WDPs.
+ URL Rewrite 2.1 - You install this via [Web Platform Installer][4].
This is required as the Sitecore WDPs contain web.configs using the module.
+ SQL Server Data-Tier Application Framework - Supports dacpac installation via the WDPs.
Download [here][5]. Please ensure you closely follow the detailed system requirements
and install both versions of `SQLSysCLRTypes` and both versions of the `DacFramework`
on x64 machines.
+ SqlCmd - Some configurations require use of SqlCmd. You will need to install
[Microsoft ODBC driver][9] and [Microsoft command line utilities][10]

### Installing Sitecore Install Framework

1. Open the PowerShell command line as an Administrator
2. Register the Sitecore PowerShell Gallery:
```
Register-PSRepository -Name SitecoreGallery -SourceLocation https://sitecore.myget.org/F/sc-powershell/api/v2
```
3. Install the _SitecoreInstallFramework_:
```
Install-Module -Name SitecoreInstallFramework -Repository SitecoreGallery
```

> For further information on using the Sitecore PowerShell Gallery, read the [FAQ][7]

[1]: https://dev.sitecore.net/Downloads/Sitecore_Experience_Platform/90/Sitecore_Experience_Platform_90_Update1.aspx
[2]: https://www.microsoft.com/en-us/download/details.aspx?id=53587
[3]: https://www.microsoft.com/en-us/download/details.aspx?id=54616
[4]: https://www.microsoft.com/web/downloads/platform.aspx
[5]: https://www.microsoft.com/en-us/download/details.aspx?id=53013
[6]: https://lucene.apache.org/solr/guide/6_6/enabling-ssl.html
[7]: https://doc.sitecore.net/sitecore_experience_platform/developing/developing_with_sitecore/sitecore_powershell_public_nuget_feed_faq
[8]: https://docs.microsoft.com/en-us/sql/relational-databases/databases/migrate-to-a-partially-contained-database#enable
[9]: https://download.microsoft.com/download/D/5/E/D5EEF288-A277-45C8-855B-8E2CB7E25B96/x64/msodbcsql.msi
[10]: https://download.microsoft.com/download/C/8/8/C88C2E51-8D23-4301-9F4B-64C8E2F163C5/x64/MsSqlCmdLnUtils.msi
